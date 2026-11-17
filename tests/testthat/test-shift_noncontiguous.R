noncontiguous_states <- function() {
  UNOS_regions_sf[UNOS_regions_sf$State %in% c("Alaska", "Hawaii", "Puerto Rico"), ]
}

test_that("shift_noncontiguous() returns EPSG:5070 and leaves the contiguous states in place", {
  skip_if_not_installed("sf")
  contiguous <- UNOS_regions_sf[
    !UNOS_regions_sf$State %in% c("Alaska", "Hawaii", "Puerto Rico"),
  ]

  shifted <- shift_noncontiguous(contiguous)

  expect_identical(sf::st_crs(shifted), sf::st_crs(5070))
  expect_equal(sf::st_geometry(shifted), sf::st_geometry(contiguous))
})

test_that("shift_noncontiguous() rescales each area by its stated factor", {
  skip_if_not_installed("sf")
  # Scale factors of the 'below' layout: Alaska 0.5, Hawaii 1.5, Puerto Rico 2.5.
  # Areas are compared in each area's own equal-area or local projection.
  areas <- noncontiguous_states()
  shifted <- shift_noncontiguous(areas)
  local_crs <- c(Alaska = "EPSG:3338", Hawaii = "ESRI:102007", `Puerto Rico` = "EPSG:32161")
  scale <- c(Alaska = 0.5, Hawaii = 1.5, `Puerto Rico` = 2.5)

  for (state in names(scale)) {
    before <- as.numeric(sf::st_area(sf::st_transform(areas[areas$State == state, ], local_crs[[state]])))
    after <- as.numeric(sf::st_area(shifted[shifted$State == state, ]))
    expect_equal(after / before, scale[[state]]^2, tolerance = 1e-6, label = state)
  }
})

test_that("shift_noncontiguous() places the areas below the contiguous states without overlap", {
  skip_if_not_installed("sf")
  shifted <- shift_noncontiguous(UNOS_regions_sf)
  is_moved <- shifted$State %in% c("Alaska", "Hawaii", "Puerto Rico")
  contiguous <- shifted[!is_moved, ]
  moved <- shifted[is_moved, ]

  expect_identical(sum(lengths(sf::st_intersects(moved, contiguous))), 0L)
  expect_lte(sf::st_bbox(moved)[["ymax"]], sf::st_bbox(contiguous)[["ymax"]])
})

test_that("shift_noncontiguous() moves points with the area they are in", {
  skip_if_not_installed("sf")
  outside <- c(Hawaii = "The Queen's Medical Center", `Puerto Rico` = "Auxilio Mutuo Hospital")
  centers <- transplant_centers_sf[transplant_centers_sf$OTCName %in% outside, ]
  areas <- shift_noncontiguous(noncontiguous_states())
  points <- shift_noncontiguous(centers)

  for (state in names(outside)) {
    point <- points[points$OTCName == outside[[state]], ]
    area <- areas[areas$State == state, ]
    expect_identical(lengths(sf::st_intersects(point, area)), 1L, label = state)
  }
})

test_that("shift_noncontiguous() needs a coordinate reference system", {
  skip_if_not_installed("sf")
  x <- sf::st_sf(id = 1, geometry = sf::st_sfc(sf::st_point(c(0, 0))))

  expect_snapshot(shift_noncontiguous(x), error = TRUE)
  expect_error(shift_noncontiguous(x), class = "sRtr_error_missing_crs")
})
