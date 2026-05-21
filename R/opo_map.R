#' Download HRSA OPO Service Area Boundaries
#'
#' Downloads the publicly available HRSA GIS layer containing detailed
#' Organ Procurement Organization service area boundaries and returns it
#' as an `sf` object.
#'
#' The data are served directly from the HRSA ArcGIS REST MapServer and
#' include all attributes provided by HRSA at the time of download.
#'
#' @details
#' This function queries the HRSA ArcGIS REST MapServer layer:
#'
#' \url{https://gisportal.hrsa.gov/server/rest/services/Organs/OrganProcurementAndTransplantation_FS/MapServer/3}
#'
#' using a `where = 1 = 1` filter to retrieve all available features.
#' No caching is performed.
#'
#' Layer 3 is the detailed polygon layer for Organ Procurement Organization
#' service areas. It is distinct from Layer 2, which is the generalized
#' county-based service-area layer.
#'
#' @note
#' The HRSA ArcGIS GeoJSON endpoint may not provide unique feature IDs.
#' When `quiet = TRUE`, GDAL warnings related to feature IDs are suppressed.
#'
#' @param quiet Logical; if `TRUE`, suppresses messages and warnings
#'   emitted during download. Default is `TRUE`.
#'
#' @return
#' An `sf` object with polygon geometries representing detailed OPO service
#' area boundaries, along with HRSA-provided attributes. Human-readable
#' variable labels are attached.
#'
#' @seealso
#' [sf::st_read()], [labelled::var_label()],
#' [get_hrsa_transplant_centers()]
#'
#' @examples
#' \dontrun{
#' opo_areas <- get_hrsa_opo_service_areas()
#'
#' # Inspect variable labels
#' labelled::var_label(opo_areas)
#'
#' # Plot OPO service areas
#' plot(opo_areas["OPO_PROVIDER_NM"])
#' }
#'
#' @export
get_hrsa_opo_service_areas <- function(quiet = TRUE) {

  url <- paste0(
    "https://gisportal.hrsa.gov/server/rest/services/",
    "Organs/OrganProcurementAndTransplantation_FS/",
    "MapServer/3/query?",
    "where=1%3D1&outFields=*&f=geojson"
  )

  # Read data (suppress warnings if quiet = TRUE)
  if (quiet) {
    opo_areas <- suppressWarnings(
      sf::st_read(dsn = url, quiet = TRUE)
    )
  } else {
    opo_areas <- sf::st_read(dsn = url, quiet = FALSE)
  }

  # Attach human-readable variable labels
  var_labels <- c(
    X                                = "Longitude",
    Y                                = "Latitude",
    OBJECTID                         = "HRSA Object ID",
    OPO_PROVIDER_ID                  = "OPO Provider ID",
    OPO_PROVIDER_NUM                 = "OPO Provider Number",
    OPO_PROVIDER_NM                  = "Organ Procurement Organization Name",
    OPO_ADDRESS                      = "OPO Address",
    OPO_CITY                         = "OPO City",
    OPO_STATE_ABBR                   = "OPO State Abbreviation",
    OPO_ZIP_CD                       = "OPO ZIP Code",
    OPO_PHONE_NUM                    = "OPO Phone Number",
    OPO_URL                          = "OPO Website",
    OPO_US_MEXICO_BORDER_100KM_IND   = "OPO Within 100km of US–Mexico Border Indicator",
    RURAL_IND                        = "Rural Indicator",
    DW_RECORD_CREATE_DT              = "Record Creation Date",
    DW_RECORD_CREATE_DT_TXT          = "Record Creation Date (Text)",
    DW_RECORD_UPDATE_DT              = "Record Update Date"
  )

  common_vars <- intersect(names(var_labels), names(opo_areas))

  suppressWarnings(
    labelled::var_label(opo_areas[common_vars]) <- as.list(var_labels[common_vars])
  )

  return(opo_areas)
}
