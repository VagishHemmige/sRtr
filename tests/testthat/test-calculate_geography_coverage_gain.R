# Synthetic geography only: a 2 x 2 grid of unit squares in EPSG:5070.
# Expected values are worked by hand for each method.
#
#   G3 (30) | G4 (40)        y 1..2
#   G1 (10) | G2 (20)        y 0..1
#   x 0..1    x 1..2

fake_grid <- function() {
  sq <- function(x0, y0) {
    sf::st_polygon(list(rbind(
      c(x0, y0), c(x0 + 1, y0), c(x0 + 1, y0 + 1), c(x0, y0 + 1), c(x0, y0)
    )))
  }
  sf::st_sf(
    geoid = c("G1", "G2", "G3", "G4"),
    area_cases = c(10, 20, 30, 40),
    geometry = sf::st_sfc(sq(0, 0), sq(1, 0), sq(0, 1), sq(1, 1), crs = 5070)
  )
}

fake_circles <- function(x, y, name) {
  sf::st_sf(
    name = name,
    geometry = sf::st_sfc(
      lapply(seq_along(x), function(i) sf::st_buffer(sf::st_point(c(x[i], y[i])), 0.6)),
      crs = 5070
    )
  )
}

test_that("calculate_geography_coverage_gain() runs without dplyr or sf attached", {
  skip_if_not_installed("sf")
  expect_false("package:sf" %in% search())
  expect_false("package:dplyr" %in% search())

  # Radius-0.6 circles reach the edges of neighbouring squares (distance 0.5)
  # but not diagonal corners (distance 0.71).
  # Existing (0.5, 0.5) touches G1, G2, G3 = 60.
  # candA (1.5, 0.5) touches G1, G2, G4; candB (1.5, 1.5) touches G2, G3, G4.
  existing <- fake_circles(0.5, 0.5, "existing")
  added <- fake_circles(c(1.5, 1.5), c(0.5, 1.5), c("candA", "candB"))

  out <- calculate_geography_coverage_gain(
    existing, added, fake_grid(), "area_cases",
    geography_id = "geoid", method = "intersection"
  )

  expect_equal(out$total, 100)
  expect_equal(out$existing_covered, 60)
  expect_equal(out$added_covered, 100)
  expect_equal(out$newly_covered, 40)
  expect_equal(out$combined_covered, 100)
})

test_that("rank_individual_coverage_gains() runs without dplyr or sf attached", {
  skip_if_not_installed("sf")
  existing <- fake_circles(0.5, 0.5, "existing")
  candidates <- fake_circles(c(1.5, 1.5), c(0.5, 1.5), c("candA", "candB"))

  out <- rank_individual_coverage_gains(
    candidates, existing, fake_grid(), "area_cases",
    geography_id = "geoid", method = "intersection"
  )

  # Each candidate adds only G4 (40) beyond the existing area.
  expect_setequal(out$name, c("candA", "candB"))
  expect_equal(out$added_covered[match(c("candA", "candB"), out$name)], c(70, 90))
  expect_equal(out$newly_covered, c(40, 40))
})

# Rectangles keep the areal shares easy to work by hand. Neither rectangle
# passes through a cell centroid or runs along a cell edge.
#   existing: x 0..1.4, y 0..0.6
#   added:    x 1.2..2, y 0..2
fake_rect <- function(xmin, xmax, ymin, ymax, name) {
  sf::st_sf(
    name = name,
    geometry = sf::st_sfc(
      sf::st_polygon(list(rbind(
        c(xmin, ymin), c(xmax, ymin), c(xmax, ymax), c(xmin, ymax), c(xmin, ymin)
      ))),
      crs = 5070
    )
  )
}
rect_existing <- function() fake_rect(0, 1.4, 0, 0.6, "existing")
rect_added <- function() fake_rect(1.2, 2, 0, 2, "added")

coverage <- function(method, ...) {
  calculate_geography_coverage_gain(
    rect_existing(), rect_added(), fake_grid(), "area_cases",
    geography_id = "geoid", method = method, ...
  )
}

test_that("method = 'intersection' counts every cell the catchment touches", {
  skip_if_not_installed("sf")
  out <- coverage("intersection")
  # existing touches G1, G2; added touches G2, G4; union touches G1, G2, G4.
  expect_equal(out$existing_covered, 30)
  expect_equal(out$added_covered, 60)
  expect_equal(out$combined_covered, 70)
  expect_equal(out$newly_covered, 40)
})

test_that("method = 'centroid' counts cells whose centroid lies inside", {
  skip_if_not_installed("sf")
  out <- coverage("centroid")
  # Centroids: G1 (0.5, 0.5) G2 (1.5, 0.5) G3 (0.5, 1.5) G4 (1.5, 1.5).
  # existing holds G1's; added holds G2's and G4's.
  expect_equal(out$existing_covered, 10)
  expect_equal(out$added_covered, 60)
  expect_equal(out$combined_covered, 70)
  expect_equal(out$newly_covered, 60)
})

test_that("method = 'areal' allocates each cell by its share of area covered", {
  skip_if_not_installed("sf")
  out <- coverage("areal")
  # existing: G1 0.6 of its area (6) + G2 0.4 x 0.6 = 0.24 (4.8)        = 10.8
  # added:    G2 0.8 (16) + G4 0.8 (32)                                  = 48
  # union:    G1 0.6 (6) + G2 0.8 + 0.2 x 0.6 = 0.92 (18.4) + G4 0.8 (32) = 56.4
  expect_equal(out$existing_covered, 10.8)
  expect_equal(out$added_covered, 48)
  expect_equal(out$combined_covered, 56.4)
  expect_equal(out$newly_covered, 45.6)
  expect_equal(out$total, 100)
})

test_that("an unknown method is an error, not a silent fallback", {
  skip_if_not_installed("sf")
  expect_error(coverage("centriod"), "should be one of")
})

test_that("catchments in another CRS are transformed to `crs` first", {
  skip_if_not_installed("sf")
  existing_4326 <- sf::st_transform(rect_existing(), 4326)
  out <- calculate_geography_coverage_gain(
    existing_4326, rect_added(), fake_grid(), "area_cases",
    geography_id = "geoid", method = "areal"
  )
  expect_equal(out$existing_covered, 10.8, tolerance = 1e-6)
})

test_that("the default method is areal for both functions", {
  skip_if_not_installed("sf")
  default <- calculate_geography_coverage_gain(
    rect_existing(), rect_added(), fake_grid(), "area_cases"
  )
  expect_equal(default$existing_covered, 10.8)

  ranked <- rank_individual_coverage_gains(
    rect_added(), rect_existing(), fake_grid(), "area_cases"
  )
  expect_equal(ranked$newly_covered, 45.6)
})

test_that("output = 'wide' gives one row with var_measure columns", {
  skip_if_not_installed("sf")
  grid <- fake_grid()
  grid$area_noncases <- grid$area_cases * 10

  long <- calculate_geography_coverage_gain(
    rect_existing(), rect_added(), grid, c("area_cases", "area_noncases"),
    method = "areal", output = "long"
  )
  wide <- calculate_geography_coverage_gain(
    rect_existing(), rect_added(), grid, c("area_cases", "area_noncases"),
    method = "areal", output = "wide"
  )

  expect_equal(nrow(long), 2)
  expect_equal(nrow(wide), 1)
  expect_false("coverage_var" %in% names(wide))
  expect_equal(wide$area_cases_newly_covered, 45.6)
  expect_equal(wide$area_noncases_newly_covered, 456)
  expect_equal(wide$area_noncases_pct_combined_covered, 0.564)
  expect_equal(ncol(wide), 2 * (ncol(long) - 1))
})

test_that("geography_id returns the IDs counted in each set", {
  skip_if_not_installed("sf")
  ids <- function(method) attr(coverage(method), "covered_ids")

  expect_equal(
    ids("intersection"),
    list(existing = c("G1", "G2"), added = c("G2", "G4"),
         combined = c("G1", "G2", "G4"), newly = "G4")
  )
  expect_equal(
    ids("centroid"),
    list(existing = "G1", added = c("G2", "G4"),
         combined = c("G1", "G2", "G4"), newly = c("G2", "G4"))
  )
  # Areal: "newly" is every unit whose covered share went up (G2 0.24 -> 0.92).
  expect_equal(
    ids("areal"),
    list(existing = c("G1", "G2"), added = c("G2", "G4"),
         combined = c("G1", "G2", "G4"), newly = c("G2", "G4"))
  )
})

test_that("no covered_ids attribute without geography_id; a missing column errors", {
  skip_if_not_installed("sf")
  out <- calculate_geography_coverage_gain(
    rect_existing(), rect_added(), fake_grid(), "area_cases"
  )
  expect_null(attr(out, "covered_ids"))
  expect_error(
    calculate_geography_coverage_gain(
      rect_existing(), rect_added(), fake_grid(), "area_cases",
      geography_id = "tract_id"
    ),
    "tract_id"
  )
})

test_that("areal treats point geographies as all-or-nothing, not NaN", {
  skip_if_not_installed("sf")
  points <- fake_grid()
  sf::st_geometry(points) <- sf::st_centroid(sf::st_geometry(points))
  out <- calculate_geography_coverage_gain(
    rect_existing(), rect_added(), points, "area_cases", method = "areal"
  )
  # Same as the centroid rule on the grid.
  expect_equal(out$existing_covered, 10)
  expect_equal(out$combined_covered, 70)
})
