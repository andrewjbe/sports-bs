library(RedditExtractoR)
library(dplyr)

urls_list <- find_thread_urls(
  keywords = "[Game Thread]",
  sort_by = "new",
  subreddit = "cfb",
  period = "month"
  ) |>
  as_tibble() |>
  filter(
    grepl("\\[Game Thread]", title)
  )

