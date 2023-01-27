library(cfbfastR)
library(tidyverse)
library(janitor)
library(ggthemes)
library(lubridate)

yr <- 2022
wk <- 2
# date <- "Nov-26-2022"
date <- "bowl-games"

# NEW
file_list <- list.files(path = paste0("./data/", date, "/"), pattern = "*.csv")
comments_ <- lapply(paste0("./data/", date, "/", file_list), read_csv)
names(comments_) <- gsub(file_list, pattern = "\\..*", replacement = "")
comments_ <- bind_rows(comments_, .id = "id") |>
  select(!`...1`) |>
  rename(title = id, body = `0`, flair = `1`, time_unix = `2`, score = `3`)

# Analysis

comments_clean <- comments_ |>
  mutate(
    time = as_datetime(time_unix),
    ref_complaint = if_else(grepl(
      " REF | REFS|REFS |REFFING|REFEREE|OFFICIAL|OFFICIATING|OFFICIATED|REFFING|REFBALL|RIGGED|RIGGING|THE FIX|FIXED|FUCKING FLAG|DAMN FLAG|TERRIBLE FLAG|BAD FLAG|BULLSHIT FLAG|AWFUL FLAG|BS FLAG|FUCKING CALL|DAMN CALL|TERRIBLE CALL|BAD CALL|BULLSHIT CALL|AWFUL CALL|BS CALL|FUCKING SPOT|DAMN SPOT|TERRIBLE SPOT|BAD SPOT|BULLSHIT SPOT|AWFUL SPOT|BS SPOT|HOSED|ROBBED",
      toupper(body)), TRUE, FALSE),
    salt_detected = if_else(grepl("SALT|🧂|TEARS", toupper(body)), TRUE, FALSE),
    choke_detected = if_else(grepl("CHOKE|CHOKING", toupper(body)), TRUE, FALSE),
    flair = trimws(str_remove(flair, "\\:[^()]*\\:"))
  ) |>
  separate(col = flair, sep = " • ", into = c("flair_one", "flair_two")) |>
  separate(col = title, sep = " @ ", into = c("away", "home"), remove = FALSE) |>
  mutate(
    away = str_remove(away, "\\[Game Thread]"),
    away = trimws(str_replace_all(away, pattern = "[^a-zA-Z ]", "")),
    home = str_remove(home, " \\s*\\([^\\)]+\\)"),
    home = trimws(str_replace_all(home, pattern = "[^a-zA-Z ]", "")),
    # home_fan = if_else(grepl(home, flair_one), TRUE, FALSE),
    # away_fan = if_else(grepl(away, flair_one), TRUE, FALSE),
  ) |>
  # FLAIR FIXES +===
  mutate(
    home = case_when(
      home == "Texas AM" ~ "Texas A&M",
      TRUE ~ home
    )
  ) |>
  group_by(title) |>
  mutate(
    faction = case_when(
      flair_one == home ~ "Home Team Fan",
      flair_one == away ~ "Away Team Fan",
      # grepl(home, flair_one) & !grepl(away, flair_two) ~ "Home Team Fan",
      # grepl(away, flair_one) & !grepl(home, flair_two) ~ "Away Team Fan",
      # !grepl(home, flair_one) & !grepl(away, flair_one) & !grepl(home, flair_two) & !grepl(away, flair_two) ~ "Neutral / Both / Neither",
      TRUE ~ "Neutral / Both / Neither"
    )
  ) |>
  ungroup()

# Schedule data (start time)
sched <- cfbfastR::espn_cfb_schedule(year = yr,
                                     week = wk
                                     ) |>
  select(game_date, home_team_location, away_team_location, start_date) |>
  mutate(
    game_date = ymd_hm(game_date),
    home_team_location = case_when(
      home_team_location == "South Florida" ~ "USF",
      TRUE ~ home_team_location
    )
  )  |>
  filter(#type == "postseason",
         #game_date > ymd("12-20-2022"), # filter out non-bowls
         home_team_location %in% comments_clean$home | away_team_location %in% comments_clean$home)

# Final Dataset
comments <- comments_clean |>
  left_join(sched, by = c("home" = "home_team_location")) |>
  mutate(start_date = parse_datetime(start_date),
         end_date = start_date + hours(4) + minutes(30)) 

# Graph -- Cumulative

graph_data <- comments |>
  mutate(title = str_remove(title, "\\[Game Thread]"),
         title = str_remove(title, "\\s*\\([^\\)]+\\)")) |>
  group_by(title, faction) |>
  summarize(
    n_complaints = sum(ref_complaint, na.rm = T),
    n_comments = n(),
    n_salty = sum(salt_detected, na.rm = T)
  ) |>
  group_by(title) |>
  mutate(
    total_comments = sum(n_comments, na.rm = T),
    total_complaints = sum(n_complaints, na.rm = T),
    total_salt = sum(n_salty, na.rm = T),
    p_complaints = n_complaints / total_comments,
    sum_p_complaints = total_complaints / total_comments,
    salt_level = total_salt / total_comments
  ) 
# ungroup() |>
# slice_max(order_by = sum_p_complaints, n = 30)

label_data <- graph_data |>
  group_by(title) |>
  summarize(
    sum_comments = unique(total_comments),
    sum_complaints = unique(total_complaints),
    sum_p_complaints = total_complaints / total_comments
  ) |>
  distinct()

ggplot(data = graph_data, 
       aes(x = reorder(title, sum_p_complaints),
           y = p_complaints)) +
  geom_col(aes(fill = as.factor(faction))) +
  geom_text(data = label_data,
            aes(x = reorder(title, sum_p_complaints),
                y = sum_p_complaints,
                label = paste0(format(sum_complaints, big.mark = ","), " complaints / ", format(sum_comments, big.mark = ","), " comments = ", round(100 * sum_p_complaints, 1), "%")), 
            position = "stack", hjust = -0.05) +
  coord_flip() +
  labs(
    title = "r/CFB Game Threads\nby Proportion of Comments Complaining About the Refs",
    # subtitle = paste0("Selected Games, Week ", wk, " 2022"),
    y = "% of Comments Featuring a Remark About the Refs",
    x = "Game Thread",
    fill = "Complainer Flair",
    caption = "Data collected from r/CFB using PRAW (https://praw.readthedocs.io/en/stable/)"
  ) +
  theme_fivethirtyeight() +
  scale_fill_fivethirtyeight() +
  scale_y_continuous(labels = scales::percent, limits = c(0, 0.16)) +
  theme(
    axis.text.y = element_text(size = 13),
    axis.title = element_text(),
    plot.title.position = "plot",
    plot.title = element_text(hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5)
  )

# Thread timelines  -----------

timelines <- comments |> 
  # filter(ome == "Ohio State",
  # ref_complaint == TRUE
  # ) |> 
  count(
    min = floor_date(time, "10 minutes"),
    title,
    faction,
   # start_date, end_date
    ) |>
  filter(n > 5) |>
  ggplot(aes(x = min, 
             y = n,
             fill = faction
  )) +
  geom_col() +
  facet_wrap(~title,
             scales = "free",
             ncol = 2 
  ) +
  scale_y_continuous(labels = scales::comma) +
  labs(title = paste0("r/CFB Week ", wk, " Game Thread Timelines"),
       subtitle = "Total comments posted per 10 minute interval, by commenter's primary flair
    
    Blue bars are comments left by supporters of the away team,
    Red bars are comments left by supporters of the home team, and
    Green bars are all other comments.",
       x = "Comment time (10 minute chunks)",
       y = "Total comments",
       fill = "Commenter Faction"
  ) +
  theme_fivethirtyeight() +
  scale_fill_fivethirtyeight() +
  theme(legend.direction = "vertical",
        axis.text.y = element_text(size = 13),
        axis.title = element_text(),
        plot.title.position = "plot",
        plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5)
  )
timelines

# ggsave(timelines,
#        filename = paste0("./thread-timelines/", yr, "-week-", wk, "-thread-timelines.png"),
#          device = "png",
#          height = 24,
#          width = 12)

# # SODIUM LEVELS
# graph_data |>
#   distinct(title, total_comments, total_salt, salt_level) |>
#   ggplot(aes(
#     x = reorder(title, salt_level),
#     y = salt_level,
#     fill = salt_level
#   )) +
#   geom_col() +
#   labs(
#     title = paste0("🧂🧂🧂 r/CFB Week ", wk, " Game Thread 🧂🧂🧂\n Sodium Index™"),
#     subtitle = "% of comments referencing 'salt' or 'saltiness'",
#     x = "Game Thread",
#     y = "% of comments indicating salt",
#     caption = "Searched for all variations of 'salt,' 'salty,' 'tears,' etc., including the emoji."
#   ) +
#   scale_y_continuous(labels = scales::percent) +
#   # scale_fill_viridis_c(option = "H") +
#   coord_flip() +
#   guides(
#     fill = "none"
#   ) +
#   theme_fivethirtyeight() +
#   theme(
#     axis.text.y = element_text(size = 13),
#     axis.title = element_text(),
#     plot.title.position = "plot",
#     plot.title = element_text(hjust = 0.5),
#     plot.subtitle = element_text(hjust = 0.5)
#   )

# FANBASE WIDE COMPLAINTS
comments |> 
  group_by(flair_one) |>
  summarize(
    n = n(),
    mean_score = mean(score, na.rm = T),
    med_score = median(score, na.rm = T),
    n_complaints = sum(ref_complaint, na.rm = T),
    n_salty = sum(salt_detected, na.rm = T),
    complaints_per_1000 = round(1000 * n_complaints / n, 2), 
    salt_per_1000 = round(1000 * n_salty / n, 2) 
  ) |>
  filter(n >= 500) |>
  arrange(desc(salt_per_1000)) |>
  mutate(
    across(.cols = everything(),
           .fns = ~format(.x, big.mark = ",")
           )
  ) |>
  select(-c(n_complaints, complaints_per_1000)) 
  # clipr::write_clip()

# # Sentiment analysis
# library(tidytext)
# 
# tidy_comments <- comments_ |>
#   group_by(title) |>
#   mutate(
#     comment_number = row_number(),
#     total_comments = n()
#   ) |>
#   ungroup() |>
#   unnest_tokens(word, body)
# 
# sa <- tidy_comments |>
#   inner_join(get_sentiments("nrc")) |>
#   count(title, sentiment, total_comments) |>
#   pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) |>
#   mutate(sentiment = positive - negative) |>
#   mutate(across(.cols = !c(title, total_comments), .fns = ~ .x / total_comments, .names = "avg_{.col}"))
# 
# sa |>
#   ggplot(aes(x = reorder(title, -avg_sentiment), y = avg_sentiment)) +
#   geom_col() +
#   coord_flip()


comments |> 
  group_by(flair_one) |> 
  summarise(
    n_comments = n(),
    mean_score = mean(score, na.rm = T),
    med_score = median(score, na.rm = T),
    n_complaints = sum(ref_complaint, na.rm = T),
    p_complaints_100 = 100 * n_complaints / n_comments
  ) |>
  filter(n_comments >= 100) |>
  arrange(desc(n_comments))


