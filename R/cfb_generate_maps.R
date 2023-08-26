#' Generate a "Classic" Imperialism Map for a given CFB season / week ==========
#'
#' @param season the year of the map you want to generate
#' @param week the week of the map you want to generate
#' @param output_file the file you want to save the map image to, ends with .png
#'
#' @returns Saves an image of the CFB "Classic" Imperialism Map and returns the data
#' @export


cfb_generate_imp_map <- function(season = 2022, end_week = 1, output_file, no_ak_pr = TRUE){

  cli::cli_h1("Generating 'Classic' Imperialism map...")

  cli::cli_alert_info("Preparing data...")

  # Preparing data -------------------------------------------------------------
  base_map <- readr::read_rds("./data/map-files/base_map_fbs_grouped_no_ak_wa_logo_fix.rds")
  base_map_no_ak <- readr::read_rds("./data/map-files/base_map_fbs_grouped_no_ak.rds")
  styling <- readr::read_csv("./data/map-files/cfb-map-styling.csv", show_col_types = FALSE)
  counties <- readr::read_rds("./data/map-files/counties_shifted.rds")
  states <- readr::read_rds("./data/map-files/states_shifted.rds")

  # All CFB team data
  ds_teams <- cfbfastR::cfbd_team_info(only_fbs = FALSE) |>
    dplyr::filter(!is.na(conference)) |> # There are like 1,700 teams otherwise
    dplyr::rename(
      logo_light = logo,
      logo_dark = logo_2
    ) |>
    dplyr::mutate(
      conference = dplyr::if_else(is.na(conference), "FCS", conference),
      logo_light = dplyr::if_else(is.na(logo_light), "https://b.fssta.com/uploads/application/leagues/logos/NCAAFootball.vresize.350.350.medium.2.png", logo_light), # default backup logo
      logo_dark = dplyr::if_else(is.na(logo_dark), "https://b.fssta.com/uploads/application/leagues/logos/NCAAFootball.vresize.350.350.medium.2.png", logo_dark),
      logo_chosen = dplyr::if_else(school %in% styling$alt_logo_list, logo_dark, logo_light),
      color_chosen = dplyr::if_else(school %in% styling$alt_color_list, alt_color, color)
    )

  cli::cli_alert_info("Accessing game outcome data...")

  # All CFB results data
  ds_results_all <- cfbfastR::cfbd_game_info(year = season,
                                          season_type = "both") |>
    dplyr::mutate(week = dplyr::if_else(season_type == "postseason", max(week) + 1, as.numeric(week)))

  ds_results <- ds_results_all |>
    dplyr::filter(!is.na(home_points),
                  week <= end_week) |>
    dplyr::mutate(
      winner = dplyr::if_else(home_points > away_points, home_team, away_team),
      loser = dplyr::if_else(home_points < away_points, home_team, away_team)
    ) |>
    dplyr::select(winner, loser, week) |>
    dplyr::left_join(ds_teams |>
                       dplyr::select(school, logo_chosen, color_chosen, conference) |>
                       dplyr::rename(winner = school),
                     by = "winner") |>
    dplyr::rename(winner_logos = logo_chosen, winner_color = color_chosen) |>
    dplyr::mutate(
      # default logo for if the others are missing
      winner_logos = dplyr::if_else(is.na(winner_logos), "https://www.ncaa.com/modules/custom/casablanca_core/img/sportbanners/football.svg", winner_logos)
    ) |>
    dplyr::distinct() |>
    dplyr::arrange(week)

  cli::cli_alert_info("Re-assigning land based on game outcomes...")

  # Re-assigning land based on game outcomes -----------------------------------
  # 'counties_grouped' is the df that will be used in the final map
  counties_grouped <- base_map |>
    dplyr::mutate(home_school = school) |>
    dplyr::left_join(ds_teams |>
                       dplyr::select(home_mascot = mascot,
                                     home_conference = conference,
                                     home_city = city,
                                     school),
                     by = "school")

  counties_grouped_no_ak <- base_map_no_ak |>
    dplyr::mutate(home_school = school) |>
    dplyr::left_join(ds_teams |>
                       dplyr::select(home_mascot = mascot,
                                     home_conference = conference,
                                     home_city = city,
                                     school),
                     by = "school")

  # Loop through all the games in the season so far
  if(end_week > 0) {
    for(i in (1:nrow(ds_results))){
      counties_grouped <- counties_grouped |>
        dplyr::mutate(
          school = dplyr::if_else(school == ds_results$loser[i], ds_results$winner[i], school)
        )

      counties_grouped_no_ak <- counties_grouped_no_ak |>
        dplyr::mutate(
          school = dplyr::if_else(school == ds_results$loser[i], ds_results$winner[i], school)
        )
    }
  }

  # Add logos and colors back on according to the new owner of each county
  counties_grouped <- counties_grouped |>
    dplyr::left_join(ds_teams |>
                       dplyr::select(school, logo_chosen, color_chosen),
                     by = "school")

  counties_grouped_no_ak <- counties_grouped_no_ak |>
    dplyr::left_join(ds_teams |>
                       dplyr::select(school, logo_chosen, color_chosen),
                     by = "school")

  cli::cli_alert_info("Generating map...")

  # The map itself -------------------------------------------------------------
  # Logos and sizing
  logoIcons.os <- leaflet::icons(
    iconUrl = counties_grouped$logo_chosen,
    iconWidth = (as.numeric(log(sf::st_area(counties_grouped))) - 21) * 44,
    iconHeight = (as.numeric(log(sf::st_area(counties_grouped))) - 21) * 44
  )

  # Colors
  map_teams <- counties_grouped |>
    dplyr::group_by(school) |>
    dplyr::summarize(color_chosen = unique(color_chosen))

  fill_team <- leaflet::colorFactor(map_teams$color_chosen, map_teams$school, na.color = "grey", ordered = TRUE)

  # Reprojection
  epsg2163 <- leaflet::leafletCRS(
    crsClass = "L.Proj.CRS",
    code = "ESRI:102003",
    proj4def = "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs",
    resolutions = 2^(16:7)
  )

  # The leaflet map
  m <- leaflet::leaflet(options = leaflet::leafletOptions(crs = epsg2163,
                                                          zoomControl = TRUE,
                                                          zoomSnap = 0.25,
                                                          zoomDelta = 1),
                        height = 4000,
                        width = 6400) |>
    leaflet::setView(lng = -98.64580,
                     lat = 38.05909,
                     zoom = 6) |>
    leaflet::addPolygons(data = counties_grouped,
                         smoothFactor = 0.2,
                         color = "white",
                         fillColor = ~fill_team(school),
                         fillOpacity = 0.9,
                         label = ~school,
                         weight = 0,
                         stroke = F) |>
    # Add logos
    leaflet::addMarkers(data = sf::st_centroid(counties_grouped,
                                               of_largest_polygon = TRUE) |> suppressWarnings(),
                        label = ~school,
                        icon = logoIcons.os) |>
    # Add county and state borders, then harder overlay of the territory boundaries
    leaflet::addPolylines(data = counties,
                          color = "grey",
                          weight = 0.25,
                          smoothFactor = 0,
                          opacity = 0.75)  |>
    leaflet::addPolylines(data = states,
                          color = "grey",
                          weight = 2,
                          smoothFactor = 0,
                          opacity = 1) |>
    leaflet::addPolylines(data = counties_grouped,
                          color = "black",
                          weight = 3,
                          smoothFactor = 0,
                          opacity = 1)

  cli::cli_alert_info("Saving and optimizing image...")

  # Saving the PNG -------------------------------------------------------------
  htmlwidgets::saveWidget(m, "./temp_files/temp.html", selfcontained = F)

  webshot2::webshot(url = "./temp_files/temp.html",
                    file = output_file,
                    vwidth = 6400,
                    vheight = 4000)


  # Adding text, logo, etc.
  img <- png::readPNG(output_file)
  h <- as.numeric(dim(img)[1])
  w <- as.numeric(dim(img)[2])

  leader_logo <- counties_grouped_no_ak |>
    dplyr::group_by(school) |>
    dplyr::reframe(total_domain = sum(sum_total),
                   school = school,
                   logo_chosen = logo_chosen,
                   color_chosen = color_chosen) |>
    dplyr::distinct() |>
    dplyr::slice_max(order_by = total_domain, n = 1) |>
    dplyr::select(school, logo_chosen, color_chosen)


  text_to_plot <- tibble::tibble(x = 0.63,
                                 y = 0.952,
                                 text = paste0("CFB IMPERIALISM MAP | ",  season,
                                               " season, week ", end_week)
                                 )

  final_img <- ggplot2::ggplot(data = text_to_plot) +
    ggplot2::annotation_raster(img, xmin = 0, xmax = 1, ymin = 0, ymax = 1) +
    ggplot2::annotation_raster(png::readPNG("./inst/www/cfb-imp-map-frame.png"),
                               xmin = 0, xmax = 1, ymin = 0, ymax = 1) +
    ggplot2::geom_text(ggplot2::aes(x = x, y = y, label = text),
                       size = 4000,
                       color = "#161616",
                       family = "Open Sans Extrabold") +
    # Leader logo
    ggplot2::geom_point(ggplot2::aes(x = 0.899, y = 0.1653),
                                   color = dplyr::pull(leader_logo, var = color_chosen),
                        size = 2.4 * 10^4,
                        alpha = 0.9) +
    ggimage::geom_image(ggplot2::aes(x = 0.899, y = 0.1653,
                                     image = dplyr::pull(leader_logo, var = logo_chosen)),
                        size = 0.111, by = "height") +
    # Replaced below w/ an all-inclusive frame as another raster annotation
    # ggimage::geom_image(ggplot2::aes(image = "./inst/www/cfb-imp-map-logo-mod.png",
    #                                  x = 0.11, y = 0.85),
    #                     size = 0.14, asp = 1.6) +
    # ggimage::geom_image(ggplot2::aes(image = "./inst/www/cfb-imp-map-header.png", x = 0.085, y = 0.85), size = 0.090, asp = 1.6) +
    ggplot2::xlim(0,1) +
    ggplot2::ylim(0,1) +
    ggthemes::theme_map() +
    ggplot2::guides(fill = "none")

  # Saving, trimming, and compressing
  ggplot2::ggsave(paste0(output_file),
                  plot = final_img,
                  device = "png",
                  width = w,
                  height = h,
                  limitsize = FALSE,
                  dpi = 1)

  system(paste0("convert ", output_file, " -trim ", output_file)) # trim ws on edges
  system(paste0("convert ", output_file, " -shave 40x10 ", output_file)) # shave a few pixels more off the edges to get rid of leaflet UI

  system(paste0("optipng ", output_file)) # lossless compression to get < 1Mb

  cli::cli_alert_success(paste("Image saved at", output_file))

  # TODO: Upload to imgur for sharing?

  # TODO: Generate text for accompanying post (including imgur links) and return?
  if(no_ak_pr){
    data <- counties_grouped_no_ak |>
      st_drop_geometry()

    return(data)
  } else {
    data <- counties_grouped |>
      st_drop_geometry()

    return(data)
  }

  # Then all I'd have to do is run one function each week and then paste the output over

}
