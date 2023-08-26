library(sf)
library(tigris)
library(cfbfastR)
library(dplyr)
library(purrr)

# Base map #1: FBS teams only ==================================================
ds_fbs <- cfbfastR::cfbd_team_info(only_fbs = TRUE) |>
  rename(
    logo_light = logo,
    logo_dark = logo_2
  ) |>
  mutate(
    logo_light = if_else(is.na(logo_light), "https://b.fssta.com/uploads/application/leagues/logos/NCAAFootball.vresize.350.350.medium.2.png", logo_light),
    logo_dark = if_else(is.na(logo_dark), "https://b.fssta.com/uploads/application/leagues/logos/NCAAFootball.vresize.350.350.medium.2.png", logo_dark)
  )

pnts_sf <- st_as_sf(ds_fbs, coords = c("longitude", "latitude"))
st_crs(pnts_sf) <- 4326

counties <- tigris::counties(cb = TRUE, resolution = "20m") |>
  # tigris::shift_geometry() |> # wait and do this later
  st_transform(crs = 4326) |>
  mutate(n = row_number())

# Assign each county to the closest school -------------------------------------
closest_list <- map(cli::cli_progress_along(seq_len(nrow(counties))), function(i){
  pnts_sf[which.min(
    sf::st_distance(pnts_sf, counties[i, ])^2
  ), ]
}) |>
  bind_rows() |>
  select(school) |>
  mutate(n = row_number()) |>
  st_drop_geometry()

# Creating final county-level dataset ------------------------------------------
county_pops <- readr::read_csv("./data/misc/counties_pop.csv") |>
  filter(variable == "POP") |>
  rename(population = estimate) |>
  select(!variable)

base_map_fbs_counties <- left_join(counties, closest_list) |>
  left_join(county_pops, by = "GEOID") |>
  tigris::shift_geometry(position = "below") |>
  # Manually adjusting some messed up looking territories
  mutate(
    school = case_when(
      GEOID == "35005" ~ "Texas Tech",
      GEOID == "32009" ~ "UNLV",
      GEOID == "06079" ~ "San José State",
      GEOID == "06009" ~ "Fresno State",
      GEOID == "26161" ~ "Michigan",
      TRUE ~ school
    )
  ) |>
  st_transform(crs = 4326)

# Creating grouped multipolygon (the actual base map) --------------------------
base_map_fbs_grouped <- base_map_fbs_counties |>
  group_by(school) |>
  summarise(
    n_counties = n(),
    sum_land = sum(ALAND) * 0.000000386102, # Convert sq meters to sq miles
    sum_water = sum(AWATER) * 0.000000386102,
    sum_total = sum_land + sum_water,
    total_pop = sum(population, na.rm = T)
  ) |>
  st_cast("MULTIPOLYGON")

# no alaska version
base_map_fbs_grouped_no_ak <- base_map_fbs_counties |>
  filter(STATEFP != "02",
         STATEFP != "72") |>
  group_by(school) |>
  summarise(
    n_counties = n(),
    sum_land = sum(ALAND) * 0.000000386102, # Convert sq meters to sq miles
    sum_water = sum(AWATER) * 0.000000386102,
    sum_total = sum_land + sum_water,
    total_pop = sum(population, na.rm = T)
  ) |>
  st_cast("MULTIPOLYGON")

# # Check in mapview:
# mapview::mapview(base_map_fbs_grouped,
#                  zcol = "school")

# Save to RDS ------------------------------------------------------------------
readr::write_rds(base_map_fbs_grouped, "./data/map-files/base_map_fbs_grouped.rds")
readr::write_rds(base_map_fbs_grouped_no_ak, "./data/map-files/base_map_fbs_grouped_no_ak.rds")

# Splitting Washington / Alaska so there are two logos -------------------------
# .shp versions:
sf::write_sf(base_map_fbs_grouped, "./data/map-files/base_map_fbs_grouped.shp")
sf::write_sf(base_map_fbs_grouped_no_ak, "./data/map-files/base_map_fbs_grouped_no_ak.shp")

sf::read_sf("./data/map-files/base_map_fbs_grouped_no_ak_wa_logo_fix.shp") |>
  readr::write_rds("./data/map-files/base_map_fbs_grouped_no_ak_wa_logo_fix.rds")

# Base map 2: All counties -----------------------------------------------------
states <- tigris::states()

counties_shifted <- counties |>
  tigris::shift_geometry(position = "below") |>
  st_transform(crs = 4326)

states_shifted <- states |>
  tigris::shift_geometry(position = "below") |>
  st_transform(crs = 4326)

readr::write_rds(counties_shifted, "./data/map-files/counties_shifted.rds")
readr::write_rds(states_shifted, "./data/map-files/states_shifted.rds")











