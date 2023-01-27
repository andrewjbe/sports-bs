library(RedditExtractoR)
library(dplyr)
library(lubridate)
library(ggplot2)
library(stringr)

devtools::load_all()

# Gonna scrape some r/nfl threads for posterity

urls <- find_thread_urls(
  keywords = "Game Thread:",
  sort_by = "relevance",
  subreddit = "nfl",
  period = "month"
  )

# urls <- get_user_content("cfb_referee")

to_scrape <- urls |>
  as_tibble() |>
  filter(!grepl("Post Game Thread:|Pre Game Thread:", title),
         grepl("^Game Thread", title),
         # grepl("@|vs.", title),
         ymd(date_utc) >= ymd("2023-01-14")
         )

list_files <- list.files("./data/nfl/2022-2023-playoffs/") |>
  str_replace("-20.*", "")

remaining <- to_scrape |>
  filter(!title %in% list_files)

to_scrape <- remaining |>
  arrange(date_utc)

ds <- tibble()
log <- tibble()
for(i in c(1:nrow(to_scrape))){

  start <- Sys.time()

  print(paste0("Start time: ", start))
  print(paste0("N comments: ", to_scrape$comments[i]))

  temp <- sportsBs::scrape_reddit_url(
    save_locally = TRUE,
    save_local_directory = paste0("./data/nfl/2022-2023-playoffs/"),
    thread_url = to_scrape$url[i]
  )

  ds <- rbind(ds, temp)

  elapsed <- Sys.time() - start
  log <- log |>
    rbind(tibble("title" = to_scrape$title[i],
                 "n_comments" = to_scrape$comments[i],
                 "scrape_time" = elapsed))

  print(paste("Finished", i, "/", nrow(to_scrape), " at ", Sys.time()))

}


# ==============================================================================
# Logs

readr::write_csv(log, paste0("./data/nfl/2022-2023-playoffs/scrape-log-", lubridate::now(), ".csv"))

list_logs <- list.files("./data/nfl/2022-2023-playoffs/", pattern = "*.csv", full.names = T)

all_logs <- lapply(list_logs, readr::read_csv) |>
  dplyr::bind_rows()

all_logs |>
  ggplot2::ggplot(aes(x = n_comments,
                      y = scrape_time)) +
  geom_point() +
  geom_smooth()




# ==============================================================================
# Results

list_data <- list.files("./data/nfl/2022-2023-playoffs/", pattern = "*.rds", full.names = T)

all_data <- lapply(list_data, readr::read_rds) |>
  dplyr::bind_rows()

all_data |>
  count(day = lubridate::floor_date(lubridate::as_datetime(time_unix), "days")) |>
  filter(n > 10) |>
  ggplot2::ggplot(aes(x = day,
                      y = n)) +
  geom_point()




