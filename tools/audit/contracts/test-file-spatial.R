testthat::test_that("uppercase SAS extensions remain discoverable", {
  dir <- withr::local_tempdir()
  withr::local_envvar(SRTR_WD = dir)
  x <- data.frame(FAKE_VALUE = 7)
  suppressWarnings(haven::write_sas(x, file.path(dir, "AUDIT.SAS7BDAT")))
  y <- load_srtr_file("AUDIT", factor_labels = FALSE, var_labels = FALSE)
  testthat::expect_equal(y$FAKE_VALUE, 7)
})

testthat::test_that("empty candidate sets return zero ranked rows", {
  pop <- synthetic_square()
  y <- rank_individual_coverage_gains(pop[0, ], NULL, pop, "count")
  testthat::expect_equal(nrow(y), 0L)
})

testthat::test_that("candidate coverage_var metadata does not break ranking", {
  pop <- synthetic_square()
  candidate <- pop
  candidate$coverage_var <- "SYNTHETIC METADATA"
  y <- rank_individual_coverage_gains(candidate, NULL, pop, "count")
  testthat::expect_equal(nrow(y), 1L)
})

testthat::test_that("candidate newly_covered metadata does not break ranking", {
  pop <- synthetic_square()
  candidate <- pop
  candidate$newly_covered <- "SYNTHETIC METADATA"
  y <- rank_individual_coverage_gains(candidate, NULL, pop, "count")
  testthat::expect_equal(nrow(y), 1L)
})

testthat::test_that("duplicate file keys require an explicit resolution", {
  dir <- withr::local_tempdir()
  withr::local_envvar(SRTR_WD = dir)
  x <- data.frame(FAKE_SOURCE = "SYNTHETIC SAS")
  suppressWarnings(haven::write_sas(x, file.path(dir, "AUDIT.sas7bdat")))
  x$FAKE_SOURCE <- "SYNTHETIC PARQUET"
  arrow::write_parquet(x, file.path(dir, "AUDIT.parquet"))
  result <- tryCatch(load_srtr_file("AUDIT", factor_labels = FALSE,
                                  var_labels = FALSE), error = identity)
  # Proposed acceptance contract: no silent selection between different files.
  # The future API/condition class is deliberately not prescribed here.
  testthat::expect_s3_class(result, "error")
})
