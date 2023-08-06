library(RedditExtractoR)
library(dplyr)
library(lubridate)
library(ggplot2)
library(stringr)
library(here)
library(tidyr)
library(ggthemes)
library(imguR)
library(knitr)

devtools::load_all()

imgur_links <- c()

# Gonna scrape some r/CBB threads for posterity

urls <- find_thread_urls(
  keywords = "[Game Thread]",
  sort_by = "relevance",
  subreddit = "CollegeBasketball",
  period = "month"
)

to_scrape <- urls |>
  filter(grepl("Game Thread", title))

# urls <- get_user_content("cfb_referee")

to_scrape <- urls |>
  as_tibble() |>
  filter(grepl("\\[Game Thread]", title),
         # grepl("@|vs.", title),
         grepl("#", title),
         ymd(date_utc) >= ymd("2023-03-14")
         # ymd(date_utc) < ymd("2023-03-17")
         ) |>
  mutate(title = stringr::str_replace_all(title, "amp;", "")) |>
  arrange(ymd(date_utc))

list_files <- list.files(here("data", "reddit-comment-data", "collegebasketball", "ncaa-tournament-2023/"),
                         recursive = T,
                         full.names = F,
                         include.dirs = F) |>
  str_replace(".*/", "") |>
  str_replace("-2.*", "") # cut off scrape date

remaining <- to_scrape |>
  filter(!title %in% list_files)

to_scrape <- remaining |>
  arrange(timestamp)

ds <- tibble()
log <- tibble()
for(i in c(1:nrow(to_scrape))){

  start <- Sys.time()

  temp <- sportsBs::scrape_reddit_url(
    save_locally = TRUE,
    save_local_directory = here("data", "reddit-comment-data", "collegebasketball", "ncaa-tournament-2023/"),
    thread_url = to_scrape$url[i]
  )

  ds <- rbind(ds, temp)

  elapsed <- Sys.time() - start
  log <- log |>
    rbind(tibble("title" = to_scrape$title[i],
                 "n_comments" = to_scrape$comments[i],
                 "scrape_time" = elapsed))

  print(paste("Finished", i, "/", nrow(to_scrape)))

}


# ==============================================================================
# Logs

readr::write_csv(log, "./data/collegebasketball/2022-2023/scrape-log-1-30-2023-1.csv")

list_logs <- list.files("./data/collegebasketball/ncaa-tournament-2023/", pattern = "*.csv", full.names = T)

all_logs <- lapply(list_logs, readr::read_csv) |>
  dplyr::bind_rows()

all_logs |>
  ggplot2::ggplot(aes(x = n_comments,
                      y = scrape_time)) +
  geom_point() +
  geom_smooth()




# ==============================================================================
# Results / reports / graphs

# subtitle_var <- "Elite Eight"

list_data <- list.files(here("data", "reddit-comment-data", "collegebasketball",
                             "ncaa-tournament-2023"),
                        pattern = "*.rds",
                        recursive = T,
                        full.names = T)
  # str_replace_all("^.*/", "") # remove folders

all_data <- lapply(list_data, readr::read_rds) |>
  dplyr::bind_rows()

all_data |> count(title) |> arrange(desc(n))

# all_data |>
#   count(day = lubridate::floor_date(lubridate::as_datetime(time_unix), "days")) |>
#   filter(n > 10) |>
#   ggplot2::ggplot(aes(x = day,
#                       y = n)) +
#   geom_point()


# generate_report_cbb(thread_data = here("data", "reddit-comment-data", "collegebasketball",
#                                        "ncaa-tournament-2023",
#                                        "[Game Thread] #9 Florida Atlantic @ #8 Memphis (09:20 PM ET)-2023-03-18.rds"
#                                        ),
#                     year = 2023,
#                     output_file = "./test.png"
#                     )



# ==============================================================================
# Big graph

comments_clean <- all_data |>
  mutate(
    time = as_datetime(time_unix),
    ref_complaint = if_else(grepl(
      " REF | REFS|REFS |REFFING|REFEREE|OFFICIAL|OFFICIATING|OFFICIATED|REFFING|
      |REFBALL|RIGGED|RIGGING|THE FIX|WHISTLE|FUCKING CALL|DAMN CALL|
      |TERRIBLE CALL|BAD CALL|BULLSHIT CALL|AWFUL CALL|HOSED|ROBBED|JOBBED",
      # " FRAN | FRAN(.|!|?)|FRAN ",
      body, ignore.case = TRUE),
      TRUE, FALSE),
    flair = trimws(str_remove(flair, "\\:[^()]*\\:")),
    flair = if_else(flair == "NULL", "No Flair", flair)
  ) |>
  separate(col = flair, sep = " • ", into = c("flair_one", "flair_two")) |>
  separate(col = title, sep = " (@|defeats) ", into = c("away", "home"), remove = FALSE) |>
  mutate(
    away = str_remove(away, "\\[Game Thread]"),
    away = trimws(str_replace_all(away, pattern = "[^a-zA-Z ]", "")),
    home = str_remove(home, " \\s*\\([^\\)]+\\)"),
    home = trimws(str_replace_all(home, pattern = "[^a-zA-Z ]", "")),
  ) |>
  # FLAIR FIXES
  mutate(
    across(.cols = c(home, away),
           .fns = ~case_when(
             .x == "Texas AM" ~ "Texas A&M",
             .x == "UConn" ~ "Connecticut",
             .x == "Florida Atlantic" ~ "FAU",
             TRUE ~ .x
           ))
  ) |>
  group_by(title) |>
  mutate(
    faction = case_when(
      # flair_one == home ~ "Home Team Fan",
      # flair_one == away ~ "Away Team Fan",
      grepl(home, flair_one) ~ "Home Team Fan",
      grepl(away, flair_one) ~ "Away Team Fan",
      TRUE ~ "Neutral / Both / Neither"
    ),
    flair_one = if_else(is.na(flair_one), "No Flair", flair_one),
    title_clean = str_replace_all(title, "\\[Game Thread\\]", ""),
    title_clean = str_replace(title_clean, "\\s*\\([^\\)]+\\)", "") |> trimws(),
  ) |>
  ungroup()


# Graph -- Cumulative
graph_data <- comments_clean |>
  mutate(title = str_remove(title, "\\[Game Thread]"),
         title = str_remove(title, "\\s*\\([^\\)]+\\)")) |>
  group_by(title, faction) |>
  summarize(
    n_complaints = sum(ref_complaint, na.rm = T),
    n_comments = n(),
    # n_salty = sum(salt_detected, na.rm = T)
  ) |>
  group_by(title) |>
  mutate(
    total_comments = sum(n_comments, na.rm = T),
    total_complaints = sum(n_complaints, na.rm = T),
    # total_salt = sum(n_salty, na.rm = T),
    p_complaints = n_complaints / total_comments,
    sum_p_complaints = total_complaints / total_comments,
    # salt_level = total_salt / total_comments
  ) |>
  ungroup()
  # slice_max(order_by = sum_p_complaints, n = 0)

label_data <- graph_data |>
  group_by(title) |>
  summarize(
    sum_comments = unique(total_comments),
    sum_complaints = unique(total_complaints),
    sum_p_complaints = total_complaints / total_comments
  ) |>
  distinct()

p_ref_complaints <- ggplot(data = graph_data,
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
    title = "r/CollegeBasketball Game Threads\nby Proportion of Comments Complaining About the Refs",
    subtitle = "Entire 2023 Tournament",
    y = "% of Comments Featuring a Remark About the Refs",
    x = "",
    fill = "Complainer Flair",
    caption = paste0("Data collected from r/CollegeBasketball using PRAW (https://praw.readthedocs.io/en/stable/)\n",
                     "Allegiance determined by primary flairs only")
  ) +
  ggthemes::theme_fivethirtyeight() +
  # ggthemes::scale_fill_fivethirtyeight() +
  scale_fill_manual(labels = c("Away Team Fan", "Home Team Fan", "Neutral / No Flair"),
                    values = c("#008FD5", "#FF2700", "#A8A8A8")) +
  scale_y_continuous(labels = scales::percent, limits = c(0, 0.23)) +
  theme(
    axis.text.y = element_text(size = 13),
    axis.title = element_text(),
    plot.title.position = "plot",
    plot.title = element_text(hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5)
  )
p_ref_complaints

ggsave(p_ref_complaints, filename = "./ref-complaints.png",
       height = 6000, width = 4800, units = "px")

# Thread timelines  ----------------------------------------

top_ten <- comments_clean |>
  count(title) |>
  # slice_max(order_by = n,
  #           n = 10)
  filter(title %in% c("[Game Thread] #9 Florida Atlantic @ #5 San Diego State (06:09 PM ET)",
                      "[Game Thread] #5 Miami @ #4 UConn (08:49 PM ET)",
                      "[Game Thread] #5 San Diego State @ #4 UConn (09:20 PM ET)"))

p_timelines <- comments_clean |>
  filter(title %in% top_ten$title) |>
  count(
    min = floor_date(time, "5 minutes"),
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
  labs(title = "r/CollegeBasketball Game Thread Timelines\nTotal comments posted per 5 minute interval, by commenter's primary flair",
       subtitle =  "Final Four + National Championship Games",
       x = "Comment time (5 minute chunks)",
       y = "Total comments",
       fill = "Commenter Faction",
       caption = paste0("Data collected from r/CollegeBasketball using PRAW (https://praw.readthedocs.io/en/stable/)\n",
                        "Allegiance determined by primary flairs only")
  ) +
  theme_fivethirtyeight() +
    # scale_fill_fivethirtyeight() +
    scale_fill_manual(labels = c("Away Team Fan", "Home Team Fan", "Neutral / No Flair"),
                      values = c("#008FD5", "#FF2700", "#A8A8A8")) +
  theme(legend.direction = "vertical",
        axis.text.y = element_text(size = 13),
        axis.title = element_text(),
        plot.title.position = "plot",
        plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5)
  )
p_timelines

ggsave(p_timelines, filename = "./thread-timelines.png",
       height = 3000, width = 4800, units = "px")

# Word clouds -------------------------------------------------------------
library(wordcloud)
library(tidytext)

i3 <- imgur()

comments_clean |>
  filter(
    # score < 1
    # ref_complaint
    # flair_one == "Arkansas Razorbacks",
    # home == "Kansas State",
    title == "[Game Thread] #5 San Diego State @ #4 UConn (09:20 PM ET)"
    # faction != "Away Team Fan"
  ) |>
  mutate(text = body,
         text = str_remove_all(text, "game"), # This is always the #1 word so I removed it
         text = str_remove_all(text, "&amp;|&lt;|&gt;"),
         text = str_remove_all(text, "\\s?(f|ht)(tp)(s?)(://)([^\\.]*)[\\.|/](\\S*)"),
         text = str_remove_all(text, "[^\x01-\x7F]")) |>
  unnest_tokens(word, text, token = "words") |>
  filter(!word %in% stop_words$word,
         !word %in% str_remove_all(stop_words$word, "'"),
         # !word %in% c("refs"),
         !word %in% c("uconn", "sdsu", "diego", "san", "connecticut"),
         str_detect(word, "[a-z]"),
         !str_detect(word, "^#"),
         !str_detect(word, "@\\S+")) |>
  count(word, sort = TRUE) |>
  with(wordcloud(word,
                 n,
                 scale = c(4, 1.3),
                 random.order = FALSE,
                 max.words = 100,
                 colors = brewer.pal(9, "Blues"),
                 # color = "black"
  ))

imgur_links[1] <- imgur_off(i3)$link

paste0("# [WORD CLOUD: Description]",
       "(", imgur_links[1], ")") |>
  clipr::write_clip()

# User stats -------------------------------------------------------------

total_n_threads <- n_distinct(comments_clean$title)

user_stats <- comments_clean |>
  group_by(author) |>
  summarize(
    flair_one = flair_one[[1]],
    n_comments = n(),
    avg_score = mean(score, na.rm = T),
    min_score = min(score),
    max_score = max(score),
    n_threads = n_distinct(title),
    # p_threads = paste0(round(100 * n_threads / total_n_threads, 2), "%")
    p_threads = n_threads / total_n_threads
  ) |>
  arrange(desc(n_comments))

# # Most prolific poster
# user_stats |>
#   slice_max(order_by = n_comments,
#             n = 10)
#
# # Most threads posted in
# user_stats |>
#   slice_max(order_by = n_threads,
#             n = 10)
#
# # Most efficient poster
# user_stats |>
#   filter(n_comments >= 5) |>
#   slice_max(order_by = avg_score,
#             n = 10)

user_stats |>
  slice_max(order_by = n_comments,
            n = 10) |>
  mutate(
    across(.cols = !c(author, flair_one),
           .fns = ~format(round(.x, 2), big.mark = ",")),
    rank = paste0("#", row_number()),
    author = paste0("\\/u/", author)
  ) |>
  select("Rank" = rank,
         "Commentor" = author,
         "Flair" = flair_one,
         "Total Comments" = n_comments,
         "Avg. Score" = avg_score,
         "Min. Score" = min_score,
         "Max. Score" = max_score,
         "Threads Visited" = n_threads) |>
  kable() |>
  clipr::write_clip()


# Flair stats -------------------------------------------------------
flair_stats <- comments_clean |>
  group_by(flair_one) |>
  summarize(
    n_comments = n(),
    n_users = n_distinct(author),
    avg_comments = n_comments / n_users,
    avg_score = mean(score, na.rm = T)
    # min_score = min(score),
    # max_score = max(score)
  ) |>
  # filter(n_users >= 10) |>
  arrange(desc(n_comments))

flair_stats |>
  filter(flair_one != "No Flair") |>
  slice_max(order_by = n_comments,
            n = 10) |>
  mutate(
    across(.cols = !flair_one,
           .fns = ~format(round(.x, 2), big.mark = ",")),
    rank = paste0("#", row_number())
  ) |>
  select("Rank" = rank,
         "Primary Flair" = flair_one,
         "Total Comments" = n_comments,
         "Unique Users" = n_users,
         "Comments per User" = avg_comments,
         "Avg. Score" = avg_score) |>
  kable() |>
  clipr::write_clip()


# Ref complaints ------------------------------------------------------
ref_complaint_stats <- comments_clean |>
  group_by(flair_one) |>
  summarize(
    n_comments = n(),
    n_fucks = sum(grepl("fuck|shit| ass|ass |damn|hell|bitch|god", body, ignore.case = TRUE)),
    p_fucks = 100 * n_fucks / n_comments,
    # n_ = sum(grepl("", body, ignore.case = TRUE)),
    n_ref_complaints = sum(ref_complaint),
    p_ref_complaints = 100 * n_ref_complaints / n_comments
    ) |>
  filter(n_comments > 500)

ref_complaint_stats |>
  # filter(!flair_one %in% c("No Flair", "/r/CollegeBasketball")) |>
  slice_max(order_by = p_ref_complaints,
            n = 10) |>
  mutate(
    across(.cols = !flair_one,
           .fns = ~format(round(.x, 2), big.mark = ",")),
    rank = paste0("#", row_number()),
    p_ref_complaints = paste0(p_ref_complaints, "%")
  ) |>
  select("Rank" = rank,
         "Primary Flair" = flair_one,
         "Total Comments" = n_comments,
         "N Comments w/ ref complaints" = n_ref_complaints,
         "% Comments w/ ref complaints" = p_ref_complaints) |>
  kable() |>
  clipr::write_clip()

ref_complaint_stats |>
  # filter(!flair_one %in% c("No Flair", "/r/CollegeBasketball")) |>
  slice_max(order_by = p_fucks,
            n = 10) |>
  mutate(
    across(.cols = !flair_one,
           .fns = ~format(round(.x, 2), big.mark = ",")),
    rank = paste0("#", row_number()),
    p_fucks = paste0(p_fucks, "%")
  ) |>
  select("Rank" = rank,
         "Primary Flair" = flair_one,
         "Total Comments" = n_comments,
         "N Comments w/ Swears" = n_fucks,
         "% Comments w/ Swears" = p_fucks) |>
  kable() |>
  clipr::write_clip()

# Most toxic thread -----------------------------------------

comments_clean |>
  group_by(title) |>
  summarize(
    n_comments = n(),
    mean_score = mean(score, na.rm = T),
    medi_score = median(score, na.rm = T),
    n_downvoted = sum(score < 1, na.rm = T),
    p_downvoted = n_downvoted / n_comments,
    n_commercial = sum(grepl("commercial| ads", body, ignore.case = TRUE)),
    p_commercial = 100 * n_commercial / n_comments,
  ) |>
  arrange(desc(p_downvoted))

# Upload to imgur ==================================================
# tkn <- imgur_login()


i1 <- imgur(file = "./ref-complaints.png")
imgur_links[2] <- imgur_off(i1)$link

i2 <- imgur(file = "./thread-timelines.png")
imgur_links[3] <- imgur_off(i2)$link

paste0("# [CHART: Ref complaint leaderboard]",
       "(", imgur_links[2], ")") |>
  clipr::write_clip()

paste0("# [CHART: Game thread timelines]",
       "(", imgur_links[3], ")") |>
  clipr::write_clip()


# ==============================================================================
# Summarizing the whole thing ==================================================
# ==============================================================================

game_data_raw <- hoopR::espn_mbb_scoreboard(2023)
# kp_dat_raw <- hoopR::kp_game_attrs()

game_data <- game_data_raw |>
  filter(
    season == 2023,
    tournament_id == 22
    # season_slug == "post-season"
  ) |>
  mutate(
    across(.cols = c(home_team_location, away_team_location),
           .fns = ~case_when(
             .x == "Florida Atlantic" ~ "FAU",
             .x == "UConn" ~ "Connecticut",
             .x == "Saint Mary's" ~ "Saint Marys",
             .x == "Texas A&M-Corpus Christi" ~ "Texas AMCorpus Christi",
             TRUE ~ .x
           )),
    join_matchup = paste0(away_team_location, " @ ", home_team_location)
  )

# write_csv(game_data, "./game-data.csv")

# Joining game data on
full_ds <- comments_clean |>
  mutate(
    join_matchup = paste0(away, " @ ", home)
  ) |>
  group_by(title) |>
  summarize(
    join_matchup = unique(join_matchup),
    n_comments = n(),
    n_ref_complaints = sum(ref_complaint),
    p_ref_complaints = n_ref_complaints / n_comments
    #
  ) |>
  left_join(game_data, by = "join_matchup") |>
  mutate(
    margin = abs(home_score - away_score),
    fav_margin = home_score - away_score
  )

library(ggrepel)
library(ggpmisc)

p_relationship <- full_ds |>
  ggplot(aes(x = fav_margin,
             y = p_ref_complaints)) +
  geom_text_repel(aes(label = matchup_short),
                  min.segment.length = 0,
                  size = 3,
                  force = 3) +
  # geom_smooth(method = "lm",
  #             se = F) +
  stat_poly_line(se = F) +
  stat_poly_eq(label.x = 0.6,
               label.y = 0.3,
               color = "blue"
               ) +
  geom_point() +
  scale_y_continuous(limits = c(0, NA),
                     labels = scales::percent) +
  labs(
    title = "r/CBB Ref Complaints vs. Margin of Victory",
    subtitle = "Entire 2023 NCAA Tournament",
    x = "Final margin of victory",
    y = "% of game thread comments\ncomplaining about the refs",
    caption = "Blue line denotes linear fit"
  ) +
  theme_clean()
p_relationship

ggsave(p_relationship, filename = "./correlation.png",
       height = 3000, width = 4800, units = "px")

i4 <- imgur(file = "./correlation.png")
imgur_links[4] <- imgur_off(i4)$link

paste0("# [CHART: Correlation between margin of victory and ref complaints]",
       "(", imgur_links[4], ")") |>
  clipr::write_clip()

# Models =======================================================================

library(stargazer)

# All game threads, % ref complaints by margin / n comments
mod <- lm(data = full_ds,
          formula = p_ref_complaints ~ n_comments, margin)
mod |>
  stargazer(type = "text")

mod_data_flair <- comments_clean |>
  group_by(flair_one) |>
  mutate(total_comments = n()) |>
  ungroup() |>
  filter(total_comments >= 250)

# All comments, prob. of ref complaint by flair
mod2 <- glm(data = mod_data_flair,
            family = "binomial",
            formula = ref_complaint ~ flair_one + title)
mod2 |>
  stargazer(type = "text")


# # Cumulative stats =============================================================

cum_stats <- comments_clean |>
  group_by(title) |>
  summarize(
    n_comments = n(),
    n_ref_complaints = sum(ref_complaint),
    p_ref_complaints = n_ref_complaints / n_comments
  ) |>
  ungroup() |>
  mutate(
    mean_p_ref_complaints = mean(p_ref_complaints)
  )

p_dist <- cum_stats |>
  ggplot(aes(x = p_ref_complaints)) +
  geom_histogram() +
  # Annotations
  geom_vline(aes(xintercept = mean_p_ref_complaints),
             color = "red", linewidth = 2) +
  annotate(x = mean(cum_stats$p_ref_complaints),
           y = 6,
           geom = "label",
           label = "Mean\n😐") +
  geom_vline(xintercept = mean(cum_stats$p_ref_complaints) - sd(cum_stats$p_ref_complaints),
             linetype = "dashed") +
  annotate(x = mean(cum_stats$p_ref_complaints) - sd(cum_stats$p_ref_complaints),
           y = 6,
           geom = "label",
           label = "-1 SD\n😪") +
  geom_vline(xintercept = mean(cum_stats$p_ref_complaints) + sd(cum_stats$p_ref_complaints),
             linetype = "dashed") +
  annotate(x = mean(cum_stats$p_ref_complaints) + sd(cum_stats$p_ref_complaints),
           y = 6,
           geom = "label",
           label = "+1 SD\n🧐") +
  geom_vline(xintercept = mean(cum_stats$p_ref_complaints) + 2 * sd(cum_stats$p_ref_complaints),
             linetype = "dashed") +
  annotate(x = mean(cum_stats$p_ref_complaints) + 2 * sd(cum_stats$p_ref_complaints),
           y = 6,
           geom = "label",
           label = "+2 SD\n🥵") +
  geom_vline(xintercept = mean(cum_stats$p_ref_complaints) + 3 * sd(cum_stats$p_ref_complaints),
             linetype = "dashed") +
  annotate(x = mean(cum_stats$p_ref_complaints) + 3 * sd(cum_stats$p_ref_complaints),
           y = 6,
           geom = "label",
           label = "+3 SD\n🔥") +
  # callouts
  annotate(x = .1227, y = 2, geom = "text", hjust = 0.76,
           label = "#9 Florida Atlantic @ #8 Memphis") +
  annotate(geom = "segment",
           x = 0.115, xend = 0.12,
           y = 1.8, yend = 1.2,
           arrow = arrow(type = "closed"),
           size = 1
  ) +
  # Labels / scales
  scale_x_continuous(labels = scales::percent) +
  theme_fivethirtyeight() +
  labs(title = "Distribution of Ref Complaint Frequency",
       subtitle = "2023 NCAA Tournament, all threads",
       x = "% of comments complaining about the refs",
       y = "Number of Threads")



ggsave(p_dist, filename = "./dist.png",
       height = 3000, width = 4800, units = "px")

i5 <- imgur(file = "./dist.png")
imgur_links[5] <- imgur_off(i5)$link

paste0("# [CHART: Distribution of game thread ref complaints]",
       "(", imgur_links[5], ")") |>
  clipr::write_clip()


comments_clean |>
  group_by(title_clean) |>
  summarize(
    n_no_flairs = sum(flair_one == "No Flair"),
    n_comments = n(),
    p_no_flairs = 100 * n_no_flairs / n_comments
    ) |>
  arrange(desc(p_no_flairs)) |>
  # slice_max(order_by = p_no_flairs,
  #           n = 10) |>
  mutate(
    across(.cols = !title_clean,
           .fns = ~format(round(.x, 2), big.mark = ",")),
    rank = paste0("#", row_number()),
    p_no_flairs = paste0(p_no_flairs, "%")
  ) |>
  select("Rank" = rank,
         "Thread" = title_clean,
         "Total Comments" = n_comments,
         "N No-Flair Comments" = n_no_flairs,
         "% No-Flair Comments" = p_no_flairs) |>
  kable()
  clipr::write_clip()
