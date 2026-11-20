#' Get OPTN/UNOS Region Boundaries
#'
#' Returns OPTN/UNOS region boundaries from the package's internal
#' state-level UNOS region spatial dataset.
#'
#' @seealso Guides:
#' * [Plotting UNOS/OPTN regions](https://vagishhemmige.github.io/sRtr/articles/mapping.html#plotting-unosoptn-regions)
#' * [National maps with Alaska, Hawaii and Puerto Rico](https://vagishhemmige.github.io/sRtr/articles/mapping.html#national-maps-with-alaska-hawaii-and-puerto-rico)
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
#' Region 6 includes Alaska and Hawaii, and Region 3 includes Puerto Rico.
#' Alaska has no transplant center, and on a national map these areas
#' stretch the extent far beyond the contiguous states, so by default they
#' are left out. `noncontiguous = "shift"` keeps them and moves them below the
#' contiguous states with [shift_noncontiguous()], for national maps of
#' residents or donors; `noncontiguous = "include"` keeps them at their real
#' locations, for spatial joins.
#'
#' The regions are built from whole states, but OPTN splits three: Northern
#' Virginia is in Region 2, eastern Vermont in Region 1 and southern Ohio in
#' Region 11. Here all of Virginia is in Region 11, all of Vermont in Region 9
#' and all of Ohio in Region 10.
#'
#' @param crs Coordinate reference system of the result: anything
#'   [sf::st_crs()] accepts, such as an EPSG code. The default, `4326`
#'   (longitude/latitude), matches the layers that
#'   [get_hrsa_transplant_centers()] and [get_hrsa_opo_service_areas()]
#'   download. `5070` keeps the NAD83 / Conus Albers equal-area projection of
#'   `UNOS_regions_sf`. The boundaries are generalized Census cartographic
#'   files, drawn for maps, so areas and distances computed from them are
#'   approximate; use detailed boundaries for measurement. With
#'   `noncontiguous = "shift"` the result is always in `5070`.
#' @param noncontiguous What to do with Alaska, Hawaii and Puerto Rico.
#'   `"exclude"` (the default) leaves them out, for maps of transplant
#'   centers. `"shift"` keeps them and moves them below the contiguous states
#'   for display; the moved coordinates are map positions, not locations.
#'   `"include"` keeps them at their real locations, as OPTN defines the
#'   regions. The default is a convention for center maps, not part of the
#'   OPTN definition.
#'
#' @return
#' An `sf` object with one feature per OPTN/UNOS region, in `crs` (EPSG:5070
#' with `noncontiguous = "shift"`).
#'
#' @seealso
#' [sf::st_make_valid()], [dplyr::summarise()],
#' [get_hrsa_transplant_centers()], [shift_noncontiguous()]
#'
#' @examples
#' \dontrun{
#' regions <- get_hrsa_optn_regions()
#'
#' regions
#' sf::st_crs(regions)
#' plot(regions["Region"])
#'
#' # Keep the Albers projection of UNOS_regions_sf, as the bundled maps use
#' regions_albers <- get_hrsa_optn_regions(crs = 5070)
#'
#' # All regions, with Alaska, Hawaii and Puerto Rico moved for a national map
#' regions_shifted <- get_hrsa_optn_regions(noncontiguous = "shift")
#' }
#'
#' @export
get_hrsa_optn_regions <- function(
  crs = 4326,
  noncontiguous = c("exclude", "shift", "include")
) {
  noncontiguous <- rlang::arg_match(noncontiguous)
  if (noncontiguous == "shift") {
    if (!missing(crs) && check_crs(crs) != sf::st_crs(5070)) {
      srtr_abort(
        c(
          "{.code noncontiguous = \"shift\"} returns map positions in EPSG:5070 only.",
          "i" = "Leave {.arg crs} out, or use {.code noncontiguous = \"include\"} for real locations in another coordinate reference system."
        ),
        class = "shift_crs"
      )
    }
    crs <- sf::st_crs(5070)
  } else {
    crs <- check_crs(crs)
  }

  states <- sRtr::UNOS_regions_sf
  if (noncontiguous == "exclude") {
    states <- states[!states$State %in% .srtr_noncontiguous, ]
  }
  if (noncontiguous == "shift") {
    # Shift states before dissolving: Region 6 joins Alaska and Hawaii to
    # contiguous states, and a feature is moved as a whole
    states <- shift_noncontiguous(states)
  }

  regions <- states |>
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

# States and territories outside the contiguous United States that
# UNOS_regions_sf places in a region (OPTN Regions 3 and 6).
.srtr_noncontiguous <- c("Alaska", "Hawaii", "Puerto Rico")

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
