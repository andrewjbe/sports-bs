library(RedditExtractoR)
library(dplyr)
library(tidyr)
library(tibble)
library(lubridate)
library(ggplot2)
library(stringr)
library(here)
library(fs)

devtools::load_all()

# Load data --------------------------------------------------------------------

list_data <- list.files(here("data", "reddit-comment-data", "cfb", "2023"),
                        pattern = "*.rds", full.names = T)
  # str_replace("-2023.*", "") |>
  # str_replace(".*/", "")

all_data <- lapply(list_data, readr::read_rds) |>
  dplyr::bind_rows()

gt_data <- all_data |>
  filter(str_detect(title, "@|vs|v.s") & str_detect(title, "\\[Game Thread"))

pgt_data <- all_data |>
  filter(str_detect(title, "\\[Postgame Thread"))

# Coverage checks --------------------------------------------------------------

# Comments per thread
gt_data |>
  count(title, sort = T) |>
  print(n = 30)

gt_data |>
  count(day = lubridate::floor_date(lubridate::as_datetime(time_unix), "1 hours")) |>
  # filter(n > 10) |>
  ggplot2::ggplot(aes(x = day,
                      y = n)) +
  geom_point() +
  geom_line()

 # Cleaning data ----------------------------------------------------------------

clean_rcfb_comments <- function(data) {

  data_clean <- data |>
    mutate(
      # Cleaning
      time = as_datetime(time_unix),
      time_cst = lubridate::as_datetime(time_unix) |> with_tz("America/Chicago"),
      flair = trimws(str_remove(flair, "\\:[^()]*\\:")),
      flair = if_else(flair == "NULL", "No Flair", flair),
      title_clean = trimws(str_remove_all(title, "\\([^)]*\\)|\\[[^]]*\\]|\\d+|[^A-Za-z@\\s]")),
      # Ref complaints
      # ref_complaint = if_else(grepl(ref_strings, body, ignore.case = TRUE), TRUE, FALSE)
    ) |>
    # separate(col = flair, sep = " • ", into = c("flair_one", "flair_two")) |>
    separate(col = title_clean, sep = " (@|Defeats) ", into = c("away", "home"), remove = FALSE) |>
    separate_wider_delim(cols = flair,
                         delim = " • ",
                         names = c("flair_one", "flair_two"),
                         too_few = "align_start",
                         cols_remove = F
    ) |>
    # separate_wider_delim(cols = title_clean,
    #                      delim = "@|defeats",
    #                      names = c("away", "home"),
    #                      too_few = "align_start",
    #                      cols_remove = F
    # ) |>
    mutate(
      flair_one = if_else(is.na(flair_one) | flair_one == "", "Unflaired ️Scum", flair_one),
      away = str_remove(away, "\\[Game Thread]"),
      away = trimws(str_replace_all(away, pattern = "[^a-zA-Z ]", "")),
      home = str_remove(home, " \\s*\\([^\\)]+\\)"),
      home = trimws(str_replace_all(home, pattern = "[^a-zA-Z ]", ""))
    ) # |> suppressWarnings()

}

all_data_clean <- all_data |>
  clean_rcfb_comments()

gt_data_clean <- gt_data |>
  clean_rcfb_comments()

pgt_data_clean <- pgt_data |>
  clean_rcfb_comments()

# Leaderboards =================================================================

# Total threads:
gt_data_clean |> count(title, sort = T) |> nrow() |> format(big.mark = ",")
pgt_data_clean |> count(title, sort = T) |> nrow() |> format(big.mark = ",")
all_data_clean |> count(title, sort = T) |> nrow() |> format(big.mark = ",")

# Top threads ------------------------------------------------------------------

pgt_data_clean |>
  group_by(title_clean) |>
  summarize(
    n_comments = n(),
    n_comments_formatted = format(n_comments, big.mark = ",")
  ) |>
  slice_max(order_by = n_comments, n = 100) |>
  select(-n_comments) |>
  knitr::kable()

gt_data_clean |>
  group_by(title_clean) |>
  summarize(
    n_comments = n(),
    n_comments_formatted = format(n_comments, big.mark = ",")
  ) |>
  slice_max(order_by = n_comments, n = 100) |>
  select(title_clean, n_comments_formatted) |>
  knitr::kable()

# Top Flairs -------------------------------------------------------------------

all_data_clean |>
  count(flair_one, sort = T) |>
  slice_max(order_by = n, n = 100) |>
  knitr::kable()

# Top posters ------------------------------------------------------------------

all_data_clean |>
  group_by(author) |>
  summarize(
    n_comments = n(),
    n_comments_formatted = format(n_comments, big.mark = ","),
    avg_score = mean(score, na.rm = T),
    n_unique_threads = n_distinct(title_clean, na.rm = T)
  ) |>
  slice_max(order_by = n_comments,
            n = 50) |>
  # filter(str_detect(author, "asas")) |>
  select(-n_comments) |>
  knitr::kable()

# "Sicko Award"
all_data_clean |>
  filter(author != "RivalryBot") |>
  group_by(author) |>
  summarize(
    n_comments = n(),
    n_comments_formatted = format(n_comments, big.mark = ","),
    avg_score = mean(score, na.rm = T),
    n_unique_threads = n_distinct(title_clean, na.rm = T)
  ) |>
  slice_max(order_by = n_unique_threads,
            n = 10)

























