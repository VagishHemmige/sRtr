test_that("get_hrsa_optn_regions() returns longitude/latitude by default", {
  skip_if_not_installed("sf")
  regions <- get_hrsa_optn_regions()

  expect_identical(sf::st_crs(regions), sf::st_crs(4326))
  expect_setequal(regions$Region, paste("Region", 1:11))
})

test_that("get_hrsa_optn_regions() returns the requested crs", {
  skip_if_not_installed("sf")
  regions <- get_hrsa_optn_regions(crs = 5070)

  expect_identical(sf::st_crs(regions), sf::st_crs(UNOS_regions_sf))
  expect_setequal(regions$Region, paste("Region", 1:11))
})

test_that("get_hrsa_optn_regions(crs = 5070) keeps each region's area", {
  skip_if_not_installed("sf")
  regions <- get_hrsa_optn_regions(crs = 5070, noncontiguous = "include")
  state_area <- as.numeric(sf::st_area(UNOS_regions_sf))
  expected <- tapply(state_area, UNOS_regions_sf$Region, sum)

  got <- as.numeric(sf::st_area(regions))
  names(got) <- regions$Region

  expect_equal(got[names(expected)], c(expected), tolerance = 1e-6)
})

test_that("get_hrsa_optn_regions() rejects an unusable crs", {
  skip_if_not_installed("sf")

  expect_snapshot(get_hrsa_optn_regions(crs = "not a crs"), error = TRUE)
  expect_error(
    get_hrsa_optn_regions(crs = "not a crs"),
    class = "sRtr_error_invalid_crs"
  )
  expect_error(
    get_hrsa_optn_regions(crs = NA),
    class = "sRtr_error_invalid_crs"
  )
})

test_that("UNOS_regions_sf places Alaska, Hawaii and Puerto Rico in their OPTN regions", {
  skip_if_not_installed("sf")
  region_of <- stats::setNames(UNOS_regions_sf$Region, UNOS_regions_sf$State)

  expect_identical(nrow(UNOS_regions_sf), 52L)
  expect_identical(
    unname(region_of[c("Alaska", "Hawaii", "Puerto Rico")]),
    c("Region 6", "Region 6", "Region 3")
  )
})

test_that("get_hrsa_optn_regions() leaves out Alaska, Hawaii and Puerto Rico by default", {
  skip_if_not_installed("sf")
  regions <- get_hrsa_optn_regions()
  states <- unlist(strsplit(regions$states_included, "; ", fixed = TRUE))
  noncontiguous <- c("Alaska", "Hawaii", "Puerto Rico")

  expect_setequal(states, setdiff(UNOS_regions_sf$State, noncontiguous))
  expect_setequal(regions$Region, paste("Region", 1:11))
})

test_that("get_hrsa_optn_regions(noncontiguous = 'include') keeps every state", {
  skip_if_not_installed("sf")
  regions <- get_hrsa_optn_regions(noncontiguous = "include")
  states <- unlist(strsplit(regions$states_included, "; ", fixed = TRUE))

  expect_setequal(states, UNOS_regions_sf$State)
  expect_identical(sf::st_crs(regions), sf::st_crs(4326))
})

test_that("get_hrsa_optn_regions(noncontiguous = 'shift') keeps every state, in Albers", {
  skip_if_not_installed("sf")
  regions <- get_hrsa_optn_regions(noncontiguous = "shift")
  states <- unlist(strsplit(regions$states_included, "; ", fixed = TRUE))

  expect_setequal(states, UNOS_regions_sf$State)
  expect_identical(sf::st_crs(regions), sf::st_crs(5070))
})

test_that("get_hrsa_optn_regions(noncontiguous = 'shift') refuses another crs", {
  skip_if_not_installed("sf")

  expect_snapshot(
    get_hrsa_optn_regions(crs = 4326, noncontiguous = "shift"),
    error = TRUE
  )
  expect_error(
    get_hrsa_optn_regions(crs = 4326, noncontiguous = "shift"),
    class = "sRtr_error_shift_crs"
  )
  expect_identical(
    sf::st_crs(get_hrsa_optn_regions(crs = 5070, noncontiguous = "shift")),
    sf::st_crs(5070)
  )
})

test_that("get_hrsa_optn_regions() rejects an unknown noncontiguous value", {
  skip_if_not_installed("sf")

  expect_error(
    get_hrsa_optn_regions(noncontiguous = "sideways"),
    class = "rlang_error"
  )
})
