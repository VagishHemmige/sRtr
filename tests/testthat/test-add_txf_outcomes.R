# Synthetic data only: IDs and dates are obviously fake.

fake_tx <- function(file_key) {
  df <- tibble::tibble(TRR_ID = c(900001, 900002, 900003))
  attr(df, "file_key") <- file_key
  df
}

fake_txf <- function(org_ty) {
  tibble::tibble(
    TRR_ID = c(900001, 900001, 900002, 900003),
    ORG_TY = org_ty,
    TFL_MALIG = c("N", "Y", "N", "N"),
    TFL_ACUTE_REJ_EPISODE = c(
      "1: Yes, at least one episode treated with anti-rejection agent",
      "3: No",
      "3: No",
      "1: Yes, at least one episode treated with anti-rejection agent"
    ),
    TFL_PX_STAT_DT = as.Date(c("2001-01-01", "2002-01-01", "2001-06-01", "2003-01-01"))
  )
}

test_that("add_txf_outcomes() runs for a single-organ file without dplyr attached", {
  expect_false("package:dplyr" %in% search())
  local_mocked_bindings(load_srtr_file = function(...) fake_txf("KI"))

  out <- add_txf_outcomes(fake_tx("TX_KI"))

  expect_named(out, c("TRR_ID", "FIRST_FU_MALIG_DATE", "FIRST_FU_REJ_DATE"))
  expect_equal(nrow(out), 3)
  expect_equal(out$FIRST_FU_MALIG_DATE, as.Date(c("2002-01-01", NA, NA)))
  expect_equal(out$FIRST_FU_REJ_DATE, as.Date(c("2001-01-01", NA, "2003-01-01")))
})

test_that("add_tte_outcomes() builds rejection dates without dplyr attached", {
  expect_false("package:dplyr" %in% search())
  # Isolate the rejection step: the other helpers are tested separately (#25).
  local_mocked_bindings(
    srtr_composite_death = function(df, ...) df,
    srtr_time_to_event = function(df, ...) df,
    add_txf_outcomes = function(df) {
      df$FIRST_FU_REJ_DATE <- as.Date(c(NA, "2005-01-01"))
      df
    }
  )
  df <- tibble::tibble(
    TRR_ID = c(900001, 900002),
    REC_TX_DT = as.Date(c("2000-01-01", "2000-01-01")),
    REC_POSTX_LOS = c(10, 10),
    REC_ACUTE_REJ_EPISODE = c(
      "1: Yes, at least one episode treated with anti-rejection agent",
      "3: No"
    )
  )
  attr(df, "file_key") <- "TX_KI"

  out <- add_tte_outcomes(df)

  expect_equal(out$FIRST_REJ_DATE, as.Date(c("2000-01-11", "2005-01-01")))
})
