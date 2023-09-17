library(RedditExtractoR)
library(tidyverse)
library(here)

devtools::load_all("~/Documents/GitHub/sportsBs/.")

# Number of retries before giving up
max_retries <- 5
# Initial delay in seconds between retries
initial_delay <- 5

retry_count <- 0

while (retry_count < max_retries) {
  tryCatch({
    urls <- find_thread_urls(
      keywords = "game thread",
      sort_by = "new",
      subreddit = "cfb",
      period = "week"
    )

    # If the code reaches here, it succeeded, so break out of the loop
    break
  }, error = function(e) {
    # Print the error message
    cat("Error:", conditionMessage(e), "\n")

    # Increment the retry count
    retry_count <- retry_count + 1

    # Check if we've reached the maximum number of retries
    if (retry_count >= max_retries) {
      cat("Max retries reached. Exiting.\n")
      # You can choose to exit the loop or handle this differently
      break
    }

    # If not, wait for a few seconds before retrying
    cat("Retrying in", initial_delay, "seconds...\n")
    Sys.sleep(initial_delay)
  })
}

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

list_files <- list.files(here("data", "reddit-comment-data", "cfb", "2023"),
                         recursive = T,
                         full.names = F) |>
  str_replace("-2023.*", "") |>
  str_replace(".*/", "")

list_files_formatted <- list_files |>
  substr(start = 1, stop = 60) |>
  str_replace_all("[^a-zA-Z0-9]", "") |>
  tolower()

remaining <- to_scrape |>
  filter(!title_formatted %in% list_files_formatted)

to_scrape_final <- remaining |>
  arrange(timestamp)

ds <- tibble()
log <- tibble()

if(nrow(to_scrape_final) != 0){

  for(i in c(1:nrow(to_scrape_final))){

    start <- Sys.time()

    temp <- sportsBs::scrape_reddit_url(
      save_locally = TRUE,
      save_local_directory = here("data", "reddit-comment-data", "cfb", "2023/"),
      thread_url = to_scrape_final$url[i]
    )

    ds <- rbind(ds, temp)

    elapsed <- Sys.time() - start
    log <- log |>
      rbind(tibble("title" = to_scrape_final$title[i],
                   "n_comments" = to_scrape_final$comments[i],
                   "scrape_time" = elapsed))

    print(paste("Finished", i, "/", nrow(to_scrape_final)))

  }

} else {
    print("No new threads found.")
}






