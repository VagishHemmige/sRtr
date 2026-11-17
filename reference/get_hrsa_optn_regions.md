# Get OPTN/UNOS Region Boundaries

Returns OPTN/UNOS region boundaries from the package's internal
state-level UNOS region spatial dataset.

## Usage

``` r
get_hrsa_optn_regions(crs = 4326)
```

## Arguments

- crs:

  Coordinate reference system of the result: anything
  [`sf::st_crs()`](https://r-spatial.github.io/sf/reference/st_crs.html)
  accepts, such as an EPSG code. The default, `4326`
  (longitude/latitude), matches the layers that
  [`get_hrsa_transplant_centers()`](https://vagishhemmige.github.io/sRtr/reference/get_hrsa_transplant_centers.md)
  and
  [`get_hrsa_opo_service_areas()`](https://vagishhemmige.github.io/sRtr/reference/get_hrsa_opo_service_areas.md)
  download. `5070` keeps the NAD83 / Conus Albers equal-area projection
  of `UNOS_regions_sf`. The boundaries are generalized Census
  cartographic files, drawn for maps, so areas and distances computed
  from them are approximate; use detailed boundaries for measurement.

## Value

An `sf` object with one feature per OPTN/UNOS region, in `crs`.

## Details

This function uses the package's internal `UNOS_regions_sf` object,
which contains state-level geometries assigned to OPTN/UNOS regions. The
function dissolves those state-level geometries into one feature per
OPTN/UNOS region.

Unlike the HRSA ArcGIS `REGION_CD` and `REGION_NM` fields, which appear
to represent 10 HRSA/HHS administrative regions, this function returns
the 11 OPTN/UNOS regions.

The regions are dissolved in the projection of `UNOS_regions_sf` (NAD83
/ Conus Albers, EPSG:5070) and then transformed to `crs`.

## See also

[`sf::st_make_valid()`](https://r-spatial.github.io/sf/reference/valid.html),
[`dplyr::summarise()`](https://dplyr.tidyverse.org/reference/summarise.html),
[`get_hrsa_transplant_centers()`](https://vagishhemmige.github.io/sRtr/reference/get_hrsa_transplant_centers.md)

## Examples

``` r
if (FALSE) { # \dontrun{
regions <- get_hrsa_optn_regions()

regions
sf::st_crs(regions)
plot(regions["Region"])

# Keep the Albers projection of UNOS_regions_sf, as the bundled maps use
regions_albers <- get_hrsa_optn_regions(crs = 5070)
} # }
```
