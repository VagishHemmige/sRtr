fake_deaths <- function() {
  data.frame(
    TRR_ID = 900001:900004,
    PERS_OPTN_DEATH_DT = as.Date(c("2010-01-05", NA, NA, "2010-03-01")),
    PERS_SSA_DEATH_DT = as.Date(c("2010-01-09", "2011-02-02", NA, "2010-03-01")),
    TFL_DEATH_DT = as.Date(c(NA, "2011-02-01", "2012-06-30", NA))
  )
}

test_that("srtr_composite_death() takes OPTN, then SSA, then TFL", {
  out <- srtr_composite_death(fake_deaths())

  expect_equal(
    out$REC_DEATH_DT_COMPOSITE,
    as.Date(c("2010-01-05", "2011-02-02", "2012-06-30", "2010-03-01"))
  )
  expect_equal(
    out$REC_DEATH_DT_COMPOSITE_source,
    c("PERS_OPTN_DEATH_DT", "PERS_SSA_DEATH_DT", "TFL_DEATH_DT", "PERS_OPTN_DEATH_DT")
  )
  expect_equal(out$REC_DEATH_DT_COMPOSITE_conflict, c(TRUE, TRUE, FALSE, FALSE))
})

test_that("srtr_composite_death() can take the earliest date instead", {
  out <- srtr_composite_death(fake_deaths(), prefer_earliest = TRUE)

  expect_equal(
    out$REC_DEATH_DT_COMPOSITE,
    as.Date(c("2010-01-05", "2011-02-01", "2012-06-30", "2010-03-01"))
  )
  expect_equal(
    out$REC_DEATH_DT_COMPOSITE_source,
    c("PERS_OPTN_DEATH_DT", "TFL_DEATH_DT", "TFL_DEATH_DT", "PERS_OPTN_DEATH_DT")
  )
})

test_that("srtr_composite_death() leaves the date NA when every source is NA", {
  df <- fake_deaths()[3, ]
  df$TFL_DEATH_DT <- as.Date(NA)

  out <- srtr_composite_death(df)

  expect_equal(out$REC_DEATH_DT_COMPOSITE, as.Date(NA))
  expect_equal(out$REC_DEATH_DT_COMPOSITE_source, NA_character_)
  expect_equal(out$REC_DEATH_DT_COMPOSITE_conflict, FALSE)
})

test_that("srtr_composite_death() errors when a death date column is missing", {
  df <- fake_deaths()
  df$PERS_SSA_DEATH_DT <- NULL

  expect_error(srtr_composite_death(df), class = "sRtr_error_missing_columns")
  expect_snapshot(error = TRUE, srtr_composite_death(df))
})

test_that("srtr_composite_death() errors on death dates that are not Date", {
  df <- fake_deaths()
  df$PERS_OPTN_DEATH_DT <- c(20100105, NA, NA, 20100301)
  df$TFL_DEATH_DT <- c(NA, "2011-02-01", "2012-06-30", NA)

  expect_error(srtr_composite_death(df), class = "sRtr_error_non_date_columns")
  cnd <- rlang::catch_cnd(srtr_composite_death(df))
  expect_equal(cnd$columns, c("PERS_OPTN_DEATH_DT", "TFL_DEATH_DT"))
  expect_snapshot(error = TRUE, srtr_composite_death(df))
})

# ---- #210: tolerance for the conflict flag ---------------------------------

spread_deaths <- function() {
  # 900001: three sources 5 days apart each, 10 days in all. 900002: exactly
  # 7 days apart. 900003: 8 days apart. 900004: one source. 900005: none.
  # 900006: two sources on the same day.
  data.frame(
    TRR_ID = 900001:900006,
    PERS_OPTN_DEATH_DT = as.Date(c("2010-01-01", "2010-01-01", "2010-01-01", NA, NA, "2010-01-01")),
    PERS_SSA_DEATH_DT = as.Date(c("2010-01-06", "2010-01-08", "2010-01-09", "2010-01-01", NA, NA)),
    TFL_DEATH_DT = as.Date(c("2010-01-11", NA, NA, NA, NA, "2010-01-01"))
  )
}

test_that("conflict_days flags only spreads strictly greater than it", {
  out <- srtr_composite_death(spread_deaths(), conflict_days = 7)

  expect_equal(
    out$REC_DEATH_DT_COMPOSITE_conflict,
    c(TRUE, FALSE, TRUE, FALSE, FALSE, FALSE)
  )
})

test_that("conflict_days = 0 keeps the old flag: any difference", {
  out <- srtr_composite_death(spread_deaths())
  zero <- srtr_composite_death(spread_deaths(), conflict_days = 0)

  expect_equal(out$REC_DEATH_DT_COMPOSITE_conflict, c(TRUE, TRUE, TRUE, FALSE, FALSE, FALSE))
  expect_equal(zero, out)
})

test_that("add_spread_days adds the spread, NA with fewer than two sources", {
  out <- srtr_composite_death(spread_deaths(), add_spread_days = TRUE)

  expect_equal(out$REC_DEATH_DT_COMPOSITE_spread_days, c(10, 7, 8, NA, NA, 0))
  expect_named(
    srtr_composite_death(spread_deaths()),
    c(names(spread_deaths()), "REC_DEATH_DT_COMPOSITE", "REC_DEATH_DT_COMPOSITE_source",
      "REC_DEATH_DT_COMPOSITE_conflict")
  )
})

test_that("conflict_days changes only the flag, not the date or its source", {
  for (earliest in c(FALSE, TRUE)) {
    strict <- srtr_composite_death(spread_deaths(), prefer_earliest = earliest)
    loose <- srtr_composite_death(spread_deaths(), prefer_earliest = earliest, conflict_days = 30)
    expect_equal(loose$REC_DEATH_DT_COMPOSITE, strict$REC_DEATH_DT_COMPOSITE)
    expect_equal(loose$REC_DEATH_DT_COMPOSITE_source, strict$REC_DEATH_DT_COMPOSITE_source)
    expect_equal(loose$REC_DEATH_DT_COMPOSITE_conflict, rep(FALSE, 6))
  }
})

test_that("a column given as two sources counts once", {
  df <- spread_deaths()[c(4, 1), ]
  out <- srtr_composite_death(
    df,
    optn = "PERS_SSA_DEATH_DT",
    ssa = "PERS_SSA_DEATH_DT",
    add_spread_days = TRUE
  )

  # 900004 has one date, in the column named twice; 900001 has SSA and TFL
  # dates 5 days apart.
  expect_equal(out$REC_DEATH_DT_COMPOSITE_spread_days, c(NA, 5))
  expect_equal(out$REC_DEATH_DT_COMPOSITE_conflict, c(FALSE, TRUE))
})

test_that("an output named like a source does not hide a disagreement", {
  df <- spread_deaths()[1:3, ]
  fresh <- srtr_composite_death(df, add_spread_days = TRUE)
  reused <- srtr_composite_death(df, out = "PERS_SSA_DEATH_DT", add_spread_days = TRUE)

  expect_equal(reused$PERS_SSA_DEATH_DT_spread_days, fresh$REC_DEATH_DT_COMPOSITE_spread_days)
  expect_equal(reused$PERS_SSA_DEATH_DT_conflict, fresh$REC_DEATH_DT_COMPOSITE_conflict)
})

test_that("the spread is in calendar days, as the old flag was", {
  df <- spread_deaths()[6, ]
  df$TFL_DEATH_DT <- df$PERS_OPTN_DEATH_DT + 0.5

  out <- srtr_composite_death(df, add_spread_days = TRUE)

  expect_equal(out$REC_DEATH_DT_COMPOSITE_spread_days, 0)
  expect_equal(out$REC_DEATH_DT_COMPOSITE_conflict, FALSE)
})

test_that("conflict_days must be one non-negative number", {
  expect_error(
    srtr_composite_death(spread_deaths(), conflict_days = -1),
    class = "sRtr_error_invalid_conflict_days"
  )
  expect_snapshot(error = TRUE, srtr_composite_death(spread_deaths(), conflict_days = -1))
  expect_snapshot(error = TRUE, srtr_composite_death(spread_deaths(), conflict_days = c(1, 2)))
  expect_snapshot(error = TRUE, srtr_composite_death(spread_deaths(), conflict_days = "7"))
})

test_that("live: the TX_LI composite death date is NA only when every source is", {
  skip_if_no_srtr_file("TX_LI")
  sources <- c("PERS_OPTN_DEATH_DT", "PERS_SSA_DEATH_DT", "TFL_DEATH_DT")

  tx <- srtr_composite_death(load_live("TX_LI", col_select = c("TRR_ID", tidyselect::all_of(sources))))

  expect_s3_class(tx$REC_DEATH_DT_COMPOSITE, "Date")
  every_source_na <- Reduce(`&`, lapply(tx[sources], is.na))
  expect_equal(is.na(tx$REC_DEATH_DT_COMPOSITE), every_source_na)
})
