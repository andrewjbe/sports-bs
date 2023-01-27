library(tidyverse)
library(leaflet)
library(lubridate)
library(cfbfastR)
library(sf)
library(data.table)
library(tictoc)
library(extrafont)

yr <- 2022
wk <- 16

# DATA --------------------------------------------------
source('keys.R')
options(scipen=999)
extrafont::loadfonts()

tic()

# see /scripts/app-sandbox.R
counties <- readRDS("./data/counties-shifted.RDS")
states <- readRDS("./data/states-shifted.RDS")
pops <- read_csv("./data/counties_pop.csv") |>
  filter(variable == "POP")

# base_map <- readRDS("base-map-shifted-block-groups.RDS")
base_map_ <- readRDS("./data/base-map-shifted-illinois-contig.RDS")

dark_logo_list <- c("Oregon", "Nevada", "UCLA", "Kansas State", "Air Force", "Washington State", "California",
                    "Indiana", "Michigan State", "Rice", "Texas", "Clemson", "Duke", "Pittsburgh", "Alabama",
                    "BYU", "TCU")
alt_color_list <- c("Tennessee", "North Texas", "Temple", "LSU", "San Diego State", "UMass", "Iowa", 
                    "Northwestern", "Utah State", "UC Davis", "Montana", "Wisconsin", "NC State",
                    "Oklahoma", "Minnesota", "Kent State", "SMU", "Akron", "Tulsa", "Houston", "UCLA", "USC")

# team information dataframe, sans FCS teams
ds_teams_ <- cfbfastR::cfbd_team_info(only_fbs = F)

ds_teams <- ds_teams_ |>
  # unnest_wider(col = logos, names_sep = ",") |>
  rename(
    # logo_light = `logos,1`,
    # logo_dark = `logos,2`
    logo_light = logo,
    logo_dark = logo_2
  ) |>
  mutate(
    conference = if_else(is.na(conference), "FCS", conference),
    # default backup logo
    logo_light = if_else(is.na(logo_light), "https://b.fssta.com/uploads/application/leagues/logos/NCAAFootball.vresize.350.350.medium.2.png", logo_light),
    logo_dark = if_else(is.na(logo_dark), "https://b.fssta.com/uploads/application/leagues/logos/NCAAFootball.vresize.350.350.medium.2.png", logo_dark),
    latitude = if_else(school == "Hawai'i", 29.3, latitude),
    longitude = if_else(school == "Hawai'i", -123.23, longitude),
    logo_chosen = if_else(school %in% dark_logo_list, logo_dark, logo_light),
    color_chosen = if_else(school %in% alt_color_list, alt_color, color)
  ) |>
  # Have to fix fucking illinois still
  mutate(
    latitude = if_else(school == "Illinois", 40.1020, latitude),
    longitude = if_else(school == "Illinois", -88.2272, longitude)
  )

# Results data
ds_results_ <- cfbd_game_info(year = yr, season_type = "both") |>
  mutate(week = if_else(season_type == "postseason", max(week) + 1, as.numeric(week))) # |>
  # filter(week <= wk)

ds_results <- ds_results_ |>
  filter(!is.na(home_points)) |>
  mutate(
    winner = if_else(home_points > away_points, home_team, away_team),
    loser = if_else(home_points < away_points, home_team, away_team)
  ) |>
  dplyr::select(winner, loser, week) |>
  left_join(ds_teams |> dplyr::select(school, logo_chosen, color_chosen, conference) |> rename(winner = school), by = "winner") |>
  rename(winner_logos = logo_chosen, winner_color = color_chosen) |>
  mutate(
    # default logo for if the others are missing
    winner_logos = if_else(is.na(winner_logos), "https://www.ncaa.com/modules/custom/casablanca_core/img/sportbanners/football.svg", winner_logos)
  ) |>
  distinct() |>
  arrange(week)

# This is the loop that iterates through each game result and gives the loser's land to the winner
counties_grouped <- base_map_ |>
  mutate(home_school = school) |>
  left_join(ds_teams |>
              select(home_mascot = mascot,
                     home_conference = conference,
                     home_city = city,
                     school), 
            by = "school")

for(i in (1:nrow(ds_results))){
  
  counties_grouped <- counties_grouped |>
    mutate(
      school = if_else(school == ds_results$loser[i], ds_results$winner[i], school)
    )
  
  if(i %% (nrow(ds_results) / 4) == 0){
    print(paste0(
      round(100 * (i / nrow(ds_results)), 2), "% done...")
    )
  }
}

counties_grouped <- counties_grouped |>
  left_join(ds_teams |> select(school, logo_chosen, color_chosen), by = "school")

# manual color / logo changes UGHGHHGHGHG
counties_grouped <- counties_grouped |>
  mutate(
    color_chosen = case_when(
      school == "Cincinnati" ~ "#E00122",
      TRUE ~ color_chosen
    ),
    logo_chosen = case_when(
      school == "TCU" ~ "https://cdn.freebiesupply.com/logos/thumbs/2x/tcu-5-logo.png",
      TRUE ~ logo_chosen
    )
  )

# # Experiment ----
# library(mapview)
# library(data.table)
# 
# test <- tibble()
# for(i in 1:nrow(counties_grouped)){
#   schl <- counties_grouped[i, "school"] |>
#     pull(var = school)
#   
#   counties_regrouped <- counties_grouped %>%
#     filter(school == schl) %>%
#     st_filter(., counties_grouped[1,], .predicate = st_touches)
#   
#   test <- rbind(test, counties_regrouped)
# }


# This is the actual map -------------------------------------------------------
logoIcons.os <- icons(
  iconUrl = counties_grouped$logo_chosen,
  iconWidth = (as.numeric(log(st_area(counties_grouped))) - 21) * 22,
  iconHeight = (as.numeric(log(st_area(counties_grouped))) - 21) * 22
)

# function to apply the correct colors to each territory 
map_teams <- counties_grouped |> group_by(school) |> summarize(color_chosen = unique(color_chosen))
fill_team <- colorFactor(map_teams$color_chosen, map_teams$school, na.color = "grey", ordered = TRUE)

# Reprojection
epsg2163 <- leafletCRS(
  crsClass = "L.Proj.CRS",
  code = "ESRI:102003",
  proj4def = "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs",
  resolutions = 2^(16:7)
)

m <- leaflet(options = leafletOptions(crs = epsg2163,
                                      zoomControl = TRUE,
                                      zoomSnap = 0.25,
                                      zoomDelta = 1),
             height = 2000, 
             width = 3200) |>
  setView(lng = -98.64580, lat = 39.85909, zoom = 5) |>
  addPolygons(data = counties_grouped, 
              smoothFactor = 0.2, 
              color = "white", 
              fillColor = ~fill_team(school), 
              fillOpacity = 0.9, 
              label = ~school, 
              weight = 0,
              stroke = F
  ) |>
  addMarkers(data = st_centroid(counties_grouped), label = ~school, icon = logoIcons.os,
             popup = paste0(
               "<center><b>", counties_grouped$home_city, " Territory, home of the ", counties_grouped$home_mascot, "</b><br></center>",
               "<center>Currently Controlled by ", counties_grouped$school, "<br></center>",
               "<hr>",
               "Territory Area: ", format(round(counties_grouped$sum_land, 1), nsmall = 1, big.mark = ","), " sq. miles<br>",
               "Territory Water area: ", format(round(counties_grouped$sum_water, 1), nsmall = 1, big.mark = ","), " sq. miles<br>",
               "No. of Counties in Territory: ", format(counties_grouped$n_counties, nsmall = 1, big.mark = ","), "<br>",
               "Territory Population: ", format(counties_grouped$total_pop, big.mark = ",")
             )) |>
  addPolylines(data = counties, color = "grey", weight = 0.3, smoothFactor = 0, opacity = 1)  |>
  addPolylines(data = states, color = "grey", weight = 2, smoothFactor = 0, opacity = 1) |>
  addPolylines(data = counties_grouped, color = "grey", weight = 2, smoothFactor = 0, opacity = 1) # 
  # addCircleMarkers(data = filter(ds_teams, classification %in% c("fcs", "fbs")), label = ~school, stroke = T, fillOpacity = 0.8, weight = 0.75, color = "black", fillColor = ~color, radius = 5,
  #                popup = paste0("<center><img src=", ds_teams$logos, " width = '50' height = '50'>",
  #                               "<br><hr><b>", ds_teams$school, "</center>",
  #                               "</b><br>", ds_teams$conference,
  #                               "<br>Mascot: ", ds_teams$mascot
  #                ))

# m

# Saving image ------
file_name <- paste0(getwd(), "/map-image-generator-scripts/imp-maps/", yr, "/imp-map-", yr, "-week-", wk, ".png")

library(webshot2)
library(htmlwidgets)
library(png)
library(ggimage)

# mapshot(m, file = file_name, selfcontained = F)
saveWidget(m, "temp.html", selfcontained = F)
# webshot2::webshot(url = "temp.html", file = file_name,
#                   vwidth = 3000,
#                   vheight = 1600)

webshot2::webshot(url = "temp.html", file = file_name,
                  vwidth = 3200,
                  vheight = 2000)


# Adding label

img <- readPNG(file_name)
h <- as.numeric(dim(img)[1])
w <- as.numeric(dim(img)[2])

text_to_plot <- 
  tibble(x = 0.6,
         y = 0.86,
         text = paste0("CFB Imperialism Map - ",  yr, " season, week ", wk)) 
         # text = "CFB Imperialism Base Map")

final_img <- ggplot(data = text_to_plot) + 
  annotation_raster(img, xmin = 0, xmax = 1, ymin = 0, ymax = 1) +
  geom_text(aes(x = x, y = y, label = text), 
            size = 1800,
            family = "Open Sans Extrabold",
            fontface = "bold") +
  geom_image(aes(image = "www/cfb-imp-map-logo-named.png", x = 0.09, y = 0.87), size = 0.085, asp = 1.6) +
  geom_image(aes(image = "www/ireeland.png", x = 0.90, y = 0.3), size = 0.07, asp = 1.6) +
  xlim(0,1) +
  ylim(0,1) +
  ggthemes::theme_map() 

# final_img

ggsave(paste0(file_name), plot = final_img, device = "png", width = w, height = h, limitsize = FALSE, dpi = 1)
system(paste0("convert ", file_name, " -trim ", file_name)) # trim ws on edges
system(paste0("convert ", file_name, " -shave 40x10 ", file_name)) # shave a few pixels more off the edges to get rid of leaflet UI

system(paste0("optipng ", file_name)) # lossless compression to get < 1Mb

print(paste("Week", wk, "complete!"))

# Leaderboards -----------------------------------------------------------------
# NOTE: These are set up to handle ties as well, can be adapted for the dashboard
ds_sum <- counties_grouped |>
  group_by(school) |>
  summarize(
    n_counties = sum(n_counties, na.rm = T),
    n_territories = n(),
    total_land = sum(sum_land, na.rm = T),
    total_water = sum(sum_water, na.rm = T),
    total_domain = sum(sum_total, na.rm = T),
    total_pop = sum(total_pop, na.rm = T)
  ) |>
  sf::st_drop_geometry()

# N counties
leader_counties <- paste0(
  "* **Counties Controlled:** ",
  ds_sum |>
    slice_max(n_counties, n = 1) |>
    pull(var = school) |>
    paste(collapse = ", "),
  " (",
  ds_sum |>
    slice_max(n_counties, n = 1) |>
    pull(var = n_counties) |>
    unique(),
  " counties)")

# N territories
leader_counties <- paste0(
  "* **FBS Stadiums Controlled:** ",
  ds_sum |>
    slice_max(n_territories, n = 1) |>
    pull(var = school) |>
    paste(collapse = ", "),
  " (",
  ds_sum |>
    slice_max(n_territories, n = 1) |>
    pull(var = n_territories) |>
    unique(),
  " territories)")

# land
leader_land <- paste0(
  "* **Land Area:** ",
  ds_sum |>
    slice_max(total_land, n = 1) |>
    pull(var = school) |>
    paste(collapse = ", "),
  " (",
  ds_sum |>
    slice_max(total_land, n = 1) |>
    pull(var = total_land) |>
    round(2) |>
    format(big.mark = ",") |>
    unique(),
  " sq. miles)")

# water
leader_water <- paste0(
  "* **Water Area:** ",
  ds_sum |>
    slice_max(total_water, n = 1) |>
    pull(var = school) |>
    paste(collapse = ", "),
  " (",
  ds_sum |>
    slice_max(total_water, n = 1) |>
    pull(var = total_water) |>
    round(2) |>
    format(big.mark = ",") |>
    unique(),
  " sq. miles)")

# domain
leader_domain <- paste0(
  "* **Total Domain:** ",
  ds_sum |>
    slice_max(total_domain, n = 1) |>
    pull(var = school) |>
    paste(collapse = ", "),
  " (",
  ds_sum |>
    slice_max(total_domain, n = 1) |>
    pull(var = total_domain) |>
    round(2) |>
    format(big.mark = ",") |>
    unique(),
  " sq. miles)")

# population
leader_pop <- paste0(
  "* **Total Population:** ",
  ds_sum |>
    slice_max(total_pop, n = 1) |>
    pull(var = school) |>
    paste(collapse = ", "),
  " (",
  ds_sum |>
    slice_max(total_pop, n = 1) |>
    pull(var = total_pop) |>
    round(2) |>
    format(big.mark = ",") |>
    unique(),
  " people)")

# official leaderboard
cat(paste(leader_counties, leader_land, leader_water, leader_domain, leader_pop, sep = "\n"))

toc()





