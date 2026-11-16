test_that("PVR is (mean PA - PCWP) / CO", {
  df <- tibble::tibble(
    CAN_PULM_ART_MEAN = c(40, 25, 30, NA),
    CAN_PCW_MEAN = c(20, 15, 10, 10),
    CAN_CARDIAC_OUTPUT = c(4, 5, 0, 4)
  )
  expect_message(
    out <- add_pvr(df),
    class = "sRtr_message_score_missing_inputs"
  )
  expect_equal(out$PVR, c(5, 2, NA, NA), ignore_attr = TRUE)
})

test_that("dyn units multiply Wood units by 80", {
  df <- tibble::tibble(CAN_PULM_ART_MEAN = 40, CAN_PCW_MEAN = 20, CAN_CARDIAC_OUTPUT = 4)
  expect_equal(add_pvr(df, units = "dyn")$PVR, 400, ignore_attr = TRUE)
})

test_that("transplant PVR uses the REC columns", {
  df <- tibble::tibble(REC_PULM_ART_MEAN = 40, REC_PCW_MEAN = 20, REC_CARDIAC_OUTPUT = 4)
  expect_equal(add_pvr(df, at = "transplant")$PVR, 5, ignore_attr = TRUE)
})

test_that("missing columns are reported", {
  df <- tibble::tibble(CAN_PULM_ART_MEAN = 40)
  expect_error(add_pvr(df), class = "sRtr_error_missing_columns")
})
