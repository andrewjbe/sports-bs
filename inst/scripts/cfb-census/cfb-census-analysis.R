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
                        pattern = "*.rds", full.names = T, recursive = T)
  # str_replace("-2023.*", "") |>
  # str_replace(".*/", "")

all_data <- lapply(list_data, readr::read_rds) |>
  dplyr::bind_rows()

gt_data <- all_data |>
  filter(str_detect(title, "@|vs|v.s") & str_detect(title, "\\[Game Thread"))

pgt_data <- all_data |>
  filter(str_detect(title, "\\[Postgame Thread"))

# Coverage checks --------------------------------------------------------------

# Repeats
test_repeat_data <- list.files(here("data", "reddit-comment-data", "cfb", "2023"),
                        pattern = "*.rds", full.names = T, recursive = T) |>
  str_replace("-2023.*", "") |>
  str_replace(".*/", "")

n_repeats <- test_repeat_data[duplicated(test_repeat_data)]

if(length(n_repeats) != 0){
  for(i in seq(from = 1, to = 10)){
    cli::cli_alert_danger("There's some repeat data in there! This is why you should write to a database!")
  }
}

# Comments per thread
gt_data |>
  count(title, sort = T) |>
  print(n = 30)

gt_data |>
  count(day = lubridate::floor_date(lubridate::as_datetime(time_unix), "1 hours")) |>
  ggplot2::ggplot(aes(x = day,
                      y = n)) +
  geom_point() +
  geom_line() +
  labs(
    title = "r/CFB [Game Thread] comments per hour",
    subtitle = "2023 season through Sep. 25",
    caption = "data scraped at 4AM each night using PRAW for Python"
  ) +
  scale_y_continuous(labels = scales::comma) +
  ggthemes::theme_fivethirtyeight()

 # Cleaning data ----------------------------------------------------------------

make_flair <- function(flair_text) {

  if(flair_text == "Unflaired") {
    return(paste0("🤡 Unflaired"))
  } else {
    return(paste0("[", flair_text, "](#f/", tolower(str_remove_all(flair_text, "\\s")), ")"))
  }
}

clean_rcfb_comments <- function(data) {

  swear_strings <- paste("(?i)\\b(fuc(k.*|c|))\\b",
                         "\\b(wtf)\\b",
                         "\\b(ass|hole|es|)\\b",
                         "damn",
                         "shit",
                         "\\b(hell)\\b",
                         "bitch",
                         "bastard",
                         sep = "|")
  ref_strings <- paste("(?i)\\b(ref(s|erees|effing|efball|))\\b", # ref, refs, referees, reffing, refball, etc.
                       "\\b(officials)\\b", # officials -- singluar has too many false positives
                       "\\b(flag(s|))\\b", # flag(s)
                       # "\\b(calls)\\b", # calls -- others have too many false positives
                       "\\b(whistle(s|))\\b", # whistle(s)
                       "the fix", # the fix, fixed
                       "\\b(rigging|rig|rigged)\\b", # rig, rigged, rigging
                       # "\\b(spot|spotted|spots)\\b", # spot, spots, spotted
                       "\\b(hosed|jobbed|robbed)\\b", # hosed, jobbed, robbed
                       sep = "|")
  ad_strings <- paste("(?i)\\b(ad|ads|advertisements)\\b",
                      "\\b(commercial|comer.*al|commer.*al)\\b",
                      "\\b(progressive|all state|cheez|att|at&t|lilly|fansville|fansvile|dr\\. pepper|dr pepper|burger king)\\b",
                      sep = "|")

data_clean <- data |>
    mutate(
      # Cleaning
      time = as_datetime(time_unix),
      time_cst = lubridate::as_datetime(time_unix) |> with_tz("America/Chicago"),
      flair = trimws(str_remove(flair, "\\:[^()]*\\:")),
      flair = if_else(flair == "NULL", "No Flair", flair), # No flairs
      flair = if_else(flair == "Go to https://flair.redditcfb.com to get your flair!", "/r/CFB", flair),
      title_clean = trimws(str_remove_all(title, "\\([^)]*\\)|\\[[^]]*\\]|\\d+|[^A-Za-z@\\s]")),
      # Ref complaints
      ref_complaint = if_else(str_detect(body, ref_strings), TRUE, FALSE),
      # Swears
      swear = if_else(str_detect(body, swear_strings), TRUE, FALSE),
      # Commercials
      ad_complaint = if_else(str_detect(body, ad_strings), TRUE, FALSE)
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
      flair_one = if_else(is.na(flair_one) | flair_one == "", "Unflaired", flair_one),
      away = str_remove(away, "\\[Game Thread]"),
      away = trimws(str_replace_all(away, pattern = "[^a-zA-Z ]", "")),
      home = str_remove(home, " \\s*\\([^\\)]+\\)"),
      home = trimws(str_replace_all(home, pattern = "[^a-zA-Z ]", ""))
    ) # |> suppressWarnings()

}

all_data_clean <- all_data |>
  clean_rcfb_comments()

gt_data_clean <- all_data_clean |>
  filter(str_detect(title, "@|vs|v.s") & str_detect(title, "\\[Game Thread"))

pgt_data_clean <- all_data_clean |>
  filter(str_detect(title, "\\[Postgame Thread"))

# Exploration ==================================================================

# Total threads:
n_gts <- gt_data_clean |> count(title, sort = T) |> nrow() |> format(big.mark = ",")
n_pgts <- pgt_data_clean |> count(title, sort = T) |> nrow() |> format(big.mark = ",")
n_all <- all_data_clean |> count(title, sort = T) |> nrow() |> format(big.mark = ",")

# Top threads ------------------------------------------------------------------

pgt_data_clean |>
  group_by(title_clean) |>
  summarize(
    n_comments = n(),
    n_comments_formatted = format(n_comments, big.mark = ",")
  ) |>
  slice_max(order_by = n_comments, n = 20) |>
  select(-n_comments) |>
  knitr::kable()

gt_data_clean |>
  group_by(title_clean) |>
  summarize(
    n_comments = n(),
    n_comments_formatted = format(n_comments, big.mark = ",")
  ) |>
  slice_max(order_by = n_comments, n = 10) |>
  select(title_clean, n_comments_formatted) |>
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

# Score dropoff ----------------------------------------------------------------

# pgt_data_clean |>
#   group_by(title_clean) |>
#   mutate(
#     min_comment_time = min(time_cst),
#     t_since_start = as.integer(difftime(time_cst, min_comment_time, units = "mins"))
#   ) |>
#   ggplot(aes(x = t_since_start)) +
#   scale_x_log10() +
#   geom_histogram()

pgt_data_clean |>
  group_by(title_clean) |>
  mutate(
    min_comment_time = min(time_cst),
    t_since_start = as.integer(difftime(time_cst, min_comment_time, units = "secs"))
  ) |>
  ggplot(aes(x = t_since_start,
             y = score,
             color = score)) +
  # Annotations
  # annotate(geom = "text",
  #          x = 0.9, y = 5000, hjust = 0,
  #          label = "first comment in each PGT") +
  # geom_curve(
  #   aes(x = 1.5, y = 4800, xend = 0, yend = 4300),
  #   arrow = arrow(type = "closed", length = unit(0.1, "inches")),
  #   lineend = "round", color = "black", curvature = -0.2
  # ) +
  annotate(geom = "text",
           x = 800, y = 4000,
           label = "More low-score comments") +
  geom_segment(
    aes(x = 750, y = 3800, xend = 850, yend = 3800),
    color = "black",
    arrow = arrow(type = "closed", length = unit(0.1, "inches"))
  ) +
  annotate(geom = "text",
           x = 60, y = 3000, angle = 90, vjust = -0.3, hjust = 0,
           label = "1 min. since PGT posted") +
  geom_vline(xintercept = 60, linetype = "dashed") +
  annotate(geom = "text",
           x = 60 * 10, y = 3000, angle = 90, vjust = -0.3, hjust = 0,
           label = "10 min. since PGT posted") +
  geom_vline(xintercept = 60 * 10, linetype = "dashed") +
  geom_point(size = 1.5) +
  # Scales
  # scale_x_log10(labels = scales::comma,
  #               breaks = c(0, 1, 2, 3, 4, 5, 10, 100, 1000, 100000)) +
  scale_x_continuous(limits = c(0, 60 * 15)) +
  scale_y_continuous(labels = scales::comma) +
  scale_color_gradient2(low = "blue",
                        mid = "orange",
                        high = "red",
                        midpoint = 1800) +
  guides(color = "none") +
  labs(
    title = "EVERYBODY GET IN HERE!!!",
    subtitle = "r/CFB [Post Game Thread] comment score vs. comment speed",
    x = "Seconds between PGT post time
    and comment post time",
    y = "Final comment score",
    caption = "data scraped using PRAW for Python, graphs made with R
    includes all PGTs so far in 2023 season"
  ) +
  ggthemes::theme_solarized() +
  theme(
    axis.text = element_text(color = "black"),
    axis.title = element_text(color = "black"),
    plot.title = element_text(color = "black",
                              face = "bold"),
    plot.subtitle = element_text(color = "black"),
    plot.caption = element_text(color = "black"),
    # panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )

# Census =======================================================================

unique_users <- gt_data_clean |>
  group_by(author) |>
  summarize(
    n_comments = n(),
    n_comments_formatted = format(n_comments, big.mark = ","),
    avg_score = mean(score, na.rm = T),
    n_downvoted = sum(score < 1, na.rm = T),
    p_downvoted = n_downvoted / n_comments,
    n_unique_threads = n_distinct(title_clean, na.rm = T),
    all_primary_flairs = paste0(unique(flair_one), collapse = ", "),
    all_secondary_flairs = paste0(unique(flair_two), collapse = ", "),
    flair_list = list(unique(flair_one)),
    # TODO: replace this with something where instead of first() it's
    # looping through and pulling out the first one that's not "Unflaired"
    counted_flair = purrr::map_chr(flair_list, first),
    flaired_up = if_else(str_detect(all_primary_flairs, ","), TRUE, FALSE),
    n_swears = sum(swear, na.rm = T),
    p_swears = sum(n_swears) / n_comments,
    n_ref_comps = sum(ref_complaint, na.rm = T),
    p_ref_comps = sum(n_ref_comps) / n_comments,
    n_ads = sum(ad_complaint, na.rm = T),
    p_ads = sum(n_ads) / n_comments
  )

# Top users
summary_users <- unique_users |>
  # slice_max(order_by = n_comments, n = 25)
  arrange(desc(n_comments))

summary_users_formatted  <- summary_users |>
  mutate(
    rank = paste0("#", row_number()),
    p_swears = paste0(100 * round(p_swears, 4), "%"),
    p_ref_comps = paste0(100 * round(p_ref_comps, 4), "%"),
    # p_ads = paste0(100 * round(p_ads, 4), "%")
  ) |>
  slice_max(order_by = n_comments, n = 25) |>
  select(c(rank, author, counted_flair, n_comments_formatted, avg_score, n_unique_threads,
           p_swears,
           p_ref_comps,
           # p_ads
           )) |>
  rename(
    "Rank" = rank,
    "Poster" = author,
    "Primary Flair" = counted_flair,
    "Total Comments" = n_comments_formatted,
    "Avg. Score" = avg_score,
    "Unique Threads" = n_unique_threads,
    "% Comments w/ Swears" = p_swears,
    "% Comments w/ Ref Complaints" = p_ref_comps,
    # "% Comments w/ Ad Complaints" = p_ads
  )

summary_users_formatted


# Flair breakdown --------------------------------------------------------------
summary_flair <- unique_users |>
  group_by(counted_flair) |>
  summarize(
    n_unique_users = n(),
    n_total_comments = sum(n_comments, na.rm = T),
    avg_comments_per_user = n_total_comments / n_unique_users,
    avg_avg_score = mean(avg_score, na.rm = T),
    p_swears = sum(n_swears) / n_total_comments,
    p_ref_comps = sum(n_ref_comps) / n_total_comments,
    # p_ads = sum(n_ads) / n_total_comments
  )
  # arrange(desc(n_unique_users)) |>
  # slice_max(n = 100, order_by = n_unique_users) |>
  # Formatting

top_users <- unique_users |>
  group_by(counted_flair) |>
  filter(
    n_comments == max(n_comments)
  ) |>
  mutate(author = paste0(author, " (", n_comments_formatted, " comments)")) |>
  select(counted_flair, "top_poster" = author)

summary_flair_formatted <- summary_flair |>
  filter(n_unique_users >= 50) |>
  arrange(desc(n_unique_users)) |>
  mutate(
    across(.cols = !c(counted_flair, p_swears, p_ref_comps),
           .fns = ~format(round(.x, 2), big.mark = ",")),
    p_swears = paste0(100 * round(p_swears, 4), "%"),
    p_ref_comps = paste0(100 * round(p_ref_comps, 4), "%")
  ) |>
  # Add top user
  left_join(top_users, by = "counted_flair") |>
  mutate(counted_flair = if_else(counted_flair == "Unflaired", "🤮 Unflaired 🤮", counted_flair)) |>
  # slice_max(n = 100, order_by = n_unique_users) |>
  rename(
    "Primary Flair" = counted_flair,
    "Unique Users" = n_unique_users,
    "Total Comments" = n_total_comments,
    "Comments per User" = avg_comments_per_user,
    "Avg. Comment Score" = avg_avg_score,
    "% of Comments w/ Swears" = p_swears,
    "% of Comments w/ Ref Complaints" = p_ref_comps,
    "Top Poster" = top_poster
  )

# How many flaired up in the dataset?
n_flaired_up <- sum(unique_users$flaired_up)

summary_flaired_up <- unique_users |>
  filter(flaired_up) |>
  count(counted_flair, sort = T) |>
  left_join(summary_flair |>
              select(counted_flair, n_unique_users)) |>
  mutate(new_flairs_percap = n / n_unique_users)

# Final post ===================================================================

# Main flair table, all w/ at least 50 users -----------------------------------
summary_flair_formatted |>
  knitr::kable() |>
  clipr::write_clip()

# Lowest / most swears
summary_flair |>
  filter(n_unique_users >= 50) |>
  slice_max(order_by = p_swears,
            n = 10) |>
  transmute("Flair" = counted_flair,
            "Total Comments" = format(n_total_comments, big.mark = ","),
            "% Comments w/ Swears" = paste0(100 * round(p_swears, 4), "%")
  )

summary_flair |>
  filter(n_unique_users >= 50) |>
  slice_max(order_by = -p_swears,
            n = 10) |>
  transmute("Flair" = counted_flair,
            "Total Comments" = format(n_total_comments, big.mark = ","),
            "% Comments w/ Swears" = paste0(100 * round(p_swears, 4), "%")
  )

# Lowest / most ref complaints
summary_flair |>
  filter(n_unique_users >= 50) |>
  slice_max(order_by = p_ref_comps,
            n = 10) |>
  transmute("Flair" = counted_flair,
            "Total Comments" = format(n_total_comments, big.mark = ","),
            "% Comments w/ Ref Mentions" = paste0(100 * round(p_ref_comps, 4), "%")
  )

summary_flair |>
  filter(n_unique_users >= 50) |>
  slice_max(order_by = -p_ref_comps,
            n = 10) |>
  transmute("Flair" = counted_flair,
            "Total Comments" = format(n_total_comments, big.mark = ","),
            "% Comments w/ Ref Mentions" = paste0(100 * round(p_ref_comps, 4), "%")
  )

# Comments per User
summary_flair |>
  filter(n_unique_users >= 50) |>
  slice_max(order_by = avg_comments_per_user,
            n = 10) |>
  transmute("Flair" = counted_flair,
            "Total Comments" = format(n_total_comments, big.mark = ","),
            "Comments per User" = format(round(avg_comments_per_user, 1), big.mark = ",")
  )

summary_flair |>
  filter(n_unique_users >= 50) |>
  slice_max(order_by = -avg_comments_per_user,
            n = 10) |>
  transmute("Flair" = counted_flair,
            "Total Comments" = format(n_total_comments, big.mark = ","),
            "Comments per User" = format(round(avg_comments_per_user, 1), big.mark = ",")
  )


# Main user table, top 25 by total comments posted -----------------------------
summary_users_formatted |>
  knitr::kable()

# Sicko
summary_users |>
  filter(author != "RivalryBot") |>
  slice_max(order_by = n_unique_threads,
            n = 10) |>
  mutate(rank = paste0("#", row_number())) |>
  select(rank, author, counted_flair, n_unique_threads, n_comments)





# Game reports =================================================================

data <- "/home/andrew/Documents/GitHub/sportsBs/data/reddit-comment-data/cfb/2023/[Game Thread] Colorado State @ Colorado (10:00 PM ET)-2023-09-17.rds"
name <- "Colorado State @ Colorado"

sportsBs::generate_report_cfb(thread_data = data,
                              year = 2023,
                              output_file = paste0("./posts/game-reports/", name, ".png"))

cu_csu <- read_rds(data)
cu_csu_clean <- clean_rcfb_comments(cu_csu) |>
  mutate(
    prime_detected = grepl("(?i)prime|deion|dion|dieon|deon|coach prime|coach sanders", body),
  )

sum(cu_csu_clean$prime_detected) / nrow(cu_csu_clean)

sum(cu_csu_clean$swear) / nrow(cu_csu_clean)

cu_csu_clean |>
  filter(flair_one != "Colorado" & flair_one != "Colorado State") |>
  count(flair_one, sort = T)


cu_csu_clean |>
  filter(score < 1) |>
  count(flair_one, sort = T)
