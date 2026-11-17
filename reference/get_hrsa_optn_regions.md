# Get OPTN/UNOS Region Boundaries

Returns OPTN/UNOS region boundaries from the package's internal
state-level UNOS region spatial dataset.

## Usage

``` r
get_hrsa_optn_regions(
  crs = 4326,
  noncontiguous = c("exclude", "shift", "include")
)
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
  With `noncontiguous = "shift"` the result is always in `5070`.

- noncontiguous:

  What to do with Alaska, Hawaii and Puerto Rico. `"exclude"` (the
  default) leaves them out, for maps of transplant centers. `"shift"`
  keeps them and moves them below the contiguous states for display; the
  moved coordinates are map positions, not locations. `"include"` keeps
  them at their real locations, as OPTN defines the regions. The default
  is a convention for center maps, not part of the OPTN definition.

## Value

An `sf` object with one feature per OPTN/UNOS region, in `crs`
(EPSG:5070 with `noncontiguous = "shift"`).

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

Region 6 includes Alaska and Hawaii, and Region 3 includes Puerto Rico.
Alaska has no transplant center, and on a national map these areas
stretch the extent far beyond the contiguous states, so by default they
are left out. `noncontiguous = "shift"` keeps them and moves them below
the contiguous states with
[`shift_noncontiguous()`](https://vagishhemmige.github.io/sRtr/reference/shift_noncontiguous.md),
for national maps of residents or donors; `noncontiguous = "include"`
keeps them at their real locations, for spatial joins.

The regions are built from whole states, but OPTN splits three: Northern
Virginia is in Region 2, eastern Vermont in Region 1 and southern Ohio
in Region 11. Here all of Virginia is in Region 11, all of Vermont in
Region 9 and all of Ohio in Region 10.

## See also

[`sf::st_make_valid()`](https://r-spatial.github.io/sf/reference/valid.html),
[`dplyr::summarise()`](https://dplyr.tidyverse.org/reference/summarise.html),
[`get_hrsa_transplant_centers()`](https://vagishhemmige.github.io/sRtr/reference/get_hrsa_transplant_centers.md),
[`shift_noncontiguous()`](https://vagishhemmige.github.io/sRtr/reference/shift_noncontiguous.md)

## Examples

``` r
if (FALSE) { # \dontrun{
regions <- get_hrsa_optn_regions()

regions
sf::st_crs(regions)
plot(regions["Region"])

# Keep the Albers projection of UNOS_regions_sf, as the bundled maps use
regions_albers <- get_hrsa_optn_regions(crs = 5070)

# All regions, with Alaska, Hawaii and Puerto Rico moved for a national map
regions_shifted <- get_hrsa_optn_regions(noncontiguous = "shift")
} # }
```
