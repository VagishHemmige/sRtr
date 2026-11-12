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
