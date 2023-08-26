library(cfbfastR)
library(tidyverse)
library(ggthemes)

# Parameters -------------------------------------------------------------------

min_year = 2021
max_year = 2022

# Data -------------------------------------------------------------------------

teams <- cfbd_team_info()
games <- cfbfastR::load_cfb_schedules(seasons = seq(from = min_year, to = max_year))


pbp_2021_2023 <- cfbfastR::load_cfb_pbp(seasons = seq(from = min_year, to = max_year))

# Data quality testing ---------------------------------------------------------

pbp_2021_2023 |>
  filter(
    home == "Oklahoma" | away == "Oklahoma"
  ) |>
  count(game_title = as.factor(paste(away, "@", home, "-", year))) |>
  ggplot(aes(x = reorder(game_title, -n),
             y = n)) +
  geom_col() +
  coord_flip()

# Data cleaning ----------------------------------------------------------------

pbp_enhanced <- pbp_2021_2023 |>
  right_join(games,
             by = "game_id"
             ) |>
  filter(
    # home == "Oklahoma" | away == "Oklahoma"
    !is.na(start_date)
  ) |>
  select(year, week = week.x, start_date, home, away, conference_game,
         game_play_number, half_play_number, drive_play_number,
         pos_team, def_pos_team, pos_team_score, def_pos_team_score,
         half, period, clock.minutes, clock.seconds,
         play_type, play_text, penalty_detail, yds_penalty, penalty_1st_conv,
         down, distance, yards_to_goal,
         yards_gained) |>
  mutate(
    start_date = ymd_hms(start_date)
  )

# Holding calls analysis =======================================================

# Holding calls per game for given team ----------------------------------------

current_team <- "Iowa State"

penalties <- pbp_enhanced |>
  filter(grepl("(?i)penalty", play_type)) |>
  mutate(
    holding = if_else(str_detect(penalty_detail, "(?i)hold"), TRUE, FALSE),
    holding_imputed = case_when(
      holding & yards_gained > 0 ~ "Defensive Holding",
      holding & yards_gained < 0 ~ "Offensive Holding"
      # TODO: Need to cover case where yards_gained == 0 bc the play was offset or something
    ),
    team_penalized = if_else(holding_imputed == "Offensive Holding", pos_team, def_pos_team),
    week_abs = as.numeric(paste0(year, ".", sprintf("%02d", week)))
  )

penalties |>
  mutate(
    against_current_team = if_else(pos_team == current_team & holding_imputed == "Offensive Holding" |
                                     def_pos_team == current_team & holding_imputed == "Defensive Holding",
                                   TRUE, FALSE)
  ) |>
  # Holding calls against chosen team only
  filter(
    home == current_team | away == current_team
  ) |>
  group_by(game = paste0(away, " @ ", home, " (", year, ")"),
           start_date) |>
  summarize(
    n_penalties = n(),
    n_holding_calls = sum(holding),
    n_holding_against_current_team = sum(against_current_team, na.rm = T)
  ) |>
  arrange(desc(start_date))


# graph
penalties |>
  left_join(teams, by = c("team_penalized" = "school")) |>
  mutate(
    against_current_team = if_else(pos_team == current_team & holding_imputed == "Offensive Holding" |
                                     def_pos_team == current_team & holding_imputed == "Defensive Holding",
                                   TRUE, FALSE)
  ) |>
  filter(
    home == current_team | away == current_team,
    conference_game
  ) |>
  group_by(game_title = as.factor(paste(away, "@", home, "-", year)),
           against_current_team) |>
  reframe(
    n_penalties = n(),
    n_holding_calls = sum(holding),
    n_holding_against_current_team = sum(against_current_team, na.rm = T),
    day = floor_date(start_date, "days"),
    team_penalized = unique(team_penalized),
    against_current_team = case_when(
      against_current_team == TRUE ~ paste0("Holding Against ", current_team),
      against_current_team == FALSE ~ paste0("Holding Against Opponent"),
      is.na(against_current_team) ~ "All Other Penalties"
    )
  ) |>
  distinct(game_title, team_penalized, against_current_team,
           .keep_all = TRUE) |>
  ggplot(aes(x = reorder(game_title, day),
             y = n_penalties,
             fill = team_penalized)) +
  geom_col() +
  coord_flip() +
  facet_wrap(~against_current_team,
             # scales = "free_x"
             ) +
  scale_fill_manual(breaks = teams$school,
                    values = teams$color) +
  guides(fill = "none") +
  labs(
    title = paste0("holding penalties called against / in favor of ", tolower(current_team)),
    subtitle = paste0(min_year, " - ", max_year, " seasons"),
    caption = "data from https://collegefootballdata.com/
    retrieved using https://cfbfastr.sportsdataverse.org/"
  ) +
  theme_fivethirtyeight()


# table

penalties |>
  filter(
    conference_game,
    holding
  ) |>
  group_by(team_penalized) |>
  summarize(
    n_holding_calls = n()
  ) |>
  arrange(desc(n_holding_calls)) |>
  mutate(rank = row_number()) |> View()


