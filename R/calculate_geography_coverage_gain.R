#' Calculate net geographic coverage gain from adding new coverage areas to an existing coverage base
#'
#' `calculate_geography_coverage_gain()` estimates the additional population or burden
#' covered by adding one group of catchment areas to an already-existing group.
#'
#' The function is used to calculate the total additional population, or total sub-populations, covered by a group of
#' geographies in `added_areas` not covered by the geographies in `existing areas`.
#'
#' This function does not create buffers or travel-time isochrones. The
#' `existing_areas` and `added_areas` arguments should already contain the
#' catchment geometries to be compared.
#'
#' The function accounts for overlap between centers and therefore does not calculate the gain for each geography
#' in the `existing_areas` object individually.
#'
#' This function is best used for analyses requiring repeated analysis in order to avoid recreating geographic objects
#' multiple times. To compare candidate areas one at a time, see
#' [rank_individual_coverage_gains()].
#'
#' @param existing_areas An `sf` object containing polygon geometries for the
#'   currently existing catchment areas.
#' @param added_areas An `sf` object containing polygon geometries for the
#'   catchment areas being added to the existing group.
#' @param population_geography An `sf` object containing the population or burden
#'   geography to summarize. This object should contain the columns named in
#'   `coverage_vars`.
#' @param coverage_vars Character vector of numeric column names in
#'   `population_geography` to summarize over the existing, added, newly covered,
#'   and combined catchment areas.
#' @param geography_id Optional name of an identifier column in
#'   `population_geography`. If supplied, the result has a `covered_ids`
#'   attribute (see Value).
#' @param method How a geography counts as covered. One of:
#'   * `"areal"` (default): each geography contributes the share of its area
#'     inside the catchment. This assumes the counts are spread evenly over
#'     each geography.
#'   * `"centroid"`: a geography counts in full if its centroid lies inside
#'     the catchment (or on its edge), otherwise not at all.
#'   * `"intersection"`: a geography counts in full if any part of it, even
#'     only an edge, touches the catchment. This gives the largest estimates.
#' @param crs Coordinate reference system for the spatial calculations. All
#'   three geography inputs are transformed to it first. Defaults to
#'   EPSG:5070, a projected equal-area CRS for the contiguous United States.
#'   Use a projected CRS: areas and centroids are computed in it.
#' @param output `"long"` (default): one row per variable in `coverage_vars`.
#'   `"wide"`: one row, with columns named `<variable>_<measure>`, for example
#'   `area_cases_newly_covered`.
#'
#' @return A tibble summarizing, for each variable in `coverage_vars`, the
#'   total, baseline coverage (`existing_covered`), coverage from the added
#'   group (`added_covered`), newly covered population or burden
#'   (`newly_covered`), post-addition coverage (`combined_covered`), and each
#'   as a share of the total (`pct_*`).
#'
#'   If `geography_id` is supplied, the attribute `covered_ids` is a list of the
#'   IDs of geographies counted (in full or in part) in the `existing`, `added`
#'   and `combined` areas, and the `newly` covered ones: those whose covered
#'   share went up when `added_areas` were added.
#'
#' @details
#' The main quantity of interest is the net newly covered population or burden:
#'
#' `newly_covered = coverage(added_areas union) - coverage(existing_areas union overlap)`
#'
#' More precisely, the function compares the union of `added_areas` with the
#' union of `existing_areas` and summarizes the portion of the added union that
#' was not already covered. This avoids double-counting when added geographies
#' overlap with each other or with existing ones.
#'
#' @examples
#' \dontrun{
#' calculate_geography_coverage_gain(
#'   existing_areas = existing_buffers,
#'   added_areas = added_buffers,
#'   population_geography = tract_data,
#'   coverage_vars = c("area_cases", "area_noncases"),
#'   geography_id = "geoid",
#'   method = "areal"
#' )
#'
#' # One row, and the tract IDs behind each figure
#' gain <- calculate_geography_coverage_gain(
#'   existing_buffers, added_buffers, tract_data,
#'   coverage_vars = "area_cases",
#'   geography_id = "geoid",
#'   output = "wide"
#' )
#' attr(gain, "covered_ids")$newly
#' }
#'
#' @export
calculate_geography_coverage_gain <- function(
  existing_areas,
  added_areas,
  population_geography,
  coverage_vars,
  geography_id = NULL,
  method = c("areal", "centroid", "intersection"),
  crs = 5070,
  output = c("long", "wide")
) {
  method <- match.arg(method)
  output <- match.arg(output)

  if (
    !is.null(geography_id) && !geography_id %in% names(population_geography)
  ) {
    srtr_abort(
      "{.arg geography_id} column {.field {geography_id}} is not in {.arg population_geography}.",
      class = "missing_columns",
      missing = geography_id
    )
  }

  population_geography <- sf::st_transform(population_geography, crs)

  existing_united <- .union_or_empty(existing_areas, "Existing area", crs)
  added_united <- .union_or_empty(added_areas, "Added area", crs)
  combined_united <- .union_or_empty(
    dplyr::bind_rows(existing_united, added_united),
    "United area",
    crs
  )

  w_existing <- .coverage_weights(population_geography, existing_united, method)
  w_added <- .coverage_weights(population_geography, added_united, method)
  w_combined <- .coverage_weights(population_geography, combined_united, method)

  values <- sf::st_drop_geometry(population_geography)[coverage_vars]
  weighted_sum <- function(w) {
    vapply(
      coverage_vars,
      function(v) sum(values[[v]] * w, na.rm = TRUE),
      numeric(1)
    )
  }
  total <- weighted_sum(rep(1, nrow(values)))
  existing <- weighted_sum(w_existing)
  added <- weighted_sum(w_added)
  combined <- weighted_sum(w_combined)

  out <- tibble::tibble(
    coverage_var = coverage_vars,
    total = unname(total),
    existing_covered = unname(existing),
    added_covered = unname(added),
    newly_covered = unname(combined - existing),
    combined_covered = unname(combined)
  ) |>
    dplyr::mutate(
      pct_existing_covered = .data$existing_covered / .data$total,
      pct_added_covered = .data$added_covered / .data$total,
      pct_newly_covered = .data$newly_covered / .data$total,
      pct_combined_covered = .data$combined_covered / .data$total
    )

  if (output == "wide") {
    out <- out |>
      tidyr::pivot_wider(
        names_from = "coverage_var",
        values_from = -"coverage_var",
        names_glue = "{coverage_var}_{.value}",
        names_vary = "slowest"
      )
  }

  if (!is.null(geography_id)) {
    ids <- population_geography[[geography_id]]
    pick <- function(keep) unique(ids[keep])
    attr(out, "covered_ids") <- list(
      existing = pick(w_existing > 0),
      added = pick(w_added > 0),
      combined = pick(w_combined > 0),
      newly = pick(w_combined > w_existing)
    )
  }

  out
}


#' Clean catchment area input
#'
#' Internal helper: transforms `areas` to `crs` and dissolves them into one
#' feature. `NULL` or zero-row input gives an empty geometry.
#'
#' @noRd

.union_or_empty <- function(areas, label, crs) {
  if (is.null(areas) || nrow(areas) == 0) {
    return(
      sf::st_sf(
        catchment_area = label,
        geometry = sf::st_sfc(sf::st_geometrycollection(), crs = crs)
      )
    )
  }

  sf::st_sf(
    catchment_area = label,
    geometry = sf::st_union(sf::st_geometry(sf::st_transform(areas, crs)))
  )
}


#' Weight of each population unit inside a catchment
#'
#' Internal helper. Each population unit gets a weight between 0 and 1:
#' - "intersection": 1 if the unit touches the catchment at all;
#' - "centroid": 1 if the unit's centroid lies in (or on the edge of) the catchment;
#' - "areal": the share of the unit's area inside the catchment, which assumes
#'   the counts are spread evenly over each unit.
#'
#' @return Numeric vector, one value per row of `population`.
#' @noRd

.coverage_weights <- function(population, catchment, method) {
  n <- nrow(population)
  if (all(sf::st_is_empty(sf::st_geometry(catchment)))) {
    return(rep(0, n))
  }

  units <- sf::st_geometry(population)
  area <- sf::st_geometry(catchment)
  switch(
    method,
    intersection = as.numeric(lengths(sf::st_intersects(units, area)) > 0),
    centroid = as.numeric(
      lengths(sf::st_intersects(sf::st_centroid(units), area)) > 0
    ),
    areal = .area_share(units, area)
  )
}


#' Share of each unit's area that lies inside `area`
#'
#' Units with no area (points or lines) count in full if they touch `area`.
#'
#' @param units,area `sfc` geometries in the same projected CRS.
#' @return Numeric vector, one value per unit, between 0 and 1.
#' @noRd

.area_share <- function(units, area) {
  share <- rep(0, length(units))
  hits <- which(lengths(sf::st_intersects(units, area)) > 0)
  if (length(hits) == 0) {
    return(share)
  }

  unit_area <- as.numeric(sf::st_area(units[hits]))
  overlap <- sf::st_intersection(
    sf::st_sf(.unit = hits, geometry = units[hits], agr = "constant"),
    sf::st_sf(geometry = sf::st_union(area), agr = "constant")
  )
  overlap_area <- tapply(as.numeric(sf::st_area(overlap)), overlap$.unit, sum)
  covered <- overlap_area[as.character(hits)]
  covered[is.na(covered)] <- 0

  share[hits] <- ifelse(unit_area > 0, pmin(covered / unit_area, 1), 1)
  share
}
