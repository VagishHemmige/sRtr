donors <- function() {
  tibble::tibble(
    DON_AGE = c(50, 50, 30, 30),
    DON_GENDER = c("F", "F", "M", "M"),
    DON_CREAT = c(0.6, 1.4, 0.8, 2.0),
    DON_RACE = c(8, 16, 16, 8)
  )
}

test_that("CKD-EPI 2021 follows Inker 2021 Table 2", {
  d <- donors()
  expected <- with(d, {
    female <- DON_GENDER == "F"
    kappa <- ifelse(female, 0.7, 0.9)
    a1 <- ifelse(female, -0.241, -0.302)
    142 * pmin(DON_CREAT / kappa, 1)^a1 * pmax(DON_CREAT / kappa, 1)^-1.200 *
      0.9938^DON_AGE * ifelse(female, 1.012, 1)
  })
  expect_equal(add_donor_egfr(d)$DON_EGFR, expected, ignore_attr = TRUE)
})

test_that("CKD-EPI 2009 includes the race coefficient", {
  d <- donors()
  expected <- with(d, {
    female <- DON_GENDER == "F"
    kappa <- ifelse(female, 0.7, 0.9)
    a1 <- ifelse(female, -0.329, -0.411)
    141 * pmin(DON_CREAT / kappa, 1)^a1 * pmax(DON_CREAT / kappa, 1)^-1.209 *
      0.9929^DON_AGE * ifelse(female, 1.018, 1) * ifelse(DON_RACE == 16, 1.159, 1)
  })
  expect_equal(add_donor_egfr(d, equation = "ckd_epi_2009")$DON_EGFR, expected, ignore_attr = TRUE)
})

test_that("each branch meets at the creatinine breakpoint", {
  d <- donors()[c(1, 3), ]
  d$DON_CREAT <- c(0.7, 0.9)
  expect_equal(
    add_donor_egfr(d)$DON_EGFR,
    142 * 0.9938^c(50, 30) * c(1.012, 1),
    ignore_attr = TRUE
  )
})

test_that("another creatinine column can be used", {
  d <- donors()
  d$DON_KI_CREAT_PREOP <- d$DON_CREAT
  d$DON_CREAT <- NULL
  expect_equal(
    add_donor_egfr(d, creatinine = "DON_KI_CREAT_PREOP")$DON_EGFR,
    add_donor_egfr(donors())$DON_EGFR
  )
})

test_that("donors under 18 get no eGFR unless asked", {
  d <- donors()[1, ]
  d$DON_AGE <- 12
  expect_message(
    out <- add_donor_egfr(d),
    class = "sRtr_message_score_missing_inputs"
  )
  expect_equal(out$DON_EGFR, NA_real_, ignore_attr = TRUE)
  expect_false(is.na(add_donor_egfr(d, adults_only = FALSE)$DON_EGFR))
})

test_that("unknown sex gives NA", {
  d <- donors()[1, ]
  d$DON_GENDER <- "U"
  expect_message(
    out <- add_donor_egfr(d),
    class = "sRtr_message_score_missing_inputs"
  )
  expect_equal(out$DON_EGFR, NA_real_, ignore_attr = TRUE)
})

test_that("creatinine that is zero, negative or not finite gives NA", {
  d <- donors()[rep(3, 3), ]
  d$DON_CREAT <- c(0, -0.5, Inf)
  expect_message(
    out <- add_donor_egfr(d),
    class = "sRtr_message_score_missing_inputs"
  )
  expect_equal(as.numeric(out$DON_EGFR), rep(NA_real_, 3))
})

test_that("unknown race gives NA in the 2009 equation", {
  d <- donors()[rep(1, 2), ]
  d$DON_RACE <- c(1024, NA)
  expect_message(
    out <- add_donor_egfr(d, equation = "ckd_epi_2009"),
    class = "sRtr_message_score_missing_inputs"
  )
  expect_equal(as.numeric(out$DON_EGFR), c(NA_real_, NA_real_))
  expect_false(anyNA(add_donor_egfr(d)$DON_EGFR))
})

test_that("results match kidney.epi where both apply", {
  skip_if_not_installed("kidney.epi")
  d <- donors()
  ref <- kidney.epi::egfr.ckdepi.cr.2021(
    creatinine = d$DON_CREAT,
    age = d$DON_AGE,
    sex = d$DON_GENDER,
    creatinine_units = "mg/dl",
    label_sex_male = "M",
    label_sex_female = "F"
  )
  expect_equal(add_donor_egfr(d)$DON_EGFR, ref, tolerance = 1e-6, ignore_attr = TRUE)
})
