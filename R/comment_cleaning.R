#' Clean r/CFB comments
#'
#' @param data some r/CFB comment data
#'
#' @return a cleaned dataframe
#' @export
clean_rcfb_comments <- function(data) {

  swear_strings <- paste("(?i)\\b(fuc(k.*|c|))\\b",
                         "\\b(wtf)\\b",
                         "\\b(ass(hole|es|))\\b",
                         "damn",
                         "shit",
                         "\\b(hell)\\b",
                         "bitch",
                         "bastard",
                         sep = "|")
  ref_strings <- paste("(?i)\\b(ref(s|erees|effing|efball|))\\b", # ref, refs, referees, reffing, refball, etc.
                       "\\b(officials)\\b", # officials -- singluar has too many FPs
                       "\\b(flag(s|))\\b", # flag(s)
                       "\\b(ump(s|ire|ires))\\b", # ump / umps
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
    separate(col = title_clean, sep = " (@|Defeats|vs) ", into = c("away", "home"), remove = FALSE) |>
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

  return(data_clean)

}
