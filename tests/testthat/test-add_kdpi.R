# The two worked examples are the donors in the OPTN KDPI guides: the 2026
# guide (refit) and the 2020 guide (Rao 2009, with the 2018 table).
guide_donor <- function(...) {
  tibble::tibble(
    DON_AGE = 52,
    DON_HGT_CM = 183,
    DON_WGT_KG = 81,
    DON_HIST_HYPERTEN = 2,
    DON_HIST_DIAB = 1,
    DON_CAD_DON_COD = 2,
    DON_CREAT = 1.7,
    DON_NON_HR_BEAT = "Y",
    DON_RACE = 2000,
    DON_ANTI_HCV = "N",
    ...
  )
}

test_that("refit KDRI matches the OPTN guide's worked example", {
  out <- add_kdpi(guide_donor(), version = "refit2024")
  expect_equal(out$KDRI_RAO, 1.71235565748184, tolerance = 1e-12, ignore_attr = TRUE)
  # The guide then scales by the 2024-donor median, whose table OPTN has not
  # archived, so its KDPI (72%) cannot be checked here.
  expect_equal(out$KDRI, out$KDRI_RAO / 1.45737870501158, ignore_attr = TRUE)
})

test_that("Rao 2009 KDRI and KDPI match the 2020 guide's worked example", {
  out <- add_kdpi(guide_donor(), version = "rao2009", table = "2018")
  expect_equal(out$KDRI_RAO, 1.77531877792565, tolerance = 1e-12, ignore_attr = TRUE)
  expect_equal(out$KDRI, 1.4194649431395, tolerance = 1e-12, ignore_attr = TRUE)
  # The guide prints KDPI = 63%, but no stored table maps this KDRI to 63:
  # the 2018 table puts it in (1.41295, 1.43347], which is 83%.
  expect_equal(out$KDPI, 83, ignore_attr = TRUE)
})

test_that("each age and weight branch follows its coefficient", {
  donors <- guide_donor()[rep(1, 3), ]
  donors$DON_AGE <- c(10, 40, 70)
  donors$DON_WGT_KG <- c(30, 80, 100)
  terms <- add_kdpi(donors, version = "refit2024", return_terms = TRUE)$KDRI_terms
  expect_equal(terms[[1]][["age"]], 0.0092 * (10 - 40) + 0.0113 * (10 - 18))
  expect_equal(terms[[2]][["age"]], 0)
  expect_equal(terms[[3]][["age"]], 0.0092 * 30 + 0.0067 * 20)
  expect_equal(terms[[1]][["weight"]], -0.0333 * (30 - 80) / 5)
  expect_equal(terms[[3]][["weight"]], 0)
})

test_that("creatinine above 8 counts as 8", {
  donors <- guide_donor()[rep(1, 2), ]
  donors$DON_CREAT <- c(8, 15)
  out <- add_kdpi(donors)
  expect_equal(out$KDRI_RAO[[1]], out$KDRI_RAO[[2]])
})

test_that("unknown hypertension uses the table's percentage or gives NA", {
  donor <- guide_donor(DON_HIST_HYPERTEN = NULL)
  donor$DON_HIST_HYPERTEN <- 998
  meta <- optn_mapping_tables$tables
  pct <- meta$hypertension_pct[meta$score == "kdpi" & meta$label == "current"]

  optn <- add_kdpi(donor, return_terms = TRUE)
  expect_equal(optn$KDRI_terms[[1]][["hypertension"]], 0.1106 * pct / 100)

  expect_message(
    na <- add_kdpi(donor, unknown_history = "na"),
    class = "sRtr_message_score_missing_inputs"
  )
  expect_equal(na$KDRI_RAO, NA_real_, ignore_attr = TRUE)
})

test_that("labelled factor codes give the same result as raw codes", {
  raw <- guide_donor()
  labelled <- raw
  labelled$DON_HIST_HYPERTEN <- factor("2: YES, 0-5 YEARS")
  labelled$DON_HIST_DIAB <- factor("1: NO")
  labelled$DON_CAD_DON_COD <- factor("2: CEREBROVASCULAR/STROKE")
  expect_equal(add_kdpi(labelled)$KDRI_RAO, add_kdpi(raw)$KDRI_RAO)
})

test_that("cause of death falls back to DON_COD_DON_STROKE", {
  raw <- guide_donor()
  stroke <- raw
  stroke$DON_CAD_DON_COD <- NULL
  stroke$DON_COD_DON_STROKE <- 1
  expect_equal(add_kdpi(stroke)$KDRI_RAO, add_kdpi(raw)$KDRI_RAO)
})

test_that("Rao 2009 race and HCV terms read SAF codes", {
  donors <- guide_donor()[rep(1, 3), ]
  donors$DON_RACE <- c(16, 8, 8)
  donors$DON_ANTI_HCV <- c("N", "P", "U")
  terms <- add_kdpi(donors, version = "rao2009", table = "2018", return_terms = TRUE)$KDRI_terms
  expect_equal(terms[[1]][["race"]], 0.1790)
  expect_equal(terms[[2]][["race"]], 0)
  expect_equal(terms[[2]][["hcv"]], 0.2400)
  # Unknown HCV counts as negative (KDPI guide, 2020).
  expect_equal(terms[[3]][["hcv"]], 0)
})

test_that("a missing input gives NA and a message", {
  donors <- guide_donor()[rep(1, 2), ]
  donors$DON_CREAT[2] <- NA
  expect_message(
    out <- add_kdpi(donors),
    class = "sRtr_message_score_missing_inputs"
  )
  expect_false(is.na(out$KDPI[[1]]))
  expect_equal(out$KDPI[[2]], NA_real_)
})

test_that("a table built with the other formula is refused", {
  expect_snapshot(
    add_kdpi(guide_donor(), version = "refit2024", table = "2018"),
    error = TRUE
  )
  expect_error(
    add_kdpi(guide_donor(), version = "refit2024", table = "2018"),
    class = "sRtr_error_bad_table"
  )
})

test_that("in_force uses the table in force on the recovery date", {
  dates <- as.Date(c(
    "2024-05-28", "2024-05-29", "2024-10-30", "2024-10-31", "2013-03-01"
  ))
  donors <- guide_donor()[rep(1, length(dates)), ]
  donors$DON_RECOV_DT <- dates
  expect_warning(
    rao <- add_kdpi(donors, version = "rao2009", table = "in_force"),
    class = "sRtr_warning_table_not_stored"
  )
  # 2024-05-29 is OPTN's published switch; Rao 2009 ends with the refit on
  # 2024-10-31; in March 2013 the 2011 table, which has no scaling factor.
  expect_equal(attr(rao$KDPI, "optn_table"), c("2022", "2023", "2023", NA, NA))
  expect_equal(
    rao$KDPI[[2]],
    add_kdpi(donors[2, ], version = "rao2009", table = "2023")$KDPI[[1]]
  )

  dates <- as.Date(c(
    "2024-10-30", "2024-10-31", "2025-05-20", "2025-05-21", "2026-06-01"
  ))
  donors <- guide_donor()[rep(1, length(dates)), ]
  donors$DON_RECOV_DT <- dates
  expect_warning(
    refit <- add_kdpi(donors, version = "refit2024", table = "in_force"),
    class = "sRtr_warning_table_not_stored"
  )
  # From 2025-05-21 the 2024-donor table, which OPTN has not archived.
  expect_equal(attr(refit$KDPI, "optn_table"), c(NA, "2024", "2024", NA, "current"))
  expect_equal(is.na(as.numeric(refit$KDPI)), c(TRUE, FALSE, FALSE, TRUE, FALSE))
})

test_that("unknown codes give NA rather than a negative", {
  donors <- guide_donor()[rep(1, 3), ]
  donors$DON_CAD_DON_COD <- c(998, 3, 1)
  expect_message(
    out <- add_kdpi(donors),
    class = "sRtr_message_score_missing_inputs"
  )
  expect_equal(is.na(out$KDRI_RAO), c(TRUE, FALSE, FALSE))

  labelled <- guide_donor()
  labelled$DON_CAD_DON_COD <- factor("998: UNKNOWN")
  expect_message(
    out <- add_kdpi(labelled),
    class = "sRtr_message_score_missing_inputs"
  )
  expect_equal(out$KDRI_RAO[[1]], NA_real_)

  stroke <- guide_donor(DON_CAD_DON_COD = NULL)
  stroke$DON_CAD_DON_COD <- NULL
  stroke <- stroke[rep(1, 2), ]
  stroke$DON_COD_DON_STROKE <- c(9, NA)
  expect_message(
    out <- add_kdpi(stroke),
    class = "sRtr_message_score_missing_inputs"
  )
  expect_equal(as.numeric(out$KDRI_RAO), c(NA_real_, NA_real_))
})

test_that("Rao 2009 race: unknown is NA, multiracial is not counted", {
  donors <- guide_donor()[rep(1, 3), ]
  donors$DON_RACE <- c(1024, NA, 24)
  expect_message(
    out <- add_kdpi(donors, version = "rao2009", table = "2018", return_terms = TRUE),
    class = "sRtr_message_score_missing_inputs"
  )
  expect_equal(is.na(out$KDRI_RAO), c(TRUE, TRUE, FALSE))
  expect_equal(out$KDRI_terms[[3]][["race"]], 0)
})

test_that("creatinine that is zero, negative or not finite gives NA", {
  donors <- guide_donor()[rep(1, 3), ]
  donors$DON_CREAT <- c(0, -1, Inf)
  expect_message(
    out <- add_kdpi(donors),
    class = "sRtr_message_score_missing_inputs"
  )
  expect_equal(as.numeric(out$KDRI_RAO), rep(NA_real_, 3))
})

test_that("the table used is recorded on the KDPI column", {
  out <- add_kdpi(guide_donor())
  expect_equal(attr(out$KDPI, "optn_table"), "current")
  expect_equal(attr(out$KDPI, "kdri_formula"), "refit2024")
})
