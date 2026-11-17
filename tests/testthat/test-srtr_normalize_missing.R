# Made-up rows built from real dictionary column names of TX_KI:
#   DON_ANTI_CMV  character, format SRLSTT
#   DON_HIST_DIAB numeric, format HSTDBDR
#   CAN_MALIG     character flag with no format (variables table)
#   CAN_PRIMARY_PAY numeric, format PRMSRCPY... not used here
fake_tx_ki_values <- function() {
  tibble::tibble(
    FAKE_ID = 1:8,
    DON_ANTI_CMV = c("P", "N", "U", "I", "ND", "PD", "C", NA),
    DON_HIST_DIAB = c(1, 2, 5, 998, 998, NA, 1, 3),
    CAN_MALIG = c("Y", "N", "", "U", "u", "ND", "Y", NA)
  )
}

test_that("the default policy turns unknown-type codes into NA", {
  out <- srtr_normalize_missing(fake_tx_ki_values(), file_key = "TX_KI")

  expect_equal(out$DON_ANTI_CMV, c("P", "N", NA, "I", NA, NA, NA, NA))
  expect_equal(out$DON_HIST_DIAB, c(1, 2, 5, NA, NA, NA, 1, 3))
  expect_equal(out$CAN_MALIG, c("Y", "N", NA, NA, NA, NA, "Y", NA))
  expect_equal(out$FAKE_ID, 1:8)
})

test_that("the reason column says why a value became NA, and only that", {
  out <- srtr_normalize_missing(fake_tx_ki_values(), file_key = "TX_KI")

  expect_equal(
    out$DON_ANTI_CMV_MISS,
    c(NA, NA, "unknown", NA, "not_done", "pending", "cannot_disclose", NA)
  )
  expect_equal(
    out$DON_HIST_DIAB_MISS,
    c(NA, NA, NA, "unknown", "unknown", NA, NA, NA)
  )
})

test_that("a variable with nothing to change gets no reason column", {
  df <- tibble::tibble(DON_ANTI_CMV = c("P", "N", "I", NA))

  out <- srtr_normalize_missing(df, file_key = "TX_KI")

  expect_identical(out, df)
})

test_that("raw codes and labelled columns are normalized alike", {
  raw <- fake_tx_ki_values()
  labelled <- suppressWarnings(apply_srtr_factors(raw, file_key = "TX_KI"))

  from_raw <- srtr_normalize_missing(raw, file_key = "TX_KI")
  from_labelled <- srtr_normalize_missing(labelled)

  expect_equal(is.na(from_labelled$DON_ANTI_CMV), is.na(from_raw$DON_ANTI_CMV))
  expect_equal(is.na(from_labelled$DON_HIST_DIAB), is.na(from_raw$DON_HIST_DIAB))
  expect_equal(from_labelled$DON_ANTI_CMV_MISS, from_raw$DON_ANTI_CMV_MISS)
  expect_equal(from_labelled$DON_HIST_DIAB_MISS, from_raw$DON_HIST_DIAB_MISS)
})

test_that("a factor loses the levels that became NA and keeps its order", {
  labelled <- suppressWarnings(
    apply_srtr_factors(fake_tx_ki_values(), file_key = "TX_KI")
  )
  attr(labelled$DON_ANTI_CMV, "label") <- "Fake label"

  out <- srtr_normalize_missing(labelled)

  expect_equal(
    levels(out$DON_ANTI_CMV),
    c("I: Indeterminate", "N: Negative", "P: Positive")
  )
  expect_equal(attr(out$DON_ANTI_CMV, "label"), "Fake label")
  expect_equal(attr(out$DON_ANTI_CMV, "srtr_format"), "SRLSTT")
  expect_equal(
    levels(out$DON_HIST_DIAB),
    setdiff(levels(labelled$DON_HIST_DIAB), "998: UNKNOWN")
  )
})

test_that("policy 'strict' leaves only substantive values", {
  out <- srtr_normalize_missing(
    fake_tx_ki_values(),
    policy = "strict",
    file_key = "TX_KI"
  )

  expect_equal(out$DON_ANTI_CMV, c("P", "N", NA, NA, NA, NA, NA, NA))
  expect_equal(out$DON_HIST_DIAB, c(1, 2, NA, NA, NA, NA, 1, 3))
  expect_equal(out$DON_ANTI_CMV_MISS[4], "indeterminate")
  expect_equal(out$DON_HIST_DIAB_MISS[3], "partial")
})

test_that("policy 'tag_only' changes no value and tags every recognised code", {
  df <- fake_tx_ki_values()

  out <- srtr_normalize_missing(df, policy = "tag_only", file_key = "TX_KI")

  expect_identical(out[names(df)], df)
  expect_equal(
    out$DON_ANTI_CMV_MISS,
    c(
      NA, NA, "unknown", "indeterminate", "not_done", "pending",
      "cannot_disclose", NA
    )
  )
  expect_equal(out$DON_HIST_DIAB_MISS[3], "partial")
})

test_that("actions override the policy for one type", {
  out <- srtr_normalize_missing(
    fake_tx_ki_values(),
    actions = c(not_done = "keep", indeterminate = "na"),
    file_key = "TX_KI"
  )

  expect_equal(out$DON_ANTI_CMV, c("P", "N", NA, NA, "ND", NA, NA, NA))
  expect_equal(out$CAN_MALIG, c("Y", "N", NA, NA, NA, "ND", "Y", NA))
})

test_that("overrides change the rule for one variable only", {
  out <- srtr_normalize_missing(
    fake_tx_ki_values(),
    overrides = list(DON_ANTI_CMV = c(not_done = "keep")),
    file_key = "TX_KI"
  )

  expect_equal(out$DON_ANTI_CMV[5], "ND")
  expect_true(is.na(out$CAN_MALIG[6]))
})

test_that("reason = 'none' adds no columns", {
  df <- fake_tx_ki_values()

  out <- srtr_normalize_missing(df, reason = "none", file_key = "TX_KI")

  expect_named(out, names(df))
})

test_that("output = 'append' keeps the original columns", {
  df <- fake_tx_ki_values()

  out <- srtr_normalize_missing(df, output = "append", file_key = "TX_KI")

  expect_identical(out[names(df)], df)
  expect_equal(out$DON_ANTI_CMV_NORM, c("P", "N", NA, "I", NA, NA, NA, NA))
  expect_true("DON_ANTI_CMV_MISS" %in% names(out))
})

test_that("cols limits the variables that are normalized", {
  out <- srtr_normalize_missing(
    fake_tx_ki_values(),
    cols = "CAN_MALIG",
    file_key = "TX_KI"
  )

  expect_equal(out$DON_ANTI_CMV, fake_tx_ki_values()$DON_ANTI_CMV)
  expect_true(is.na(out$CAN_MALIG[4]))
})

test_that("na_level makes missing an explicit last level or value", {
  labelled <- suppressWarnings(
    apply_srtr_factors(fake_tx_ki_values(), file_key = "TX_KI")
  )

  out <- srtr_normalize_missing(labelled, na_level = "Missing")
  raw <- srtr_normalize_missing(
    fake_tx_ki_values(),
    na_level = "Missing",
    file_key = "TX_KI"
  )

  expect_equal(
    levels(out$DON_ANTI_CMV),
    c("I: Indeterminate", "N: Negative", "P: Positive", "Missing")
  )
  expect_equal(as.character(out$DON_ANTI_CMV[c(3, 8)]), c("Missing", "Missing"))
  expect_equal(raw$CAN_MALIG[c(3, 8)], c("Missing", "Missing"))
  expect_equal(raw$DON_HIST_DIAB, c(1, 2, 5, NA, NA, NA, 1, 3))
})

test_that("extra_codes adds the caller's own codes", {
  df <- tibble::tibble(FAKE_SCORE = c("1", "ZZ", "2"), DON_ANTI_CMV = "P")

  out <- srtr_normalize_missing(
    df,
    extra_codes = list(FAKE_SCORE = c(ZZ = "unknown")),
    file_key = "TX_KI"
  )

  expect_equal(out$FAKE_SCORE, c("1", NA, "2"))
  expect_equal(out$FAKE_SCORE_MISS, c(NA, "unknown", NA))
})

test_that("normalizing twice changes nothing more", {
  once <- srtr_normalize_missing(
    fake_tx_ki_values(),
    reason = "none",
    file_key = "TX_KI"
  )

  expect_identical(
    srtr_normalize_missing(once, reason = "none", file_key = "TX_KI"),
    once
  )
})

test_that("values a format does not list are left alone", {
  df <- tibble::tibble(DON_ANTI_CMV = c("P", "ZQ", "U"))

  out <- srtr_normalize_missing(df, file_key = "TX_KI")

  expect_equal(out$DON_ANTI_CMV, c("P", "ZQ", NA))
})

test_that("the data frame's attributes are kept", {
  df <- fake_tx_ki_values()
  attr(df, "file_key") <- "TX_KI"
  attr(df, "source_path") <- "fake/path"

  out <- srtr_normalize_missing(df)

  expect_equal(attr(out, "file_key"), "TX_KI")
  expect_equal(attr(out, "source_path"), "fake/path")
  expect_s3_class(out, "tbl_df")
})

test_that("an existing reason or output column is not overwritten", {
  df <- fake_tx_ki_values()
  df$DON_ANTI_CMV_MISS <- "mine"

  expect_error(
    srtr_normalize_missing(df, file_key = "TX_KI"),
    class = "sRtr_error_column_exists"
  )
})

test_that("invalid actions, overrides and extra codes are errors", {
  df <- fake_tx_ki_values()

  expect_error(
    srtr_normalize_missing(df, actions = c(unknown = "drop"), file_key = "TX_KI"),
    class = "sRtr_error_invalid_actions"
  )
  expect_error(
    srtr_normalize_missing(df, actions = c(maybe = "na"), file_key = "TX_KI"),
    class = "sRtr_error_invalid_actions"
  )
  expect_error(
    srtr_normalize_missing(
      df,
      overrides = list(NOT_THERE = c(unknown = "keep")),
      file_key = "TX_KI"
    ),
    class = "sRtr_error_columns_not_found"
  )
  expect_error(
    srtr_normalize_missing(
      df,
      extra_codes = list(CAN_MALIG = c(Q = "whatever")),
      file_key = "TX_KI"
    ),
    class = "sRtr_error_invalid_extra_codes"
  )
})

test_that("the old missing_vals list is refused with a pointer", {
  expect_error(
    srtr_normalize_missing(fake_tx_ki_values(), list(CAN_MALIG = "U")),
    class = "sRtr_error_missing_vals_removed"
  )
})

test_that("verbose reports how many values changed", {
  expect_message(
    srtr_normalize_missing(
      fake_tx_ki_values(),
      file_key = "TX_KI",
      verbose = TRUE
    ),
    class = "sRtr_message_missing_normalized"
  )
})
