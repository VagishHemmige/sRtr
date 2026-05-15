#' Rank individual candidate areas by marginal coverage gain
#'
#' `rank_individual_coverage_gains()` calculates the marginal coverage gain from
#' adding each candidate area to an existing coverage network one at a time.
#'
#' This is a convenience wrapper around [calculate_geography_coverage_gain()].
#' It is useful for ranking candidate catchment areas, such as buffers or
#' travel-time isochrones, by the population or burden newly covered after
#' accounting for overlap with an existing network.
#'
#' The function assumes that `candidate_areas` and `existing_areas` already
#' contain the catchment geometries to evaluate. It does not create buffers,
#' travel-time isochrones, or other catchment areas internally.
#'
#' @param candidate_areas An `sf` object containing candidate catchment
#'   geometries to evaluate one at a time.
#' @param existing_areas An `sf` object containing the existing catchment
#'   geometries, or `NULL` if there is no existing network.
#' @param population_geography An `sf` object containing the population or burden
#'   geography to summarize. This object should contain the columns named in
#'   `coverage_vars`.
#' @param coverage_vars Character vector of numeric column names in
#'   `population_geography` to summarize.
#' @param geography_id Optional character string naming an identifier column in
#'   `population_geography`. Passed to [calculate_geography_coverage_gain()].
#' @param method Character string specifying how geographic coverage should be
#'   calculated. One of `"intersection"`, `"centroid"`, or `"areal"`.
#' @param crs Coordinate reference system to use for spatial calculations.
#'   Defaults to EPSG:5070.
#'
#' @return If `coverage_vars` has length 1, a tibble with one row per candidate
#'   area. If `coverage_vars` has length greater than 1, a named list of tibbles
#'   split by `coverage_var`. Each tibble includes the coverage summaries returned
#'   by [calculate_geography_coverage_gain()], the non-geometry columns from
#'   `candidate_areas`, and a `rank` column ordered by descending
#'   `newly_covered`.
#'
#' @export

rank_individual_coverage_gains <- function(
    candidate_areas,
    existing_areas = NULL,
    population_geography,
    coverage_vars,
    geography_id = NULL,
    method = c("intersection", "centroid", "areal"),
    crs = 5070
) {
  method <- match.arg(method)

  candidate_areas <- candidate_areas %>%
    sf::st_transform(crs) %>%
    dplyr::mutate(.candidate_id = dplyr::row_number())

  population_geography <- population_geography %>%
    sf::st_transform(crs)

  if (!is.null(existing_areas)) {
    existing_areas <- existing_areas %>%
      sf::st_transform(crs)
  }

  results <- candidate_areas %>%
    dplyr::group_split(.candidate_id) %>%
    purrr::map_dfr(function(candidate_area) {

      candidate_metadata <- candidate_area %>%
        sf::st_drop_geometry() %>%
        dplyr::select(-.candidate_id)

      calculate_geography_coverage_gain(
        existing_areas = existing_areas,
        added_areas = candidate_area,
        population_geography = population_geography,
        coverage_vars = coverage_vars,
        geography_id = geography_id,
        method = method,
        crs = crs,
        output = "wide"
      ) %>%
        dplyr::bind_cols(candidate_metadata)
    }) %>%
    dplyr::group_by(coverage_var) %>%
    dplyr::arrange(dplyr::desc(newly_covered), .by_group = TRUE) %>%
    dplyr::mutate(rank = dplyr::row_number()) %>%
    dplyr::ungroup()

  if (length(coverage_vars) == 1) {
    results
  } else {
    split(results, results$coverage_var)
  }
}
