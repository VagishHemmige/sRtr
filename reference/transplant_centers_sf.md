# U.S. Transplant Centers (sf), EPSG:5070

Point locations of U.S. transplant centers derived from a CSV of center
names, codes, and WGS84 coordinates, converted to an `sf` object and
projected to NAD83 / Conus Albers (EPSG:5070).

## Usage

``` r
transplant_centers_sf
```

## Format

An `sf` object with the following columns:

- OTCName:

  Transplant center name (character)

- OTCCode:

  Transplant center code (character)

- geometry:

  `sfc_POINT` in EPSG:5070

## Source

`data-raw/Transplant centers.csv`. Verify licensing/redistribution terms
for the source list of centers prior to public release.

## Details

Coordinates are consumed by
`sf::st_as_sf(coords = c("Longitude","Latitude"), crs = 4326)` and
stored in the `geometry` column; the original numeric longitude/latitude
columns are not retained.

## Examples

``` r
if (FALSE) { # \dontrun{
if (requireNamespace("sf", quietly = TRUE)) {
  plot(sf::st_geometry(transplant_centers_sf))

  # Tag each center with a UNOS region using a spatial join
  if (exists("UNOS_regions_sf")) {
    centers_with_region <- sf::st_join(
      transplant_centers_sf,
      UNOS_regions_sf %>% dplyr::group_by(Region) %>%
        dplyr::summarise(geometry = sf::st_union(geometry), .groups = "drop"),
      join = sf::st_within, left = TRUE
    )
    head(centers_with_region)
  }
}
} # }
```
