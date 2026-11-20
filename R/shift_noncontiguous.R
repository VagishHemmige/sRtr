#' Move Alaska, Hawaii and Puerto Rico below the contiguous United States
#'
#' Rescales Alaska, Hawaii and Puerto Rico and places them below the
#' contiguous United States, so a national map shows all of them at a readable
#' size. Features elsewhere are only transformed to NAD83 / Conus Albers
#' (EPSG:5070).
#'
#' @seealso Guides:
#' * [National maps with Alaska, Hawaii and Puerto Rico](https://vagishhemmige.github.io/sRtr/articles/mapping.html#national-maps-with-alaska-hawaii-and-puerto-rico)
#' @details
#' Each feature that falls in or within 100 km of Alaska, Hawaii or Puerto
#' Rico (as drawn in [UNOS_regions_sf]) is projected to a coordinate reference
#' system suited to that area, rescaled about the area's centroid and moved to
#' a fixed position below the contiguous states. Alaska is drawn at half size,
#' Hawaii at 1.5 times and Puerto Rico at 2.5 times. The same move applies to
#' every layer, so points (such as [transplant_centers_sf] or the layer from
#' [get_hrsa_transplant_centers()]) land in the right place on shifted
#' polygons.
#'
#' Shifted coordinates are positions on a map, not locations: use the result
#' for drawing only, never for spatial joins, distances or areas. Shift
#' state-level or point data before dissolving it into regions, since a
#' feature that spans both the contiguous states and one of these areas is
#' moved as a whole.
#'
#' The layout follows the "below" layout of `tigris::shift_geometry()`, which
#' needs an internet connection; this function uses the boundaries bundled
#' with sRtr and works offline.
#'
#' @param x An `sf` or `sfc` object with a coordinate reference system.
#'
#' @return `x` in EPSG:5070, with features in Alaska, Hawaii and Puerto Rico
#'   moved and rescaled.
#'
#' @seealso [get_hrsa_optn_regions()] with `noncontiguous = "shift"`.
#'
#' @examples
#' if (requireNamespace("sf", quietly = TRUE)) {
#'   shifted <- shift_noncontiguous(UNOS_regions_sf)
#'   plot(sf::st_geometry(shifted))
#'   plot(
#'     sf::st_geometry(shift_noncontiguous(transplant_centers_sf)),
#'     add = TRUE, pch = 16, cex = 0.4
#'   )
#' }
#'
#' @export
shift_noncontiguous <- function(x) {
  if (is.na(sf::st_crs(x))) {
    srtr_abort(
      c(
        "{.arg x} has no coordinate reference system.",
        "i" = "Set one with {.fn sf::st_set_crs} so its locations can be placed."
      ),
      class = "missing_crs"
    )
  }

  albers <- sf::st_crs(5070)
  x <- sf::st_transform(x, albers)
  geometry <- sf::st_geometry(x)

  for (area in .srtr_shift_layout()) {
    hit <- lengths(sf::st_intersects(geometry, area$zone)) > 0
    if (!any(hit)) {
      next
    }
    moved <- sf::st_transform(geometry[hit], area$crs)
    sf::st_crs(moved) <- NA
    moved <- (moved - area$centroid) * area$scale + area$target
    geometry[hit] <- sf::st_set_crs(moved, albers)
  }

  if (inherits(x, "sf")) {
    sf::st_geometry(x) <- geometry
    return(x)
  }
  geometry
}

# For Alaska, Hawaii and Puerto Rico: the zone whose features are moved (the
# area buffered by 100 km, EPSG:5070), a local coordinate reference system,
# the area's centroid in it, the scale, and the target point in EPSG:5070.
# Layout ("below") and scales follow tigris::shift_geometry() (Kyle Walker,
# MIT licence), after Claus Wilke, Fundamentals of Data Visualization. Its
# offsets are fractions of the contiguous states' bounding box.
.srtr_shift_layout <- function() {
  states <- sRtr::UNOS_regions_sf
  layout <- list(
    Alaska = list(crs = "EPSG:3338", scale = 0.5, at = c(0.08, 0.07)),
    Hawaii = list(crs = "ESRI:102007", scale = 1.5, at = c(0.35, 0)),
    `Puerto Rico` = list(crs = "EPSG:32161", scale = 2.5, at = c(0.65, 0))
  )

  missing <- setdiff(names(layout), states$State)
  if (length(missing) > 0) {
    srtr_abort(
      "{.code UNOS_regions_sf} has no boundary for {.val {missing}}.",
      class = "shift_boundary_missing"
    )
  }

  box <- sf::st_bbox(states[!states$State %in% names(layout), ])
  size <- c(box[["xmax"]] - box[["xmin"]], box[["ymax"]] - box[["ymin"]])
  origin <- c(box[["xmin"]], box[["ymin"]])

  lapply(stats::setNames(names(layout), names(layout)), function(name) {
    spec <- layout[[name]]
    shape <- sf::st_union(sf::st_make_valid(states[states$State == name, ]))
    local <- sf::st_transform(shape, spec$crs)
    list(
      zone = sf::st_buffer(shape, 100000),
      crs = sf::st_crs(spec$crs),
      centroid = as.numeric(sf::st_coordinates(sf::st_centroid(local))),
      scale = spec$scale,
      target = origin + spec$at * size
    )
  })
}
