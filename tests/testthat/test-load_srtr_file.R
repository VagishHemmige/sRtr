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


test_that("load_srtr_file loads expected data and attaches metadata", {
  skip_if(Sys.getenv("SRTR_WD") == "", "SRTR_WD not set")

  result <- load_srtr_file("TX_HR", factor_labels = TRUE, var_labels = TRUE)

  # Check return type and content
  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)
  expect_true("PX_ID" %in% names(result))  # Adjust to match a known column

  # Check attached attributes
  expect_true(!is.null(attr(result, "source_path")))
  expect_true(!is.null(attr(result, "file_key")))
  expect_match(attr(result, "file_key"), "TX_HR", ignore.case = TRUE)
  expect_type(attr(result, "source_path"), "character")
  expect_true(file.exists(attr(result, "source_path")))
})
