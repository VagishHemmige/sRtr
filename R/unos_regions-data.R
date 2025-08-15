#' UNOS Regions by State (sf), EPSG:5070
#'
#' Each row represents one U.S. state (contiguous U.S. plus the District of Columbia)
#' annotated with its UNOS region. Geometries are state polygons projected to
#' NAD83 / Conus Albers (EPSG:5070).
#'
#' The object is generated in \code{data-raw/} by joining a table of UNOS region
#' membership (state → region) to Census state boundaries and projecting once to
#' a CONUS-appropriate projected CRS. Note this is **state-level geometry**; to
#' obtain region polygons, dissolve by \code{Region} (see Examples).
#'
#' @format An \code{sf} object with one row per state and the following columns:
#' \describe{
#'   \item{Region}{UNOS region label (character)}
#'   \item{State}{State name as in the Census shapefile (character)}
#'   \item{geometry}{\code{sfc_MULTIPOLYGON} in EPSG:5070}
#' }
#'
#' @source
#' \itemize{
#'   \item U.S. Census Bureau Cartographic Boundary Files (2018), states (20m).
#'   \item UNOS region membership table from \code{data-raw/UNOS regions.xlsx}.
#' }
#'
#' @details
#' Alaska, Hawaii, and Puerto Rico are excluded to focus on CONUS + DC, matching
#' typical analytic maps and the chosen CRS. The original lat/long CRS of the
#' shapefile is transformed to EPSG:5070 for consistent area/length behavior.
#'
#' @examples
#' if (requireNamespace("sf", quietly = TRUE)) {
#'   # quick look
#'   plot(sf::st_geometry(UNOS_regions_sf))
#'
#'   # build dissolved region polygons if needed
#'   library(dplyr)
#'   unos_regions_poly <- UNOS_regions_sf %>%
#'     group_by(Region) %>%
#'     summarise(geometry = sf::st_union(geometry), .groups = "drop") %>%
#'     sf::st_make_valid()
#'   plot(sf::st_geometry(unos_regions_poly))
#' }
"UNOS_regions_sf"
