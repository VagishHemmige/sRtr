test_that("srtr_normalize_missing replaces expected values", {
  skip_if_no_srtr_data()
  # Load real data
  df <- load_srtr_file("TX_LI", factor_labels = TRUE, var_labels = FALSE)

  # Check column presence
  expect_true("REC_HIV_STAT" %in% names(df))
  expect_true("REC_HCV_STAT" %in% names(df))

  # Sanity check: missing codes exist before normalization
  pre_vals <- unique(as.character(df$REC_HIV_STAT))
  expect_true(any(pre_vals %in% c("U", "", "ND")))

  # Run normalization
  df_clean <- srtr_normalize_missing(df)

  # Check that "U", "", and "ND" are gone
  post_vals <- unique(as.character(df_clean$REC_HIV_STAT))
  expect_false(any(post_vals %in% c("U", "", "ND")))

  # Check that default is NA by default
  expect_true(any(is.na(df_clean$REC_HIV_STAT)))

  # Now try replacement = "Missing"
  df_missing <- srtr_normalize_missing(df, replacement = "Missing")

  expect_true("Missing" %in% unique(as.character(df_missing$REC_HIV_STAT)))
  expect_false(any(is.na(df_missing$REC_HIV_STAT)))
})

# ---- Offline test: a tiny made-up table, no SAF needed ----

test_that("verbose = TRUE reports processed and skipped columns", {
  df <- tibble::tibble(FAKE_A = c(1, -99))
  expect_snapshot(
    out <- srtr_normalize_missing(
      df,
      missing_vals = list(FAKE_A = -99, FAKE_NOT_THERE = -99),
      verbose = TRUE
    )
  )
  expect_equal(out$FAKE_A, c(1, NA))
})

test_that("factor levels keep their order and lose only the replaced codes", {
  df <- tibble::tibble(
    FAKE_F = factor(c("B", "U", "A"), levels = c("A", "B", "C", "U"))
  )
  out <- srtr_normalize_missing(df, missing_vals = list(FAKE_F = "U"))
  expect_equal(levels(out$FAKE_F), c("A", "B", "C"))
  expect_equal(as.character(out$FAKE_F), c("B", NA, "A"))
})

test_that("a column with no missing codes is left unchanged", {
  df <- tibble::tibble(
    FAKE_F = factor(c("B", "A"), levels = c("A", "B", "C"))
  )
  out <- srtr_normalize_missing(df, missing_vals = list(FAKE_F = "U"))
  expect_identical(out$FAKE_F, df$FAKE_F)
})

test_that("a string replacement becomes the last level", {
  df <- tibble::tibble(
    FAKE_F = factor(c("B", "U", NA), levels = c("A", "B", "U"))
  )
  out <- srtr_normalize_missing(
    df,
    missing_vals = list(FAKE_F = "U"),
    replacement = "Missing"
  )
  expect_equal(levels(out$FAKE_F), c("A", "B", "Missing"))
  expect_equal(as.character(out$FAKE_F), c("B", "Missing", "Missing"))
})

test_that("ordered factors and variable labels are kept", {
  vec <- factor(c("Low", "U", "High"), levels = c("Low", "High", "U"),
                ordered = TRUE)
  attr(vec, "label") <- "Fake variable label"
  df <- tibble::tibble(FAKE_F = vec)
  out <- srtr_normalize_missing(df, missing_vals = list(FAKE_F = "U"))
  expect_s3_class(out$FAKE_F, "ordered")
  expect_equal(levels(out$FAKE_F), c("Low", "High"))
  expect_equal(attr(out$FAKE_F, "label"), "Fake variable label")
})
