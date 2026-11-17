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
  regions <- get_hrsa_optn_regions(crs = 5070)
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
