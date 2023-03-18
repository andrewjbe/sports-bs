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

# Gonna scrape some r/CBB threads for posterity

urls <- find_thread_urls(
  keywords = "[Game Thread] \\@ ",
  sort_by = "new",
  subreddit = "CollegeBasketball",
  period = "week"
)

# urls <- get_user_content("cfb_referee")

to_scrape <- urls |>
  as_tibble() |>
  filter(grepl("\\[Game Thread]", title),
         grepl("@|vs.", title),
         grepl("#", title),
         ymd(date_utc) >= ymd("2023-03-14")
         # ymd(date_utc) < ymd("2023-03-17")
         ) |>
  mutate(title = stringr::str_replace_all(title, "amp;", "")) |>
  arrange(ymd(date_utc))

list_files <- list.files(here("data", "reddit-comment-data", "collegebasketball", "ncaa-tournament-2023/")) |>
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

list_data <- list.files(here("data", "reddit-comment-data", "collegebasketball", "ncaa-tournament-2023"),
                        pattern = "*.rds",
                        full.names = T)

all_data <- lapply(list_data, readr::read_rds) |>
  dplyr::bind_rows()

all_data |> count(title) |> arrange(desc(n))

# all_data |>
#   count(day = lubridate::floor_date(lubridate::as_datetime(time_unix), "days")) |>
#   filter(n > 10) |>
#   ggplot2::ggplot(aes(x = day,
#                       y = n)) +
#   geom_point()

# path <- "/home/andrew/Documents/GitHub/sportsBs/data/reddit-comment-data/collegebasketball/ncaa-tournament-2023/"
# thread <- "[Game Thread] #12 Oral Roberts @ #5 Duke (07:10 PM ET)-2023-03-17.rds"
#
# generate_report_cbb(thread_data = paste0(path, thread),
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
  separate(col = title, sep = " @ ", into = c("away", "home"), remove = FALSE) |>
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
    flair_one = if_else(is.na(flair_one), "No Flair", flair_one)
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
  ungroup() # |>
  # slice_max(order_by = sum_p_complaints, n = 60)

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
    subtitle = "-- Round of 64 --",
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
  scale_y_continuous(labels = scales::percent, limits = c(0, 0.2)) +
  theme(
    axis.text.y = element_text(size = 13),
    axis.title = element_text(),
    plot.title.position = "plot",
    plot.title = element_text(hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5)
  )

ggsave(p_ref_complaints, filename = "./ref-complaints-r-64.png",
       height = 6000, width = 4800, units = "px")

# Thread timelines  ----------------------------------------

top_ten <- comments_clean |>
  count(title) |>
  slice_max(order_by = n,
            n = 10)

p_timelines <- comments_clean |>
  filter(title %in% top_ten$title) |>
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
  labs(title = "r/CollegeBasketball Game Thread Timelines\nTotal comments posted per 10 minute interval, by commenter's primary flair",
       subtitle = "-- Round of 64 --\nTop 10 threads",
       x = "Comment time (10 minute chunks)",
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

ggsave(p_timelines, filename = "./thread-timelines-r-64.png",
       height = 6000, width = 4800, units = "px")

# Word clouds -------------------------------------------------------------
library(wordcloud)
library(tidytext)

comments_clean |>
  filter(
    # flair_one == chosen_flair,
    # home == "Kansas",
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
         # !word %in% c("duke", "roberts"),
         str_detect(word, "[a-z]"),
         !str_detect(word, "^#"),
         !str_detect(word, "@\\S+")) |>
  count(word, sort = TRUE) |>
  with(wordcloud(word,
                 n,
                 random.order = FALSE,
                 max.words = 75,
                 colors = brewer.pal(9, "Blues"),
                 # color = "red"
  ))

# User stats -------------------------------------------------------------

total_n_threads <- n_distinct(comments_clean$title)

user_stats <- comments_clean |>
  group_by(author) |>
  summarize(
    n_comments = n(),
    avg_score = mean(score, na.rm = T),
    min_score = min(score),
    max_score = max(score),
    n_threads = n_distinct(title),
    # p_threads = paste0(round(100 * n_threads / total_n_threads, 2), "%")
    p_threads = n_threads / total_n_threads
  ) |>
  arrange(desc(n_comments))

# Most prolific poster
user_stats |>
  slice_max(order_by = n_comments,
            n = 10)

# Most threads posted in
user_stats |>
  slice_max(order_by = n_threads,
            n = 10)

# Most efficient poster
user_stats |>
  filter(n_comments >= 5) |>
  slice_max(order_by = avg_score,
            n = 10)

user_stats |>
  slice_max(order_by = n_comments,
            n = 10) |>
  mutate(
    across(.cols = !author,
           .fns = ~format(round(.x, 2), big.mark = ",")),
    rank = paste0("#", row_number()),
    author = paste0("u/", author)
  ) |>
  select("Rank" = rank,
         "Commentor" = author,
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


# Random words ------------------------------------------------------
comments_clean |>
  summarize(
    n_fucks = sum(grepl("fuck", body, ignore.case = TRUE)),
    # n_ = sum(grepl("", body, ignore.case = TRUE)),
    n_ref_complaints = sum(ref_complaint)
    )


# Upload to imgur ==================================================
# tkn <- imgur_login()
imgur_links <- c()

i1 <- imgur(file = "./ref-complaints-r-64.png")
imgur_links[1] <- imgur_off(i1)$link

i2 <- imgur(file = "./thread-timelines-r-64.png")
imgur_links[2] <- imgur_off(i2)$link

paste0("[Ref complaint leaderboard]",
       "(", imgur_links[1], ")") |>
  clipr::write_clip()

paste0("[Game thread timelines]",
       "(", imgur_links[2], ")") |>
  clipr::write_clip()
