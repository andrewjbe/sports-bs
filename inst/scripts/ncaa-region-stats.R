library(hoopR)
library(tidyverse)

team_info <- hoopR::espn_mbb_teams() |>
  mutate(
    team = if_else(team == "UConn", "Connecticut", team),
    team = if_else(team == "Miami", "Miami FL", team),
    team = if_else(team == "Texas A&M-Corpus Christi", "Texas A&M Corpus Chris", team),
    team = str_replace_all(team, "State", "St."),
    team = if_else(team == "NC St.", "N.C. State", team)
  )

all_teams <- hoopR::kp_teamstats(min_year = 2023) |>
  left_join(team_info,
  by = c("team"))


tourney_teams <- all_teams |>
  filter(!is.na(ncaa_seed)) |>
  mutate(
    adj_em = adj_o - adj_d,
    region = case_when(
      team %in% c("Alabama", "Texas A&M Corpus Chris", "Southeast Missouri St.",
                  "Maryland", "West Virginia", "San Diego St.", "Charleston",
                  "Virginia", "Furman", "Creighton", "N.C. State", "Baylor",
                  "UC Santa Barbara", "Missouri", "Utah St.", "Arizona",
                  "Princeton") ~ "South Region",
      team %in% c("Purdue", "Texas Southern", "Fairleigh Dickinson",
                  "Memphis", "Florida Atlantic", "Duke", "Oral Roberts",
                  "Tennessee", "Louisiana", "Kentucky", "Providence",
                  "Kansas St.", "Montana St.", "Michigan St.", "USC",
                  "Marquette", "Vermont") ~ "East Region",
      team %in% c("Houston", "Northern Kentucky", "Iowa", "Auburn",
                  "Miami FL", "Drake", "Indiana", "Kent St.", "Iowa St.",
                  "Mississippi St.", "Pittsburgh", "Xavier", "Kennesaw St.",
                  "Texas A&M", "Penn St.", "Texas", "Colgate"
                  ) ~ "Midwest Region",
      TRUE ~ "West Region"
    )
  ) |>
  select(team, conf, ncaa_seed, year, mascot, logo)

# Region summaries:
tourney_teams |>
  # filter(ncaa_seed <= 14) |>
  group_by(region) |>
  summarize(
    avg_adj_em = round(mean(adj_em), 2),
    avg_adj_o = round(mean(adj_o), 2),
    avg_adj_d = round(mean(adj_d), 2),
    #
    best_adj_em = paste0(round(max(adj_em), 2), " (", team[which.max(adj_em)], ")"),
    worst_adj_em = paste0(round(min(adj_em), 2), " (", team[which.min(adj_em)], ")"),
    #
    best_adj_o = paste0(round(max(adj_o), 2), " (", team[which.max(adj_o)], ")"),
    worst_adj_o = paste0(round(min(adj_o), 2), " (", team[which.min(adj_o)], ")"),
    #
    best_adj_d = paste0(round(min(adj_d), 2), " (", team[which.min(adj_d)], ")"),
    worst_adj_d = paste0(round(max(adj_d), 2), " (", team[which.max(adj_d)], ")")
  ) |>
  ungroup() |>
  mutate(
    across(.cols = everything(),
           .fns = ~as.character(.x))
  ) |>
  pivot_longer(cols = !region) |>
  arrange(region)

# Graphs:
library(ggimage)
library(ggthemes)

p <- tourney_teams |>
  ggplot(aes(x = adj_o,
             y = -adj_d)) +
  geom_image(aes(image = logo),
             size = 0.08) +
  geom_vline(aes(xintercept = mean(adj_o)),
             linetype = "dashed") +
  geom_hline(aes(yintercept = mean(-adj_d)),
             linetype = "dashed") +
  facet_wrap(~region,
             scales = "fixed") +
  labs(title = "NCAA Tournament Regions",
       subtitle = "by Kenpom Scores",
       x = "Adj. O",
       y = "Adj. D",
       caption = paste0("Higher up on the Y-axis means good defense;\n",
       "Farther to the right on the X-axis means good offense.\n",
       "Dashed lines are tournament-wide averages.")) +
  theme_clean()
p

# ggsave(filename = "./kenpom-region-scores.png",
#        plot = p,
#        device = "png", width = 3000, height = 3000, units = "px")


# =-===========================================================================

ds <- read_csv("~/Downloads/NCAATournamentBracket.csv") |>
  janitor::clean_names()



