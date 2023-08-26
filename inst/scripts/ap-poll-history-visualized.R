library(cfbfastR)
library(tidyverse)

# Data =========================================================================

team_data <- cfbfastR::cfbd_team_info() |>
  mutate(
    color = case_when(
      school == "LSU" ~ "#461D7C",
      TRUE ~ color
    )
  )

years <- seq(from = 1989, to = 2022)
weeks <- seq(from = 1, to = 16)

# Have to get the data one year at a time
ap_data <- tibble()
for(yr in years){
  for(wk in weeks){
    temp <- cfbfastR::cfbd_rankings(year = yr,
                                       week = wk,
                                       season_type = "regular")

    if(nrow(temp) > 0 & exists("temp")){
      temp <- temp |>
        filter(poll == "AP Top 25")

      ap_data <- rbind(ap_data, temp)
      rm(temp)

      cli::cli_progress_message(paste0("Season ", yr, ", week ", wk, " done!"))
    } else {
      cli::cli_alert_danger(paste0("Season ", yr, ", week ", wk, " not found!"))
      # rm(temp)
    }

  }
}

# AP Top 25 starts in 1989
# Points start in 2014
# First place rankings start in 2001

# Cleaning data ================================================================

all_schools <- tibble(school = unique(ap_data$school))
all_seasons_weeks <- ap_data |>
  group_by(season, week) |>
  reframe()

all_weeks_absolute <- cross_join(all_seasons_weeks, all_schools)

ap_data_clean <- all_weeks_absolute |>
  left_join(ap_data) |>
  group_by(season, week) |>
  mutate(
    week_absolute = cur_group_id()
  ) |>
    mutate(
    across(.cols = c("rank", "points", "first_place_votes"),
           .fns = ~if_else(is.na(.x), as.integer(0), .x))
  )

# Graphs =======================================================================

# Rankings since 1989 ==========================================================
# Single Team ------------------------------------------------------------------
given_team <- "Illinois"

graph_data <- ap_data_clean |>
  mutate(
    rank_inv = if_else(rank != 0, 26 - rank, 0)
  ) |>
  filter(school == given_team)

graph_labels <- graph_data |>
  group_by(season) |>
  summarize(
    min_week = min(week_absolute),
    max_week = max(week_absolute)
  ) |>
  filter(season %% 2 == 0) |>
  mutate(season = paste0("'", substr(season, 3, 4)))

top_12_all_time <- graph_data |>
  group_by(school) |>
  summarize(total_ranks = sum(rank_inv, na.rm = T)) |>
  slice_max(total_ranks, n = 12)

graph_data |>
  filter(season != 2020, # COVID year
         school %in% top_12_all_time$school
  ) |>
  left_join(top_12_all_time, by = "school") |>
  mutate(
    school_w_total = paste0(school, " (",
                            format(total_ranks, big.mark = ",") |> trimws(),
                            " total points)"
    )
  ) |>
  ggplot(aes(x = week_absolute,
             y = rank_inv,
             color = school)) +
  geom_line() +
  geom_hline(yintercept = 1, linetype = "dashed", alpha = 0.8) +
  annotate("rect",
           xmin = 473, xmax = 488,
           ymin = 0, ymax = 25,
           alpha = 0.5) +
  # geom_smooth(se = F) +
  scale_x_continuous(
    labels = graph_labels$season,
    breaks = graph_labels$min_week
  ) +
  scale_y_continuous(breaks = c(1, 6, 11, 16, 21, 26),
                     labels = ~26 - .x) +
  scale_color_manual(breaks = team_data$school,
                     values = team_data$color) +
  facet_wrap(~factor(reorder(school_w_total, -total_ranks), ordered = T),
             ncol = 3,
             scales = "free_x") +
  guides(color = "none") +
  ggthemes::theme_fivethirtyeight() +
  labs(
    title = paste0("AP Top 25 History: Rankings Over Time"),
    subtitle = "AP Poll Rankings, 1989 - present",
    x = "Poll Week",
    y = "Ranking Position",
    caption = "Weeks below the dotted line indicate a team was unranked.
    Due to comparability issues (missing teams, weeks, etc.),
    data from the 2020 season have been removed."
  )

# Multiple Teams ---------------------------------------------------------------
graph_data <- ap_data_clean |>
  mutate(
    rank_inv = if_else(rank != 0, 26 - rank, 0)
  )

graph_labels <- graph_data |>
  group_by(season) |>
  summarize(
    min_week = min(week_absolute),
    max_week = max(week_absolute)
  ) |>
  filter(season %% 2 == 0) |>
  mutate(season = paste0("'", substr(season, 3, 4)))

top_12_all_time <- graph_data |>
  group_by(school) |>
  summarize(total_ranks = sum(rank_inv, na.rm = T)) |>
  filter(school %in% c("Utah", "Utah State", "BYU"))
  # slice_max(total_ranks, n = 12)

graph_data |>
  filter(season != 2020, # COVID year
         school %in% top_12_all_time$school
  ) |>
  left_join(top_12_all_time, by = "school") |>
  mutate(
    school_w_total = paste0(school, " (",
                            format(total_ranks, big.mark = ",") |> trimws(),
                            " total points)"
    )
  ) |>
  ggplot(aes(x = week_absolute,
             y = rank_inv,
             color = school)) +
  geom_line() +
  geom_hline(yintercept = 1, linetype = "dashed", alpha = 0.8) +
  annotate("rect",
           xmin = 473, xmax = 488,
           ymin = 0, ymax = 25,
           alpha = 0.5) +
  # geom_smooth(se = F) +
  scale_x_continuous(
    labels = graph_labels$season,
    breaks = graph_labels$min_week
  ) +
  scale_y_continuous(breaks = c(1, 6, 11, 16, 21, 26),
                     labels = ~26 - .x) +
  scale_color_manual(breaks = team_data$school,
                     values = team_data$color) +
  facet_wrap(~factor(reorder(school_w_total, -total_ranks), ordered = T),
             ncol = 1,
             scales = "free_x") +
  guides(color = "none") +
  ggthemes::theme_fivethirtyeight() +
  labs(
    title = paste0("AP Top 25 History: Rankings Over Time"),
    subtitle = "AP Poll Rankings, 1989 - present",
    x = "Poll Week",
    y = "Ranking Position",
    caption = "Weeks below the dotted line indicate a team was unranked.
    Due to comparability issues (missing teams, weeks, etc.),
    data from the 2020 season have been removed."
  )

# Single team ------------------------------------------------------------------
given_team <- "Oklahoma"

graph_data <- ap_data_clean |>
  filter(
    season >= 2014,
    school == given_team
  )

graph_labels <- graph_data |>
  group_by(season) |>
  summarize(
    min_week = min(week_absolute),
    max_week = max(week_absolute)
  )

p <- graph_data |>
  filter(season != 2020) |> # COVID year
  ggplot(aes(x = week_absolute,
             y = points,
             color = school,
             text = paste0(season, ", wk ", week),
             group = 1
             )) +
  geom_line(linewidth = 1.5) +
  # 2020 removal annotation
  annotate("rect",
           xmin = 473, xmax = 488,
           ymin = 0, ymax = max(graph_data$points),
           alpha = 0.5) +
  # annotate("text",
  #          x = 473, y = max(graph_data$points) + 30,
  #          hjust = 0.5,
  #          label = "*2020 data removed due to comparability issues") +
  #
  guides(color = "none") +
  scale_x_continuous(
    labels = graph_labels$season,
    breaks = graph_labels$min_week
  ) +
  scale_y_continuous(limits = c(0, NA)) +
  scale_color_manual(breaks = team_data$school,
                     values = team_data$color) +
  ggthemes::theme_fivethirtyeight() +
  labs(
    title = paste0("AP Top 25 History: ", given_team),
    subtitle = "Total points per poll, 2014 - present",
    x = "Poll Week",
    y = "Total Points Received",
    caption = "Due to comparability issues (missing teams, weeks, etc.),
    data from the 2020 season have been removed."
  )

p
# plotly::ggplotly(p, tooltip = "text")

# Multiple teams ---------------------------------------------------------------
top_12_all_time <- ap_data_clean |>
  group_by(school) |>
  summarize(total_points = sum(points, na.rm = T)) |>
  filter(school %in% c("Utah", "Utah State", "BYU"))
  # slice_max(total_points, n = 12)

graph_data <- ap_data_clean |>
  filter(
    season >= 2014,
    school %in% top_12_all_time$school
  )

graph_labels <- graph_data |>
  group_by(season = paste0("'", substr(season, 3, 4))) |>
  summarize(
    min_week = min(week_absolute),
    max_week = max(week_absolute)
  )

p <- graph_data |>
  filter(season != 2020) |> # COVID year
  left_join(top_12_all_time, by = "school") |>
  mutate(
    school_w_total = paste0(school, " (",
                            format(total_points, big.mark = ",") |> trimws(),
                            ")"
                            )
  ) |>
  arrange(desc(total_points)) |>
  ggplot(aes(x = week_absolute,
             y = points,
             color = school,
             text = paste0(season, ", wk ", week),
             group = 1
  )) +
  geom_line(linewidth = 1.5) +
  # 2020 removal annotation
  annotate("rect",
           xmin = 473, xmax = 488,
           ymin = 0, ymax = max(graph_data$points),
           alpha = 0.5) +
  # Styling
  guides(color = "none") +
  scale_x_continuous(
    labels = graph_labels$season,
    breaks = graph_labels$min_week
  ) +
  scale_y_continuous(limits = c(0, NA),
                     labels = scales::comma) +
  scale_color_manual(breaks = team_data$school,
                     values = team_data$color) +
  ggthemes::theme_fivethirtyeight() +
  facet_wrap(
    ~factor(reorder(school_w_total, -total_points), ordered = T),
    ncol = 1
  ) +
  labs(
    title = paste0("AP Top 25 History: Utah Schools"),
    subtitle = "Total points per poll, 2014 - present",
    x = "Poll Week",
    y = "Total Points Received",
    caption = "Due to comparability issues (missing teams, weeks, etc.),
    data from the 2020 season have been removed."
  )

p
# plotly::ggplotly(p, tooltip = "text")



