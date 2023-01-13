library(RedditExtractoR)
library(dplyr)

devtools::load_all()

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

to_scrape <- urls_list |>
  filter(comments < 1000)

ds <- tibble()
for(i in c(1:nrow(to_scrape))){

  temp <- sportsBs::scrape_reddit_url(
    save_locally = TRUE,
    save_local_directory = paste0("./data/cfb/test/"),
    thread_url = to_scrape$url[i]
  )

  ds <- rbind(ds, temp)

}

