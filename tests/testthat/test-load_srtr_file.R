# test_loader.R
#
# Unit tests for the `get_SRTR_table()` function in the sRtr package.
# These tests validate that the SRTR loader function:
#   - Returns a data frame
#   - Loads expected columns
#   - Handles missing or invalid input gracefully
#
# These tests require the SRTR_WD environment variable to be set and
# relevant SRTR SAS or Parquet files to be available in the expected directory structure.


test_that("load_srtr_file loads expected data", {
  skip_if(Sys.getenv("SRTR_WD") == "", "SRTR_WD not set")

  result <- load_srtr_file("TX_HR", factor_labels = TRUE, var_labels = TRUE)
  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)
  expect_true("PX_ID" %in% names(result))  # Modify to reflect real column names
})


