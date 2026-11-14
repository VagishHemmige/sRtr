# Reconciliation reproducer: all values below are invented, not SAF records.
# Positive later reporting establishes evidence, not the true onset date.

testthat::test_that("KI missing admission duration does not erase dated positive follow-up", {
  yes <- "1: Yes, at least one episode treated with anti-rejection agent"
  cohort <- tibble::tibble(
    TRR_ID = "SYNTHETIC-TX-KI", REC_TX_DT = as.Date("2000-01-01"),
    REC_POSTX_LOS = NA_real_, REC_ACUTE_REJ_EPISODE = yes,
    PERS_OPTN_DEATH_DT = as.Date(NA), PERS_SSA_DEATH_DT = as.Date(NA),
    TFL_DEATH_DT = as.Date(NA), TFL_GRAFT_DT = as.Date(NA),
    TFL_LAFUDATE = as.Date("2002-01-01")
  )
  attr(cohort, "file_key") <- "TX_KI"
  forms <- tibble::tibble(
    TRR_ID = "SYNTHETIC-TX-KI", ORG_TY = "KI", TFL_MALIG = "N",
    TFL_ACUTE_REJ_EPISODE = yes, TFL_PX_STAT_DT = as.Date("2001-01-01")
  )
  testthat::local_mocked_bindings(load_srtr_file = function(...) forms)
  out <- add_time_to_event_outcomes(cohort)

  testthat::expect_equal(out$FIRST_FU_REJ_DATE, as.Date("2001-01-01"))
  testthat::expect_equal(out$FIRST_REJ_DATE_BINARY, 1L)
})

testthat::test_that("KP missing admission duration does not erase either graft's positive follow-up", {
  yes <- "1: Yes, at least one episode treated with anti-rejection agent"
  cohort <- tibble::tibble(
    TRR_ID = "SYNTHETIC-TX-KP", REC_TX_DT = as.Date("2000-01-01"),
    REC_POSTX_LOS = NA_real_, REC_ACUTE_REJ_EPISODE = yes,
    REC_ACUTE_REJ_EPISODE_PA = yes,
    PERS_OPTN_DEATH_DT = as.Date(NA), PERS_SSA_DEATH_DT = as.Date(NA),
    TFL_DEATH_DT = as.Date(NA),
    TFL_GRAFT_DT_KI = as.Date(NA), TFL_GRAFT_DT_PA = as.Date(NA),
    TFL_LAFUDATEKI = as.Date("2002-01-01"),
    TFL_LAFUDATEPA = as.Date("2002-01-01")
  )
  attr(cohort, "file_key") <- "TX_KP"
  forms <- tibble::tibble(
    TRR_ID = "SYNTHETIC-TX-KP", ORG_TY = c("KI", "PA"), TFL_MALIG = "N",
    TFL_ACUTE_REJ_EPISODE = yes,
    TFL_PX_STAT_DT = as.Date(c("2001-01-01", "2001-02-01"))
  )
  testthat::local_mocked_bindings(load_srtr_file = function(...) forms)
  out <- add_time_to_event_outcomes(cohort)

  testthat::expect_equal(out$FIRST_FU_REJ_DATE_KI, as.Date("2001-01-01"))
  testthat::expect_equal(out$FIRST_FU_REJ_DATE_PA, as.Date("2001-02-01"))
  testthat::expect_equal(out$FIRST_REJ_DATE_BINARY, 1L)
  testthat::expect_equal(out$FIRST_REJ_DATE_PA_BINARY, 1L)
})
