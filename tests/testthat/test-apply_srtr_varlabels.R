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
