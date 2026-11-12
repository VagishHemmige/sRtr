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
    TFL_PX_STAT_DT = as.Date(c(
      "2001-01-01",
      "2002-01-01",
      "2001-06-01",
      "2003-01-01"
    ))
  )
}

test_that("add_txf_outcomes() runs for a single-organ file without dplyr attached", {
  expect_equal(intersect(search(), "package:dplyr"), character())
  local_mocked_bindings(load_srtr_file = function(...) fake_txf("KI"))

  out <- add_txf_outcomes(fake_tx("TX_KI"))

  expect_named(out, c("TRR_ID", "FIRST_FU_MALIG_DATE", "FIRST_FU_REJ_DATE"))
  expect_equal(nrow(out), 3)
  expect_equal(out$FIRST_FU_MALIG_DATE, as.Date(c("2002-01-01", NA, NA)))
  expect_equal(
    out$FIRST_FU_REJ_DATE,
    as.Date(c("2001-01-01", NA, "2003-01-01"))
  )
})

test_that("add_time_to_event_outcomes() builds rejection dates without dplyr attached", {
  expect_equal(intersect(search(), "package:dplyr"), character())
  # Isolate the rejection step: the other helpers are tested separately (#25).
  local_mocked_bindings(
    srtr_composite_death = function(df, ...) {
      df$REC_DEATH_DT_COMPOSITE <- as.Date(NA)
      df
    },
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
    ),
    TFL_LAFUDATE = as.Date(c("2006-01-01", "2006-01-01"))
  )
  attr(df, "file_key") <- "TX_KI"

  out <- add_time_to_event_outcomes(df)

  expect_equal(out$FIRST_REJ_DATE, as.Date(c("2000-01-11", "2005-01-01")))
})

# ---- #16: output columns come from the file type, not the data ------------

no_rejection_txf <- function(org_ty) {
  txf <- fake_txf(org_ty)
  txf$TFL_ACUTE_REJ_EPISODE <- "3: No"
  txf
}

test_that("a single-organ cohort with no rejections still gets FIRST_FU_REJ_DATE", {
  local_mocked_bindings(load_srtr_file = function(...) no_rejection_txf("KI"))
  out <- add_txf_outcomes(fake_tx("TX_KI"))
  expect_named(out, c("TRR_ID", "FIRST_FU_MALIG_DATE", "FIRST_FU_REJ_DATE"))
  expect_equal(out$FIRST_FU_REJ_DATE, rep(as.Date(NA), 3))
  expect_s3_class(out$FIRST_FU_REJ_DATE, "Date")
})

test_that("a cohort with no malignancy still gets FIRST_FU_MALIG_DATE", {
  txf <- fake_txf("KI")
  txf$TFL_MALIG <- "N"
  local_mocked_bindings(load_srtr_file = function(...) txf)
  out <- add_txf_outcomes(fake_tx("TX_KI"))
  expect_equal(out$FIRST_FU_MALIG_DATE, rep(as.Date(NA), 3))
  expect_s3_class(out$FIRST_FU_MALIG_DATE, "Date")
})

test_that("TX_KP keeps _KI and _PA columns when only kidney rejections occur", {
  local_mocked_bindings(load_srtr_file = function(...) fake_txf("KI"))
  out <- add_txf_outcomes(fake_tx("TX_KP"))
  expect_named(
    out,
    c(
      "TRR_ID",
      "FIRST_FU_MALIG_DATE",
      "FIRST_FU_REJ_DATE_KI",
      "FIRST_FU_REJ_DATE_PA"
    )
  )
  expect_equal(
    out$FIRST_FU_REJ_DATE_KI,
    as.Date(c("2001-01-01", NA, "2003-01-01"))
  )
  expect_equal(out$FIRST_FU_REJ_DATE_PA, rep(as.Date(NA), 3))
})

test_that("TX_KP splits rejections by organ", {
  txf <- fake_txf(c("KI", "KI", "PA", "PA"))
  local_mocked_bindings(load_srtr_file = function(...) txf)
  out <- add_txf_outcomes(fake_tx("TX_KP"))
  # Rows 1 (KI, 2001-01-01) and 4 (PA, 2003-01-01) are the rejections.
  expect_equal(out$FIRST_FU_REJ_DATE_KI, as.Date(c("2001-01-01", NA, NA)))
  expect_equal(out$FIRST_FU_REJ_DATE_PA, as.Date(c(NA, NA, "2003-01-01")))
})

# ---- add_time_to_event_outcomes(): whole pipeline on made-up cohorts ----------------
# Only the follow-up file loader is replaced; the outcome helpers run for real.

fake_cohort <- function(file_key) {
  df <- tibble::tibble(
    TRR_ID = c(900001, 900002),
    REC_TX_DT = as.Date("2000-01-01"),
    REC_POSTX_LOS = 10,
    REC_ACUTE_REJ_EPISODE = "3: No",
    PERS_OPTN_DEATH_DT = as.Date(c(NA, "2004-01-01")),
    PERS_SSA_DEATH_DT = as.Date(NA),
    TFL_DEATH_DT = as.Date(NA)
  )
  if (file_key == "TX_KP") {
    df$REC_ACUTE_REJ_EPISODE_PA <- "3: No"
    df$TFL_GRAFT_DT_KI <- as.Date(NA)
    df$TFL_GRAFT_DT_PA <- as.Date(NA)
    df$TFL_LAFUDATEKI <- as.Date(c("2003-01-01", "2004-01-01"))
    df$TFL_LAFUDATEPA <- as.Date(c("2005-01-01", "2002-01-01"))
  } else {
    df$TFL_GRAFT_DT <- as.Date(NA)
    df$TFL_LAFUDATE <- as.Date(c("2005-01-01", "2004-01-01"))
  }
  attr(df, "file_key") <- file_key
  df
}

fake_cohort_txf <- function(org_ty) {
  tibble::tibble(
    TRR_ID = 900001,
    ORG_TY = org_ty,
    TFL_MALIG = "N",
    TFL_ACUTE_REJ_EPISODE = "1: Yes, at least one episode treated with anti-rejection agent",
    TFL_PX_STAT_DT = as.Date("2001-01-01")
  )
}

test_that("add_time_to_event_outcomes() runs on a TX_KP cohort", {
  local_mocked_bindings(load_srtr_file = function(...) fake_cohort_txf("KI"))
  out <- add_time_to_event_outcomes(fake_cohort("TX_KP"))

  # Death is patient-level: censored at the later of the kidney and pancreas
  # follow-up dates (900001: 2005-01-01), or at death (900002: 2004-01-01).
  expect_equal(out$REC_DEATH_DT_COMPOSITE_BINARY, c(0L, 1L))
  expect_equal(
    out$REC_DEATH_DT_COMPOSITE_CENSOR,
    as.Date(c("2005-01-01", "2004-01-01"))
  )

  # Kidney rejection is censored at kidney follow-up.
  expect_equal(out$FIRST_REJ_DATE_BINARY, c(1L, 0L))
  expect_equal(
    out$FIRST_REJ_DATE_CENSOR,
    as.Date(c("2001-01-01", "2004-01-01"))
  )

  # Pancreas columns use the FIRST_REJ_DATE_PA prefix (was FIRST_REJ_DATEPA).
  expect_contains(
    names(out),
    c(
      "FIRST_REJ_DATE_PA_CENSOR",
      "FIRST_REJ_DATE_PA_BINARY",
      "FIRST_REJ_DATE_PA_days"
    )
  )
  expect_equal(grep("^FIRST_REJ_DATEPA", names(out), value = TRUE), character())
  expect_equal(
    out$FIRST_REJ_DATE_PA_CENSOR,
    as.Date(c("2005-01-01", "2002-01-01"))
  )
})

test_that("add_time_to_event_outcomes() runs on a single-organ cohort with no rejections", {
  txf <- fake_cohort_txf("KI")
  txf$TFL_ACUTE_REJ_EPISODE <- "3: No"
  local_mocked_bindings(load_srtr_file = function(...) txf)
  out <- add_time_to_event_outcomes(fake_cohort("TX_KI"))
  expect_equal(out$FIRST_REJ_DATE_BINARY, c(0L, 0L))
  expect_equal(
    out$FIRST_REJ_DATE_CENSOR,
    as.Date(c("2005-01-01", "2004-01-01"))
  )
})

test_that("a missing follow-up date column is a clear error", {
  kp <- fake_cohort("TX_KP")
  kp$TFL_LAFUDATEPA <- NULL
  expect_error(
    add_time_to_event_outcomes(kp),
    class = "sRtr_error_missing_columns"
  )
  expect_snapshot(error = TRUE, add_time_to_event_outcomes(kp))

  ki <- fake_cohort("TX_KI")
  ki$TFL_LAFUDATE <- NULL
  expect_snapshot(error = TRUE, add_time_to_event_outcomes(ki))
})

test_that("TX_KP warns when follow-up rows are coded neither KI nor PA", {
  # WLORG also allows "KP"; such rows cannot be assigned to one organ.
  local_mocked_bindings(load_srtr_file = function(...) fake_txf("KP"))
  expect_warning(
    add_txf_outcomes(fake_tx("TX_KP")),
    class = "sRtr_warning_kp_unknown_organ"
  )
  expect_snapshot(out <- add_txf_outcomes(fake_tx("TX_KP")))
  expect_equal(out$FIRST_FU_REJ_DATE_KI, rep(as.Date(NA), 3))
  expect_equal(out$FIRST_FU_REJ_DATE_PA, rep(as.Date(NA), 3))
})
