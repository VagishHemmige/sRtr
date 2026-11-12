# Synthetic geography only: a 2 x 2 grid of unit squares in EPSG:5070.
# Expected values are worked by hand from the intersection rule.
# Only intersection is tested: `method` is currently ignored (see PR notes).

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
