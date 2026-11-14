# Synthetic regression candidates; see ../README.md for expectations and limits.
testthat::test_that("PDRI retains original dot-prefixed columns", {
  x <- synthetic_donor()
  x$.analysis_weight <- 7
  y <- add_pdri(x, variant = "KP")
  testthat::expect_equal(y[[".analysis_weight"]], 7)
})
testthat::test_that("missing race propagates across encodings", {
  x <- synthetic_donor()
  x$DON_RACE <- NA_character_
  testthat::expect_equal(as.numeric(add_pdri(x, variant = "KP")$PDRI), NA_real_)
})
testthat::test_that("no-op normalization preserves factor analysis coding", {
  x <- data.frame(FAKE = ordered(c("B", "A"), levels = c("A", "B", "C")))
  y <- srtr_normalize_missing(x, missing_vals = list(FAKE = "UNKNOWN"))
  testthat::expect_identical(y$FAKE, x$FAKE)
})
testthat::test_that("reapplying factor labels preserves observations", {
  x <- tibble::tibble(CAN_ABO = c("A", "A2"))
  once <- apply_srtr_factors(x, file_key = "TX_KI")
  twice <- apply_srtr_factors(once, file_key = "TX_KI")
  testthat::expect_identical(twice$CAN_ABO, once$CAN_ABO)
})
testthat::test_that("undated positive forms yield missing dates not infinity", {
  testthat::local_mocked_bindings(load_srtr_file = function(...) synthetic_followup(date = as.Date(NA)))
  y <- add_txf_outcomes(synthetic_cohort())
  testthat::expect_identical(y$FIRST_FU_MALIG_DATE, as.Date(NA))
  testthat::expect_identical(y$FIRST_FU_REJ_DATE, as.Date(NA))
})
testthat::test_that("epsilon does not mask a pre-origin event", {
  x <- data.frame(start = as.Date("2000-01-02"), event = as.Date("2000-01-01"), end = as.Date("2000-01-10"))
  y <- suppressWarnings(srtr_time_to_event(x, event, start, end, prefix = "FAKE", units = "days"))
  testthat::expect_equal(y$FAKE_days, NA_real_)
})
testthat::test_that("documented time units use exact hand-worked conversion", {
  x <- data.frame(start = as.Date("2000-01-01"), event = as.Date("2001-01-01"), end = as.Date("2002-01-01"))
  y <- srtr_time_to_event(x, event, start, end, prefix = "FAKE", units = "days", add_epsilon = 0)
  testthat::expect_equal(y$FAKE_BINARY, 1L)
  testthat::expect_equal(y$FAKE_CENSOR, as.Date("2001-01-01"))
  testthat::expect_equal(y$FAKE_days, 366)
  z <- srtr_time_to_event(x, event, start, end, prefix = "FAKE", units = "years", add_epsilon = 0)
  testthat::expect_equal(z$FAKE_yrs, 366/365.25)
})
testthat::test_that("thoracic and abdominal keys use their own followup table", {
  for (organ in c("KI", "PA", "HR", "LU", "HL", "LI", "IN")) {
    seen <- NULL
    testthat::local_mocked_bindings(load_srtr_file = function(file_key, ...) {
      seen <<- file_key
      synthetic_followup(organ = organ)
    })
    y <- add_txf_outcomes(synthetic_cohort(organ))
    testthat::expect_equal(seen, paste0("TXF_", organ))
    testthat::expect_equal(y$FIRST_FU_REJ_DATE, as.Date("2000-01-05"))
    testthat::expect_equal(nrow(y), 1L)
  }
})
testthat::test_that("PDRI is invariant to documented default loader labeling", {
  raw <- synthetic_donor()
  labeled <- apply_srtr_factors(raw, file_key = "TX_KP")
  a <- add_pdri(raw, variant = "KP")
  b <- add_pdri(labeled, variant = "KP")
  testthat::expect_equal(as.numeric(b$PDRI), as.numeric(a$PDRI))
})
testthat::test_that("a selected synthetic SAS file round trips without row inflation", {
  dir <- withr::local_tempdir()
  withr::local_envvar(SRTR_WD = dir)
  x <- data.frame(TRR_ID = c(900001, 900002), FAKE_VALUE = c(7, 8))
  suppressWarnings(haven::write_sas(x, file.path(dir, "AUDIT.sas7bdat")))
  y <- load_srtr_file("AUDIT", trr_id_filter = 900002, col_select = "FAKE_VALUE", factor_labels = FALSE, var_labels = FALSE)
  testthat::expect_equal(y$FAKE_VALUE, 8)
  testthat::expect_named(y, "FAKE_VALUE")
})
testthat::test_that("raw and labeled rejection codes identify the same event", {
  testthat::local_mocked_bindings(load_srtr_file = function(...) synthetic_followup()[0, ])
  raw <- synthetic_cohort("LI")
  raw$REC_ACUTE_REJ_EPISODE <- 1
  labeled <- raw
  labeled$REC_ACUTE_REJ_EPISODE <- "1: Yes, at least one episode treated with anti-rejection agent"
  a <- add_time_to_event_outcomes(raw)
  b <- add_time_to_event_outcomes(labeled)
  testthat::expect_equal(a$FIRST_REJ_DATE_BINARY, b$FIRST_REJ_DATE_BINARY)
  testthat::expect_equal(a$FIRST_REJ_DATE_CENSOR, b$FIRST_REJ_DATE_CENSOR)
  testthat::expect_equal(a$FIRST_REJ_DATE_days, b$FIRST_REJ_DATE_days)
})
testthat::test_that("empty composite inputs preserve a typed empty result", {
  x <- synthetic_cohort()[0, ]
  y <- srtr_composite_death(x, prefer_earliest = TRUE)
  testthat::expect_equal(nrow(y), 0L)
  testthat::expect_s3_class(y$REC_DEATH_DT_COMPOSITE, "Date")
  testthat::expect_identical(y$REC_DEATH_DT_COMPOSITE_conflict, logical())
})
testthat::test_that("normalization works after SRLSTT factor labeling", {
  x <- tibble::tibble(DON_EBV_IGG = "U")
  x <- apply_srtr_factors(x, file_key = "DONOR_DECEASED")
  testthat::expect_equal(as.character(x$DON_EBV_IGG), "U: Unknown")
  testthat::expect_equal(is.na(srtr_normalize_missing(x)$DON_EBV_IGG), TRUE)
})
testthat::test_that("outcome orchestration preserves caller dot columns", {
  testthat::local_mocked_bindings(load_srtr_file = function(...) synthetic_followup()[0, ])
  x <- synthetic_cohort()
  x$.patient_lafu <- "caller-owned"
  y <- add_time_to_event_outcomes(x)
  testthat::expect_identical(y[[".patient_lafu"]], x$.patient_lafu)
})
testthat::test_that("unknown transplant keys do not link unrelated followup forms", {
  x <- synthetic_cohort()
  x$TRR_ID <- NA_real_
  f <- synthetic_followup()
  f$TRR_ID <- NA_real_
  testthat::local_mocked_bindings(load_srtr_file = function(...) f)
  y <- add_txf_outcomes(x)
  testthat::expect_equal(y$FIRST_FU_MALIG_DATE, as.Date(NA))
  testthat::expect_equal(y$FIRST_FU_REJ_DATE, as.Date(NA))
})
