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
