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

  python_scraping_script <- paste0("
import praw
import csv
from datetime import date
import pandas as pd

chosen_url = '", thread_url, "'
current_date = date.today().strftime('%b-%d-%Y')

r = praw.Reddit(
    client_id='bETczEve7sdlcfdvZ92lrw',
    client_secret='4NojRSIkkTYZRuFMArPDrxOsKe1-aQ',
    user_agent='test_agent',
)

submission = r.submission(url = chosen_url)

while True:
    try:
        submission.comments.replace_more(limit=None)
        break
    except PossibleExceptions:
        print('Handling replace_more exception')
        sleep(1)

comments = submission.comments.list()

df = pd.DataFrame()
for comment in comments:
  auth = comment.author
  if auth != None:
    name = auth.name
  a = pd.DataFrame([[comment.body, name, comment.author_flair_text, comment.created_utc, comment.score]])
  df = pd.concat([df, a])

final = df.rename(columns = {0: 'body', 1: 'author', 2: 'flair', 3: 'time_unix', 4: 'score'})")

tictoc::tic()
py_run_string(python_scraping_script)
tictoc::toc()

ds <- suppressWarnings(py$final)

# Save locally
if(save_locally){
  write_rds(ds, file = paste0(save_local_directory, py$submission$title))
  print(paste0("Saved local RDS to ", save_local_directory))
}

return(ds)

}
