library(renv)
library(RedditExtractoR)
library(tidyverse)
library(purrr)
library(parallel)

devtools::load_all()

urls <- find_thread_urls(
  keywords = "game thread", # try adding @ to get rid of post game threads
  sort_by = "new",
  subreddit = "cfb",
  period = "week"
)

to_scrape <- urls |>
  as_tibble() |>
  filter(
    str_detect(title, "(?i)(post|)game thread"),
    # grepl("@|vs.", title),
    # ymd(date_utc) >= ymd("2023-08-05")
  ) |>
  mutate(
    title_formatted = gsub("\\.|\\/", "", title) |>
      substr(start = 1, stop = 60) |>
      str_replace_all("[^a-zA-Z0-9]", "") |>
      tolower(),
    date_time = as.POSIXct(timestamp, origin = "1970-01-01", tz = "CST")
  )

list_files <- list.files(here("data", "reddit-comment-data", "cfb", "2023")) |>
  str_replace("-2023.*", "")

list_files_formatted <- list_files |>
  substr(start = 1, stop = 60) |>
  str_replace_all("[^a-zA-Z0-9]", "") |>
  tolower()

remaining <- to_scrape |>
  filter(!title_formatted %in% list_files_formatted)

to_scrape_final <- remaining |>
  arrange(date_utc)

ds <- tibble()
log <- tibble()
for(i in c(1:nrow(to_scrape))){

  start <- Sys.time()

  temp <- sportsBs::scrape_reddit_url(
    save_locally = TRUE,
    save_local_directory = here("data", "reddit-comment-data", "cfb", "2023/"),
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






