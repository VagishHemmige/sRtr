# Synthetic data only: IDs and dates are obviously fake.

fake_tx <- function(file_key) {
  df <- tibble::tibble(TRR_ID = c(900001, 900002, 900003))
  attr(df, "file_key") <- file_key
  df
}

# The columns add_txf_outcomes() adds, for rejection column suffixes `organs`.
fu_columns <- function(organs) {
  c(
    "FIRST_FU_MALIG_DATE",
    "FIRST_FU_MALIG_STATUS",
    "FIRST_FU_MALIG_LAST_NEG_DATE",
    as.vector(t(outer(
      organs,
      c("FIRST_FU_REJ_DATE", "FIRST_FU_REJ_STATUS", "FIRST_FU_REJ_LAST_NEG_DATE"),
      \(organ, stem) paste0(stem, organ)
    )))
  )
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

  expect_named(out, c("TRR_ID", fu_columns("")))
  expect_equal(nrow(out), 3)
  expect_equal(out$FIRST_FU_MALIG_DATE, as.Date(c("2002-01-01", NA, NA)))
  expect_equal(
    out$FIRST_FU_REJ_DATE,
    as.Date(c("2001-01-01", NA, "2003-01-01"))
  )
})

test_that("add_txf_outcomes() reads only the follow-up columns it uses", {
  selected <- NULL
  local_mocked_bindings(load_srtr_file = function(file_key, ..., col_select) {
    schema <- fake_txf("KI")
    schema$TFL_SPARE_COLUMN <- 1
    selected <<- names(tidyselect::eval_select(rlang::enquo(col_select), schema))
    fake_txf("KI")
  })

  add_txf_outcomes(fake_tx("TX_KI"))

  expect_setequal(
    selected,
    c("TRR_ID", "ORG_TY", "TFL_MALIG", "TFL_ACUTE_REJ_EPISODE", "TFL_PX_STAT_DT")
  )
})

test_that("add_txf_outcomes() gives the same result from a real TXF file", {
  local_sas_file(
    tibble::tibble(
      TRR_ID = c(900001, 900001, 900002),
      ORG_TY = "KI",
      TFL_MALIG = c("N", "Y", "N"),
      TFL_ACUTE_REJ_EPISODE = c(1, 3, 1),
      TFL_PX_STAT_DT = as.Date(c("2001-01-01", "2002-01-01", "2003-01-01")),
      TFL_GRAFT_STAT = c("Y", "Y", "Y")
    ),
    "TXF_KI"
  )
  tx <- tibble::tibble(TRR_ID = c(900001, 900002, 900003))
  attr(tx, "file_key") <- "TX_KI"

  out <- suppressWarnings(add_txf_outcomes(tx))

  expect_equal(out$FIRST_FU_MALIG_DATE, as.Date(c("2002-01-01", NA, NA)))
  expect_equal(out$FIRST_FU_REJ_DATE, as.Date(c("2001-01-01", "2003-01-01", NA)))
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
    .srtr_add_txf_outcomes = function(df, ...) {
      df$FIRST_FU_REJ_DATE <- as.Date(c(NA, "2005-01-01"))
      attr(df, ".srtr_eligible") <- list(FIRST_FU_REJ_DATE = df$FIRST_FU_REJ_DATE)
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
  expect_named(out, c("TRR_ID", fu_columns("")))
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
  expect_named(out, c("TRR_ID", fu_columns(c("_KI", "_PA"))))
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

# ---- #213: admission rejection with no length of stay -----------------------

admission_rejection_cohort <- function() {
  df <- tibble::tibble(
    TRR_ID = c(900001, 900002, 900003, 900004),
    REC_TX_DT = as.Date("2000-01-01"),
    REC_POSTX_LOS = c(10, NA, NA, NA),
    REC_DISCHRG_DT = as.Date(c("2000-01-11", "2000-01-20", NA, NA)),
    REC_ACUTE_REJ_EPISODE = c(
      rep("1: Yes, at least one episode treated with anti-rejection agent", 3),
      "3: No"
    ),
    PERS_OPTN_DEATH_DT = as.Date(NA),
    PERS_SSA_DEATH_DT = as.Date(NA),
    TFL_DEATH_DT = as.Date(NA),
    TFL_GRAFT_DT = as.Date(NA),
    TFL_LAFUDATE = as.Date("2005-01-01")
  )
  attr(df, "file_key") <- "TX_KI"
  df
}

admission_rejection_txf <- function() {
  # A later follow-up rejection for 900003, whose admission rejection is undated.
  tibble::tibble(
    TRR_ID = 900003,
    ORG_TY = "KI",
    TFL_MALIG = "N",
    TFL_ACUTE_REJ_EPISODE = "1: Yes, at least one episode treated with anti-rejection agent",
    TFL_PX_STAT_DT = as.Date("2002-01-01")
  )
}

test_that("an admission rejection with no length of stay stays a rejection", {
  local_mocked_bindings(load_srtr_file = function(...) admission_rejection_txf())

  out <- suppressWarnings(add_time_to_event_outcomes(admission_rejection_cohort()))

  # 900001: length of stay; 900002: discharge date; 900003: no date at all.
  expect_equal(
    out$FIRST_REJ_DATE,
    as.Date(c("2000-01-11", "2000-01-20", NA, NA))
  )
  expect_equal(
    out$FIRST_REJ_DATE_SOURCE,
    c("admission_los", "admission_discharge", "admission_undated", NA)
  )
  expect_equal(out$FIRST_REJ_DATE_BINARY, c(1L, 1L, 1L, 0L))
  expect_equal(is.na(out$FIRST_REJ_DATE_days), c(FALSE, FALSE, TRUE, FALSE))
  expect_equal(out$FIRST_REJ_DATE_CENSOR[3], as.Date(NA))
  # The later follow-up rejection is kept in its own column, not substituted.
  expect_equal(out$FIRST_FU_REJ_DATE[3], as.Date("2002-01-01"))
})

test_that("an undated admission rejection is reported", {
  local_mocked_bindings(load_srtr_file = function(...) admission_rejection_txf())

  expect_warning(
    add_time_to_event_outcomes(admission_rejection_cohort()),
    class = "sRtr_warning_undated_admission_rejection"
  )
  expect_snapshot(out <- add_time_to_event_outcomes(admission_rejection_cohort()))
})

test_that("a follow-up rejection is dated as before when there is none at admission", {
  local_mocked_bindings(load_srtr_file = function(...) admission_rejection_txf())
  df <- admission_rejection_cohort()
  df$REC_ACUTE_REJ_EPISODE <- "3: No"

  out <- add_time_to_event_outcomes(df)

  expect_equal(out$FIRST_REJ_DATE, as.Date(c(NA, NA, "2002-01-01", NA)))
  expect_equal(out$FIRST_REJ_DATE_SOURCE, c(NA, NA, "follow_up", NA))
})

test_that("TX_KP applies the same rule to the kidney and the pancreas", {
  local_mocked_bindings(load_srtr_file = function(...) fake_cohort_txf("PA")[0, ])
  df <- fake_cohort("TX_KP")
  df$REC_POSTX_LOS <- NA
  df$REC_DISCHRG_DT <- as.Date(c("2000-01-20", NA))
  df$REC_ACUTE_REJ_EPISODE <- "1: Yes, at least one episode treated with anti-rejection agent"
  df$REC_ACUTE_REJ_EPISODE_PA <- "1: Yes, at least one episode treated with anti-rejection agent"

  out <- suppressWarnings(add_time_to_event_outcomes(df))

  expect_equal(out$FIRST_REJ_DATE, as.Date(c("2000-01-20", NA)))
  expect_equal(out$FIRST_REJ_DATE_PA, as.Date(c("2000-01-20", NA)))
  expect_equal(out$FIRST_REJ_DATE_BINARY, c(1L, 1L))
  expect_equal(out$FIRST_REJ_DATE_PA_BINARY, c(1L, 1L))
  expect_equal(out$FIRST_REJ_DATE_PA_SOURCE, c("admission_discharge", "admission_undated"))
})

test_that("a recipient whose positive forms are all undated gets NA, not Inf", {
  txf <- fake_txf("KI")
  txf$TFL_PX_STAT_DT[txf$TRR_ID == 900003] <- NA
  local_mocked_bindings(load_srtr_file = function(...) txf)

  expect_no_warning(out <- add_txf_outcomes(fake_tx("TX_KI")))

  expect_equal(out$FIRST_FU_REJ_DATE, as.Date(c("2001-01-01", NA, NA)))
})

test_that("an admission rejection is found in raw codes as well as labels", {
  local_mocked_bindings(load_srtr_file = function(...) admission_rejection_txf())
  labelled <- admission_rejection_cohort()
  raw <- labelled
  raw$REC_ACUTE_REJ_EPISODE <- c(1, 1, 1, 3)

  out_labelled <- suppressWarnings(add_time_to_event_outcomes(labelled))
  out_raw <- suppressWarnings(add_time_to_event_outcomes(raw))

  expect_equal(out_raw$FIRST_REJ_DATE_SOURCE, out_labelled$FIRST_REJ_DATE_SOURCE)
  expect_equal(out_raw$FIRST_REJ_DATE, out_labelled$FIRST_REJ_DATE)
  expect_equal(out_raw$FIRST_REJ_DATE_BINARY, c(1L, 1L, 1L, 0L))
})

test_that("raw TX_KP pancreas codes are read like labelled ones", {
  local_mocked_bindings(load_srtr_file = function(...) fake_cohort_txf("PA")[0, ])
  df <- fake_cohort("TX_KP")
  df$REC_ACUTE_REJ_EPISODE <- c(3, 3)
  df$REC_ACUTE_REJ_EPISODE_PA <- c(1, 3)

  out <- add_time_to_event_outcomes(df)

  expect_equal(out$FIRST_REJ_DATE_PA_SOURCE, c("admission_los", NA))
  expect_equal(out$FIRST_REJ_DATE_PA, as.Date(c("2000-01-11", NA)))
})

test_that("an admission date before the transplant is not used", {
  local_mocked_bindings(load_srtr_file = function(...) admission_rejection_txf()[0, ])
  df <- admission_rejection_cohort()[1:2, ]
  df$REC_POSTX_LOS <- c(-5, NA)
  df$REC_DISCHRG_DT <- as.Date(c("2000-01-15", "1999-12-31"))

  out <- suppressWarnings(add_time_to_event_outcomes(df))

  # 900001: negative length of stay, valid discharge date.
  # 900002: no length of stay, discharge before transplant: undated.
  expect_equal(out$FIRST_REJ_DATE, as.Date(c("2000-01-15", NA)))
  expect_equal(out$FIRST_REJ_DATE_SOURCE, c("admission_discharge", "admission_undated"))
  expect_equal(out$FIRST_REJ_DATE_BINARY, c(1L, 1L))
  expect_equal(out$FIRST_REJ_DATE_CENSOR, as.Date(c("2000-01-15", NA)))
})

test_that("a discharge date is kept when the transplant date is missing", {
  local_mocked_bindings(load_srtr_file = function(...) admission_rejection_txf()[0, ])
  df <- admission_rejection_cohort()[2, ]
  df$REC_TX_DT <- as.Date(NA)

  out <- suppressWarnings(add_time_to_event_outcomes(df))

  # The date cannot be checked against the transplant, but it is the best
  # date there is; the elapsed time is unknown without a start.
  expect_equal(out$FIRST_REJ_DATE, as.Date("2000-01-20"))
  expect_equal(out$FIRST_REJ_DATE_SOURCE, "admission_discharge")
  expect_equal(out$FIRST_REJ_DATE_BINARY, 1L)
  expect_equal(out$FIRST_REJ_DATE_days, NA_real_)
})

# ---- #214: follow-up evidence kept apart from "no event" --------------------

malig_forms <- function() {
  # Made-up forms. 900001: N, N, Y, Y. 900002: U then N. 900003: U and no
  # answer. 900004: no forms. 900005: an undated Y and an N. 900006: an N on
  # the day of the first Y, and an earlier N.
  tibble::tibble(
    TRR_ID = c(900001, 900001, 900001, 900001, 900002, 900002, 900003, 900003,
               900005, 900005, 900006, 900006, 900006),
    ORG_TY = "KI",
    TFL_MALIG = c("N", "N", "Y", "Y", "U", "N", "U", NA, "Y", "N", "N", "N", "Y"),
    TFL_ACUTE_REJ_EPISODE = "3: No",
    TFL_PX_STAT_DT = as.Date(c(
      "2001-01-01", "2002-01-01", "2003-01-01", "2004-01-01",
      "2001-01-01", "2002-01-01",
      "2001-01-01", "2002-01-01",
      NA, "2001-01-01",
      "2000-06-01", "2001-01-01", "2001-01-01"
    ))
  )
}

six_tx <- function(file_key = "TX_KI") {
  df <- tibble::tibble(TRR_ID = 900001:900006 + 0)
  attr(df, "file_key") <- file_key
  df
}

test_that("malignancy status keeps unknown and no follow-up apart from no event", {
  local_mocked_bindings(load_srtr_file = function(...) malig_forms())

  out <- add_txf_outcomes(six_tx())

  expect_equal(
    out$FIRST_FU_MALIG_STATUS,
    c("event", "no event", "unknown", "no follow-up", "event", "event")
  )
  # The undated report is evidence of an event with an unknown date.
  expect_equal(
    out$FIRST_FU_MALIG_DATE,
    as.Date(c("2003-01-01", NA, NA, NA, NA, "2001-01-01"))
  )
})

test_that("the last negative malignancy form is strictly before the first report", {
  local_mocked_bindings(load_srtr_file = function(...) malig_forms())

  out <- add_txf_outcomes(six_tx())

  # 900002: no report, so its last explicit "N"; 900003: no "N" at all;
  # 900005: report undated, so no bound; 900006: the same-day "N" does not count.
  expect_equal(
    out$FIRST_FU_MALIG_LAST_NEG_DATE,
    as.Date(c("2002-01-01", "2002-01-01", NA, NA, NA, "2000-06-01"))
  )
})

rejection_forms <- function(codes = c(3, 2, 1, 3, 998, 2, 998)) {
  # Made-up forms. 900001: no, untreated, treated. 900002: no, unknown.
  # 900003: untreated only. 900004: no forms. 900005: unknown only.
  tibble::tibble(
    TRR_ID = c(900001, 900001, 900001, 900002, 900002, 900003, 900005),
    ORG_TY = "KI",
    TFL_MALIG = "N",
    TFL_ACUTE_REJ_EPISODE = codes,
    TFL_PX_STAT_DT = as.Date(c(
      "2001-01-01", "2002-01-01", "2003-01-01",
      "2001-01-01", "2002-01-01",
      "2001-01-01",
      "2001-01-01"
    ))
  )
}

labelled_rejection <- function(codes) {
  meaning <- sRtr::formats$Meaning[sRtr::formats$Format == "ACREJEPF"]
  names(meaning) <- sRtr::formats$Code[sRtr::formats$Format == "ACREJEPF"]
  unname(meaning[as.character(codes)])
}

test_that("rejection status keeps untreated, unknown and no follow-up apart", {
  local_mocked_bindings(load_srtr_file = function(...) rejection_forms())

  out <- add_txf_outcomes(six_tx()[1:5, ])

  expect_equal(
    out$FIRST_FU_REJ_STATUS,
    c("event", "no event", "untreated", "no follow-up", "unknown")
  )
  expect_equal(out$FIRST_FU_REJ_DATE, as.Date(c("2003-01-01", NA, NA, NA, NA)))
  # An untreated rejection is not a negative form: 900001's bound is the "no".
  expect_equal(
    out$FIRST_FU_REJ_LAST_NEG_DATE,
    as.Date(c("2001-01-01", "2001-01-01", NA, NA, NA))
  )
})

test_that("rejection status reads raw codes and labels alike", {
  codes <- c(3, 2, 1, 3, 998, 2, 998)
  labelled <- rejection_forms(labelled_rejection(codes))
  local_mocked_bindings(load_srtr_file = function(...) rejection_forms(codes))
  raw_out <- add_txf_outcomes(six_tx()[1:5, ])
  local_mocked_bindings(load_srtr_file = function(...) labelled)
  labelled_out <- add_txf_outcomes(six_tx()[1:5, ])

  expect_equal(raw_out$FIRST_FU_REJ_STATUS, labelled_out$FIRST_FU_REJ_STATUS)
  expect_equal(raw_out$FIRST_FU_REJ_DATE, labelled_out$FIRST_FU_REJ_DATE)
  expect_equal(raw_out$FIRST_FU_REJ_DATE, as.Date(c("2003-01-01", NA, NA, NA, NA)))
})

test_that("TX_KP rejection status and bounds are kept per graft", {
  # 900001: kidney "no" in 2001, pancreas treated rejection in 2002. The
  # kidney form does not bound the pancreas rejection.
  forms <- tibble::tibble(
    TRR_ID = 900001,
    ORG_TY = c("KI", "PA"),
    TFL_MALIG = "N",
    TFL_ACUTE_REJ_EPISODE = labelled_rejection(c(3, 1)),
    TFL_PX_STAT_DT = as.Date(c("2001-01-01", "2002-01-01"))
  )
  local_mocked_bindings(load_srtr_file = function(...) forms)

  out <- add_txf_outcomes(six_tx("TX_KP")[1:2, ])

  expect_equal(out$FIRST_FU_REJ_STATUS_KI, c("no event", "no follow-up"))
  expect_equal(out$FIRST_FU_REJ_STATUS_PA, c("event", "no follow-up"))
  expect_equal(out$FIRST_FU_REJ_LAST_NEG_DATE_KI, as.Date(c("2001-01-01", NA)))
  expect_equal(out$FIRST_FU_REJ_LAST_NEG_DATE_PA, as.Date(c(NA, NA)))
  # Malignancy is patient-level: both organs' forms count.
  expect_equal(out$FIRST_FU_MALIG_STATUS, c("no event", "no follow-up"))
  expect_equal(out$FIRST_FU_MALIG_LAST_NEG_DATE, as.Date(c("2002-01-01", NA)))
})

# ---- #215: events counted only within follow-up and before death ------------

window_cohort <- function() {
  # Transplant 2000-01-01, last follow-up 2005-01-01.
  # 900001: report exactly at last follow-up. 900002: report one day after.
  # 900003: died 2003-01-01, report in 2004. 900004: died 2003-01-01, report
  # that day. 900005: died 2003-01-01, no report. 900006: no last follow-up.
  df <- tibble::tibble(
    TRR_ID = 900001:900006 + 0,
    REC_TX_DT = as.Date("2000-01-01"),
    REC_POSTX_LOS = 10,
    REC_ACUTE_REJ_EPISODE = "3: No",
    PERS_OPTN_DEATH_DT = as.Date(c(NA, NA, "2003-01-01", "2003-01-01", "2003-01-01", NA)),
    PERS_SSA_DEATH_DT = as.Date(NA),
    TFL_DEATH_DT = as.Date(NA),
    TFL_GRAFT_DT = as.Date(NA),
    TFL_LAFUDATE = as.Date(c(rep("2005-01-01", 5), NA))
  )
  attr(df, "file_key") <- "TX_KI"
  df
}

window_forms <- function() {
  tibble::tibble(
    TRR_ID = c(900001, 900002, 900003, 900004, 900006),
    ORG_TY = "KI",
    TFL_MALIG = "Y",
    TFL_ACUTE_REJ_EPISODE = "1: Yes, at least one episode treated with anti-rejection agent",
    TFL_PX_STAT_DT = as.Date(c(
      "2005-01-01", "2005-01-02", "2004-01-01", "2003-01-01", "2002-01-01"
    ))
  )
}

test_that("malignancy counts only through last follow-up and death, inclusive", {
  local_mocked_bindings(load_srtr_file = function(...) window_forms())

  out <- add_time_to_event_outcomes(window_cohort())

  expect_equal(out$FIRST_FU_MALIG_DATE_BINARY, c(1L, 0L, 0L, 1L, 0L, 0L))
  expect_equal(
    out$FIRST_FU_MALIG_DATE_CENSOR,
    as.Date(c("2005-01-01", "2005-01-01", "2003-01-01", "2003-01-01", "2003-01-01", NA))
  )
  # No last follow-up date: death is not substituted for it.
  expect_equal(out$FIRST_FU_MALIG_DATE_days[6], NA_real_)
  # Reports outside the window stay in the date column, for auditing.
  expect_equal(out$FIRST_FU_MALIG_DATE, window_forms()$TFL_PX_STAT_DT[c(1:4, NA, 5)])
})

test_that("rejection counts only through last follow-up and death, inclusive", {
  local_mocked_bindings(load_srtr_file = function(...) window_forms())

  out <- add_time_to_event_outcomes(window_cohort())

  expect_equal(out$FIRST_REJ_DATE_BINARY, c(1L, 0L, 0L, 1L, 0L, 0L))
  expect_equal(
    out$FIRST_REJ_DATE_CENSOR,
    as.Date(c("2005-01-01", "2005-01-01", "2003-01-01", "2003-01-01", "2003-01-01", NA))
  )
  expect_equal(out$FIRST_REJ_DATE, window_forms()$TFL_PX_STAT_DT[c(1:4, NA, 5)])
})

test_that("reports dated on the day of death are flagged", {
  local_mocked_bindings(load_srtr_file = function(...) window_forms())

  out <- add_time_to_event_outcomes(window_cohort())

  expect_equal(
    out$FIRST_FU_MALIG_DATE_DEATH_DAY,
    c(FALSE, FALSE, FALSE, TRUE, NA, FALSE)
  )
  expect_equal(out$FIRST_REJ_DATE_DEATH_DAY, c(FALSE, FALSE, FALSE, TRUE, NA, FALSE))
})

test_that("TX_KP rejection uses each graft's own follow-up window", {
  # Kidney followed to 2003, pancreas to 2005; both report a rejection in 2004.
  df <- fake_cohort("TX_KP")[1, ]
  df$TFL_LAFUDATEKI <- as.Date("2003-01-01")
  df$TFL_LAFUDATEPA <- as.Date("2005-01-01")
  forms <- tibble::tibble(
    TRR_ID = 900001,
    ORG_TY = c("KI", "PA"),
    TFL_MALIG = "N",
    TFL_ACUTE_REJ_EPISODE = "1: Yes, at least one episode treated with anti-rejection agent",
    TFL_PX_STAT_DT = as.Date("2004-01-01")
  )
  local_mocked_bindings(load_srtr_file = function(...) forms)

  out <- add_time_to_event_outcomes(df)

  expect_equal(out$FIRST_REJ_DATE_BINARY, 0L)
  expect_equal(out$FIRST_REJ_DATE_CENSOR, as.Date("2003-01-01"))
  expect_equal(out$FIRST_REJ_DATE_PA_BINARY, 1L)
  expect_equal(out$FIRST_REJ_DATE_PA_CENSOR, as.Date("2004-01-01"))
})

test_that("live: follow-up status, bounds and window hold on real liver files", {
  skip_if_no_srtr_file(c("TX_LI", "TXF_LI"))
  out <- withCallingHandlers(
    add_time_to_event_outcomes(load_live("TX_LI")),
    sRtr_warning_unknown_codes = function(cnd) rlang::cnd_muffle(cnd),
    sRtr_warning_undated_admission_rejection = function(cnd) rlang::cnd_muffle(cnd),
    sRtr_warning_undated_follow_up_report = function(cnd) rlang::cnd_muffle(cnd)
  )

  expect_in(
    out$FIRST_FU_MALIG_STATUS,
    c("event", "no event", "unknown", "no follow-up")
  )
  expect_in(
    out$FIRST_FU_REJ_STATUS,
    c("event", "untreated", "no event", "unknown", "no follow-up")
  )
  for (stem in c("MALIG", "REJ")) {
    date <- out[[paste0("FIRST_FU_", stem, "_DATE")]]
    status <- out[[paste0("FIRST_FU_", stem, "_STATUS")]]
    last_neg <- out[[paste0("FIRST_FU_", stem, "_LAST_NEG_DATE")]]
    expect_in(status[!is.na(date)], "event")
    both <- !is.na(date) & !is.na(last_neg)
    expect_equal(sum(last_neg[both] >= date[both]), 0)
  }
  for (prefix in c("FIRST_FU_MALIG_DATE", "FIRST_REJ_DATE")) {
    counted <- out[[paste0(prefix, "_BINARY")]] %in% 1 & !is.na(out[[prefix]])
    end <- pmin(out$TFL_LAFUDATE, out$REC_DEATH_DT_COMPOSITE, na.rm = TRUE)
    expect_equal(sum(out[[prefix]][counted] > end[counted], na.rm = TRUE), 0)
  }
})

# ---- #216: merge report ------------------------------------------------------

test_that("add_txf_outcomes() reports the merge in transplant registrations", {
  # Cohort rows: 900001 twice, 900002 (no forms), and a missing TRR_ID.
  # Forms: three for 900001 (one undated), one for 900003 (not in the
  # cohort), and a positive one with a missing TRR_ID.
  df <- tibble::tibble(TRR_ID = c(900001, 900001, 900002, NA))
  attr(df, "file_key") <- "TX_KI"
  forms <- tibble::tibble(
    TRR_ID = c(900001, 900001, 900001, 900003, NA),
    ORG_TY = "KI",
    TFL_MALIG = c("Y", "Y", "N", "Y", "Y"),
    TFL_ACUTE_REJ_EPISODE = labelled_rejection(c(1, 3, 3, 1, 1)),
    TFL_PX_STAT_DT = as.Date(c(NA, "2002-01-01", "2001-01-01", "2001-01-01", "2001-01-01"))
  )
  local_mocked_bindings(load_srtr_file = function(...) forms)

  report <- attr(add_txf_outcomes(df), "txf_report")

  expect_equal(report$follow_up_file, "TXF_KI")
  expect_equal(report$cohort_rows, 4)
  expect_equal(report$registrations, 2)
  expect_equal(report$registrations_with_forms, 1)
  expect_equal(report$forms, 3)
  expect_equal(report$forms_undated, 1)
  expect_equal(report$outcomes$outcome, c("malignancy", "rejection"))
  expect_equal(report$outcomes$column, c("FIRST_FU_MALIG_DATE", "FIRST_FU_REJ_DATE"))
  expect_equal(report$outcomes$positive_forms, c(2, 1))
  expect_equal(report$outcomes$registrations_with_report, c(1, 1))
  # The only treated rejection form is undated.
  expect_equal(report$outcomes$registrations_with_dated_report, c(1, 0))
  # The form with a missing TRR_ID is evidence for no row.
  out <- add_txf_outcomes(df)
  expect_equal(out$FIRST_FU_MALIG_STATUS, c("event", "event", "no follow-up", "no follow-up"))
})

test_that("the TX_KP merge report counts rejection per graft", {
  forms <- tibble::tibble(
    TRR_ID = 900001,
    ORG_TY = c("KI", "PA", "PA"),
    TFL_MALIG = "N",
    TFL_ACUTE_REJ_EPISODE = labelled_rejection(c(3, 1, 1)),
    TFL_PX_STAT_DT = as.Date(c("2001-01-01", "2002-01-01", "2003-01-01"))
  )
  local_mocked_bindings(load_srtr_file = function(...) forms)

  report <- attr(add_txf_outcomes(six_tx("TX_KP")[1:2, ]), "txf_report")

  expect_equal(report$outcomes$outcome, c("malignancy", "rejection, kidney", "rejection, pancreas"))
  expect_equal(report$outcomes$positive_forms, c(0, 0, 2))
  expect_equal(report$outcomes$registrations_with_report, c(0, 0, 1))
})

test_that("the merge report survives add_time_to_event_outcomes()", {
  local_mocked_bindings(load_srtr_file = function(...) window_forms())

  out <- add_time_to_event_outcomes(window_cohort())

  expect_equal(attr(out, "txf_report")$registrations_with_forms, 5)
})

# ---- review of cae0f22 -------------------------------------------------------

test_that("a registration listed twice gets the same outcomes on both rows", {
  df <- tibble::tibble(TRR_ID = c(900001, 900002, 900001))
  attr(df, "file_key") <- "TX_KI"
  forms <- tibble::tibble(
    TRR_ID = 900001,
    ORG_TY = "KI",
    TFL_MALIG = c("N", "Y"),
    TFL_ACUTE_REJ_EPISODE = labelled_rejection(c(3, 1)),
    TFL_PX_STAT_DT = as.Date(c("2001-01-01", "2002-01-01"))
  )
  local_mocked_bindings(load_srtr_file = function(...) forms)

  out <- add_txf_outcomes(df)

  expect_equal(out$FIRST_FU_MALIG_STATUS, c("event", "no follow-up", "event"))
  expect_equal(out$FIRST_FU_MALIG_DATE, as.Date(c("2002-01-01", NA, "2002-01-01")))
  expect_equal(out$FIRST_FU_MALIG_LAST_NEG_DATE, as.Date(c("2001-01-01", NA, "2001-01-01")))
  expect_equal(out$FIRST_FU_REJ_STATUS, c("event", "no follow-up", "event"))
  expect_equal(out$FIRST_FU_REJ_DATE, as.Date(c("2002-01-01", NA, "2002-01-01")))
})

test_that("a report dated before the transplant is not counted, but a later one is", {
  # 900001: report the day before transplant only. 900002: one the day before
  # and a later one in the window.
  df <- window_cohort()[1:2, ]
  forms <- tibble::tibble(
    TRR_ID = c(900001, 900002, 900002),
    ORG_TY = "KI",
    TFL_MALIG = "Y",
    TFL_ACUTE_REJ_EPISODE = "1: Yes, at least one episode treated with anti-rejection agent",
    TFL_PX_STAT_DT = as.Date(c("1999-12-31", "1999-12-31", "2002-01-01"))
  )
  local_mocked_bindings(load_srtr_file = function(...) forms)

  out <- add_time_to_event_outcomes(df)

  for (prefix in c("FIRST_FU_MALIG_DATE", "FIRST_REJ_DATE")) {
    expect_equal(out[[paste0(prefix, "_BINARY")]], c(0L, 1L))
    expect_equal(out[[paste0(prefix, "_CENSOR")]], as.Date(c("2005-01-01", "2002-01-01")))
  }
  # The follow-up date columns keep the first report, for auditing.
  expect_equal(out$FIRST_FU_MALIG_DATE, as.Date(rep("1999-12-31", 2)))
  expect_equal(out$FIRST_FU_REJ_DATE, as.Date(rep("1999-12-31", 2)))
  expect_equal(out$FIRST_REJ_DATE, as.Date(c(NA, "2002-01-01")))
  expect_equal(out$FIRST_REJ_DATE_SOURCE, c(NA, "follow_up"))
  expect_equal(grep("^\\.", names(out), value = TRUE), character())
})

test_that("an event reported only on undated forms has status 1 and no time", {
  df <- window_cohort()[1:2, ]
  forms <- tibble::tibble(
    TRR_ID = 900001,
    ORG_TY = "KI",
    TFL_MALIG = "Y",
    TFL_ACUTE_REJ_EPISODE = "1: Yes, at least one episode treated with anti-rejection agent",
    TFL_PX_STAT_DT = as.Date(NA)
  )
  local_mocked_bindings(load_srtr_file = function(...) forms)

  out <- suppressWarnings(add_time_to_event_outcomes(df))

  for (prefix in c("FIRST_FU_MALIG_DATE", "FIRST_REJ_DATE")) {
    expect_equal(out[[paste0(prefix, "_BINARY")]], c(1L, 0L))
    expect_equal(out[[paste0(prefix, "_CENSOR")]], as.Date(c(NA, "2005-01-01")))
    expect_equal(out[[paste0(prefix, "_days")]], c(NA, 1828))
  }
  expect_equal(out$FIRST_REJ_DATE_SOURCE, c("follow_up_undated", NA))
})

test_that("an event reported only on undated forms is reported", {
  df <- window_cohort()[1:2, ]
  forms <- tibble::tibble(
    TRR_ID = 900001,
    ORG_TY = "KI",
    TFL_MALIG = "Y",
    TFL_ACUTE_REJ_EPISODE = "1: Yes, at least one episode treated with anti-rejection agent",
    TFL_PX_STAT_DT = as.Date(NA)
  )
  local_mocked_bindings(load_srtr_file = function(...) forms)

  # One warning for the rejection and one for the malignancy.
  expect_warning(
    expect_warning(
      add_time_to_event_outcomes(df),
      class = "sRtr_warning_undated_follow_up_report"
    ),
    class = "sRtr_warning_undated_follow_up_report"
  )
  expect_snapshot(out <- add_time_to_event_outcomes(df))
})

test_that("a registration's transplant date is used whichever row has it", {
  # 900001 twice: one row has no transplant date. Reports before and after
  # the transplant; the later one counts, whichever row comes first.
  forms <- tibble::tibble(
    TRR_ID = 900001,
    ORG_TY = "KI",
    TFL_MALIG = "Y",
    TFL_ACUTE_REJ_EPISODE = "1: Yes, at least one episode treated with anti-rejection agent",
    TFL_PX_STAT_DT = as.Date(c("1999-12-31", "2002-01-01"))
  )
  local_mocked_bindings(load_srtr_file = function(...) forms)
  df <- window_cohort()[c(1, 1), ]
  df$REC_TX_DT[1] <- NA

  for (rows in list(1:2, 2:1)) {
    out <- add_time_to_event_outcomes(df[rows, ])
    known <- which(!is.na(out$REC_TX_DT))
    expect_equal(out$FIRST_FU_MALIG_DATE_BINARY[known], 1L)
    expect_equal(out$FIRST_FU_MALIG_DATE_CENSOR[known], as.Date("2002-01-01"))
    expect_equal(out$FIRST_REJ_DATE[known], as.Date("2002-01-01"))
  }
})

test_that("a caller's own columns that look like helpers are kept", {
  local_mocked_bindings(load_srtr_file = function(...) window_forms())
  df <- window_cohort()
  df$.FIRST_FU_note <- "kept"
  df$.FIRST_FU_MALIG_ELIGIBLE <- "also kept"

  out <- add_time_to_event_outcomes(df)

  expect_equal(out$.FIRST_FU_note, rep("kept", 6))
  expect_equal(out$.FIRST_FU_MALIG_ELIGIBLE, rep("also kept", 6))
  expect_equal(out$FIRST_FU_MALIG_DATE_BINARY, c(1L, 0L, 0L, 1L, 0L, 0L))
})

test_that("a plain data frame keeps its attributes", {
  local_mocked_bindings(load_srtr_file = function(...) window_forms())
  df <- as.data.frame(window_cohort())
  attr(df, "file_key") <- "TX_KI"
  attr(df, "srtr_note") <- "kept"

  out <- add_time_to_event_outcomes(df)

  expect_equal(attr(out, "file_key"), "TX_KI")
  expect_equal(attr(out, "srtr_note"), "kept")
  expect_null(attr(out, ".srtr_eligible"))
  expect_null(attr(add_txf_outcomes(df), ".srtr_eligible"))
  expect_equal(attr(out, "txf_report")$registrations_with_forms, 5)
})

# ---- #21: rejection after graft failure ---------------------------------------

gf_cohort <- function() {
  # Transplant 2000-01-01, last follow-up 2006-01-01, graft failed 2003-01-01
  # (900001-900004); 900005 has no graft failure.
  df <- window_cohort()[1:5, ]
  df$PERS_OPTN_DEATH_DT <- as.Date(NA)
  df$TFL_LAFUDATE <- as.Date("2006-01-01")
  df$TFL_GRAFT_DT <- as.Date(c(rep("2003-01-01", 4), NA))
  df
}

gf_forms <- function(fol = c(801, 10, 800, 801, 801)) {
  # 900001: rejection on a "1 year after graft failure" form, 2004.
  # 900002: rejection on an ordinary form dated after the failure, 2004.
  # 900003: rejection on the form filed at graft failure, 2003-01-01.
  # 900004: rejection on a post-failure form, and an earlier one in 2002.
  # 900005: no graft failure; a 801 form cannot happen, but it is not used.
  tibble::tibble(
    TRR_ID = c(900001, 900002, 900003, 900004, 900004, 900005),
    ORG_TY = "KI",
    TFL_FOL_CD = c(fol[1:4], 20, fol[5]),
    TFL_MALIG = "Y",
    TFL_ACUTE_REJ_EPISODE = "1: Yes, at least one episode treated with anti-rejection agent",
    TFL_PX_STAT_DT = as.Date(c(
      "2004-01-01", "2004-01-01", "2003-01-01", "2004-01-01", "2002-01-01", "2004-01-01"
    ))
  )
}

test_that("by default, rejection after graft failure does not count", {
  local_mocked_bindings(load_srtr_file = function(...) gf_forms())

  out <- add_time_to_event_outcomes(gf_cohort())

  expect_equal(out$FIRST_REJ_DATE_BINARY, c(0L, 0L, 1L, 1L, 0L))
  expect_equal(
    out$FIRST_REJ_DATE_CENSOR,
    as.Date(c("2003-01-01", "2003-01-01", "2003-01-01", "2002-01-01", "2006-01-01"))
  )
  # The follow-up date column still reports the first report of all.
  expect_equal(out$FIRST_FU_REJ_DATE[1], as.Date("2004-01-01"))
  # Malignancy is patient-level: post-failure forms still count.
  expect_equal(out$FIRST_FU_MALIG_DATE_BINARY, c(1L, 1L, 1L, 1L, 1L))
})

test_that("rejection_after_graft_failure = 'keep' counts them", {
  local_mocked_bindings(load_srtr_file = function(...) gf_forms())

  out <- add_time_to_event_outcomes(gf_cohort(), rejection_after_graft_failure = "keep")

  expect_equal(out$FIRST_REJ_DATE_BINARY, rep(1L, 5))
  expect_equal(out$FIRST_REJ_DATE[1:2], as.Date(c("2004-01-01", "2004-01-01")))
})

test_that("the follow-up code is read raw or labelled", {
  meaning <- sRtr::formats$Meaning[sRtr::formats$Format == "FOLCD"]
  names(meaning) <- sRtr::formats$Code[sRtr::formats$Format == "FOLCD"]
  codes <- c(801, 10, 800, 801, 801)
  labelled <- gf_forms(unname(meaning[as.character(codes)]))
  labelled$TFL_FOL_CD[5] <- meaning[["20"]]
  local_mocked_bindings(load_srtr_file = function(...) labelled)
  out <- add_time_to_event_outcomes(gf_cohort())
  expect_equal(out$FIRST_REJ_DATE_BINARY, c(0L, 0L, 1L, 1L, 0L))
})

test_that("an admission rejection counts even when the graft failed during the admission", {
  df <- gf_cohort()[1, ]
  df$REC_ACUTE_REJ_EPISODE <- "1: Yes, at least one episode treated with anti-rejection agent"
  df$REC_POSTX_LOS <- 20
  df$TFL_GRAFT_DT <- as.Date("2000-01-10")
  local_mocked_bindings(load_srtr_file = function(...) gf_forms()[1, ])

  out <- add_time_to_event_outcomes(df)

  expect_equal(out$FIRST_REJ_DATE_SOURCE, "admission_los")
  expect_equal(out$FIRST_REJ_DATE_BINARY, 1L)
})

test_that("an unknown rejection_after_graft_failure is an error", {
  expect_error(
    add_time_to_event_outcomes(gf_cohort(), rejection_after_graft_failure = "drop"),
    class = "rlang_error"
  )
})

test_that("TX_KP rejection is bounded by its own graft's failure", {
  # Kidney failed 2002; both grafts report a rejection in 2003.
  df <- fake_cohort("TX_KP")[1, ]
  df$TFL_GRAFT_DT_KI <- as.Date("2002-01-01")
  forms <- tibble::tibble(
    TRR_ID = 900001,
    ORG_TY = c("KI", "PA"),
    TFL_FOL_CD = c(10, 30),
    TFL_MALIG = "N",
    TFL_ACUTE_REJ_EPISODE = "1: Yes, at least one episode treated with anti-rejection agent",
    TFL_PX_STAT_DT = as.Date("2003-01-01")
  )
  local_mocked_bindings(load_srtr_file = function(...) forms)

  out <- add_time_to_event_outcomes(df)

  expect_equal(out$FIRST_REJ_DATE_BINARY, 0L)
  expect_equal(out$FIRST_REJ_DATE_CENSOR, as.Date("2002-01-01"))
  expect_equal(out$FIRST_REJ_DATE_PA_BINARY, 1L)
})

# ---- #218 review: one registration, two transplant dates ---------------------

test_that("a registration with two different transplant dates is an error", {
  df <- window_cohort()[c(1, 1), ]
  df$REC_TX_DT[2] <- as.Date("2000-06-01")
  local_mocked_bindings(load_srtr_file = function(...) window_forms())

  expect_error(add_time_to_event_outcomes(df), class = "sRtr_error_conflicting_transplant_dates")
  expect_snapshot(error = TRUE, add_time_to_event_outcomes(df))
})
