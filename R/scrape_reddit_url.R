#' Scrape the comments from a reddit thread by URL
#'
#' @param save_locally TRUE or FALSE; whether or not to save an RDS of the results locally
#' @param save_local_directory a string; the directory where the RDS file should be saved
#' @param thread_url The URL you want to scrape
#'
#' @returns A dataframe of the reddit comments
#' @export

scrape_reddit_url <- function(thread_url, save_locally = FALSE, save_local_directory) {

  thread_short_name <- gsub("https://old.reddit.com/", "", thread_url)
  cli::cli_h1(paste0("Scraping comments from ", substr(thread_short_name, 1, 60), "..."))

  tictoc::tic()
  thread_url <<- thread_url
  reticulate::py_run_file("./R/reddit_scraper.py")

  ds <- suppressWarnings(reticulate::py$final) |>
    dplyr::as_tibble()

  cli::cli_alert_success("Thread scraped successfully!")
  tictoc::toc()

  # Save locally
  if(save_locally){
    readr::write_rds(ds, file = paste0(save_local_directory, reticulate::py$submission$title, "-", lubridate::today(), ".rds"))
    cli::cli_alert_success(paste0("Saved '", reticulate::py$submission$title,  ".RDS' to ", save_local_directory))
  }

  rm(thread_url)
  return(ds)

}
