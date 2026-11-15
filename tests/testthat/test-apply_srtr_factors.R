# test_factors.R
#
# Tests for apply_srtr_factors() using real SRTR data.
# Requires:
# - SRTR_WD environment variable to be set
# - Valid SRTR files
# - sRtr::dictionary and sRtr::formats loaded

# ---- Test 1: Basic functionality with inferred file_key ----
test_that("apply_srtr_factors applies factor levels correctly", {
  skip_if_no_srtr_data()

  df <- load_srtr_file("TX_KI", factor_labels = FALSE)
  df_factored <- apply_srtr_factors(df)

  expect_true(any(sapply(df_factored, is.factor)))

  if ("SEX" %in% names(df_factored)) {
    expect_s3_class(df_factored$SEX, "factor")
    expect_true(
      "Female" %in%
        levels(df_factored$SEX) ||
        "Male" %in% levels(df_factored$SEX)
    )
  }
})

# ---- Test 2: Explicit file_key argument overrides attribute ----
test_that("apply_srtr_factors works with explicit file_key", {
  skip_if_no_srtr_data()

  df <- load_srtr_file("TX_KI", factor_labels = FALSE)
  attr(df, "file_key") <- NULL # Remove attribute to test explicit key

  df_factored <- apply_srtr_factors(df, file_key = "TX_KI")

  expect_true(any(sapply(df_factored, is.factor)))
})

# ---- Test 3: Works with other datasets ----
test_that("apply_srtr_factors works with TX_HR and CAND_KIPA", {
  skip_if_no_srtr_data()

  keys <- c("TX_HR", "CAND_KIPA")

  for (key in keys) {
    df <- load_srtr_file(key, factor_labels = FALSE)
    df_factored <- apply_srtr_factors(df)
    expect_true(
      any(sapply(df_factored, is.factor)),
      info = paste("No factors in", key)
    )
  }
})

# ---- Test 4: Verbose output shows expected messages ----
test_that("apply_srtr_factors outputs verbose messages", {
  skip_if_no_srtr_data()

  df <- load_srtr_file("TX_KI", factor_labels = FALSE)

  # Capture verbose output
  output <- capture.output(
    {
      df_factored <- apply_srtr_factors(df, verbose = TRUE)
    },
    type = "message"
  )

  expect_true(any(grepl("Labeled variable:", output)))
})

# ---- Offline tests: a tiny made-up table, no SAF needed ----

fake_tx_ki <- function() {
  tibble::tibble(CAN_ABO = c("A", "A2"), FAKE_COLUMN = c(1, 2))
}

test_that("coded columns become factors with labels from formats", {
  out <- apply_srtr_factors(fake_tx_ki(), file_key = "TX_KI")
  expect_s3_class(out$CAN_ABO, "factor")
  expect_equal(as.character(out$CAN_ABO), c("A: A", "A2: A2"))
  expect_equal(out$FAKE_COLUMN, c(1, 2))
})

test_that("verbose = FALSE is silent", {
  expect_no_message(apply_srtr_factors(fake_tx_ki(), file_key = "TX_KI"))
})

test_that("verbose = TRUE reports each labeled variable", {
  expect_message(
    apply_srtr_factors(fake_tx_ki(), file_key = "TX_KI", verbose = TRUE),
    class = "sRtr_message_variable_labeled"
  )
  expect_snapshot(
    out <- apply_srtr_factors(fake_tx_ki(), file_key = "TX_KI", verbose = TRUE)
  )
})

test_that("verbose = TRUE says where an inferred file_key came from", {
  df <- fake_tx_ki()
  attr(df, "file_key") <- "tx_ki"
  expect_snapshot(out <- apply_srtr_factors(df, verbose = TRUE))
})

test_that("verbose = TRUE says when nothing is converted", {
  df <- tibble::tibble(FAKE_COLUMN = 1)
  expect_message(
    apply_srtr_factors(df, file_key = "TX_KI", verbose = TRUE),
    class = "sRtr_message_nothing_to_label"
  )
})

test_that("the result carries the upper-case file_key", {
  out <- apply_srtr_factors(fake_tx_ki(), file_key = "tx_ki")
  expect_equal(attr(out, "file_key"), "TX_KI")
  expect_s3_class(out$CAN_ABO, "factor")
})

test_that("an unknown file_key warns and returns the data unchanged", {
  df <- fake_tx_ki()
  expect_warning(
    out <- apply_srtr_factors(df, file_key = "NOT_A_FILE"),
    class = "sRtr_warning_unknown_file_key"
  )
  expect_identical(out, df)
  expect_snapshot(out <- apply_srtr_factors(df, file_key = "NOT_A_FILE"))
})

test_that("a file_key that cannot be worked out warns", {
  expect_warning(
    out <- apply_srtr_factors(fake_tx_ki()),
    class = "sRtr_warning_file_key_not_inferred"
  )
  expect_equal(out$CAN_ABO, c("A", "A2"))
  expect_snapshot(out <- apply_srtr_factors(fake_tx_ki()))
})

test_that("a known file_key with no matching columns does not warn", {
  df <- tibble::tibble(FAKE_COLUMN = 1)
  expect_no_warning(out <- apply_srtr_factors(df, file_key = "TX_KI"))
  expect_equal(attr(out, "file_key"), "TX_KI")
})
