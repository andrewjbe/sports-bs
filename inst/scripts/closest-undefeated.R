library(tidyverse)
library(leaflet)
library(lubridate)
library(cfbfastR)
library(sf)
library(data.table)
library(tictoc)
library(fontawesome)
library(tigris)
library(sf)

yr <- 2022
wk <- 16

dark_logo_list <- c("Oregon", "Nevada", "UCLA", "Kansas State", "Air Force", "Washington State", "California",
                    "Indiana", "Michigan State", "Rice", "Texas", "Clemson", "Duke", "Pittsburgh", "Alabama",
                    "BYU", "TCU")
alt_color_list <- c("Tennessee", "North Texas", "Temple", "LSU", "San Diego State", "UMass", "Iowa", 
                    "Northwestern", "Utah State", "UC Davis", "Montana", "Wisconsin", "NC State",
                    "Oklahoma", "Minnesota", "Kent State", "SMU", "Akron", "Tulsa", "Houston", "UCLA", "USC")

# DATA --------------------------------------------------
source('keys.R')
options(scipen=999)

tic()

# get ds_teams
ds_teams_ <- cfbfastR::cfbd_team_info(only_fbs = TRUE)

ds_teams <- ds_teams_ |>
  rename(
    logo_light = logo,
    logo_dark = logo_2
  ) |>
  mutate(
    conference = if_else(is.na(conference), "FCS", conference),
    logo_light = if_else(is.na(logo_light), "https://b.fssta.com/uploads/application/leagues/logos/NCAAFootball.vresize.350.350.medium.2.png", logo_light),
    logo_dark = if_else(is.na(logo_dark), "https://b.fssta.com/uploads/application/leagues/logos/NCAAFootball.vresize.350.350.medium.2.png", logo_dark)
  ) 

ds_fcs <- ds_teams |>
  filter(conference != "FCS") |>
  # Have to fix fucking illinois still
  mutate(
    latitude = if_else(school == "Illinois", 40.1020, latitude),
    longitude = if_else(school == "Illinois", -88.2272, longitude)
  ) 

ds_results <- cfbd_game_info(year = yr, season_type = "both") |>
  mutate(week = if_else(season_type == "postseason", max(week) + 1, as.numeric(week))) |>
  filter(week <= wk) |>
  filter(!is.na(home_points)) |>
  mutate(
    winner = if_else(home_points > away_points, home_team, away_team),
    loser = if_else(home_points < away_points, home_team, away_team)
  ) |>
  dplyr::select(winner, loser, week) |>
  distinct()

undefeated_list <- ds_teams |> 
  filter(!school %in% ds_results$loser) |>
  pull(var = school)

ds_undefeated <- ds_fcs |>
  filter(school %in% undefeated_list)

# see /scripts/app-sandbox.R
# counties <- readRDS("./data/counties-shifted.RDS")
# states <- readRDS("./data/states-shifted.RDS")
states <- states(cb = TRUE, resolution = "20m")
states_shifted <- shift_geometry(states, position = "outside") |>
  st_transform(crs = 4326) 

pops <- read_csv("./data/counties_pop.csv") |>
  filter(variable == "POP")
pnts_sf <- st_as_sf(ds_undefeated, coords = c("longitude", "latitude"))
st_crs(pnts_sf) <- 4326

counties <- counties(cb = TRUE, resolution = "20m") |>
  # counties <- tigris::block_groups(cb = TRUE) |>
  st_transform(crs = 4326) |>
  mutate(n = row_number())

counties_shifted <- shift_geometry(counties, position = "outside") |>
  st_transform(crs = 4326) 

closest_ <- list()
for (i in seq_len(nrow(counties))) {
  closest_[[i]] <- pnts_sf[which.min(
    sf::st_distance(pnts_sf, st_centroid(counties[i, ]))^2
  ), ]
  
  if(i %% 10 == 0){print(paste0(round(100 * i / nrow(counties), 2), "% completed..."))}
  
}
closest_ <- rbindlist(closest_)

closest_ <- closest_ |>
  dplyr::select(school) |>
  mutate(n = row_number())

counties_ <- left_join(counties, closest_, by = "n")
counties_pop <- read_csv("./data/counties_pop.csv")
counties_ <- left_join(counties_, counties_pop, by = "GEOID")

counties_ <- counties_ |>
  rename(population = estimate) %>%
  dplyr::select(!variable) |>
  shift_geometry(position = "outside") |>
  st_transform(crs = 4326) 

counties_grouped_ <- counties_ |>
  group_by(school) |>
  summarize(
    n_counties = n(),
    total_land = sum(ALAND, na.rm = T),
    total_water = sum(AWATER, na.rm = T),
    total_domain = total_land + total_water,
    total_pop = sum(population, na.rm = T) # placeholder
  ) |>
  st_cast("MULTIPOLYGON")

counties_grouped <- counties_grouped_ |>
  left_join(ds_teams, by = "school") |>
  mutate(
    logo_chosen = if_else(school %in% dark_logo_list, logo_dark, logo_light),
    color_chosen = if_else(school %in% alt_color_list, alt_color, color),
  ) 

toc()

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

# This is the actual map -------------------------------------------------------
logoIcons.os <- icons(
  iconUrl = counties_grouped$logo_chosen,
  iconWidth = (as.numeric(log(st_area(counties_grouped))) - 21) * 30,
  iconHeight = (as.numeric(log(st_area(counties_grouped))) - 21) * 30
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
             height = 2600, 
             width = 4000) |>
  setView(lng = -99.24580, lat = 41.085909, zoom = 5) |>
  addPolygons(data = counties_grouped, 
              smoothFactor = 0.2, 
              color = "white", 
              fillColor = ~fill_team(school), 
              fillOpacity = 0.9, 
              label = ~school, 
              weight = 0,
              stroke = F
  ) |>
  addMarkers(data = st_centroid(counties_grouped, of_largest_polygon = F), label = ~school, icon = logoIcons.os,
             popup = paste0("Test"
               # "<center><b>", counties_grouped$home_city, " Territory, home of the ", counties_grouped$home_mascot, "</b><br></center>",
               # "<center>Currently Controlled by ", counties_grouped$school, "<br></center>",
               # "<hr>",
               # "Territory Area: ", format(round(counties_grouped$sum_land, 1), nsmall = 1, big.mark = ","), " sq. miles<br>",
               # "Territory Water area: ", format(round(counties_grouped$sum_water, 1), nsmall = 1, big.mark = ","), " sq. miles<br>",
               # "No. of Counties in Territory: ", format(counties_grouped$n_counties, nsmall = 1, big.mark = ","), "<br>",
               # "Territory Population: ", format(counties_grouped$total_pop, big.mark = ",")
             )) |>
  addPolylines(data = counties_shifted, color = "grey", weight = 0.3, smoothFactor = 0, opacity = 1)  |>
  addPolylines(data = states_shifted, color = "grey", weight = 2, smoothFactor = 0, opacity = 1) 
  # addPolylines(data = counties_grouped, color = "grey", weight = 2, smoothFactor = 0, opacity = 1) # 
# addCircleMarkers(data = filter(ds_teams, classification %in% c("fcs", "fbs")), label = ~school, stroke = T, fillOpacity = 0.8, weight = 0.75, color = "black", fillColor = ~color, radius = 5,
#                popup = paste0("<center><img src=", ds_teams$logos, " width = '50' height = '50'>",
#                               "<br><hr><b>", ds_teams$school, "</center>",
#                               "</b><br>", ds_teams$conference,
#                               "<br>Mascot: ", ds_teams$mascot
#                ))

# m

# Saving image ------
file_name <- paste0(getwd(), "/map-image-generator-scripts/undefeated-maps/", yr, "/undefeated-map-", yr, "-week-", wk, ".png")

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
                  vwidth = 4000,
                  vheight = 2600)


# Adding label

img <- readPNG(file_name)
h <- as.numeric(dim(img)[1])
w <- as.numeric(dim(img)[2])

text_to_plot <- 
  tibble(x = 0.6,
         y = 0.85,
         text = paste0("CFB Closest Undefeated Map - ",  yr, " season, week ", wk)) 
# text = "CFB Imperialism Base Map")

final_img <- ggplot(data = text_to_plot) + 
  annotation_raster(img, xmin = 0, xmax = 1, ymin = 0, ymax = 1) +
  geom_text(aes(x = x, y = y, label = text), 
            size = 2000,
            family = "Open Sans Extrabold",
            fontface = "bold") +
  geom_image(aes(image = "www/cfb-imp-map-logo-named.png", x = 0.15, y = 0.55), size = 0.1, asp = 1.6) +
  xlim(0,1) +
  ylim(0,1) +
  ggthemes::theme_map() 

# final_img

ggsave(paste0(file_name), plot = final_img, device = "png", width = w, height = h, limitsize = FALSE, dpi = 1)
system(paste0("convert ", file_name, " -trim ", file_name)) # trim ws on edges
system(paste0("convert ", file_name, " -shave 120x100 ", file_name)) # shave a few pixels more off the edges to get rid of leaflet UI

system(paste0("optipng ", file_name)) # lossless compression to get < 1Mb

print(paste("Week", wk, "complete!"))

