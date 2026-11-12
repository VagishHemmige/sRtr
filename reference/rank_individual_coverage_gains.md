# Rank individual candidate areas by marginal coverage gain

`rank_individual_coverage_gains()` calculates the marginal coverage gain
from adding each candidate area to an existing coverage network one at a
time.

## Usage

``` r
rank_individual_coverage_gains(
  candidate_areas,
  existing_areas = NULL,
  population_geography,
  coverage_vars,
  geography_id = NULL,
  method = c("areal", "centroid", "intersection"),
  crs = 5070
)
```

## Arguments

- candidate_areas:

  An `sf` object containing candidate catchment geometries to evaluate
  one at a time.

- existing_areas:

  An `sf` object containing the existing catchment geometries, or `NULL`
  if there is no existing network.

- population_geography:

  An `sf` object containing the population or burden geography to
  summarize. This object should contain the columns named in
  `coverage_vars`.

- coverage_vars:

  Character vector of numeric column names in `population_geography` to
  summarize.

- geography_id:

  Optional character string naming an identifier column in
  `population_geography`. Passed to
  [`calculate_geography_coverage_gain()`](https://vagishhemmige.github.io/sRtr/reference/calculate_geography_coverage_gain.md).

- method:

  How a geography counts as covered: `"areal"` (default), `"centroid"`
  or `"intersection"`. See
  [`calculate_geography_coverage_gain()`](https://vagishhemmige.github.io/sRtr/reference/calculate_geography_coverage_gain.md).

- crs:

  Coordinate reference system for the spatial calculations. Defaults to
  EPSG:5070.

## Value

If `coverage_vars` has length 1, a tibble with one row per candidate
area. If `coverage_vars` has length greater than 1, a named list of
tibbles split by `coverage_var`. Each tibble includes the coverage
summaries returned by
[`calculate_geography_coverage_gain()`](https://vagishhemmige.github.io/sRtr/reference/calculate_geography_coverage_gain.md),
the non-geometry columns from `candidate_areas`, and a `rank` column
ordered by descending `newly_covered`.

## Details

This is a convenience wrapper around
[`calculate_geography_coverage_gain()`](https://vagishhemmige.github.io/sRtr/reference/calculate_geography_coverage_gain.md).
It is useful for ranking candidate catchment areas, such as buffers or
travel-time isochrones, by the population or burden newly covered after
accounting for overlap with an existing network.

The function assumes that `candidate_areas` and `existing_areas` already
contain the catchment geometries to evaluate. It does not create
buffers, travel-time isochrones, or other catchment areas internally.
