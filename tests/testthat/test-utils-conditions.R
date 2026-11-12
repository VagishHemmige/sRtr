test_that("conditions carry a general and a specific sRtr class", {
  expect_error(srtr_abort("Boom.", class = "boom"), class = "sRtr_error_boom")
  expect_error(srtr_abort("Boom.", class = "boom"), class = "sRtr_error")
  expect_warning(srtr_warn("Hmm.", class = "hmm"), class = "sRtr_warning_hmm")
  expect_message(srtr_inform("FYI.", class = "fyi"), class = "sRtr_message_fyi")
})

test_that("a condition without a specific class still has the general one", {
  cnd <- rlang::catch_cnd(srtr_abort("Boom."))
  expect_s3_class(cnd, "sRtr_error")
  expect_equal(class(cnd)[[1]], "sRtr_error")
})

test_that("srtr_abort() reports the function that called it", {
  f <- function() srtr_abort("Boom.")
  cnd <- rlang::catch_cnd(f())
  expect_equal(cnd$call, quote(f()))
})

test_that("check_columns() returns the data when every column is there", {
  df <- data.frame(FAKE_A = 1, FAKE_B = 2)
  expect_identical(check_columns(df, c("FAKE_A", "FAKE_B")), df)
})

test_that("check_columns() lists the missing columns", {
  f <- function(data) check_columns(data, c("FAKE_A", "FAKE_B", "FAKE_C"))
  df <- data.frame(FAKE_A = 1)
  expect_error(f(df), class = "sRtr_error_missing_columns")
  cnd <- rlang::catch_cnd(f(df))
  expect_equal(cnd$missing, c("FAKE_B", "FAKE_C"))
  expect_snapshot(error = TRUE, f(df))
})

test_that("check_columns() can say why the columns are needed", {
  df <- data.frame(FAKE_A = 1)
  expect_snapshot(
    error = TRUE,
    check_columns(df, "FAKE_B", why = "They are needed to censor outcomes.")
  )
})
