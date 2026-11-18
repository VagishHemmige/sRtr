testthat::test_that("PDRI matches literal formulas (PA vs KP)", {
  df <- tibble::tibble(
    DON_GENDER = c("F", "M"),
    DON_AGE_IN_MONTHS = c(300, 200),
    DON_CREAT = c(3.0, 1.2),
    DON_RACE = c(16L, 64L),
    DON_BMI = c(28, 23),
    DON_HGT_CM = c(170, 180),
    DON_COD_DON_STROKE = c(1L, 0L),
    REC_PA_PRESERV_TM = c(10, 14),
    DON_NON_HR_BEAT = c("Y", "N"),
    REC_PREV_KI = c(1L, 0L)
  )

  # Manual PA (with interaction)
  pa_manual <- with(
    df,
    exp(
      -0.13792 *
        (DON_GENDER == "F") -
        0.034455 *
          (DON_AGE_IN_MONTHS < 240) *
          ((DON_AGE_IN_MONTHS - 240) / 12) +
        0.026149 * ((DON_AGE_IN_MONTHS - 336) / 12) +
        0.19490 * (DON_CREAT > 2.5) +
        0.23951 * (DON_RACE == 16) +
        0.15711 * (DON_RACE == 64) -
        0.000986347 * (DON_BMI - 24) +
        0.033274 * (DON_BMI > 25) * (DON_BMI - 25) -
        0.006073879 * (DON_HGT_CM - 173) +
        0.21018 * (DON_COD_DON_STROKE == 1) +
        0.014678 * (REC_PA_PRESERV_TM - 12) +
        0.33172 * (DON_NON_HR_BEAT == "Y") -
        0.28137 * ((DON_COD_DON_STROKE == 1) & (REC_PREV_KI == 1))
    )
  )

  # Manual KP (no interaction)
  kp_manual <- with(
    df,
    exp(
      -0.13792 *
        (DON_GENDER == "F") -
        0.034455 *
          (DON_AGE_IN_MONTHS < 240) *
          ((DON_AGE_IN_MONTHS - 240) / 12) +
        0.026149 * ((DON_AGE_IN_MONTHS - 336) / 12) +
        0.19490 * (DON_CREAT > 2.5) +
        0.23951 * (DON_RACE == 16) +
        0.15711 * (DON_RACE == 64) -
        0.000986347 * (DON_BMI - 24) +
        0.033274 * (DON_BMI > 25) * (DON_BMI - 25) -
        0.006073879 * (DON_HGT_CM - 173) +
        0.21018 * (DON_COD_DON_STROKE == 1) +
        0.014678 * (REC_PA_PRESERV_TM - 12) +
        0.33172 * (DON_NON_HR_BEAT == "Y")
    )
  )

  pa <- add_pdri(df, variant = "PA")$PDRI
  kp <- add_pdri(df, variant = "KP")$PDRI
  testthat::expect_equal(
    pa,
    pa_manual,
    tolerance = 1e-12,
    ignore_attr = "label"
  )
  testthat::expect_equal(
    kp,
    kp_manual,
    tolerance = 1e-12,
    ignore_attr = "label"
  )
  testthat::expect_identical(attr(pa, "label"), "Pancreas Donor Risk Index")
})

testthat::test_that("Auto-detect defaults to KP and respects file_key", {
  df <- tibble::tibble(
    DON_GENDER = "F",
    DON_AGE_IN_MONTHS = 300,
    DON_CREAT = 1.0,
    DON_RACE = 16L,
    DON_BMI = 24,
    DON_HGT_CM = 170,
    DON_COD_DON_STROKE = 0L,
    REC_PA_PRESERV_TM = 12,
    DON_NON_HR_BEAT = "N"
  )

  # With no KP/PA signals, fallback should be KP
  out_auto <- add_pdri(df) # variant = NULL -> auto
  out_kp <- add_pdri(df, variant = "KP")
  testthat::expect_equal(out_auto$PDRI, out_kp$PDRI, tolerance = 1e-12)

  # file_key hint forces PA
  attr(df, "file_key") <- "TX_PA"
  out_pa_hint <- add_pdri(df, variant = NULL)
  out_pa_forced <- add_pdri(df, variant = "PA")
  testthat::expect_equal(
    out_pa_hint$PDRI,
    out_pa_forced$PDRI,
    tolerance = 1e-12
  )
})

testthat::test_that("PA equals KP when REC_PREV_KI is absent", {
  df <- tibble::tibble(
    DON_GENDER = "F",
    DON_AGE_IN_MONTHS = 300,
    DON_CREAT = 1.0,
    DON_RACE = 16L,
    DON_BMI = 24,
    DON_HGT_CM = 170,
    DON_COD_DON_STROKE = 1L,
    REC_PA_PRESERV_TM = 12,
    DON_NON_HR_BEAT = "Y"
  )
  # REC_PREV_KI missing -> PA interaction skipped -> same as KP
  out_pa <- add_pdri(df, variant = "PA")
  out_kp <- add_pdri(df, variant = "KP")
  testthat::expect_equal(out_pa$PDRI, out_kp$PDRI, tolerance = 1e-12)
})

testthat::test_that("Groupwise mean-impute works; grouping preserved; source cols unchanged", {
  df <- tibble::tibble(
    grp = c(1, 1, 2, 2),
    DON_GENDER = c("F", "F", "M", "M"),
    DON_AGE_IN_MONTHS = c(300, NA, 200, NA),
    DON_CREAT = c(1, NA, 3, NA),
    DON_RACE = c(16L, 16L, 64L, 64L),
    DON_BMI = c(28, NA, 23, NA),
    DON_HGT_CM = c(170, 170, 180, 180),
    DON_COD_DON_STROKE = c(1L, 1L, 0L, 0L),
    REC_PA_PRESERV_TM = c(10, NA, 14, NA),
    DON_NON_HR_BEAT = c("Y", "Y", "N", "N"),
    REC_PREV_KI = c(1L, 1L, 0L, 0L)
  )
  df <- dplyr::group_by(df, grp)

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

testthat::test_that("add_pdri() is exported", {
  testthat::expect_true("add_pdri" %in% getNamespaceExports("sRtr"))
})

fake_donors <- function() {
  tibble::tibble(
    DON_GENDER = "F",
    DON_AGE_IN_MONTHS = 300,
    DON_CREAT = 1,
    DON_RACE = 8L,
    DON_BMI = 25,
    DON_HGT_CM = 170,
    DON_COD_DON_STROKE = 0L,
    REC_PA_PRESERV_TM = 12,
    DON_NON_HR_BEAT = "N"
  )
}

testthat::test_that("add_pdri() names the missing columns", {
  df <- fake_donors()
  df$DON_CREAT <- NULL
  testthat::expect_error(
    add_pdri(df, variant = "KP"),
    class = "sRtr_error_missing_columns"
  )
  testthat::expect_snapshot(error = TRUE, add_pdri(df, variant = "KP"))
})

testthat::test_that("add_pdri() warns before overwriting the PDRI column", {
  df <- fake_donors()
  df$PDRI <- 1
  testthat::expect_warning(
    add_pdri(df, variant = "KP"),
    class = "sRtr_warning_column_overwritten"
  )
})

testthat::test_that("add_pdri(verbose = TRUE) reports the variant and BMI", {
  df <- fake_donors()
  df$DON_BMI <- NULL
  df$DON_WGT_KG <- 70
  testthat::expect_snapshot(out <- add_pdri(df, verbose = TRUE))
})

# ---- #96: missing race stays missing whatever the encoding ------------------

race_donors <- function(race) {
  df <- fake_donors()[rep(1, 4), ]
  df$DON_RACE <- race
  df
}

testthat::test_that("missing race gives a missing PDRI for every encoding", {
  meaning <- c(
    "16" = "16: Black or African American",
    "64" = "64: Asian",
    "8" = "8: White"
  )
  codes <- c(16L, 64L, 8L, NA)
  encodings <- list(
    numeric = codes,
    character = as.character(codes),
    label = unname(meaning[as.character(codes)]),
    factor = factor(unname(meaning[as.character(codes)]))
  )
  results <- lapply(encodings, \(race) add_pdri(race_donors(race), variant = "KP")$PDRI)

  for (enc in names(results)) {
    testthat::expect_equal(results[[enc]], results$numeric, ignore_attr = TRUE)
  }
  testthat::expect_equal(is.na(results$numeric), c(FALSE, FALSE, FALSE, TRUE))
  # Black and Asian are recognized in every encoding, not read as White.
  testthat::expect_equal(
    log(results$label[1:2] / results$label[3]),
    c(0.23951, 0.15711),
    tolerance = 1e-9
  )
})

testthat::test_that("with mean_impute, missing race counts as neither group for every encoding", {
  codes <- c(8L, NA)
  label <- c("8: White", NA)
  numeric <- add_pdri(race_donors(rep(codes, 2)), variant = "KP", mean_impute = TRUE)$PDRI
  labelled <- add_pdri(race_donors(rep(label, 2)), variant = "KP", mean_impute = TRUE)$PDRI
  testthat::expect_equal(labelled, numeric)
  testthat::expect_equal(numeric[2], numeric[1])
})

# ---- #99: the caller's columns are kept --------------------------------------

testthat::test_that("add_pdri() keeps the caller's dot-prefixed columns", {
  df <- fake_donors()[rep(1, 2), ]
  df$.row_id <- c(11L, 12L)
  attr(df$.row_id, "label") <- "Row ID"
  # Names add_pdri() once used for its own intermediate values.
  df$.DON_CREAT <- c("kept", "kept")
  df$.linpred <- c(-1, -2)

  out <- add_pdri(df, variant = "KP")

  testthat::expect_equal(out$.row_id, df$.row_id)
  testthat::expect_equal(attr(out$.row_id, "label"), "Row ID")
  testthat::expect_equal(out$.DON_CREAT, df$.DON_CREAT)
  testthat::expect_equal(out$.linpred, df$.linpred)
  testthat::expect_equal(names(out), c(names(df), "PDRI"))
  testthat::expect_equal(
    out$PDRI,
    add_pdri(fake_donors()[rep(1, 2), ], variant = "KP")$PDRI
  )
})

testthat::test_that("an output name starting with a dot is kept", {
  out <- add_pdri(fake_donors(), variant = "KP", pdri_col = ".pdri")
  testthat::expect_named(out, c(names(fake_donors()), ".pdri"))
  testthat::expect_equal(attr(out$.pdri, "label"), "Pancreas Donor Risk Index")
})

testthat::test_that("a grouped data frame keeps its groups and attributes", {
  df <- fake_donors()[rep(1, 4), ]
  df$grp <- c(1, 1, 2, 2)
  df$DON_CREAT <- c(1, NA, 3, NA)
  df <- dplyr::group_by(df, .data$grp)
  attr(df, "file_key") <- "TX_KP"

  out <- add_pdri(df, mean_impute = TRUE)

  testthat::expect_equal(dplyr::group_vars(out), "grp")
  testthat::expect_equal(attr(out, "file_key"), "TX_KP")
  # Row 2 is imputed from group 1 (creatinine 1), row 4 from group 2 (3).
  testthat::expect_equal(out$PDRI[2], out$PDRI[1])
  testthat::expect_equal(out$PDRI[4], out$PDRI[3])
})

testthat::test_that("an infinite PDRI is reported", {
  df <- fake_donors()
  df$DON_AGE_IN_MONTHS <- 1e6
  testthat::expect_warning(add_pdri(df, variant = "KP"), class = "sRtr_warning_pdri_infinite")
  testthat::expect_snapshot(out <- add_pdri(df, variant = "KP"))
})

# ---- review of eb368ae ---------------------------------------------------------

testthat::test_that("the RACE format's missing code counts as missing", {
  for (missing in c(".", "Missing")) {
    for (race in list(c("8", missing), factor(c("8: White", missing)))) {
      out <- add_pdri(race_donors(rep(race, 2)), variant = "KP")$PDRI
      testthat::expect_equal(is.na(out), c(FALSE, TRUE, FALSE, TRUE))
      imputed <- add_pdri(race_donors(rep(race, 2)), variant = "KP", mean_impute = TRUE)$PDRI
      testthat::expect_equal(imputed[2], imputed[1])
    }
  }
})

testthat::test_that("rowwise input imputes nothing from other rows", {
  df <- fake_donors()[rep(1, 2), ]
  df$DON_CREAT <- c(3, NA)
  out <- add_pdri(dplyr::rowwise(df), variant = "KP", mean_impute = TRUE)
  testthat::expect_equal(is.na(out$PDRI), c(FALSE, TRUE))
  testthat::expect_s3_class(out, "rowwise_df")
})

testthat::test_that("continuous inputs must be numeric", {
  df <- fake_donors()
  df$DON_WGT_KG <- 70
  df$DON_BMI <- factor("25")
  testthat::expect_error(
    add_pdri(df, variant = "KP"),
    class = "sRtr_error_non_numeric_columns"
  )
  testthat::expect_snapshot(error = TRUE, add_pdri(df, variant = "KP"))
})

testthat::test_that("an sf data frame is scored and keeps its geometry", {
  testthat::skip_if_not_installed("sf")
  df <- fake_donors()[rep(1, 2), ]
  geo <- sf::st_as_sf(
    cbind(df, x = c(0, 1), y = c(0, 1)),
    coords = c("x", "y")
  )

  out <- add_pdri(geo, variant = "KP")

  testthat::expect_s3_class(out, "sf")
  testthat::expect_equal(out$PDRI, add_pdri(df, variant = "KP")$PDRI)
})
