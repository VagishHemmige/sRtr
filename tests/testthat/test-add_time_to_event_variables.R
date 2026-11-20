# Synthetic recipients only. Transplant 2000-01-01, last follow-up 2004-01-01.
#   900001 alive, no death in any source
#   900002 died 2003-01-01, reported by OPTN (inside follow-up)
#   900003 died 2006-01-01, reported by SSA only (after last follow-up)

death_cohort <- function() {
  df <- tibble::tibble(
    TRR_ID = c(900001, 900002, 900003),
    REC_TX_DT = as.Date("2000-01-01"),
    REC_POSTX_LOS = 10,
    REC_ACUTE_REJ_EPISODE = "3: No",
    PERS_OPTN_DEATH_DT = as.Date(c(NA, "2003-01-01", NA)),
    PERS_SSA_DEATH_DT = as.Date(c(NA, NA, "2006-01-01")),
    TFL_DEATH_DT = as.Date(NA),
    TFL_GRAFT_DT = as.Date(NA),
    TFL_LAFUDATE = as.Date("2004-01-01"),
    TFL_ENDTXFU = as.Date("2007-01-01"),
    PERS_RETX = as.Date(NA)
  )
  attr(df, "file_key") <- "TX_KI"
  df
}

no_follow_up_forms <- function(...) {
  tibble::tibble(
    TRR_ID = numeric(),
    ORG_TY = character(),
    TFL_MALIG = character(),
    TFL_ACUTE_REJ_EPISODE = character(),
    TFL_PX_STAT_DT = as.Date(character())
  )
}

test_that("by default, deaths count up to each recipient's TFL_ENDTXFU", {
  local_mocked_bindings(load_srtr_file = no_follow_up_forms)
  df <- death_cohort()
  df$TFL_ENDTXFU <- as.Date(c("2007-01-01", "2007-01-01", "2005-01-01"))
  out <- add_time_to_event_outcomes(df)

  # 900001 is assumed alive past last follow-up; 900003's SSA death falls
  # after its own TFL_ENDTXFU, so it is censored there.
  expect_equal(out$REC_DEATH_DT_COMPOSITE_BINARY, c(0L, 1L, 0L))
  expect_equal(
    out$REC_DEATH_DT_COMPOSITE_CENSOR,
    as.Date(c("2007-01-01", "2003-01-01", "2005-01-01"))
  )
  expect_equal(
    add_time_to_event_outcomes(death_cohort())$REC_DEATH_DT_COMPOSITE_BINARY,
    c(0L, 1L, 1L)
  )
})

test_that("a recipient with no TFL_ENDTXFU has no death event or time, with a warning", {
  local_mocked_bindings(load_srtr_file = no_follow_up_forms)
  df <- death_cohort()
  df$TFL_ENDTXFU[2:3] <- as.Date(NA)
  expect_warning(
    out <- add_time_to_event_outcomes(df),
    class = "sRtr_warning_ascertainment_date_missing"
  )
  expect_snapshot(out <- add_time_to_event_outcomes(df))
  expect_equal(out$REC_DEATH_DT_COMPOSITE_BINARY, c(0L, 0L, 0L))
  expect_equal(out$REC_DEATH_DT_COMPOSITE_days[2:3], c(NA_real_, NA_real_))
  # The composite death date itself still reports every source.
  expect_equal(out$REC_DEATH_DT_COMPOSITE[2], as.Date("2003-01-01"))
})

test_that("ascertainment_date names a column that must exist and hold dates", {
  local_mocked_bindings(load_srtr_file = no_follow_up_forms)
  df <- death_cohort()
  df$TFL_ENDTXFU <- NULL
  expect_error(
    add_time_to_event_outcomes(df),
    class = "sRtr_error_missing_columns"
  )
  expect_snapshot(error = TRUE, add_time_to_event_outcomes(df))
  df$TFL_ENDTXFU <- "2007-01-01"
  expect_error(
    add_time_to_event_outcomes(df),
    class = "sRtr_error_non_date_columns"
  )
  expect_snapshot(error = TRUE, add_time_to_event_outcomes(df))
})

test_that("death_window = 'follow_up' censors deaths after last follow-up there (#18)", {
  local_mocked_bindings(load_srtr_file = no_follow_up_forms)
  out <- add_time_to_event_outcomes(death_cohort(), death_window = "follow_up")

  expect_equal(out$REC_DEATH_DT_COMPOSITE_BINARY, c(0L, 1L, 0L))
  expect_equal(
    out$REC_DEATH_DT_COMPOSITE_CENSOR,
    as.Date(c("2004-01-01", "2003-01-01", "2004-01-01"))
  )
  # The composite death date itself still reports every source.
  expect_equal(
    out$REC_DEATH_DT_COMPOSITE,
    as.Date(c(NA, "2003-01-01", "2006-01-01"))
  )
})

test_that("death_window = 'ascertainment' follows everyone to one closing date", {
  local_mocked_bindings(load_srtr_file = no_follow_up_forms)
  out <- add_time_to_event_outcomes(
    death_cohort(),
    death_window = "ascertainment",
    ascertainment_date = as.Date("2007-01-01")
  )

  expect_equal(out$REC_DEATH_DT_COMPOSITE_BINARY, c(0L, 1L, 1L))
  expect_equal(
    out$REC_DEATH_DT_COMPOSITE_CENSOR,
    as.Date(c("2007-01-01", "2003-01-01", "2006-01-01"))
  )
})

test_that("deaths after the ascertainment date are censored at it", {
  local_mocked_bindings(load_srtr_file = no_follow_up_forms)
  out <- add_time_to_event_outcomes(
    death_cohort(),
    death_window = "ascertainment",
    ascertainment_date = as.Date("2005-01-01")
  )

  expect_equal(out$REC_DEATH_DT_COMPOSITE_BINARY, c(0L, 1L, 0L))
  expect_equal(
    out$REC_DEATH_DT_COMPOSITE_CENSOR,
    as.Date(c("2005-01-01", "2003-01-01", "2005-01-01"))
  )
})

test_that("under death_window = 'follow_up', no last follow-up date means no death time", {
  local_mocked_bindings(load_srtr_file = no_follow_up_forms)
  df <- death_cohort()
  df$TFL_LAFUDATE[2] <- as.Date(NA)
  out <- add_time_to_event_outcomes(df, death_window = "follow_up")

  expect_equal(out$REC_DEATH_DT_COMPOSITE_BINARY[2], 0L)
  expect_equal(out$REC_DEATH_DT_COMPOSITE_days[2], NA_real_)
})

test_that("death_window = 'ascertainment' needs one valid ascertainment_date", {
  local_mocked_bindings(load_srtr_file = no_follow_up_forms)
  expect_error(
    add_time_to_event_outcomes(death_cohort(), ascertainment_date = NULL),
    class = "sRtr_error_ascertainment_date_missing"
  )
  expect_snapshot(
    error = TRUE,
    add_time_to_event_outcomes(death_cohort(), ascertainment_date = NULL)
  )
  expect_error(
    add_time_to_event_outcomes(death_cohort(), ascertainment_date = 2007),
    class = "sRtr_error_ascertainment_date_missing"
  )
  expect_snapshot(
    error = TRUE,
    add_time_to_event_outcomes(
      death_cohort(),
      death_window = "ascertainment",
      ascertainment_date = as.Date(c("2005-01-01", "2006-01-01"))
    )
  )
})

test_that("an unknown death_window is an error", {
  # Not a snapshot: match.arg()'s quote marks depend on the locale.
  expect_error(
    add_time_to_event_outcomes(death_cohort(), death_window = "all"),
    "should be one of"
  )
})

test_that("a death on the last follow-up date counts", {
  local_mocked_bindings(load_srtr_file = no_follow_up_forms)
  df <- death_cohort()
  df$PERS_SSA_DEATH_DT[3] <- as.Date("2004-01-01")
  out <- add_time_to_event_outcomes(df, death_window = "follow_up")

  expect_equal(out$REC_DEATH_DT_COMPOSITE_BINARY, c(0L, 1L, 1L))
})

test_that("ascertainment_date can be given as text", {
  local_mocked_bindings(load_srtr_file = no_follow_up_forms)
  out <- add_time_to_event_outcomes(
    death_cohort(),
    death_window = "ascertainment",
    ascertainment_date = "2007-01-01"
  )

  expect_equal(out$REC_DEATH_DT_COMPOSITE_CENSOR[1], as.Date("2007-01-01"))
})

# Synthetic recipients only. Transplant 2000-01-01, last follow-up 2004-01-01.
#   900011 died 2002-01-01 with a functioning graft
#   900012 graft failed 2001-06-01, then died 2003-01-01
#   900013 graft failure recorded 2003-01-01, after death on 2002-01-01
#   900014 alive, graft functioning
#   900015 died 2006-01-01 (SSA only), after last follow-up
#   900016 graft failed 2002-06-01, alive
graft_cohort <- function() {
  df <- tibble::tibble(
    TRR_ID = 900011:900016,
    REC_TX_DT = as.Date("2000-01-01"),
    REC_POSTX_LOS = 10,
    REC_ACUTE_REJ_EPISODE = "3: No",
    PERS_OPTN_DEATH_DT = as.Date(
      c("2002-01-01", "2003-01-01", "2002-01-01", NA, NA, NA)
    ),
    PERS_SSA_DEATH_DT = as.Date(c(NA, NA, NA, NA, "2006-01-01", NA)),
    TFL_DEATH_DT = as.Date(NA),
    TFL_GRAFT_DT = as.Date(
      c(NA, "2001-06-01", "2003-01-01", NA, NA, "2002-06-01")
    ),
    TFL_LAFUDATE = as.Date("2004-01-01"),
    TFL_ENDTXFU = as.Date("2010-01-01"),
    PERS_RETX = as.Date(NA)
  )
  attr(df, "file_key") <- "TX_KI"
  df
}

test_that("death-censored graft failure is censored at death (#22)", {
  local_mocked_bindings(load_srtr_file = no_follow_up_forms)
  out <- add_time_to_event_outcomes(graft_cohort())

  expect_equal(out$TFL_GRAFT_DT_BINARY, c(0L, 1L, 0L, 0L, 0L, 1L))
  expect_equal(
    out$TFL_GRAFT_DT_CENSOR,
    as.Date(c(
      "2002-01-01",
      "2001-06-01",
      "2002-01-01",
      "2004-01-01",
      "2004-01-01",
      "2002-06-01"
    ))
  )
  # Days from transplant, plus the default add_epsilon of 1.
  expect_equal(out$TFL_GRAFT_DT_days[1], 732)
})

test_that("death_window does not change death-censored graft failure", {
  local_mocked_bindings(load_srtr_file = no_follow_up_forms)
  cols <- c("TFL_GRAFT_DT_BINARY", "TFL_GRAFT_DT_CENSOR", "TFL_GRAFT_DT_days")
  follow_up <- add_time_to_event_outcomes(graft_cohort())
  ascertained <- add_time_to_event_outcomes(
    graft_cohort(),
    death_window = "ascertainment",
    ascertainment_date = as.Date("2007-01-01")
  )
  expect_equal(ascertained[cols], follow_up[cols])
})

test_that("graft failure on the day of death is censored by default", {
  local_mocked_bindings(load_srtr_file = no_follow_up_forms)
  df <- graft_cohort()
  df$TFL_GRAFT_DT[1] <- as.Date("2002-01-01")

  out <- add_time_to_event_outcomes(df)
  expect_equal(out$TFL_GRAFT_DT_BINARY[1], 0L)
  expect_equal(out$TFL_GRAFT_DT_CENSOR[1], as.Date("2002-01-01"))

  out <- add_time_to_event_outcomes(df, graft_death_same_day = "event")
  expect_equal(out$TFL_GRAFT_DT_BINARY[1], 1L)
  expect_equal(out$TFL_GRAFT_DT_CENSOR[1], as.Date("2002-01-01"))
})

test_that("a missing last follow-up date is not filled in from death", {
  local_mocked_bindings(load_srtr_file = no_follow_up_forms)
  df <- graft_cohort()[1:2, ]
  df$TFL_LAFUDATE <- as.Date(NA)
  out <- add_time_to_event_outcomes(df)

  # 900011 died with a working graft: no follow-up date, so no graft time.
  # 900012 failed before death: the failure still counts, timed at failure.
  expect_equal(out$TFL_GRAFT_DT_BINARY, c(0L, 1L))
  expect_equal(out$TFL_GRAFT_DT_CENSOR, as.Date(c(NA, "2001-06-01")))
  expect_equal(out$TFL_GRAFT_DT_days, c(NA, 518))
})

test_that("an unknown graft_death_same_day is an error", {
  # Not a snapshot: match.arg()'s quote marks depend on the locale.
  expect_error(
    add_time_to_event_outcomes(graft_cohort(), graft_death_same_day = "both"),
    "should be one of"
  )
})

test_that("TX_KP kidney and pancreas graft failure are each censored at death", {
  local_mocked_bindings(load_srtr_file = no_follow_up_forms)
  df <- tibble::tibble(
    TRR_ID = c(900021, 900022),
    REC_TX_DT = as.Date("2000-01-01"),
    REC_POSTX_LOS = 10,
    REC_ACUTE_REJ_EPISODE = "3: No",
    REC_ACUTE_REJ_EPISODE_PA = "3: No",
    PERS_OPTN_DEATH_DT = as.Date(c("2002-01-01", NA)),
    PERS_SSA_DEATH_DT = as.Date(NA),
    TFL_DEATH_DT = as.Date(NA),
    # 900021: kidney failed before death; pancreas still working at death.
    # 900022: alive; pancreas failure recorded, kidney working.
    TFL_GRAFT_DT_KI = as.Date(c("2001-01-01", NA)),
    TFL_GRAFT_DT_PA = as.Date(c(NA, "2003-01-01")),
    TFL_LAFUDATEKI = as.Date(c("2003-01-01", "2004-01-01")),
    TFL_ENDTXFU = as.Date("2010-01-01"),
    PERS_RETXKI = as.Date(NA),
    PERS_RETXPA = as.Date(NA),
    TFL_LAFUDATEPA = as.Date(c("2005-01-01", "2004-01-01"))
  )
  attr(df, "file_key") <- "TX_KP"

  out <- add_time_to_event_outcomes(df)
  expect_equal(out$TFL_GRAFT_DT_KI_BINARY, c(1L, 0L))
  expect_equal(
    out$TFL_GRAFT_DT_KI_CENSOR,
    as.Date(c("2001-01-01", "2004-01-01"))
  )
  expect_equal(out$TFL_GRAFT_DT_PA_BINARY, c(0L, 1L))
  expect_equal(
    out$TFL_GRAFT_DT_PA_CENSOR,
    as.Date(c("2002-01-01", "2003-01-01"))
  )
})

test_that("all-cause graft failure is the first of failure, retransplant and death", {
  local_mocked_bindings(load_srtr_file = no_follow_up_forms)
  df <- graft_cohort()
  df$PERS_RETX[4] <- as.Date("2003-01-01")
  out <- add_time_to_event_outcomes(df)

  expect_equal(
    out$GRAFT_FAIL_ALL_CAUSE_DT_SOURCE,
    c("death", "graft_failure", "death", "retransplant", "death", "graft_failure")
  )
  # 900015's death after last follow-up is kept in the date column but not
  # counted; the graft is censored at last follow-up.
  expect_equal(out$GRAFT_FAIL_ALL_CAUSE_DT_BINARY, c(1L, 1L, 1L, 1L, 0L, 1L))
  expect_equal(
    out$GRAFT_FAIL_ALL_CAUSE_DT_CENSOR,
    as.Date(c(
      "2002-01-01", "2001-06-01", "2002-01-01", "2003-01-01", "2004-01-01",
      "2002-06-01"
    ))
  )
  expect_equal(out$GRAFT_FAIL_ALL_CAUSE_DT[5], as.Date("2006-01-01"))
  # The death-censored columns are unchanged.
  expect_equal(out$TFL_GRAFT_DT_BINARY, c(0L, 1L, 0L, 0L, 0L, 1L))
})

test_that("retransplant = 'ignore' leaves retransplant out", {
  local_mocked_bindings(load_srtr_file = no_follow_up_forms)
  df <- graft_cohort()
  df$PERS_RETX[4] <- as.Date("2003-01-01")
  out <- add_time_to_event_outcomes(df, retransplant = "ignore")
  expect_equal(out$GRAFT_FAIL_ALL_CAUSE_DT_BINARY[4], 0L)

  df$PERS_RETX <- NULL
  expect_error(
    add_time_to_event_outcomes(df),
    class = "sRtr_error_missing_columns"
  )
  expect_snapshot(error = TRUE, add_time_to_event_outcomes(df))
  out <- add_time_to_event_outcomes(df, retransplant = "ignore")
  expect_equal(out$GRAFT_FAIL_ALL_CAUSE_DT_BINARY[4], 0L)
})

test_that("lung and heart-lung never count retransplant", {
  local_mocked_bindings(load_srtr_file = no_follow_up_forms)
  for (key in c("TX_LU", "TX_HL")) {
    df <- graft_cohort()
    df$PERS_RETX[4] <- as.Date("2003-01-01")
    attr(df, "file_key") <- key
    out <- add_time_to_event_outcomes(df)
    expect_equal(out$GRAFT_FAIL_ALL_CAUSE_DT_BINARY[4], 0L)
    expect_equal(out$GRAFT_FAIL_ALL_CAUSE_DT_SOURCE[4], NA_character_)

    df$PERS_RETX <- NULL
    expect_no_error(add_time_to_event_outcomes(df))
  }
})

test_that("heart grafts fail only at death or retransplant, followed past last follow-up", {
  local_mocked_bindings(load_srtr_file = no_follow_up_forms)
  df <- graft_cohort()
  df$PERS_RETX[4] <- as.Date("2003-01-01")
  attr(df, "file_key") <- "TX_HR"
  out <- add_time_to_event_outcomes(df)

  # The graft failure dates of 900012 and 900016 are not used; 900015's death
  # after last follow-up counts, because heart follow-up runs to TFL_ENDTXFU.
  expect_equal(
    out$GRAFT_FAIL_ALL_CAUSE_DT_SOURCE,
    c("death", "death", "death", "retransplant", "death", NA)
  )
  expect_equal(out$GRAFT_FAIL_ALL_CAUSE_DT_BINARY, c(1L, 1L, 1L, 1L, 1L, 0L))
  expect_equal(out$GRAFT_FAIL_ALL_CAUSE_DT_CENSOR[6], as.Date("2010-01-01"))

  # Under death_window = "follow_up", heart follow-up ends at last follow-up.
  fu <- add_time_to_event_outcomes(df, death_window = "follow_up")
  expect_equal(fu$GRAFT_FAIL_ALL_CAUSE_DT_BINARY[5], 0L)

  # The graft failure date is not needed for heart.
  df$TFL_GRAFT_DT <- NULL
  expect_no_error(
    add_time_to_event_outcomes(df, rejection_after_graft_failure = "keep")
  )
})

test_that("TX_KP has all-cause graft failure for each graft", {
  local_mocked_bindings(load_srtr_file = no_follow_up_forms)
  df <- tibble::tibble(
    TRR_ID = c(900021, 900022),
    REC_TX_DT = as.Date("2000-01-01"),
    REC_POSTX_LOS = 10,
    REC_ACUTE_REJ_EPISODE = "3: No",
    REC_ACUTE_REJ_EPISODE_PA = "3: No",
    PERS_OPTN_DEATH_DT = as.Date(c("2002-01-01", NA)),
    PERS_SSA_DEATH_DT = as.Date(NA),
    TFL_DEATH_DT = as.Date(NA),
    TFL_GRAFT_DT_KI = as.Date(c("2001-01-01", NA)),
    TFL_GRAFT_DT_PA = as.Date(c(NA, "2003-01-01")),
    TFL_LAFUDATEKI = as.Date(c("2003-01-01", "2004-01-01")),
    TFL_LAFUDATEPA = as.Date(c("2005-01-01", "2004-01-01")),
    TFL_ENDTXFU = as.Date("2010-01-01"),
    PERS_RETXKI = as.Date(c(NA, "2003-06-01")),
    PERS_RETXPA = as.Date(NA)
  )
  attr(df, "file_key") <- "TX_KP"
  out <- add_time_to_event_outcomes(df)

  expect_equal(out$GRAFT_FAIL_ALL_CAUSE_DT_KI_SOURCE, c("graft_failure", "retransplant"))
  expect_equal(out$GRAFT_FAIL_ALL_CAUSE_DT_KI_BINARY, c(1L, 1L))
  expect_equal(out$GRAFT_FAIL_ALL_CAUSE_DT_PA_SOURCE, c("death", "graft_failure"))
  expect_equal(
    out$GRAFT_FAIL_ALL_CAUSE_DT_PA_CENSOR,
    as.Date(c("2002-01-01", "2003-01-01"))
  )
})

test_that("srtr_time_to_event() warns about negative times and sets them to NA", {
  df <- tibble::tibble(
    start = as.Date(c("2001-01-10", "2001-01-10")),
    event = as.Date(c("2001-01-01", NA)),
    censor = as.Date(c("2001-01-01", "2002-01-10"))
  )
  expect_snapshot(
    out <- srtr_time_to_event(
      df, event, start, censor,
      prefix = "FAKE", units = "days", add_epsilon = 0
    )
  )
  expect_warning(
    srtr_time_to_event(
      df, event, start, censor,
      prefix = "FAKE", units = "days", add_epsilon = 0
    ),
    class = "sRtr_warning_negative_time"
  )
  expect_equal(out$FAKE_days, c(NA, 365))
})

# ---- #97: infinite dates -------------------------------------------------------

test_that("srtr_time_to_event() stops on infinite dates", {
  df <- data.frame(
    start = as.Date(c("2000-01-01", "2000-01-01")),
    event = as.Date(c(Inf, NA)),
    censor = as.Date(c("2005-01-01", "2005-01-01"))
  )
  expect_error(
    srtr_time_to_event(df, event, start, censor, prefix = "X"),
    class = "sRtr_error_nonfinite_dates"
  )
  expect_snapshot(error = TRUE, srtr_time_to_event(df, event, start, censor, prefix = "X"))

  df$event <- as.Date(NA)
  df$censor[2] <- as.Date(-Inf)
  expect_error(
    srtr_time_to_event(df, event, start, censor, prefix = "X"),
    class = "sRtr_error_nonfinite_dates"
  )
})

test_that("the infinite-date error counts rows, not values", {
  df <- data.frame(
    start = as.Date(c("2000-01-01", "2000-01-01")),
    event = as.Date(c(Inf, NA)),
    censor = structure(c(Inf, 12784), class = "Date")
  )
  expect_error(
    srtr_time_to_event(df, event, start, censor, prefix = "X"),
    "infinite dates in 1 row"
  )
})

test_that("live: deaths are ascertained up to TFL_ENDTXFU on a real transplant file", {
  skip_if_no_srtr_file(c("TX_LI", "TXF_LI"))
  tx <- load_live("TX_LI")
  expect_s3_class(tx$TFL_ENDTXFU, "Date")
  quiet <- function(expr) {
    withCallingHandlers(
      expr,
      sRtr_warning_unknown_codes = function(cnd) rlang::cnd_muffle(cnd),
      sRtr_warning_undated_admission_rejection = function(cnd) rlang::cnd_muffle(cnd),
      sRtr_warning_undated_follow_up_report = function(cnd) rlang::cnd_muffle(cnd),
      sRtr_warning_ascertainment_date_missing = function(cnd) rlang::cnd_muffle(cnd)
    )
  }
  out <- quiet(add_time_to_event_outcomes(tx))
  died <- out$REC_DEATH_DT_COMPOSITE_BINARY %in% 1L
  censor <- out$REC_DEATH_DT_COMPOSITE_CENSOR
  expect_equal(sum(censor[died] > out$TFL_ENDTXFU[died], na.rm = TRUE), 0)
  expect_equal(sum(censor[!died] != out$TFL_ENDTXFU[!died], na.rm = TRUE), 0)

  # A death counted only under "follow_up" falls after TFL_ENDTXFU.
  fu <- quiet(add_time_to_event_outcomes(tx, death_window = "follow_up"))
  only_fu <- fu$REC_DEATH_DT_COMPOSITE_BINARY %in% 1L & !died &
    !is.na(out$TFL_ENDTXFU)
  expect_equal(
    sum(only_fu),
    sum(only_fu & fu$REC_DEATH_DT_COMPOSITE > out$TFL_ENDTXFU, na.rm = TRUE)
  )
})
