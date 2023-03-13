#' Generate a report based on a single game thread from r/CFB ==================
#'
#' @param thread_data a locally saved .RDS file of reddit comment data
#' @param alt_color whether or not the home team should use their alt color
#' @param output_file the file to save the resulting image
#' @param year the cfb season during which the game took place
#'
#' @import webshot2
#' @import htmlwidgets
#' @import png
#' @import ggimage
#' @import quarto
#'
#' @returns A dataframe of the reddit comments
#' @export

generate_report_cfb <- function(thread_data, alt_color = FALSE, year, output_file) {

  cli::cli_alert("Rendering report...")

  # Rendering Quarto -----------------------------------------------------------
  quarto_render(input = "./inst/reports/cfb/game-thread-summary-cfb.qmd",
                execute_params = list(
                  data = thread_data,
                  # alt_color = alt_color,
                  yr = year)
                )

  cli::cli_alert("Report rendered successfully! Saving as image and optimizing...")

  # Saving image ------
  webshot2::webshot(url = "./inst/reports/cfb/game-thread-summary-cfb.html",
                    file = output_file,
                    zoom = 1.3)

  system(paste0("convert ",
                output_file,
                " -shave 75x0 ",
                output_file
  ))
  system(paste0("optipng ", output_file)) # lossless compression to get < 1Mb

  cli::cli_alert_success(paste0("Image saved to ", output_file, "!"))

}

#' Generate a report based on a single game thread from r/Collegebasketball ====
#'
#' @param thread_data a locally saved .RDS file of reddit comment data
#' @param alt_color whether or not the home team should use their alt color
#' @param output_file the file to save the resulting image
#' @param year the cbb season during which the game took place
#'
#' @import webshot2
#' @import htmlwidgets
#' @import png
#' @import ggimage
#' @import quarto
#'
#' @returns A dataframe of the reddit comments
#' @export

generate_report_cbb <- function(thread_data, alt_color = FALSE, year, output_file) {

  cli::cli_alert("Rendering report...")

  # Rendering Quarto -----------------------------------------------------------
  quarto_render(input = "./inst/reports/cbb/game-thread-summary-cbb.qmd",
                execute_params = list(
                  data = thread_data,
                  # alt_color = alt_color,
                  yr = year)
  )

  cli::cli_alert("Report rendered successfully! Saving as image and optimizing...")

  # Saving image ------
  webshot2::webshot(url = "./inst/reports/cbb/game-thread-summary-cbb.html",
                    file = output_file,
                    zoom = 1.3)

  system(paste0("convert ",
                output_file,
                " -shave 75x0 ",
                output_file
  ))
  system(paste0("optipng ", output_file)) # lossless compression to get < 1Mb

  cli::cli_alert_success(paste0("Image saved to ", output_file, "!"))


}

#' Generate a report based on a single game thread from r/NFL ==================
#'
#' @param thread_data a locally saved .RDS file of reddit comment data
#' @param alt_color whether or not the home team should use their alt color
#' @param output_file the file to save the resulting image
#' @param year the nfl season during which the game took place
#'
#' @import webshot2
#' @import htmlwidgets
#' @import png
#' @import ggimage
#' @import quarto
#'
#' @returns A dataframe of the reddit comments
#' @export

generate_report_nfl <- function(thread_data, alt_color = FALSE, output_file, year) {

  cli::cli_alert("Rendering report...")

  # Rendering Quarto -----------------------------------------------------------
  quarto_render(input = "./inst/reports/nfl/game-thread-summary-nfl.qmd",
                execute_params = list(
                  data = thread_data,
                  # alt_color = alt_color,
                  yr = year)
  )

  cli::cli_alert("Report rendered successfully! Saving as image and optimizing...")

  # Saving image ------
  webshot2::webshot(url = "./inst/reports/nfl/game-thread-summary-nfl.html",
                    file = output_file,
                    zoom = 1.3)

  system(paste0("convert ",
                output_file,
                " -shave 75x0 ",
                output_file
  ))
  system(paste0("optipng ", output_file)) # lossless compression to get < 1Mb

  cli::cli_alert_success(paste0("Image saved to ", output_file, "!"))


}

















