library(tidyverse)
library(tidytext)
library(lubridate)
library(wordcloud)
library(stringr)

date <- "Nov-26-2022"

team_info <- cfbfastR::cfbd_team_info()

# NEW
# file_list <- list.files(path = paste0("./data/", date, "/"), pattern = "*.csv")
file_list <- list.files(here("data", "reddit-comment-data", "cfb", "2023-offseason"), pattern = "*.rds", full.names = T)

comments_ <- lapply(list_data, readr::read_rds) |>
  dplyr::bind_rows()

comments_ <- lapply(paste0("./data/", date, "/", file_list), read_csv)
names(comments_) <- gsub(file_list, pattern = "\\..*", replacement = "")
comments_ <- bind_rows(comments_, .id = "id") |>
  select(!`...1`) |>
  rename(title = id, body = `0`, flair = `1`, time_unix = `2`, score = `3`)

comments <- comments_ |>
  mutate(
    time = as_datetime(time_unix),
    ref_complaint = if_else(grepl(
      " REF | REF(.|!|?)| REFS|REFEREE|OFFICIAL|OFFICIATING|OFFICIATED|REFFING|REFBALL|CALLS|RIGGED|RIGGING|THE FIX|FIXED|FLAG|FLAGGED",
      toupper(body)), TRUE, FALSE),
    salt_detected = if_else(grepl("SALT", toupper(body)), TRUE, FALSE),
    choke_detected = if_else(grepl("CHOKE|CHOKING", toupper(body)), TRUE, FALSE),
    flair = trimws(str_remove(flair, "\\:[^()]*\\:"))
  ) |>
  separate(col = flair, sep = " • ", into = c("flair_one", "flair_two")) |>
  separate(col = title, sep = " @ ", into = c("away", "home"), remove = FALSE) |>
  mutate(
    away = str_remove(away, "\\[Game Thread]"),
    away = trimws(str_replace_all(away, pattern = "[^a-zA-Z ]", "")),
    home = str_remove(home, " \\s*\\([^\\)]+\\)"),
    home = trimws(str_replace_all(home, pattern = "[^a-zA-Z ]", "")),
    # home_fan = if_else(grepl(home, flair_one), TRUE, FALSE),
    # away_fan = if_else(grepl(away, flair_one), TRUE, FALSE),
  ) |>
  group_by(title) |>
  mutate(
    faction = case_when(
      flair_one == home & flair_two != away ~ "Home Team Fan",
      flair_one == away & flair_two != home ~ "Away Team Fan",
      # grepl(home, flair_one) & !grepl(away, flair_two) ~ "Home Team Fan",
      # grepl(away, flair_one) & !grepl(home, flair_two) ~ "Away Team Fan",
      # !grepl(home, flair_one) & !grepl(away, flair_one) & !grepl(home, flair_two) & !grepl(away, flair_two) ~ "Neutral / Both / Neither",
      TRUE ~ "Neutral / Both / Neither"
    )
  ) |>
  ungroup() |>
  select(-c(home, away, ref_complaint, salt_detected, choke_detected, faction))

# WORDCLOUD ====
# Pick a flair, game, or flair faction
chosen_flair <- "LSU"


chosen_color <- team_info |>
  filter(school == chosen_flair) |>
  pull(var = color)

# top_words <- comments |>
#   filter(
#     flair_one == chosen_flair,
#     home == "Ohio State",
#     # faction != "Away Team Fan"
#   ) |>
#   mutate(text = body,
#          text = str_remove_all(text, "&amp;|&lt;|&gt;"),
#          text = str_remove_all(text, "\\s?(f|ht)(tp)(s?)(://)([^\\.]*)[\\.|/](\\S*)"),
#          text = str_remove_all(text, "[^\x01-\x7F]")) |>
#   unnest_tokens(word, text, token = "words") |>
#   filter(!word %in% stop_words$word,
#          !word %in% str_remove_all(stop_words$word, "'"),
#          str_detect(word, "[a-z]"),
#          !str_detect(word, "^#"),
#          !str_detect(word, "@\\S+")) |>
#   count(word, sort = TRUE) |>
#   slice_max(order_by = n, n = 50)

comments |>
  filter(
    # flair_one == chosen_flair,
    # home == "Alabama",
    # faction != "Away Team Fan"
    # time > ymd_hms("2022-11-26 22:08:43"),
    # time < ymd_hms("2022-11-26 22:12:43"),
  ) |>
  mutate(text = body,
         text = str_remove_all(text, "game"), # This is always the #1 word so I removed it
         text = str_remove_all(text, "&amp;|&lt;|&gt;"),
         text = str_remove_all(text, "\\s?(f|ht)(tp)(s?)(://)([^\\.]*)[\\.|/](\\S*)"),
         text = str_remove_all(text, "[^\x01-\x7F]")) |>
  unnest_tokens(word, text, token = "words") |>
  filter(!word %in% stop_words$word,
         !word %in% str_remove_all(stop_words$word, "'"),
         str_detect(word, "[a-z]"),
         !str_detect(word, "^#"),
         !str_detect(word, "@\\S+")) |>
  count(word, sort = TRUE) |>
  with(wordcloud(word, n, random.order = FALSE, max.words = 75,
                 # color = "red"
                 ))


# fuck _____
fuck_pattern <- "(?i)(?<=\\bfuck\\s).*?(?=\\.|,|$|\\?|\\-|but|lol|lmao|too)"

comments |>
  mutate(
    fuck = str_extract_all(body, fuck_pattern) |> tolower() |> str_replace_all("[[:punct:]]", "")
  ) |>
  unnest(fuck) |>
  count(fuck, sort = T) |>
  print(n = 20)
  # slice_head(n = 20) |>
  # knitr::kable() |>
  # clipr::write_clip()


authors <- comments |>
  group_by(author, flair_one) |>
  summarize(n_comments = n()) |>
  group_by(author) |>
  summarize(n_comments = sum(n_comments, na.rm = T),
            flairs = paste(flair_one[!flair_one == "NULL"], collapse = ", "))

authors |>
  slice_max(order_by = n_comments,
            n = 10) |>
  knitr::kable() |>
  clipr::write_clip()
