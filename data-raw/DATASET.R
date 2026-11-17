## code to prepare national mapping data goes here
library(tidyverse)

#Import State level mapping data: 50 states, DC and Puerto Rico. Alaska and
#Hawaii are in Region 6 and Puerto Rico in Region 3, so all are kept.
us_states <- sf::read_sf("data-raw/cb_2018_us_state_20m/cb_2018_us_state_20m.shp") %>%
  dplyr::select(NAME, geometry) %>%
  dplyr::rename(State=NAME)

UNOS_regions <-
  #Import data from UNOS regions into R
  readxl::read_excel("data-raw/UNOS regions.xlsx")%>%
  #Split column that contains Regions and which states they contain
  tidyr::separate(Region, c("Region", "B"),sep=":") %>%
  #Split list of states into 7 separate variables
  tidyr::separate(B, c("State1","State2","State3","State4", "State5", "State6", "State7"), sep=",") %>%
  #Trim leading spaces
  dplyr::mutate_at(vars(contains("State")), str_trim) %>%
  #Change to long format and drop extraneous variable that results
  tidyr::pivot_longer(
    cols = starts_with("State"),
    names_to = "StateNumber",
    values_to = "State",
    values_drop_na = TRUE)%>%
  select(-StateNumber)

#Entries that match no state, such as "Northern Virginia" (part of a state),
#are dropped by the join below; say which, so a renamed state is not lost
unmatched <- setdiff(UNOS_regions$State, us_states$State)
if (length(unmatched) > 0) {
  warning(
    "UNOS regions.xlsx entries with no state boundary, left out: ",
    paste(unmatched, collapse = ", ")
  )
}

UNOS_regions_sf<-inner_join(UNOS_regions, us_states, by="State") %>%
  sf::st_as_sf()%>%
  sf::st_transform(5070)

transplant_centers_sf <- readr::read_csv("data-raw/Transplant centers.csv") %>%
  dplyr::distinct(OTCName, OTCCode, Latitude, Longitude)%>%
  sf::st_as_sf(coords = c("Longitude", "Latitude"),
               crs = 4326)%>%
  sf::st_transform(5070)

# save to data/ as external datasets
usethis::use_data(
  UNOS_regions_sf,
  transplant_centers_sf,
  overwrite = TRUE
)
