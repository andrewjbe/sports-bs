import praw
import csv
from datetime import date
import pandas as pd
from typing import ContextManager, Optional
from alive_progress import alive_bar
from pytictoc import TicToc


t = TicToc()

def spinner(title: Optional[str] = None) -> ContextManager:
  """
  Context manager to display a spinner while a long-running process is running.
  
  Usage:
      with spinner("Fetching data..."):
          fetch_data()

  Args:
      title: The title of the spinner. If None, no title will be displayed.
  """
  return alive_bar(monitor=None, stats=None, title=title)


chosen_url = "https://old.reddit.com/r/CollegeBasketball/comments/tuzhan/post_game_thread_8_north_carolina_defeats_2_duke/"
current_date = date.today().strftime("%b-%d-%Y")

r = praw.Reddit(
    client_id="",
    client_secret="",
    user_agent="test_agent",
)

submission = r.submission(url = chosen_url)

n_comments = submission.num_comments
runs = round((n_comments - 1000) / 20, 0)

while True:
    try:
      with spinner():
        submission.comments.replace_more(limit=None)
        break
    except PossibleExceptions:
        print("Handling replace_more exception")
        sleep(0.1)
        
comments = submission.comments.list()

t.tic()
df = pd.DataFrame()
for comment in comments:
  auth = comment.author
  if auth != None:
    name = auth.name
  a = pd.DataFrame([[comment.body, name, comment.author_flair_text, comment.created_utc, comment.score]])
  df = pd.concat([df, a])

final = df.rename(columns = {0: "body", 1: "author", 2: "flair", 3: "time_unix", 4: "score"})
t.toc()

# df.to_csv("./data/" + submission.title + "-" + current_date + ".csv")
