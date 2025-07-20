test_that("srtr_normalize_missing replaces expected values", {
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
