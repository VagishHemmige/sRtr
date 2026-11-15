test_that("apply_srtr_varlabels applies labels from dictionary", {
  skip_if_no_srtr_data()
  df <- load_srtr_file("TX_KI", var_labels = FALSE)
  df_labeled <- apply_srtr_varlabels(df)
  expect_true(any(
    !sapply(df_labeled, function(x) is.null(labelled::var_label(x)))
  ))
})

test_that("apply_srtr_varlabels uses file_key attribute", {
  skip_if_no_srtr_data()
  df <- load_srtr_file("TX_KI", var_labels = FALSE)
  attr(df, "file_key") <- "TX_KI"
  result <- apply_srtr_varlabels(df)
  expect_s3_class(result, "data.frame") # No error
})

# ---- Offline tests: a tiny made-up table, no SAF needed ----

test_that("verbose = TRUE reports each labeled variable", {
  df <- tibble::tibble(CAN_ABO = c("A", "A2"), FAKE_COLUMN = c(1, 2))
  expect_message(
    apply_srtr_varlabels(df, file_key = "TX_KI", verbose = TRUE),
    class = "sRtr_message_variable_labeled"
  )
})

test_that("already-labelled data is left alone, with a warning", {
  df <- tibble::tibble(CAN_ABO = "A")
  labelled::var_label(df$CAN_ABO) <- "A made-up label"
  expect_warning(
    out <- apply_srtr_varlabels(df, file_key = "TX_KI"),
    class = "sRtr_warning_already_labelled"
  )
  expect_equal(labelled::var_label(out$CAN_ABO), "A made-up label")
})

test_that("the result carries the upper-case file_key", {
  df <- tibble::tibble(CAN_ABO = "A")
  out <- apply_srtr_varlabels(df, file_key = "tx_ki")
  expect_equal(attr(out, "file_key"), "TX_KI")
  expect_equal(labelled::var_label(out$CAN_ABO), "Patient/s Blood Type")
})

test_that("a chain with no file_key keeps the key from the object name", {
  TX_KI <- tibble::tibble(CAN_ABO = "A")
  out <- TX_KI |>
    apply_srtr_factors() |>
    apply_srtr_varlabels()
  expect_s3_class(out$CAN_ABO, "factor")
  expect_equal(labelled::var_label(out$CAN_ABO), "Patient/s Blood Type")
  expect_equal(attr(out, "file_key"), "TX_KI")

  out <- TX_KI |>
    apply_srtr_varlabels() |>
    apply_srtr_factors()
  expect_s3_class(out$CAN_ABO, "factor")
  expect_equal(attr(out, "file_key"), "TX_KI")
})

test_that("an unknown file_key warns and returns the data unchanged", {
  df <- tibble::tibble(CAN_ABO = "A")
  expect_warning(
    out <- apply_srtr_varlabels(df, file_key = "NOT_A_FILE"),
    class = "sRtr_warning_unknown_file_key"
  )
  expect_identical(out, df)
  expect_snapshot(out <- apply_srtr_varlabels(df, file_key = "NOT_A_FILE"))
})

test_that("a file_key that cannot be worked out warns", {
  expect_warning(
    out <- apply_srtr_varlabels(tibble::tibble(CAN_ABO = "A")),
    class = "sRtr_warning_file_key_not_inferred"
  )
  expect_null(labelled::var_label(out$CAN_ABO))
  expect_snapshot(out <- apply_srtr_varlabels(tibble::tibble(CAN_ABO = "A")))
})

test_that("a known file_key with no matching columns does not warn", {
  df <- tibble::tibble(FAKE_COLUMN = 1)
  expect_no_warning(out <- apply_srtr_varlabels(df, file_key = "TX_KI"))
  expect_equal(attr(out, "file_key"), "TX_KI")
})

test_that("file_key must be a single string", {
  df <- tibble::tibble(CAN_ABO = "A")
  for (bad in list(1, NA_character_, c("TX_KI", "TX_LI"))) {
    expect_error(
      apply_srtr_varlabels(df, file_key = bad),
      class = "sRtr_error_invalid_file_key"
    )
    expect_error(
      apply_srtr_factors(df, file_key = bad),
      class = "sRtr_error_invalid_file_key"
    )
  }
  expect_snapshot(error = TRUE, apply_srtr_varlabels(df, file_key = 1))
})

test_that("an explicit file_key overrides the attribute", {
  df <- tibble::tibble(CAN_ABO = "A")
  attr(df, "file_key") <- "NOT_A_FILE"
  out <- apply_srtr_factors(df, file_key = "TX_KI") |>
    apply_srtr_varlabels(file_key = "TX_KI")
  expect_equal(attr(out, "file_key"), "TX_KI")
  expect_s3_class(out$CAN_ABO, "factor")
  expect_equal(labelled::var_label(out$CAN_ABO), "Patient/s Blood Type")
})

test_that("other attributes on the data frame are kept", {
  df <- tibble::tibble(CAN_ABO = "A")
  attr(df, "source_path") <- "made/up/path.sas7bdat"
  out <- apply_srtr_factors(df, file_key = "TX_KI") |>
    apply_srtr_varlabels(file_key = "TX_KI")
  expect_equal(attr(out, "source_path"), "made/up/path.sas7bdat")
})
