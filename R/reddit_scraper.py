import praw
import csv
import time
from datetime import date
import pandas as pd

chosen_url = r.thread_url # r is the current R environment via {reticulate}
current_date = date.today().strftime('%b-%d-%Y')

reddit = praw.Reddit(
    client_id=r.client_id,
    client_secret=r.secret,
    user_agent='test_agent',
)

submission = reddit.submission(url = chosen_url)

n_comments = submission.num_comments

while True:
      try:
          submission.comments.replace_more(limit=None)
          break
      except:
          print('Handling replace_more exception')
          time.sleep(0.1)

comments = submission.comments.list()

df = pd.DataFrame()
name = "NULL"
for comment in comments:
  auth = comment.author
  if auth != None:
    name = auth.name
  a = pd.DataFrame([[submission.title, comment.body, name, comment.author_flair_text, comment.created_utc, comment.score]])
  df = pd.concat([df, a])

final = df.rename(columns = {0: 'title', 1: 'body', 2: 'author', 3: 'flair', 4: 'time_unix', 5: 'score'})

# df.to_csv("./data/" + submission.title + "-" + current_date + ".csv")
