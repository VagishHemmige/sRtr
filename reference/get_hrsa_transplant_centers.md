# Download HRSA Organ Procurement & Transplantation Center Locations

Downloads the publicly available HRSA GIS layer containing organ
procurement and transplant center locations and returns it as an `sf`
object.

## Usage

``` r
get_hrsa_transplant_centers(quiet = TRUE)
```

## Arguments

- quiet:

  Logical; if `TRUE`, suppresses messages and warnings emitted during
  download. Default is `TRUE`.

## Value

An `sf` object with point geometries representing transplant centers and
organ procurement organizations, along with HRSA-provided attributes.
Human-readable variable labels are attached.

## Details

The data are served directly from the HRSA ArcGIS REST MapServer and
include all attributes provided by HRSA at the time of download.

This function queries the HRSA ArcGIS REST MapServer layer:

<https://gisportal.hrsa.gov/server/rest/services/Organs/OrganProcurementAndTransplantation_FS/MapServer/1>

using a `where = 1 = 1` filter to retrieve all available features. No
caching is performed.

## Note

The HRSA ArcGIS GeoJSON endpoint does not provide unique feature IDs.
When `quiet = TRUE`, GDAL warnings related to feature IDs are
suppressed.

## See also

[`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html),
[`labelled::var_label()`](https://larmarange.github.io/labelled/reference/var_label.html)

## Examples

``` r
if (FALSE) { # \dontrun{
centers <- get_hrsa_transplant_centers()

# Inspect variable labels
labelled::var_label(centers)

# Plot by OPTN region
plot(centers["REGION_NM"])
} # }
```
