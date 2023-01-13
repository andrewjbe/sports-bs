import praw
import csv
from datetime import date
import pandas as pd

chosen_url = r.thread_url # r is the current R environment via {reticulate}
current_date = date.today().strftime('%b-%d-%Y')

reddit = praw.Reddit(
    client_id='bETczEve7sdlcfdvZ92lrw',
    client_secret='4NojRSIkkTYZRuFMArPDrxOsKe1-aQ',
    user_agent='test_agent',
)

submission = reddit.submission(url = chosen_url)

n_comments = submission.num_comments

while True:
      try:
          submission.comments.replace_more(limit=None)
          break
      except PossibleExceptions:
          print('Handling replace_more exception')
          sleep(0.1)

comments = submission.comments.list()

df = pd.DataFrame()
for comment in comments:
  auth = comment.author
  if auth != None:
    name = auth.name
  a = pd.DataFrame([[comment.body, name, comment.author_flair_text, comment.created_utc, comment.score]])
  df = pd.concat([df, a])

final = df.rename(columns = {0: 'body', 1: 'author', 2: 'flair', 3: 'time_unix', 4: 'score'})

# df.to_csv("./data/" + submission.title + "-" + current_date + ".csv")
