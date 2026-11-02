# Get OPTN/UNOS Region Boundaries

Returns OPTN/UNOS region boundaries from the package's internal
state-level UNOS region spatial dataset.

## Usage

``` r
get_hrsa_optn_regions()
```

## Value

An `sf` object with one feature per OPTN/UNOS region.

## Details

This function uses the package's internal `UNOS_regions_sf` object,
which contains state-level geometries assigned to OPTN/UNOS regions. The
function dissolves those state-level geometries into one feature per
OPTN/UNOS region.

Unlike the HRSA ArcGIS `REGION_CD` and `REGION_NM` fields, which appear
to represent 10 HRSA/HHS administrative regions, this function returns
the 11 OPTN/UNOS regions.

The returned object preserves the coordinate reference system of
`UNOS_regions_sf`, currently NAD83 / Conus Albers.

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
} # }
```
