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

  Optional name of an identifier column in `population_geography`. If
  supplied, the result has a `covered_ids` attribute (see Value).

- method:

  How a geography counts as covered. One of:

  - `"areal"` (default): each geography contributes the share of its
    area inside the catchment. This assumes the counts are spread evenly
    over each geography.

  - `"centroid"`: a geography counts in full if its centroid lies inside
    the catchment (or on its edge), otherwise not at all.

  - `"intersection"`: a geography counts in full if any part of it, even
    only an edge, touches the catchment. This gives the largest
    estimates.

- crs:

  Coordinate reference system for the spatial calculations. All three
  geography inputs are transformed to it first. Defaults to EPSG:5070, a
  projected equal-area CRS for the contiguous United States. Use a
  projected CRS: areas and centroids are computed in it.

- output:

  `"long"` (default): one row per variable in `coverage_vars`. `"wide"`:
  one row, with columns named `<variable>_<measure>`, for example
  `area_cases_newly_covered`.

## Value

A tibble summarizing, for each variable in `coverage_vars`, the total,
baseline coverage (`existing_covered`), coverage from the added group
(`added_covered`), newly covered population or burden (`newly_covered`),
post-addition coverage (`combined_covered`), and each as a share of the
total (`pct_*`).

If `geography_id` is supplied, the attribute `covered_ids` is a list of
the IDs of geographies counted (in full or in part) in the `existing`,
`added` and `combined` areas, and the `newly` covered ones: those whose
covered share went up when `added_areas` were added.

## Details

The function is used to calculate the total additional population, or
total sub-populations, covered by a group of geographies in
`added_areas` not covered by the geographies in `existing areas`.

This function does not create buffers or travel-time isochrones. The
`existing_areas` and `added_areas` arguments should already contain the
catchment geometries to be compared.

The function accounts for overlap between centers and therefore does not
calculate the gain for each geography in the `existing_areas` object
individually.

This function is best used for analyses requiring repeated analysis in
order to avoid recreating geographic objects multiple times. To compare
candidate areas one at a time, see
[`rank_individual_coverage_gains()`](https://vagishhemmige.github.io/sRtr/reference/rank_individual_coverage_gains.md).

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
  coverage_vars = c("area_cases", "area_noncases"),
  geography_id = "geoid",
  method = "areal"
)

# One row, and the tract IDs behind each figure
gain <- calculate_geography_coverage_gain(
  existing_buffers, added_buffers, tract_data,
  coverage_vars = "area_cases",
  geography_id = "geoid",
  output = "wide"
)
attr(gain, "covered_ids")$newly
} # }
```
