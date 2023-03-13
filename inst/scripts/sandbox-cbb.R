library(RedditExtractoR)
library(dplyr)
library(lubridate)
library(ggplot2)
library(stringr)
library(here)
library(tidyr)

devtools::load_all()

# Gonna scrape some r/CBB threads for posterity

urls <- find_thread_urls(
  keywords = "[Game Thread] @",
  sort_by = "relevance",
  subreddit = "CollegeBasketball",
  period = "month"
)

# urls <- get_user_content("cfb_referee")

to_scrape <- urls |>
  as_tibble() |>
  filter(grepl("\\[Game Thread]", title),
         grepl("@|vs.", title),
         ymd(date_utc) >= ymd("2023-03-01")
         ) |>
  arrange(ymd(date_utc))

list_files <- list.files(here("data", "reddit-comment-data", "collegebasketball", "2022-2023/")) |>
  str_replace("-.*", "")

remaining <- to_scrape |>
  filter(!title %in% list_files)

to_scrape <- remaining |>
  arrange(date_utc)

ds <- tibble()
log <- tibble()
for(i in c(1:nrow(to_scrape))){

  start <- Sys.time()

  temp <- sportsBs::scrape_reddit_url(
    save_locally = TRUE,
    save_local_directory = here("data", "reddit-comment-data", "collegebasketball", "2022-2023/"),
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

list_logs <- list.files("./data/collegebasketball/2022-2023/", pattern = "*.csv", full.names = T)

all_logs <- lapply(list_logs, readr::read_csv) |>
  dplyr::bind_rows()

all_logs |>
  ggplot2::ggplot(aes(x = n_comments,
                      y = scrape_time)) +
  geom_point() +
  geom_smooth()




# ==============================================================================
# Results / reports / graphs

list_data <- list.files(here("data", "reddit-comment-data", "collegebasketball", "2022-2023"),
                        pattern = "*.rds",
                        full.names = T)

all_data <- lapply(list_data, readr::read_rds) |>
  dplyr::bind_rows()

all_data |>
  count(day = lubridate::floor_date(lubridate::as_datetime(time_unix), "days")) |>
  filter(n > 10) |>
  ggplot2::ggplot(aes(x = day,
                      y = n)) +
  geom_point()

# path <- "/home/andrew/Documents/GitHub/sportsBs/data/reddit-comment-data/collegebasketball/2022-2023/"
# thread <- "[Game Thread] Rutgers @ #5 Purdue (12:00 PM ET)-2023-03-11.rds"

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
      |REFBALL|RIGGED|RIGGING|THE FIX|FIXED|WHISTLE|FUCKING CALL|DAMN CALL|
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
  ungroup() |>
  slice_max(order_by = sum_p_complaints, n = 60)

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
    title = "r/CollegeBasketball Game Threads\nby Proportion of Comments Complaining About the Refs",
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




