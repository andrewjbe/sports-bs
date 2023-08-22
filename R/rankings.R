#' Calculates an expected score given two teams' ratings
#'
#' @param home_rating The home team's elo rating
#' @param away_rating The away team's elo rating
#'
#' @export
#'
#' @return A data frame with team names and their rankings.
#'
#'
cfb_rankings_elo_expected_win_prob <- function(team_rating, opp_team_rating) {
  return(1 / (1 + 10^((opp_team_rating - team_rating) / 400)))
}

#' Calculates a new elo score given a game's outcome
#'
#' @param team_rating The team's elo rating
#' @param expected_score The expected score of the game
#' @param observed_score The actual score of the game
#' @param k_factor The k-factor to be used
#'
#' @export
#'
#' @return A data frame with team names and their rankings.
#'
cfb_rankings_elo_new_score <- function(team_rating, expected_score, observed_score,
                                       k_factor = 60) {
  return(team_rating + k_factor * (observed_score - expected_score))
}

#' Generate rankings based on performance scores
#'
#' This function generates rankings for college football teams based on their
#' performance scores. Teams with higher performance scores are ranked higher.
#'
#' @param year A given CFB season
#' @param years_lookback The number of previous years to include in elo scores
#'
#' @export
#'
#' @return A data frame with team names and their rankings.
#'
#'
cfb_rankings_drew_elo <- function(year = 2022, years_lookback = 3) {

  # Retrieve game result data
  year_seq <- seq(from = year - years_lookback, to = lubridate::year(lubridate::today()))

  ds_games <- purrr::map_dfr(year_seq, ~cfbfastR::cfbd_game_info(year = .x,
                                                                 season_type = "both",
                                                                 # division = "fbs"
  )) |>
    # Only looking at FBS matchups
    dplyr::filter(home_division == "fbs" & away_division == "fbs") |>
    dplyr::mutate(
      week = dplyr::if_else(season_type == "postseason", max(.data$week) + 1, week),
      week = dplyr::if_else(grepl("(?i)cfp national champ", notes), max(.data$week) + 1, week),
      start_date = lubridate::ymd_hms(start_date),
      game_outcome = dplyr::case_when(
        home_points > away_points ~ 1,
        home_points < away_points ~ 0,
        home_points == away_points ~ 0.5
      )
    )

  ds <- ds_games |>
    dplyr::arrange(start_date) |>
    dplyr::filter(!is.na(game_outcome))

  pb <- cli::cli_progress_bar(
    total = nrow(ds)
  )

  # Starting values
  ds_elos <- tibble::tibble(team = unique(ds$home_team),
                            elo_rating_pre = 1500,
                            elo_rating_post = 1500,
                            opp_elo_rating_pre = 1500,
                            opp_elo_rating_post = 1500,
                            game_id = NA,
                            home_team = NA, away_team = NA,
                            start_date = lubridate::ymd("1900-01-01"),
                            home_points = NA, away_points = NA,
                            home_conference = NA, away_conference = NA,
                            season = min(ds$season),
                            week = 0,
                            notes = NA
                            )

  for(game_i in seq(from = 1, to = nrow(ds))){

    current_home_team <- ds$home_team[game_i]
    current_away_team <- ds$away_team[game_i]
    current_home_outcome <- ds$game_outcome[game_i]
    current_away_outcome <- 1 - current_home_outcome

    current_game_id = ds$game_id[game_i]
    current_game_week = ds$week[game_i]
    current_game_season = ds$season[game_i]
    current_game_start_date = ds$start_date[game_i]

    current_game_info <- ds |>
      dplyr::select(game_id, home_team, away_team, week, season,
                    start_date, home_points, away_points,
                    home_conference, away_conference,
                    notes) |>
      dplyr::filter(game_id == current_game_id)

    # Each team's rating from last game
    home_rating_old <- ds_elos |>
      dplyr::filter(team == current_home_team) |>
      dplyr::arrange(dplyr::desc(season), dplyr::desc(week)) |>
      dplyr::filter(start_date < current_game_start_date) |>
      dplyr::slice(1) |>
      dplyr::pull(elo_rating_post)
    away_rating_old <- ds_elos |>
      dplyr::filter(team == current_away_team) |>
      dplyr::arrange(dplyr::desc(season), dplyr::desc(week)) |>
      dplyr::filter(start_date < current_game_start_date) |>
      dplyr::slice(1) |>
      dplyr::pull(elo_rating_post)

    # Calculating new elos
    home_rating_new <- sportsBs::cfb_rankings_elo_new_score(
      team_rating = home_rating_old,
      observed_score = current_home_outcome,
      expected_score = sportsBs::cfb_rankings_elo_expected_win_prob(
        team_rating = home_rating_old,
        opp_team_rating = away_rating_old
      ))
    away_rating_new <- sportsBs::cfb_rankings_elo_new_score(
      team_rating = away_rating_old,
      observed_score = current_away_outcome,
      expected_score = sportsBs::cfb_rankings_elo_expected_win_prob(
        team_rating = away_rating_old,
        opp_team_rating = home_rating_old
      ))

    temp <- tibble::tibble(
      team = c(current_home_team, current_away_team),
      elo_rating_pre = c(home_rating_old, away_rating_old),
      elo_rating_post = c(home_rating_new, away_rating_new),
      opp_elo_rating_pre = c(away_rating_old, home_rating_old),
      opp_elo_rating_post = c(away_rating_new, away_rating_new)
      # week = rep(current_game_week, 2),
      # season = rep(current_game_season, 2)
    ) |>
      cbind(current_game_info)

    ds_elos <- dplyr::bind_rows(ds_elos, temp)

    rm(home_rating_old, away_rating_old,
       home_rating_new, away_rating_new,
       current_home_team, current_away_team,
       current_home_outcome, current_away_outcome,
       current_game_id, current_game_info,
       temp)

    cli::cli_progress_update()

  }

  cli::cli_progress_done()

  return(ds_elos)

}


#' Generate Top 25 ELO rankings for a given week
#'
#' This function generates rankings for college football teams based on their
#' performance scores. Teams with higher performance scores are ranked higher.
#'
#' @param year A given CFB season
#' @param week A given CFB week
#' @param elos The number of previous years to include in elo scores
#' @param n_results The number of results to return
#'
#' @export
#'
#' @return A data frame with team names and their rankings.
#'
#'
cfb_rankings_drew_elo_top <- function(elos, year = 2022, week = 1, n_results = 25) {

  ds_elos <- elos |>
    dplyr::filter(.data$season == .env$year & .data$week == .env$week) |>
    dplyr::group_by(team) |>
    dplyr::filter(start_date == max(start_date)) |>
    dplyr::select(team, season, week, elo_rating_post) |>
    dplyr::ungroup() |>
    dplyr::slice_max(order_by = elo_rating_post, n = .env$n_results)

  return(ds_elos)

}

