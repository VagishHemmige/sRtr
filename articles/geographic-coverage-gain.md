# Calculating geographic coverage gain

## Introduction

Geography matters greatly in solid organ transplantation. Donor and
recipient practices vary greatly by region, and distance-related
barriers can magnify geographic disparities. In this article, we
demonstrate how the
[`calculate_geography_coverage_gain()`](https://vagishhemmige.github.io/sRtr/reference/calculate_geography_coverage_gain.md)
function can be used to estimate the number of people living with HIV
(PLWH) who gain access to heart transplant centers, defined as residence
within a 50-mile radius.

The code in this article downloads data from HRSA, CDC AtlasPlus, the
Census API and the Census Bureau’s TIGER/Line files, and needs a Census
API key in the `CENSUS_API_KEY` environment variable. It runs only when
that key is set, so the copy on the package website shows the code
without its output.

``` r

library(sRtr)
library(CDCAtlas)
library(tidyverse)
library(sf)
library(tidycensus)
library(tigris)
library(ggplot2)
```

## Create geography objects

We begin by using the
[`get_hrsa_transplant_centers()`](https://vagishhemmige.github.io/sRtr/reference/get_hrsa_transplant_centers.md)
function from the `sRtr` package to create an `sf` object containing
heart transplant centers not in PR or HI. We subsequently perform a
substantial amount of data cleaning

``` r


  Transplant_centers_all_sf<-sRtr::get_hrsa_transplant_centers()%>%
    filter(OPO_STATE_ABBR != "PR" & OPO_STATE_ABBR!= "HI")%>%
    select(OTC_NM, OTC_CD, Service_Lst, X, Y) %>%
    filter(str_detect(Service_Lst, str_to_sentence("Heart")))%>%
    select(-Service_Lst)%>%
    distinct()%>%
    rename(OTCName=OTC_NM, OTCCode=OTC_CD, Latitude=Y, Longitude=X)%>%
    st_transform(5070)  
```

We use the `tigris` package to import a map of states

``` r


state_geography <- tigris::states(
  year = 2022,
  cb = TRUE,
  class = "sf")%>%  
  filter(!STUSPS %in% c("AK", "HI", "PR", "GU", "VI", "MP", "AS")) %>%
  st_transform(5070)
```

We use ggplot to plot the centers on a map of the United States:

``` r


ggplot()+
  geom_sf(data=state_geography)+
  geom_sf(data = Transplant_centers_all_sf)+
  theme_minimal()
```

## Define existing centers and additional centers

For the purposes of this analysis, we assume baseline coverage with two
centers, *ALUA* (University of Alabama-Birmingham) and *NYMA*
(Montefiore Medical Center).

``` r


existing_centers<-Transplant_centers_all_sf%>%
  filter(OTCCode %in% c("ALUA", "NYMA"))

ggplot()+
  geom_sf(data=state_geography)+
  geom_sf(data = existing_centers, color="red")+
  theme_minimal()
```

We study the additional coverage for PLWH to add *NYCP*
(Columbia-Presbyterian) and *TXHI* (Texas Heart Institute at Baylor
St. Luke’s Medical Center in Houston, TX).

``` r


new_centers<-Transplant_centers_all_sf%>%
  filter(OTCCode %in% c("NYCP", "TXHI"))

ggplot()+
  geom_sf(data=state_geography)+
  geom_sf(data = new_centers, color="red")+
  theme_minimal()
```

We now create 50-mile buffers (80467.2 meters) around the transplant
centers in the previous objects

``` r

Transplant_centers_all_buffer<-st_buffer(Transplant_centers_all_sf,
                                        dist =80467.2)

existing_centers_buffer<-st_buffer(existing_centers,
                                   dist =80467.2)

ggplot()+
  geom_sf(data=state_geography)+
  geom_sf(data = existing_centers_buffer, color="blue")+
  geom_sf(data = existing_centers, color="red")+
  theme_minimal()


new_centers_buffer<-st_buffer(new_centers,
                              dist =80467.2)

ggplot()+
  geom_sf(data=state_geography)+
  geom_sf(data = new_centers_buffer, color="red")+
  geom_sf(data = new_centers, color="blue")+
  theme_minimal()


  
```

### Importing HIV data

We use the `CDCAtlas` package to estimate the number of PLWH in each
census tract. `get_atlas()` downloads county-level HIV data,
`impute_suppressed()` fills in suppressed county counts, and
`extrapolate_from_county()` shares each county’s count across its census
tracts in proportion to each tract’s American Community Survey (ACS)
population aged 13 and older. `extrapolate_from_county()` downloads ACS
estimates through the Census API, so it needs a Census API key in the
`CENSUS_API_KEY` environment variable. By default, cases CDC reports
with no county of residence are left out, with a message giving the
total; `no_county = "spread"` shares them across counties instead. We
then merge the estimates with tract geography obtained via the `tigris`
package.

``` r


hiv_tract_data <- CDCAtlas::get_atlas(
  disease = "hiv",
  geography = "county",
  year = 2022
) %>%
  CDCAtlas::impute_suppressed() %>%
  CDCAtlas::extrapolate_from_county(to = "tract") %>%
  filter(indicator == "HIV prevalence")

tract_geography <- tigris::tracts(
  year = 2022,
  cb = TRUE,
  class = "sf"
) %>%
  select(
    geoid = GEOID,
    geometry
  ) %>%
  st_transform(5070)

hiv_tract_sf <- tract_geography %>%
  left_join(
    hiv_tract_data,
    by = "geoid"
  )
```

## Estimating additional coverage gain

We finally use the `calculate_geography_coverage_gain` function to
estimate the number of PLWH who would gain geographic proximity to a
transplant center given the additional centers.

``` r


calculate_geography_coverage_gain(
    existing_areas=existing_centers_buffer,
    added_areas=new_centers_buffer,
    population_geography=hiv_tract_sf,
    coverage_vars=c("area_cases", "area_noncases"),
    geography_id = NULL,
    method = "intersection",
    crs = 5070,
    output = "wide"
)
```

We see that the additional two centers lead to an improvement in
coverage for PLWH from 142,598 PLWH to 177,917, a gain of 35,318. The
total number of PLWH in the `hiv_tract_sf` object is 1,099,805,
consistent with the number of PLWH with known status in the full
continental US.

We also see that for people without HIV, an additional 7.3 million
people gain geographical proximity with the added centers.

## Starting from a `NULL` base

The
[`calculate_geography_coverage_gain()`](https://vagishhemmige.github.io/sRtr/reference/calculate_geography_coverage_gain.md)
function can take a `NULL` input for `existing_areas`.

``` r



calculate_geography_coverage_gain(
    existing_areas=NULL,
    added_areas=new_centers_buffer,
    population_geography=hiv_tract_sf,
    coverage_vars=c("area_noncases", "area_cases"),
    geography_id = NULL,
    method = "intersection",
    crs = 5070,
    output = "wide"
)
```

## Ranking centers by incremental gain

The previous examples estimate the total population covered by a set of
candidate geographic areas. In some settings, however, the goal is to
compare candidate centers individually and ask which additional center
would add the greatest amount of new coverage beyond an existing
network.

Here, we evaluate each candidate transplant center not in the existing
network one at a time. Candidate centers are defined as transplant
centers that are not already included in the existing network. For each
candidate center, we create a 50-mile buffer and estimate the number of
additional people who would be covered if that center were added to the
existing network.

Here, we create the `candidate_centers_buffer` object and then pass it
to the
[`rank_individual_coverage_gains()`](https://vagishhemmige.github.io/sRtr/reference/rank_individual_coverage_gains.md)
function, a convenient wrapper which runs the
[`calculate_geography_coverage_gain()`](https://vagishhemmige.github.io/sRtr/reference/calculate_geography_coverage_gain.md)
function repeatedly to generate the output table.

``` r


candidate_centers_buffer <- Transplant_centers_all_sf %>%
  filter(!(OTCCode %in% c("ALUA", "NYMA")))%>%
  st_buffer(dist = 50 * 1609.344)

ranked_gains <- rank_individual_coverage_gains(
  candidate_areas = candidate_centers_buffer,
  existing_areas = existing_centers_buffer,
  population_geography = hiv_tract_sf,
  coverage_vars = c("area_cases", "area_noncases"),
  method = "intersection",
  crs = 5070
)
```

we examine the centers with the highest additional gain and lowest
additional gain.

``` r


ranked_gains$area_cases %>%
  select(OTCName, OTCCode, newly_covered) %>%
  head(10) %>%
  gt::gt() %>%
  gt::fmt_number(
    columns = newly_covered,
    decimals = 0
  ) %>%
  gt::cols_label(
    OTCName = "Center",
    OTCCode = "Code",
    newly_covered = "Newly covered HIV prevalent cases"
  )
```

The highest yield centers are in metropolitan areas with high numbers of
PLWH not served by the current network. The lowest yield are centers
that are in areas with low numbers of PLWH or centers with extensive
overlap with the existing centers in New York and Alabama.
