#' Download HRSA Organ Procurement & Transplantation Center Locations
#'
#' Downloads the publicly available HRSA GIS layer containing organ
#' procurement and transplant center locations and returns it as an
#' `sf` object.
#'
#' The data are served directly from the HRSA ArcGIS REST MapServer and
#' include all attributes provided by HRSA at the time of download.
#'
#' @details
#' This function queries the HRSA ArcGIS REST MapServer layer:
#'
#' \url{https://gisportal.hrsa.gov/server/rest/services/Organs/OrganProcurementAndTransplantation_FS/MapServer/1}
#'
#' using a `where = 1 = 1` filter to retrieve all available features.
#' No caching is performed.
#'
#' @note
#' The HRSA ArcGIS GeoJSON endpoint does not provide unique feature IDs.
#' When `quiet = TRUE`, GDAL warnings related to feature IDs are suppressed.
#'
#' @param quiet Logical; if `TRUE`, suppresses messages and warnings
#'   emitted during download. Default is `TRUE`.
#'
#' @return
#' An `sf` object with point geometries representing transplant centers
#' and organ procurement organizations, along with HRSA-provided
#' attributes. Human-readable variable labels are attached.
#'
#' @seealso
#' [sf::st_read()], [labelled::var_label()]
#'
#' @examples
#' \dontrun{
#' centers <- get_hrsa_transplant_centers()
#'
#' # Inspect variable labels
#' labelled::var_label(centers)
#'
#' # Plot by OPTN region
#' plot(centers["REGION_NM"])
#' }
#'
#' @export
get_hrsa_transplant_centers <- function(quiet = TRUE) {

  url <- paste0(
    "https://gisportal.hrsa.gov/server/rest/services/",
    "Organs/OrganProcurementAndTransplantation_FS/",
    "MapServer/1/query?",
    "where=1%3D1&outFields=*&f=geojson"
  )

  # Read data (suppress warnings if quiet = TRUE)
  if (quiet) {
    centers <- suppressWarnings(
      sf::st_read(dsn = url, quiet = TRUE)
    )
  } else {
    centers <- sf::st_read(dsn = url, quiet = FALSE)
  }

  # Attach human-readable variable labels
  var_labels <- c(
    X                           = "Longitude",
    Y                           = "Latitude",
    OBJECTID                    = "HRSA Object ID",
    OTC_PROVIDER_ID             = "Transplant Center Provider ID",
    OTC_CD                      = "Transplant Center Code",
    OTC_TYP                     = "Transplant Center Type",
    OTC_NM                      = "Transplant Center Name",
    OTC_ADDRESS                 = "Transplant Center Address",
    OTC_CITY                    = "Transplant Center City",
    OTC_ZIP_CD                  = "Transplant Center ZIP Code",
    OTC_PHONE_NUM               = "Transplant Center Phone Number",
    OTC_URL                     = "Transplant Center Website",
    OPO_PROVIDER_ID             = "OPO Provider ID",
    OPO_PROVIDER_NUM            = "OPO Provider Number",
    OPO_PROVIDER_NM             = "Organ Procurement Organization Name",
    OPO_ADDRESS                 = "OPO Address",
    OPO_CITY                    = "OPO City",
    OPO_STATE_ABBR              = "OPO State Abbreviation",
    OPO_STATE_NM                = "OPO State Name",
    OPO_ZIP_CD                  = "OPO ZIP Code",
    OPO_PHONE_NUM               = "OPO Phone Number",
    OPO_URL                     = "OPO Website",
    OTC_PROG_URL                = "Transplant Program Website",
    COUNTY_ID                   = "County Identifier",
    STATE_COUNTY_FIPS_CD        = "State–County FIPS Code",
    COUNTY_FIPS_CD              = "County FIPS Code",
    LIST_BOX_COUNTY_NM          = "County Name (List Box)",
    COUNTY_NM                   = "County Name",
    COUNTY_DESC                 = "County Description",
    REGION_CD                   = "OPTN Region Code",
    REGION_NM                   = "OPTN Region Name",
    STATE_FIPS_CD               = "State FIPS Code",
    STATE_NM                    = "State Name",
    STATE_ABBR                  = "State Abbreviation",
    STATE_IND                   = "State Indicator",
    US_MEXICO_BORDER_COUNTY_IND = "US–Mexico Border County Indicator",
    US_MEXICO_BORDER_100KM_IND  = "Within 100km of US–Mexico Border Indicator",
    DW_RECORD_CREATE_DT         = "Record Creation Date",
    DW_RECORD_CREATE_DT_TXT     = "Record Creation Date (Text)",
    Service_Lst                 = "Services List",
    CMN_REGION_CD               = "Common Region Code",
    CMN_REGION_NM               = "Common Region Name",
    CMN_STATE_NM                = "Common State Name",
    CMN_STATE_ABBR              = "Common State Abbreviation",
    CMN_STATE_FIPS_CD           = "Common State FIPS Code",
    CMN_STATE_COUNTY_FIPS_CD    = "Common State–County FIPS Code",
    CMN_COUNTY_NM_STATE_ABBR    = "County and State Abbreviation",
    LOC_NAME                    = "Location Name",
    SCORE                       = "Location Score",
    APPROX_VALUE_CD             = "Approximate Value Code",
    LOC_NAME_DESC               = "Location Name Description"
  )

  common_vars <- intersect(names(var_labels), names(centers))
  suppressWarnings(
  labelled::var_label(centers[common_vars]) <- as.list(var_labels[common_vars])
  )
  return(centers)
}
