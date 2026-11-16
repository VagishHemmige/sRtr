pairs <- function() {
  tibble::tibble(
    DON_AGE = c(60, 35),
    DON_GENDER = c("M", "F"),
    CAN_GENDER = c("M", "M"),
    DON_HGT_CM = c(180, 160),
    DON_WGT_KG = c(90, 64),
    REC_WGT_KG = c(80, 100),
    DON_KI_CREAT_PREOP = c(1.0, 0.7),
    DON_RACE = c(16, 8),
    DON_HIST_CIGARETTE = c("Y", "N"),
    DON_BP_PREOP_SYST = c(130, 110),
    DON_ABO = c("A", "O"),
    CAN_ABO = c("O", "B"),
    DON_RELATIONSHIP_TY = c(7, 4),
    REC_B_MM_EQUIV_TX = c(2, 1),
    REC_DR_MM_EQUIV_TX = c(1, 0)
  )
}

test_that("LKDPI follows the Massie 2016 equation", {
  d <- pairs()
  egfr <- add_donor_egfr(d, equation = "ckd_epi_2009", creatinine = "DON_KI_CREAT_PREOP")$DON_EGFR
  bmi <- d$DON_WGT_KG / (d$DON_HGT_CM / 100)^2
  expected <- -11.30 +
    1.85 * pmax(d$DON_AGE - 50, 0) -
    0.381 * egfr +
    1.17 * bmi +
    22.34 * c(1, 0) +
    14.33 * c(1, 0) +
    0.44 * d$DON_BP_PREOP_SYST -
    21.68 * c(1, 0) +
    27.30 * c(1, 0) -
    10.61 * c(1, 0) +
    8.57 * d$REC_B_MM_EQUIV_TX +
    8.26 * d$REC_DR_MM_EQUIV_TX -
    50.87 * pmin(d$DON_WGT_KG / d$REC_WGT_KG, 0.9)
  expect_equal(add_lkdpi(d)$LKDPI, expected, ignore_attr = TRUE)
})

test_that("ABO incompatibility follows donor antigens", {
  d <- pairs()[rep(1, 6), ]
  d$DON_ABO <- c("O", "A2", "A2", "AB", "B", "A1")
  d$CAN_ABO <- c("AB", "O", "B", "A", "AB", "A2")
  terms <- add_lkdpi(d, return_terms = TRUE)$LKDPI_terms
  abo <- vapply(terms, `[[`, numeric(1), "abo_incompatible")
  expect_equal(abo, 27.30 * c(0, 1, 1, 1, 0, 0))

  lenient <- add_lkdpi(d, a2_donor = "compatible", return_terms = TRUE)$LKDPI_terms
  abo2 <- vapply(lenient, `[[`, numeric(1), "abo_incompatible")
  expect_equal(abo2, 27.30 * c(0, 0, 0, 1, 0, 0))
})

test_that("relationship codes split into related and unrelated", {
  d <- pairs()[rep(1, 4), ]
  d$DON_RELATIONSHIP_TY <- c(1, 6, 9, 999)
  terms <- add_lkdpi(d, return_terms = TRUE)$LKDPI_terms
  expect_equal(vapply(terms, `[[`, numeric(1), "unrelated"), -10.61 * c(0, 0, 1, 1))
})

test_that("a missing input gives NA and a message", {
  d <- pairs()
  d$DON_BP_PREOP_SYST[2] <- NA
  expect_message(
    out <- add_lkdpi(d),
    class = "sRtr_message_score_missing_inputs"
  )
  expect_equal(is.na(as.numeric(out$LKDPI)), c(FALSE, TRUE))
})

test_that("zero creatinine or unknown race gives NA, not an infinite value", {
  d <- pairs()
  d$DON_KI_CREAT_PREOP[1] <- 0
  d$DON_RACE[2] <- 1024
  expect_message(
    out <- add_lkdpi(d),
    class = "sRtr_message_score_missing_inputs"
  )
  expect_equal(as.numeric(out$LKDPI), c(NA_real_, NA_real_))
})
