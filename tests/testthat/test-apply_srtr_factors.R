# test_factors.R
#
# Tests for apply_srtr_factors() using real SRTR data.
# Requires:
# - SRTR_WD environment variable to be set
# - Valid SRTR files
# - sRtr::dictionary and sRtr::formats loaded

# ---- Test 1: Basic functionality with inferred file_key ----
test_that("apply_srtr_factors applies factor levels correctly", {
  skip_if(Sys.getenv("SRTR_WD") == "", "SRTR_WD not set")

  df <- load_srtr_file("TX_KI", factor_labels = FALSE)
  df_factored <- apply_srtr_factors(df)

  expect_true(any(sapply(df_factored, is.factor)))

  if ("SEX" %in% names(df_factored)) {
    expect_s3_class(df_factored$SEX, "factor")
    expect_true("Female" %in% levels(df_factored$SEX) ||
                  "Male" %in% levels(df_factored$SEX))
  }
})

# ---- Test 2: Explicit file_key argument overrides attribute ----
test_that("apply_srtr_factors works with explicit file_key", {
  skip_if(Sys.getenv("SRTR_WD") == "", "SRTR_WD not set")

  df <- load_srtr_file("TX_KI", factor_labels = FALSE)
  attr(df, "file_key") <- NULL  # Remove attribute to test explicit key

  df_factored <- apply_srtr_factors(df, file_key = "TX_KI")

  expect_true(any(sapply(df_factored, is.factor)))
})

# ---- Test 3: Works with other datasets ----
test_that("apply_srtr_factors works with TX_HR and CAND_KIPA", {
  skip_if(Sys.getenv("SRTR_WD") == "", "SRTR_WD not set")

  keys <- c("TX_HR", "CAND_KIPA")

  for (key in keys) {
    df <- load_srtr_file(key, factor_labels = FALSE)
    df_factored <- apply_srtr_factors(df)
    expect_true(any(sapply(df_factored, is.factor)), info = paste("No factors in", key))
  }
})

# ---- Test 4: Verbose output shows expected messages ----
test_that("apply_srtr_factors outputs verbose messages", {
  skip_if(Sys.getenv("SRTR_WD") == "", "SRTR_WD not set")

  df <- load_srtr_file("TX_KI", factor_labels = FALSE)

  # Capture verbose output
  output <- capture.output({
    df_factored <- apply_srtr_factors(df, verbose = TRUE)
  }, type = "message")

  expect_true(any(grepl("Labeled variable:", output)))
})
