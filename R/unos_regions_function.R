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
#' The returned object preserves the coordinate reference system of
#' `UNOS_regions_sf`, currently NAD83 / Conus Albers.
#'
#' @return
#' An `sf` object with one feature per OPTN/UNOS region.
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
#' }
#'
#' @export
get_hrsa_optn_regions <- function() {

  regions <- UNOS_regions_sf |>
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
    sf::st_transform(4326)

  var_labels <- c(
    Region           = "OPTN/UNOS Region",
    n_state_features = "Number of State-Level Features Included",
    states_included  = "States Included in Region"
  )

  common_vars <- intersect(names(var_labels), names(regions))

  for (nm in common_vars) {
    labelled::var_label(regions[[nm]]) <- var_labels[[nm]]
  }

  regions
}
