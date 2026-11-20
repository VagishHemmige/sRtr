# Move Alaska, Hawaii and Puerto Rico below the contiguous United States

Rescales Alaska, Hawaii and Puerto Rico and places them below the
contiguous United States, so a national map shows all of them at a
readable size. Features elsewhere are only transformed to NAD83 / Conus
Albers (EPSG:5070).

## Usage

``` r
shift_noncontiguous(x)
```

## Arguments

- x:

  An `sf` or `sfc` object with a coordinate reference system.

## Value

`x` in EPSG:5070, with features in Alaska, Hawaii and Puerto Rico moved
and rescaled.

## Details

Each feature that falls in or within 100 km of Alaska, Hawaii or Puerto
Rico (as drawn in
[UNOS_regions_sf](https://vagishhemmige.github.io/sRtr/reference/UNOS_regions_sf.md))
is projected to a coordinate reference system suited to that area,
rescaled about the area's centroid and moved to a fixed position below
the contiguous states. Alaska is drawn at half size, Hawaii at 1.5 times
and Puerto Rico at 2.5 times. The same move applies to every layer, so
points (such as
[transplant_centers_sf](https://vagishhemmige.github.io/sRtr/reference/transplant_centers_sf.md)
or the layer from
[`get_hrsa_transplant_centers()`](https://vagishhemmige.github.io/sRtr/reference/get_hrsa_transplant_centers.md))
land in the right place on shifted polygons.

Shifted coordinates are positions on a map, not locations: use the
result for drawing only, never for spatial joins, distances or areas.
Shift state-level or point data before dissolving it into regions, since
a feature that spans both the contiguous states and one of these areas
is moved as a whole.

The layout follows the "below" layout of `tigris::shift_geometry()`,
which needs an internet connection; this function uses the boundaries
bundled with sRtr and works offline.

## See also

Guides:

- [National maps with Alaska, Hawaii and Puerto
  Rico](https://vagishhemmige.github.io/sRtr/articles/mapping.html#national-maps-with-alaska-hawaii-and-puerto-rico)

[`get_hrsa_optn_regions()`](https://vagishhemmige.github.io/sRtr/reference/get_hrsa_optn_regions.md)
with `noncontiguous = "shift"`.

## Examples

``` r
if (requireNamespace("sf", quietly = TRUE)) {
  shifted <- shift_noncontiguous(UNOS_regions_sf)
  plot(sf::st_geometry(shifted))
  plot(
    sf::st_geometry(shift_noncontiguous(transplant_centers_sf)),
    add = TRUE, pch = 16, cex = 0.4
  )
}

```
