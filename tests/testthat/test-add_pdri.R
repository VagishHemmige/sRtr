testthat::test_that("PDRI matches literal formulas (PA vs KP)", {
  df <- tibble::tibble(
    DON_GENDER = c("F","M"),
    DON_AGE_IN_MONTHS = c(300, 200),
    DON_CREAT = c(3.0, 1.2),
    DON_RACE = c(16L, 64L),
    DON_BMI = c(28, 23),
    DON_HGT_CM = c(170, 180),
    DON_COD_DON_STROKE = c(1L, 0L),
    REC_PA_PRESERV_TM = c(10, 14),
    DON_NON_HR_BEAT = c("Y","N"),
    REC_PREV_KI = c(1L, 0L)
  )

  # Manual PA (with interaction)
  pa_manual <- with(df, exp(
    -0.13792*(DON_GENDER=="F") -
      0.034455*(DON_AGE_IN_MONTHS<240)*((DON_AGE_IN_MONTHS-240)/12) +
      0.026149*((DON_AGE_IN_MONTHS-336)/12) +
      0.19490*(DON_CREAT>2.5) +
      0.23951*(DON_RACE==16) +
      0.15711*(DON_RACE==64) -
      0.000986347*(DON_BMI-24) +
      0.033274*(DON_BMI>25)*(DON_BMI-25) -
      0.006073879*(DON_HGT_CM-173) +
      0.21018*(DON_COD_DON_STROKE==1) +
      0.014678*(REC_PA_PRESERV_TM-12) +
      0.33172*(DON_NON_HR_BEAT=="Y") -
      0.28137*((DON_COD_DON_STROKE==1)&(REC_PREV_KI==1))
  ))

  # Manual KP (no interaction)
  kp_manual <- with(df, exp(
    -0.13792*(DON_GENDER=="F") -
      0.034455*(DON_AGE_IN_MONTHS<240)*((DON_AGE_IN_MONTHS-240)/12) +
      0.026149*((DON_AGE_IN_MONTHS-336)/12) +
      0.19490*(DON_CREAT>2.5) +
      0.23951*(DON_RACE==16) +
      0.15711*(DON_RACE==64) -
      0.000986347*(DON_BMI-24) +
      0.033274*(DON_BMI>25)*(DON_BMI-25) -
      0.006073879*(DON_HGT_CM-173) +
      0.21018*(DON_COD_DON_STROKE==1) +
      0.014678*(REC_PA_PRESERV_TM-12) +
      0.33172*(DON_NON_HR_BEAT=="Y")
  ))

  testthat::expect_equal(add_pdri(df, variant="PA")$PDRI, pa_manual, tolerance = 1e-12)
  testthat::expect_equal(add_pdri(df, variant="KP")$PDRI, kp_manual, tolerance = 1e-12)
})

testthat::test_that("Auto-detect defaults to KP and respects file_key", {
  df <- tibble::tibble(
    DON_GENDER="F", DON_AGE_IN_MONTHS=300, DON_CREAT=1.0, DON_RACE=16L,
    DON_BMI=24, DON_HGT_CM=170, DON_COD_DON_STROKE=0L, REC_PA_PRESERV_TM=12,
    DON_NON_HR_BEAT="N"
  )

  # With no KP/PA signals, fallback should be KP
  out_auto <- add_pdri(df)               # variant = NULL -> auto
  out_kp   <- add_pdri(df, variant="KP")
  testthat::expect_equal(out_auto$PDRI, out_kp$PDRI, tolerance = 1e-12)

  # file_key hint forces PA
  attr(df, "file_key") <- "TX_PA"
  out_pa_hint <- add_pdri(df, variant=NULL)
  out_pa_forced <- add_pdri(df, variant="PA")
  testthat::expect_equal(out_pa_hint$PDRI, out_pa_forced$PDRI, tolerance = 1e-12)
})

testthat::test_that("PA equals KP when REC_PREV_KI is absent", {
  df <- tibble::tibble(
    DON_GENDER="F", DON_AGE_IN_MONTHS=300, DON_CREAT=1.0, DON_RACE=16L,
    DON_BMI=24, DON_HGT_CM=170, DON_COD_DON_STROKE=1L, REC_PA_PRESERV_TM=12,
    DON_NON_HR_BEAT="Y"
  )
  # REC_PREV_KI missing -> PA interaction skipped -> same as KP
  out_pa <- add_pdri(df, variant="PA")
  out_kp <- add_pdri(df, variant="KP")
  testthat::expect_equal(out_pa$PDRI, out_kp$PDRI, tolerance = 1e-12)
})

testthat::test_that("Groupwise mean-impute works; grouping preserved; source cols unchanged", {
  df <- tibble::tibble(
    grp = c(1,1,2,2),
    DON_GENDER=c("F","F","M","M"),
    DON_AGE_IN_MONTHS=c(300,NA, 200,NA),
    DON_CREAT=c(1,NA, 3,NA),
    DON_RACE=c(16L,16L,64L,64L),
    DON_BMI=c(28,NA, 23,NA),
    DON_HGT_CM=c(170,170, 180,180),
    DON_COD_DON_STROKE=c(1L,1L, 0L,0L),
    REC_PA_PRESERV_TM=c(10,NA, 14,NA),
    DON_NON_HR_BEAT=c("Y","Y","N","N"),
    REC_PREV_KI=c(1L,1L, 0L,0L)
  )
  df<-dplyr::group_by(df, grp)

  out <- add_pdri(df, mean_impute = TRUE, variant = "PA")

  # Original NAs remain in the source df
  testthat::expect_true(any(is.na(df$DON_AGE_IN_MONTHS)))

  # Grouping preserved
  testthat::expect_setequal(dplyr::group_vars(out), "grp")

  # New column added
  testthat::expect_true("PDRI" %in% names(out))

  # Imputation allowed PDRI to compute (no NA solely due to those imputed fields)
  testthat::expect_true(all(!is.na(out$PDRI)))
})
