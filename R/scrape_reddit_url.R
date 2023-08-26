#' Scrape the comments from a reddit thread by URL
#'
#' @param save_locally TRUE or FALSE; whether or not to save an RDS of the results locally
#' @param save_local_directory a string; the directory where the RDS file should be saved
#' @param thread_url The URL you want to scrape
#'
#' @returns A dataframe of the reddit comments
#' @export

scrape_reddit_url <- function(thread_url, save_locally = FALSE, save_local_directory) {

  # TODO: add check to see if the file already exists at save_local_directory?

  thread_short_name <- gsub(".*/r/", "r/", thread_url)
  cli::cli_h1(paste0("Scraping comments from ", substr(thread_short_name, 1, 60), "..."))

  tictoc::tic()
  thread_url <<- thread_url
  client_id <<- Sys.getenv("REDDIT_CLIENT_ID")
  secret <<- Sys.getenv("REDDIT_SECRET")

  reticulate::py_run_file("./R/reddit_scraper.py")

  cli::cli_alert_info(paste0("N comments: ", reticulate::py$n_comments))

  ds <- suppressWarnings(reticulate::py$final) |>
    dplyr::as_tibble() |>
    dplyr::mutate(flair = as.character(flair))
  # TODO: add validation here, the flairs are causing some weird errors

  cli::cli_alert_success("Thread scraped successfully!")
  tictoc::toc()

  # Save locally
  if(save_locally){
    # TODO: change today() to date of thread posting (I think it would be like py$submission$date or something)
    readr::write_rds(ds,
                     file = paste0(save_local_directory,
                                   gsub("\\.|\\/", "", reticulate::py$submission$title) |> substr(start = 1, stop = 60),
                                   "-",
                                   lubridate::today(),
                                   ".rds")
    )
    cli::cli_alert_success(paste0("Saved '", reticulate::py$submission$title,  ".RDS' to ", save_local_directory))
  }

  try({
    rm(thread_url)
    rm(secret)
    rm(client_id)
  })

  return(ds)

}
