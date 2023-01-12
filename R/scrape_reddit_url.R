#' Scrape the comments from a reddit thread by URL
#'
#' @param save_locally TRUE or FALSE; whether or not to save an RDS of the results locally
#' @param save_local_directory a string; the directory where the RDS file should be saved
#' @param thread_url The URL you want to scrape
#'
#' @returns A dataframe of the reddit comments
#' @export

scrape_reddit_url <- function(save_locally = FALSE, save_local_directory, thread_url) {

  library(reticulate)
  library(dplyr)
  library(readr)
  # library(cli)

  python_scraping_script <- paste0("
import praw
import csv
from datetime import date
import pandas as pd
from typing import ContextManager, Optional
from alive_progress import alive_bar
from pytictoc import TicToc

t = TicToc()

chosen_url = '", thread_url, "'
current_date = date.today().strftime('%b-%d-%Y')

r = praw.Reddit(
    client_id='bETczEve7sdlcfdvZ92lrw',
    client_secret='4NojRSIkkTYZRuFMArPDrxOsKe1-aQ',
    user_agent='test_agent',
)

submission = r.submission(url = chosen_url)

n_comments = submission.num_comments

t.tic()
while True:RedditExtractoR
      try:
          submission.comments.replace_more(limit=None)
          break
      except PossibleExceptions:
          print('Handling replace_more exception')
          sleep(0.1)

comments = submission.comments.list()
t.toc()

df = pd.DataFrame()
for comment in comments:
  auth = comment.author
  if auth != None:
    name = auth.name
  a = pd.DataFrame([[comment.body, name, comment.author_flair_text, comment.created_utc, comment.score]])
  df = pd.concat([df, a])

final = df.rename(columns = {0: 'body', 1: 'author', 2: 'flair', 3: 'time_unix', 4: 'score'})")

tictoc::tic()
# cli::cli_progress_message(paste0("Scraping ", thread_url, "..."))
py_run_string(python_scraping_script)
# cli::cli_progress_done()
tictoc::toc()

ds <- suppressWarnings(py$final) |>
  as_tibble()

# Save locally
if(save_locally){
  write_rds(ds, file = paste0(save_local_directory, py$submission$title))
  print(paste0("Saved local RDS to ", save_local_directory))
}

return(ds)

}
