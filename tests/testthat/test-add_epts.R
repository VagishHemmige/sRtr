# The three worked examples are the candidates in the OPTN EPTS guide
# (updated 2026-04-07), scored as of 2025-01-01 against the table built from
# the 2024-12-31 waiting list.

test_that("raw EPTS matches the OPTN guide's worked examples", {
  raw <- .epts_raw(
    age = c(8614, 19315, 8227) / 365.25,
    diabetes = c(0, 0, 1),
    prior_tx = c(1, 0, 1),
    years_dialysis = c(1857, 0, 2511) / 365.25
  )
  expect_equal(raw, c(0.9667934, 1.4404346, 1.8687507), tolerance = 1e-7)
})

test_that("the 2024 table maps the guide's raw EPTS to its scores", {
  expect_equal(
    .optn_percentile(c(0.9667934, 1.4404346, 1.8687507), "epts", "2024"),
    c(9, 18, 32)
  )
})

candidates <- function() {
  tibble::tibble(
    CAN_AGE_IN_MONTHS_AT_LISTING = c(600, 300, 240),
    CAN_LISTING_DT = as.Date(c("2025-01-01", "2025-01-01", "2025-01-01")),
    CAN_DIAL_DT = as.Date(c("2020-01-01", NA, "2026-01-01")),
    CAN_DIAL = c(2, 1, 2),
    CAN_DIAB_TY = c(1, 3, 998),
    CAN_PREV_KI = c("N", "Y", "N"),
    CAN_PREV_LI = c("N", "N", "N")
  )
}

test_that("listing EPTS reads SAF columns", {
  out <- add_epts(candidates(), unknown_diabetes = "no", table = "2024", return_terms = TRUE)
  expect_equal(
    out$EPTS_RAW,
    .epts_raw(
      age = c(50, 25, 20),
      diabetes = c(0, 1, 0),
      prior_tx = c(0, 1, 0),
      years_dialysis = c(as.numeric(as.Date("2025-01-01") - as.Date("2020-01-01")) / 365.25, 0, 0)
    ),
    ignore_attr = TRUE
  )
  expect_equal(
    as.numeric(out$EPTS),
    .optn_percentile(as.numeric(out$EPTS_RAW), "epts", "2024")
  )
})

test_that("unknown diabetes gives NA by default", {
  expect_message(
    out <- add_epts(candidates()),
    class = "sRtr_message_score_missing_inputs"
  )
  expect_equal(is.na(as.numeric(out$EPTS)), c(FALSE, FALSE, TRUE))
})

test_that("a missing dialysis date counts as not on dialysis only when the status says so", {
  cands <- candidates()[1:2, ]
  cands$CAN_DIAL_DT <- as.Date(NA)
  cands$CAN_DIAL <- c(2, 1)
  expect_message(
    out <- add_epts(cands, return_terms = TRUE),
    class = "sRtr_message_score_missing_inputs"
  )
  expect_equal(is.na(as.numeric(out$EPTS_RAW)), c(TRUE, FALSE))
})

test_that("candidates under 18 get no EPTS unless asked", {
  cands <- candidates()[1, ]
  cands$CAN_AGE_IN_MONTHS_AT_LISTING <- 120
  expect_message(
    out <- add_epts(cands),
    class = "sRtr_message_score_missing_inputs"
  )
  expect_equal(as.numeric(out$EPTS), NA_real_)
  expect_false(is.na(as.numeric(add_epts(cands, adults_only = FALSE)$EPTS)))
})

test_that("transplant EPTS uses the recipient columns", {
  recips <- tibble::tibble(
    REC_AGE_IN_MONTHS_AT_TX = 600,
    REC_TX_DT = as.Date("2025-06-01"),
    REC_DIAL_DT = as.Date("2020-06-01"),
    REC_DIAL_TY = 2,
    CAN_DIAB_TY = 1,
    CAN_PREV_KI = "N"
  )
  out <- add_epts(recips, at = "transplant")
  expect_equal(
    out$EPTS_RAW,
    .epts_raw(50, 0, 0, as.numeric(as.Date("2025-06-01") - as.Date("2020-06-01")) / 365.25),
    ignore_attr = TRUE
  )
})

test_that("in_force uses the waiting list of the year before", {
  cands <- candidates()[1, ][rep(1, 2), ]
  cands$CAN_LISTING_DT <- as.Date(c("2019-05-01", "2013-05-01"))
  cands$CAN_DIAL_DT <- as.Date("2012-01-01")
  expect_warning(
    out <- add_epts(cands, table = "in_force"),
    class = "sRtr_warning_table_not_stored"
  )
  expect_equal(attr(out$EPTS, "optn_table"), c("2018", NA))
})

test_that("an unknown table label is refused", {
  expect_error(add_epts(candidates(), table = "1999"), class = "sRtr_error_bad_table")
})
