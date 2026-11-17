#' Get OPTN/UNOS Region Boundaries
#'
#' Returns OPTN/UNOS region boundaries from the package's internal
#' state-level UNOS region spatial dataset.
#'
#' @details
#' This function uses the package's internal `UNOS_regions_sf` object, which
#' contains state-level geometries assigned to OPTN/UNOS regions. The function
#' dissolves those state-level geometries into one feature per OPTN/UNOS region.
#'
#' Unlike the HRSA ArcGIS `REGION_CD` and `REGION_NM` fields, which appear to
#' represent 10 HRSA/HHS administrative regions, this function returns the
#' 11 OPTN/UNOS regions.
#'
#' The regions are dissolved in the projection of `UNOS_regions_sf`
#' (NAD83 / Conus Albers, EPSG:5070) and then transformed to `crs`.
#'
#' @param crs Coordinate reference system of the result: anything
#'   [sf::st_crs()] accepts, such as an EPSG code. The default, `4326`
#'   (longitude/latitude), matches the layers that
#'   [get_hrsa_transplant_centers()] and [get_hrsa_opo_service_areas()]
#'   download. Use `5070` to keep the projection of `UNOS_regions_sf`, which
#'   suits area and distance calculations.
#'
#' @return
#' An `sf` object with one feature per OPTN/UNOS region, in `crs`.
#'
#' @seealso
#' [sf::st_make_valid()], [dplyr::summarise()],
#' [get_hrsa_transplant_centers()]
#'
#' @examples
#' \dontrun{
#' regions <- get_hrsa_optn_regions()
#'
#' regions
#' sf::st_crs(regions)
#' plot(regions["Region"])
#'
#' # Keep the projection of UNOS_regions_sf, for areas and distances
#' regions_albers <- get_hrsa_optn_regions(crs = 5070)
#' }
#'
#' @export
get_hrsa_optn_regions <- function(crs = 4326) {
  crs <- check_crs(crs)

  regions <- sRtr::UNOS_regions_sf |>
    sf::st_make_valid() |>
    dplyr::group_by(.data$Region) |>
    dplyr::summarise(
      n_state_features = dplyr::n(),
      states_included = paste(
        sort(unique(.data$State)),
        collapse = "; "
      ),
      .groups = "drop"
    ) |>
    sf::st_make_valid() |>
    sf::st_transform(crs)

  var_labels <- c(
    Region = "OPTN/UNOS Region",
    n_state_features = "Number of State-Level Features Included",
    states_included = "States Included in Region"
  )

  common_vars <- intersect(names(var_labels), names(regions))

  for (nm in common_vars) {
    labelled::var_label(regions[[nm]]) <- var_labels[[nm]]
  }

  regions
}

# Error unless `crs` is a coordinate reference system sf can use. Returns the
# `sf::st_crs()` object.
check_crs <- function(
  crs,
  arg = rlang::caller_arg(crs),
  call = rlang::caller_env()
) {
  parsed <- tryCatch(sf::st_crs(crs), error = function(e) NULL)
  if (!is.null(parsed) && !is.na(parsed)) {
    return(parsed)
  }
  srtr_abort(
    c(
      "{.arg {arg}} is not a coordinate reference system {.pkg sf} can use.",
      "i" = "Pass an EPSG code such as {.code 4326} or {.code 5070}, or anything {.fn sf::st_crs} accepts."
    ),
    class = "invalid_crs",
    call = call
  )
}
