# Download HRSA OPO Service Area Boundaries

Downloads the publicly available HRSA GIS layer containing detailed
Organ Procurement Organization service area boundaries and returns it as
an `sf` object.

## Usage

``` r
get_hrsa_opo_service_areas(quiet = TRUE)
```

## Arguments

- quiet:

  Logical; if `TRUE`, suppresses messages and warnings emitted during
  download. Default is `TRUE`.

## Value

An `sf` object with polygon geometries representing detailed OPO service
area boundaries, along with HRSA-provided attributes. Human-readable
variable labels are attached.

## Details

The data are served directly from the HRSA ArcGIS REST MapServer and
include all attributes provided by HRSA at the time of download.

This function queries the HRSA ArcGIS REST MapServer layer:

<https://gisportal.hrsa.gov/server/rest/services/Organs/OrganProcurementAndTransplantation_FS/MapServer/3>

using a `where = 1 = 1` filter to retrieve all available features. No
caching is performed.

Layer 3 is the detailed polygon layer for Organ Procurement Organization
service areas. It is distinct from Layer 2, which is the generalized
county-based service-area layer.

## Note

The HRSA ArcGIS GeoJSON endpoint may not provide unique feature IDs.
When `quiet = TRUE`, GDAL warnings related to feature IDs are
suppressed.

## See also

[`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html),
[`labelled::var_label()`](https://larmarange.github.io/labelled/reference/var_label.html),
[`get_hrsa_transplant_centers()`](https://vagishhemmige.github.io/sRtr/reference/get_hrsa_transplant_centers.md)

## Examples

``` r
if (FALSE) { # \dontrun{
opo_areas <- get_hrsa_opo_service_areas()

# Inspect variable labels
labelled::var_label(opo_areas)

# Plot OPO service areas
plot(opo_areas["OPO_PROVIDER_NM"])
} # }
```
