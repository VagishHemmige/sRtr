# Review-only proposals. Every identifier and date below is invented.
# Run only through the isolated synthetic runner described in ../README.md.

testthat::test_that("report dates resist form order and duplicated reporting", {
  cohort <- tibble::tibble(TRR_ID = "SYNTHETIC-TX-A")
  attr(cohort, "file_key") <- "TX_HR"
  forms <- tibble::tibble(
    TRR_ID = rep("SYNTHETIC-TX-A", 4),
    ORG_TY = "HR",
    TFL_MALIG = c("Y", "N", "Y", "Y"),
    TFL_ACUTE_REJ_EPISODE = "3: No",
    TFL_PX_STAT_DT = as.Date(c(
      "2002-01-01", "2000-06-01", "2001-01-01", "2001-01-01"
    ))
  )
  testthat::local_mocked_bindings(load_srtr_file = function(...) forms)
  original <- add_txf_outcomes(cohort)
  forms <- forms[c(4, 2, 1, 3, 3), ]
  reordered <- add_txf_outcomes(cohort)

  testthat::expect_equal(original$FIRST_FU_MALIG_DATE, as.Date("2001-01-01"))
  testthat::expect_equal(reordered, original)
  testthat::expect_equal(nrow(original), 1L)
})

testthat::test_that("follow-up reports attach by transplant ID while person and donor metadata are preserved", {
  cohort <- tibble::tibble(
    TRR_ID = c("SYNTHETIC-TX-B", "SYNTHETIC-TX-A", "SYNTHETIC-TX-C"),
    PERS_ID = c("SYNTHETIC-PERSON-1", "SYNTHETIC-PERSON-1", "SYNTHETIC-PERSON-2"),
    DONOR_ID = c("SYNTHETIC-DONOR-2", "SYNTHETIC-DONOR-1", "SYNTHETIC-DONOR-1")
  )
  attr(cohort, "file_key") <- "TX_KI"
  forms <- tibble::tibble(
    TRR_ID = c("SYNTHETIC-TX-A", "SYNTHETIC-TX-C", "SYNTHETIC-TX-A"),
    ORG_TY = "KI",
    TFL_MALIG = c("Y", "N", "Y"),
    TFL_ACUTE_REJ_EPISODE = c(
      "3: No", "1: Yes, at least one episode treated with anti-rejection agent", "3: No"
    ),
    TFL_PX_STAT_DT = as.Date(c("2001-01-01", "2001-02-01", "2002-01-01"))
  )
  requested <- NULL
  testthat::local_mocked_bindings(load_srtr_file = function(file_key, trr_id_filter) {
    requested <<- list(key = file_key, ids = trr_id_filter)
    forms
  })
  out <- add_txf_outcomes(cohort)

  testthat::expect_identical(out[names(cohort)], cohort)
  testthat::expect_setequal(requested$ids, cohort$TRR_ID)
  testthat::expect_identical(requested$key, "TXF_KI")
  testthat::expect_equal(out$FIRST_FU_MALIG_DATE, as.Date(c(NA, "2001-01-01", NA)))
  testthat::expect_equal(out$FIRST_FU_REJ_DATE, as.Date(c(NA, NA, "2001-02-01")))
})

testthat::test_that("extending ascertainment changes only eligible death follow-up", {
  cohort <- tibble::tibble(
    TRR_ID = paste0("SYNTHETIC-TX-", 1:3),
    REC_TX_DT = as.Date("2000-01-01"),
    REC_POSTX_LOS = 10,
    REC_ACUTE_REJ_EPISODE = "3: No",
    PERS_OPTN_DEATH_DT = as.Date(c("2001-01-01", "2003-01-01", NA)),
    PERS_SSA_DEATH_DT = as.Date(NA),
    TFL_DEATH_DT = as.Date(NA),
    TFL_GRAFT_DT = as.Date(c(NA, "2002-06-01", NA)),
    TFL_LAFUDATE = as.Date("2001-06-01")
  )
  attr(cohort, "file_key") <- "TX_KI"
  forms <- tibble::tibble(
    TRR_ID = character(), ORG_TY = character(), TFL_MALIG = character(),
    TFL_ACUTE_REJ_EPISODE = character(), TFL_PX_STAT_DT = as.Date(character())
  )
  testthat::local_mocked_bindings(load_srtr_file = function(...) forms)
  early <- add_time_to_event_outcomes(
    cohort, death_window = "ascertainment", ascertainment_date = "2002-01-01"
  )
  late <- add_time_to_event_outcomes(
    cohort, death_window = "ascertainment", ascertainment_date = "2004-01-01"
  )

  testthat::expect_equal(early$REC_DEATH_DT_COMPOSITE_BINARY, c(1L, 0L, 0L))
  testthat::expect_equal(late$REC_DEATH_DT_COMPOSITE_BINARY, c(1L, 1L, 0L))
  testthat::expect_equal(
    late$REC_DEATH_DT_COMPOSITE_CENSOR,
    as.Date(c("2001-01-01", "2003-01-01", "2004-01-01"))
  )
  testthat::expect_equal(
    late$REC_DEATH_DT_COMPOSITE_days - early$REC_DEATH_DT_COMPOSITE_days,
    c(0, 365, 730)
  )
  other <- setdiff(names(early), c(
    "REC_DEATH_DT_COMPOSITE_BINARY", "REC_DEATH_DT_COMPOSITE_CENSOR",
    "REC_DEATH_DT_COMPOSITE_days"
  ))
  testthat::expect_equal(late[other], early[other])
})

testthat::test_that("decision probe records the effect of recomputing a chosen death composite", {
  cohort <- tibble::tibble(
    TRR_ID = "SYNTHETIC-TX-A", REC_TX_DT = as.Date("2000-01-01"),
    REC_POSTX_LOS = 10, REC_ACUTE_REJ_EPISODE = "3: No",
    PERS_OPTN_DEATH_DT = as.Date("2003-01-01"),
    PERS_SSA_DEATH_DT = as.Date("2001-01-01"), TFL_DEATH_DT = as.Date(NA),
    TFL_GRAFT_DT = as.Date("2001-06-01"),
    TFL_LAFUDATE = as.Date("2002-01-01")
  )
  attr(cohort, "file_key") <- "TX_KI"
  forms <- tibble::tibble(
    TRR_ID = character(), ORG_TY = character(), TFL_MALIG = character(),
    TFL_ACUTE_REJ_EPISODE = character(), TFL_PX_STAT_DT = as.Date(character())
  )
  testthat::local_mocked_bindings(load_srtr_file = function(...) forms)
  selected <- srtr_composite_death(cohort, prefer_earliest = TRUE)
  direct <- srtr_time_to_event(
    selected, REC_DEATH_DT_COMPOSITE, REC_TX_DT, TFL_LAFUDATE,
    prefix = "SELECTED", units = "days"
  )
  pipeline <- add_time_to_event_outcomes(selected)

  # Characterization only: this contrast is not an approved scientific default.
  testthat::expect_equal(selected$REC_DEATH_DT_COMPOSITE, as.Date("2001-01-01"))
  testthat::expect_equal(direct$SELECTED_BINARY, 1L)
  testthat::expect_equal(pipeline$REC_DEATH_DT_COMPOSITE, as.Date("2003-01-01"))
  testthat::expect_equal(pipeline$REC_DEATH_DT_COMPOSITE_BINARY, 0L)
  testthat::expect_equal(pipeline$TFL_GRAFT_DT_BINARY, 1L)
})
