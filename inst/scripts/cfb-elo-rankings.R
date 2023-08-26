# Top 25 Elo -------------------------------------------------------------------
library(tidyverse)
library(ggrepel)
devtools::load_all(".")

teams <- cfbfastR::cfbd_team_info()

ds_ <- sportsBs::cfb_rankings_drew_elo(year = 2022,
                                       years_lookback = 3)

ds <- ds_ |>
  arrange(team, desc(season), desc(week)) |>
  mutate(
    win = if_else(team == home_team, home_points > away_points, away_points > home_points),
    w_l = if_else(win, "W", "L"),
    elo_delta = elo_rating_post - elo_rating_pre
  )

# ds |>
#   filter(
#     team == "Oklahoma",
#     # season == 2022
#     ) |>
#   View()

ds |>
  filter(team %in% c("Air Force")) |>
  # filter(team %in% c("Oklahoma")) |>
  ggplot(aes(x = week, y = elo_rating_post, color = team)) +
  geom_line() +
  geom_hline(yintercept = 1500,
             linetype = "dashed") +
  facet_wrap(~season)
# scale_y_continuous(limits = c(500, NA))

top_25 <- ds |>
  # dplyr::filter(season == 2022 & week == 17) |>
  dplyr::group_by(team) |>
  dplyr::filter(start_date == max(start_date)) |>
  dplyr::select(team, season, week, elo_rating_post) |>
  dplyr::ungroup() |>
  dplyr::slice_max(order_by = elo_rating_post, n = 25)

# top_25_2 <- ds |>
#   sportsBs::cfb_rankings_drew_elo_top(week = 18)

ds |>
  group_by(team) |>
  mutate(
    label = if_else(start_date >= max(start_date), team, as.character(NA))
  ) |>
  ungroup() |>
  filter(team %in% top_25$team, season == 2022) |>
  ggplot(aes(x = week, y = elo_rating_post, color = team)) +
  geom_line(size = 1.5) +
  # geom_hline(yintercept = 1500, linetype = "dashed") +
  scale_y_continuous(limits = c(1600, NA)) +
  geom_label_repel(
    aes(label = label), # Specify the labels
    nudge_x = 1.5,     # Adjust the label position
    segment.size = 0.2, # Adjust the line segment size
    direction = "y"
  ) +
  scale_color_manual(values = teams$color,
                     breaks = teams$school) +
  ggthemes::theme_fivethirtyeight() +
  guides(color = "none")
