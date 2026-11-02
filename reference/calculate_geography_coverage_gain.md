# Calculate net geographic coverage gain from adding new coverage areas to an existing coverage base

`calculate_geography_coverage_gain()` estimates the additional
population or burden covered by adding one group of catchment areas to
an already-existing group.

## Usage

``` r
calculate_geography_coverage_gain(
  existing_areas,
  added_areas,
  population_geography,
  coverage_vars,
  geography_id = NULL,
  method = c("areal", "centroid", "intersection"),
  crs = 5070,
  output = c("long", "wide")
)
```

## Arguments

- existing_areas:

  An `sf` object containing polygon geometries for the currently
  existing catchment areas.

- added_areas:

  An `sf` object containing polygon geometries for the catchment areas
  being added to the existing group.

- population_geography:

  An `sf` object containing the population or burden geography to
  summarize. This object should contain the columns named in
  `coverage_vars`.

- coverage_vars:

  Character vector of numeric column names in `population_geography` to
  summarize over the existing, added, newly covered, and combined
  catchment areas.

- geography_id:

  Optional character string naming an identifier column in
  `population_geography`. If supplied, this may be used to track which
  geographic units contribute to coverage estimates.

- method:

  Character string specifying how geographic coverage should be
  calculated. One of `"areal"`, `"centroid"`, or `"intersection"`.
  `"areal"` uses proportional area allocation for polygon geographies;
  `"centroid"` counts a geography if its centroid falls inside the
  catchment; and `"intersection"` counts a geography if it intersects
  the catchment.

- crs:

  Coordinate reference system to use for spatial calculations. Defaults
  to EPSG:5070, a projected CRS commonly used for national-scale
  analyses of the contiguous United States.

- output:

  Character string specifying the output format. One of `"long"` or
  `"wide"`.

## Value

A tibble summarizing baseline coverage, coverage from the added group,
newly covered population or burden, and post-addition coverage for each
variable in `coverage_vars`.

## Details

The function is used to calculate the total additional population or or
total sub-populations covered by a group of geographies in `added_areas`
not covered by the geographies in `existing areas`.

This function does not create buffers or travel-time isochrones. The
`existing_areas` and `added_areas` arguments should already contain the
catchment geometries to be compared.

The function accounts for overlap between centers and therefore does not
calculate the gain for each geography in the `existing_areas` object
individually.

This function is best used for analyses requiring repeated analysis in
order to avoid recreating geographic objects multiple times. For a
single calculation using transplant centers,
`calculate_centers_coverage_gain()` is typically more convenient as it
generates the geographic objects internally and only requires the
transplant centers, organ, year, and type of geography as input.

The main quantity of interest is the net newly covered population or
burden:

`newly_covered = coverage(added_areas union) - coverage(existing_areas union overlap)`

More precisely, the function compares the union of `added_areas` with
the union of `existing_areas` and summarizes the portion of the added
union that was not already covered. This avoids double-counting when
added geographies overlap with each other or with existing ones.

## Examples

``` r
if (FALSE) { # \dontrun{
calculate_geography_coverage_gain(
  existing_areas = existing_buffers,
  added_areas = added_buffers,
  population_geography = tract_data,
  coverage_vars = c("tract_cases", "tract_noncases", "total_population"),
  geography_id = "GEOID",
  method = "areal"
)
} # }
```
