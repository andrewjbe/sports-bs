library(tidyverse)
library(leaflet)
library(lubridate)
library(cfbfastR)
library(sf)
library(data.table)
library(tictoc)
library(fontawesome)

yr <- 2022
wk <- 14

wk_actual <- wk + 1 # week 0 is in as week 1 for some reason

remove_logos_list <- as.list("Mississippi State") # c("Alabama")

# DATA --------------------------------------------------
source('keys.R')
options(scipen=999)

tic()

# see /scripts/app-sandbox.R
counties <- readRDS("./data/counties-shifted.RDS")
states <- readRDS("./data/states-shifted.RDS")
pops <- read_csv("./data/counties_pop.csv") |>
  filter(variable == "POP")

# base_map <- readRDS("base-map-shifted-block-groups.RDS")
base_map_ <- readRDS("./data/base-map-shifted.RDS")

# team information dataframe, sans FCS teams
ds_teams_ <- cfbfastR::cfbd_team_info(only_fbs = T)

ds_teams <- ds_teams_ |>
  # unnest_wider(col = logos, names_sep = ",") |>
  rename(
    logo_light = logo,
    logo_dark = logo_2
  ) |>
  mutate(
    conference = if_else(is.na(conference), "FCS", conference),
    # default backup logo
    logo_light = if_else(is.na(logo_light), "https://b.fssta.com/uploads/application/leagues/logos/NCAAFootball.vresize.350.350.medium.2.png", logo_light),
    logo_dark = if_else(is.na(logo_dark), "https://b.fssta.com/uploads/application/leagues/logos/NCAAFootball.vresize.350.350.medium.2.png", logo_dark),
    latitude = if_else(school == "Hawai'i", 29.3, latitude),
    longitude = if_else(school == "Hawai'i", -123.23, longitude)
  )

# API Rankings
ds_rankings_all <- cfbfastR::cfbd_rankings(year = yr, season_type = "regular")

ds_rankings <- ds_rankings_all |>
  filter(
    poll == "AP Top 25",
    week == wk_actual
  )

# Manual rankings
# ds_rankings <- read_csv("./data/manual-ap-rankings.csv")

ds_teams <- left_join(ds_teams, ds_rankings) |>
  filter(!is.na(points))

pnts_sf <- st_as_sf(ds_teams, coords = c("longitude", "latitude"))
st_crs(pnts_sf) <- 4326

counties <- counties |>
  mutate(
    n = row_number(),
    # Convert units
    ALAND = ALAND * 0.000000386102,
    AWATER = AWATER * 0.000000386102
    ) |>
  left_join(pops, by = "GEOID") |>
  rename(population = estimate)

if(nrow(ds_rankings) == 0) {
  stop("That week's AP Poll isn't out yet you fuckin moron")
}

# Processing loop
closest_list <- list()
for (i in seq_len(nrow(counties))) {
  closest_list[[i]] <- pnts_sf[which.max(
    (ds_teams$points) * (1 / sf::st_distance(pnts_sf, counties[i, ]))
  ), ]
  print(paste0(round(100 * i / nrow(counties), 2), "%"))
}
closest_list <- rbindlist(closest_list)

closest_list <- closest_list |>
  select(school) |>
  mutate(n = row_number())


dark_logo_list <- c("Oregon", "Nevada", "UCLA", "Kansas State", "Air Force", "Washington State", "California",
                    "Indiana", "Michigan State", "Rice", "Texas", "Clemson", "Duke", "Pittsburgh", "Alabama",
                    "BYU", "TCU")
alt_color_list <- c("Tennessee", "North Texas", "Temple", "LSU", "San Diego State", "UMass", "Iowa", 
                    "Northwestern", "Utah State", "UC Davis", "Montana", "Wisconsin", "NC State",
                    "Oklahoma", "Minnesota", "Kent State", "SMU", "Akron", "Tulsa", "Houston", "UCLA", "USC")

counties <- left_join(counties, closest_list, by = "n") |>
  left_join(ds_teams, by = "school") |>
  mutate(
    logo_chosen = if_else(school %in% dark_logo_list, logo_dark, logo_light),
    color_chosen = if_else(school %in% alt_color_list, alt_color, color),
  )

counties_grouped_ <- counties |>
  group_by(school) |>
  summarize(
    n_counties = n(),
    total_land = sum(ALAND, na.rm = T),
    total_water = sum(AWATER, na.rm = T),
    total_domain = total_land + total_water,
    total_pop = sum(population, na.rm = T) # placeholder
  ) |>
  st_cast("MULTIPOLYGON") 


# remove_logos_list <- c("", "USC")

counties_grouped <- counties_grouped_ |>
  left_join(select(ds_teams, school, mascot, abbreviation, conference, division,
                   color, alt_color, logo_light, logo_dark, venue_name,
                   city, state, zip, capacity, year_constructed, grass, dome), by = "school") |>
  mutate(
    logo_chosen = if_else(school %in% dark_logo_list, logo_dark, logo_light),
    color_chosen = if_else(school %in% alt_color_list, alt_color, color)
  ) |>
  # hand remove pngs from the map
  mutate(
    logo_chosen = ifelse(school %in% remove_logos_list, "https://i.stack.imgur.com/Vkq2a.png", logo_chosen)
  )

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
library(mapview)

logoIcons <- icons(
  iconUrl = counties_grouped$logo_chosen,
  iconWidth = (as.numeric(log(st_area(counties_grouped))) - 21) * 24,
  iconHeight = (as.numeric(log(st_area(counties_grouped))) - 21) * 24
)

# Reprojection

epsg2163 <- leafletCRS(
  crsClass = "L.Proj.CRS",
  code = "ESRI:102003",
  proj4def = "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs",
  resolutions = 2^(16:7)
)

# function to apply the correct colors to each territory 
fill_team <- colorFactor(counties_grouped$color_chosen, counties_grouped$school, na.color = "grey", ordered = TRUE)

m <- leaflet(options = leafletOptions(crs = epsg2163),
             height = 2000, 
             width = 3200) |>
  setView(lng = -98.24580, lat = 38.85909, zoom = 5) |>
  addPolygons(data = counties_grouped, 
              smoothFactor = 0.2, 
              color = "white", 
              fillColor = ~fill_team(school), 
              fillOpacity = 0.9, 
              label = ~school, 
              weight = 0,
              stroke = F
  ) |>
  addMarkers(data = st_centroid(counties_grouped, of_largest_polygon = T), label = ~school, icon = logoIcons,
             popup = paste0(
               "<center><b>", counties_grouped$city, " Territory, home of the ", counties_grouped$mascot, "</b><br></center>",
               "<center>Currently Controlled by ", counties_grouped$school, "<br></center>",
               "<hr>",
               "Territory Area: ", format(round(counties_grouped$total_land, 1), nsmall = 1, big.mark = ","), " sq. miles<br>",
               "Territory Water area: ", format(round(counties_grouped$total_water, 1), nsmall = 1, big.mark = ","), " sq. miles<br>",
               "No. of Counties in Territory: ", format(counties_grouped$n_counties, nsmall = 1, big.mark = ","), "<br>",
               "Territory Population: ", format(counties_grouped$total_pop, big.mark = ",")
             )
             ) |> 
  addPolylines(data = counties, color = "black", weight = 0.2, smoothFactor = 0, opacity = 1)  |>
  addPolylines(data = counties_grouped, color = "black", weight = 1.5, smoothFactor = 0, opacity = 1)  

file_name <- paste0(getwd(), "/map-image-generator-scripts/pp-maps/", yr, "/pp-map-", yr, "-week-", wk, ".png")

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
         text = paste0("CFB Power Projection Map - ",  yr, " season, week ", wk)) 

final_img <- ggplot(data = text_to_plot) + 
  annotation_raster(img, xmin = 0, xmax = 1, ymin = 0, ymax = 1) +
  geom_text(aes(x = x, y = y, label = text), 
            size = 1800,
            family = "Open Sans Extrabold",
            fontface = "bold") +
  geom_image(aes(image = "www/cfb-imp-map-logo-named.png", x = 0.09, y = 0.87), size = 0.085, asp = 1.6) +
  xlim(0,1) +
  ylim(0,1) +
  ggthemes::theme_map() 

# final_img

ggsave(paste0(file_name), plot = final_img, device = "png", width = w, height = h, limitsize = FALSE, dpi = 1)
system(paste0("convert ", file_name, " -trim ", file_name))
system(paste0("convert ", file_name, " -shave 40x10 ", file_name)) # shave a few pixels more off the edges to get rid of leaflet UI

# system(paste0("optipng ", file_name)) # lossless compression to get < 1Mb

print(paste("Week", wk, "complete!"))

# Leaderboards -----------------------------------------------------------------
# N counties
leader_counties <- paste0(
  "> * **Counties Controlled:** ",
counties_grouped |>
  slice_max(n_counties, n = 1) |>
  pull(var = school) |>
  paste(collapse = ", "),
" (",
counties_grouped |>
  slice_max(n_counties, n = 1) |>
  pull(var = n_counties),
" counties)")

# land
leader_land <- paste0(
  "* **Land Area:** ",
  counties_grouped |>
    slice_max(total_land, n = 1) |>
    pull(var = school),
  " (",
  counties_grouped |>
    slice_max(total_land, n = 1) |>
    pull(var = total_land) |>
    round(2) |>
    format(big.mark = ","),
  " sq. miles)")

# water
leader_water <- paste0(
  "* **Water Area:** ",
  counties_grouped |>
    slice_max(total_water, n = 1) |>
    pull(var = school),
  " (",
  counties_grouped |>
    slice_max(total_water, n = 1) |>
    pull(var = total_water) |>
    round(2) |>
    format(big.mark = ","),
  " sq. miles)")

# domain
leader_domain <- paste0(
  "* **Total Domain:** ",
    counties_grouped |>
    slice_max(total_domain, n = 1) |>
    pull(var = school),
  " (",
  counties_grouped |>
    slice_max(total_domain, n = 1) |>
    pull(var = total_domain) |>
    round(2) |>
    format(big.mark = ","),
  " sq. miles)")

# population
leader_pop <- paste0(
  "* **Total Population:** ",
  counties_grouped |>
    slice_max(total_pop, n = 1) |>
    pull(var = school),
  " (",
  counties_grouped |>
    slice_max(total_pop, n = 1) |>
    pull(var = total_pop) |>
    round(2) |>
    format(big.mark = ","),
  " people)")

# official leaderboard
cat(paste(leader_counties, leader_land, leader_water, leader_domain, leader_pop, sep = "\n"))

toc()



