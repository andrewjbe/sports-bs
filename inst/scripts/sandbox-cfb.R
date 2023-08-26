library(RedditExtractoR)
library(dplyr)
library(tibble)
library(lubridate)
library(ggplot2)
library(stringr)
library(here)

devtools::load_all()

# Gonna scrape some r/CBB threads for posterity

urls <- find_thread_urls(
  # keywords = "[Game Thread]", # try adding @ to get rid of post game threads
  sort_by = "new",
  subreddit = "cfb",
  period = "week"
  )

# urls <- get_user_content("cfb_referee")

to_scrape <- urls |>
  as_tibble() |>
  filter(
    # grepl("\\[Game Thread]", title),
    # grepl("@|vs.", title),
    ymd(date_utc) >= ymd("2023-08-05")
  ) |>
  mutate(
    title_formatted = gsub("\\.|\\/", "", title) |>
      substr(start = 1, stop = 60) |>
      str_replace_all("[^a-zA-Z0-9]", ""),
    date_time = as.POSIXct(timestamp, origin = "1970-01-01", tz = "CST")
  )

list_files <- list.files(here("data", "reddit-comment-data", "cfb", "2023-offseason")) |>
  str_replace("-2023.*", "")

list_files_formatted <- list_files |>
  substr(start = 1, stop = 60) |>
  str_replace_all("[^a-zA-Z0-9]", "")

remaining <- to_scrape |>
  filter(!title_formatted %in% list_files_formatted)

to_scrape <- remaining |>
  arrange(date_utc)

ds <- tibble()
log <- tibble()
for(i in c(1:nrow(to_scrape))){

  start <- Sys.time()

  temp <- sportsBs::scrape_reddit_url(
    save_locally = TRUE,
    save_local_directory = here("data", "reddit-comment-data", "cfb", "2023-offseason/"),
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

readr::write_csv(log, "./data/cfb/2022/scrape-log-1-21-2023-3.csv")

list_logs <- list.files("./data/cfb/2022/", pattern = "*.csv", full.names = T)

all_logs <- lapply(list_logs, readr::read_csv) |>
  dplyr::bind_rows()

all_logs |>
  ggplot2::ggplot(aes(x = n_comments,
                      y = scrape_time)) +
  geom_point() +
  geom_smooth()




# ==============================================================================
# Results

list_data <- list.files(here("data", "reddit-comment-data", "cfb", "2023-offseason"), pattern = "*.rds", full.names = T)

all_data <- lapply(list_data, readr::read_rds) |>
  dplyr::bind_rows()

all_data |>
  count(day = lubridate::floor_date(lubridate::as_datetime(time_unix), "30 minutes")) |>
  filter(n > 10) |>
  ggplot2::ggplot(aes(x = day,
                      y = n)) +
  geom_point() +
  geom_line()

# re-alignment graph pac-12 -> b10 --------------------------------------------0

# Create a sequence of time points corresponding to every 2 PM EST
start_date <- with_tz(ymd_hms("2023-08-01 00:00:00"), tzone = "America/New_York")
end_date <- with_tz(ymd_hms("2023-08-06 00:00:00"), tzone = "America/New_York")
# time_points <- seq(from = floor_date(start_date, unit = "day"), to = end_date, by = "2 hours") |>
#   with_tz("America/New_York")

# Filter out only the time points that correspond to 2 PM EST
# time_points_2pm_est <- time_points[hour(time_points) == 14]

all_data |>
  mutate(
    time_utc = lubridate::as_datetime(time_unix),
    time_est = lubridate::as_datetime(time_unix) |> with_tz("America/New_York"),
    time_cst = lubridate::as_datetime(time_unix) |> with_tz("America/Chicago")
  ) |>
  count(day = lubridate::floor_date(time_cst, "1 hour")) |>
  ggplot2::ggplot(aes(x = day,
                      y = n)) +
  # geom_point() +
  geom_line(linewidth = 1.5) +
  # geom_col() +
  # geom_vline(xintercept = as.numeric(time_points_2pm_est), linetype = "dashed", color = "red") +
  geom_segment(x = ymd_hms("2023-8-4 00:00:00"),
               xend = ymd_hms("2023-8-4 11:40:51"),
               color = "red",
               linetype = "dashed",
               linewidth = 1.5,
               y = 3200,
               yend = 450) +
  ggimage::geom_image(image = "/home/andrew/Pictures/Screenshots/Screenshot from 2023-08-05 13-53-30.png",
                      aes(x = ymd_hms("2023-8-3 11:40:00"),
                          y = 3200),
                      nudge_x = -8.5^5,
                      size = 0.4,
                      asp = 2.2) +
  labs(title = "r/cfb comments per hour",
       subtitle = "all posts (i think), Aug 1 - Aug 5 (CST)",
       y = "comments / hour",
       caption = "data scraped using PRAW for python") +
  scale_y_continuous(labels = scales::comma) +
  # scale_x_datetime(breaks = seq(from = floor_date(start_date, unit = "day"), to = end_date, by = "6 hours"),
  #                  date_labels = "%H:%M") +
  scale_x_datetime(breaks = seq(from = floor_date(start_date, unit = "day"), to = end_date, by = "12 hours"),
                   date_labels = "%m/%d\n%H:%M (CST)",
                   timezone = "America/Chicago") +
  ggthemes::theme_fivethirtyeight()

#

all_data |>
  filter(
    grepl("Ranking the Top", title)
  ) |>
  mutate(
    time_utc = lubridate::as_datetime(time_unix),
    time_est = lubridate::as_datetime(time_unix) |> with_tz("America/New_York"),
    time_cst = lubridate::as_datetime(time_unix) |> with_tz("America/Chicago")
  ) |>
  count(day = lubridate::floor_date(time_utc, "1 hour")) |>
  ggplot2::ggplot(aes(x = day,
                      y = n)) +
  geom_col() +
  geom_vline(xintercept = as.numeric(time_points_2pm_est), linetype = "dashed", color = "red") +
labs(title = "'top 131 fbs programs' thread comments per hour",
     subtitle = "'top 131 fbs programs' posts by 'u/jimbobbypaul', Aug 1 - Aug 5",
     y = "comments / hour",
     caption = "data scraped using PRAW for python\nred lines deonte 2PM") +
  scale_y_continuous(labels = scales::comma) +
  scale_x_datetime(breaks = seq(from = floor_date(start_date, unit = "day"), to = end_date, by = "12 hours"),
                   date_labels = "%m/%d\n%H:%M (EST)",
                   timezone = "America/New_York") +
  ggthemes::theme_fivethirtyeight()

authors <- all_data |>
  group_by(author) |>
  summarize(
    n = n(),
    n_threads = n_distinct(title),
    avg_score = mean(score),
    max_score = max(score),
    min_score = min(score),
    n_downvoted = sum(score < 1)
  ) |>
  mutate(
    n_rank = rank(desc(n), ties.method = "max"),
    n_perc = round(100 * n_rank / n(), 4)
  )




