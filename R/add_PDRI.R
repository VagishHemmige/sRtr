#' Add Pancreas Donor Risk Index (PDRI)
#'
#' Computes PDRI and appends it to `df` (default column name: "PDRI").
#' If `df` is grouped (dplyr), optional mean-imputation is performed within groups.
#' Original columns are never modified.
#'
#' Required base columns:
#'   DON_GENDER, DON_AGE_IN_MONTHS, DON_CREAT, DON_RACE, DON_HGT_CM,
#'   DON_COD_DON_STROKE, REC_PA_PRESERV_TM, DON_NON_HR_BEAT
#' If `DON_BMI` is missing, it is computed from `DON_WGT_KG` and `DON_HGT_CM`.
#' PA additionally uses `REC_PREV_KI` for an interaction term; if absent, the
#' interaction is skipped (equivalent to KP behavior).
#'
#' `DON_RACE` (format `RACE`) may be raw codes, numeric or character, or
#' labels: code 16 (Black or African American) and code 64 (Asian) are read
#' the same way in each. A missing race (`NA`, or the format's missing code
#' `"."`, labelled `"Missing"`) gives a missing PDRI unless
#' `mean_impute = TRUE`, whatever the encoding. Continuous inputs (age,
#' creatinine, height, weight, BMI and cold ischemia time) must be numeric.
#'
#' @param df A data frame (may be a dplyr grouped data frame).
#' @param variant NULL (default; auto-detect), or "PA" (pancreas-alone), or "KP" (kidney-pancreas).
#' @param mean_impute Logical. If TRUE, mean-impute missing numeric inputs within the
#'   current group (or overall if ungrouped) for the calculation only.
#'   For indicator terms, NA is treated as 0 only when `mean_impute = TRUE`;
#'   otherwise NA propagates to PDRI.
#' @param pdri_col Name of the output column. Default "PDRI".
#' @param verbose If TRUE, print inference and sanity messages.
#' @param return_terms Logical. If TRUE, also attaches a list-column `PDRI_terms`
#'   with per-row linear predictor contributions (for QA/testing).
#'
#' @return `df` with a new `pdri_col` column; grouping is preserved.
#'
#' @examplesIf requireNamespace("dplyr", quietly = TRUE)
#' # Two made-up donors
#' donors <- data.frame(
#'   DON_GENDER = c("F", "M"),
#'   DON_AGE_IN_MONTHS = c(300, 540),
#'   DON_CREAT = c(0.9, 2.8),
#'   DON_RACE = c(8L, 16L),
#'   DON_BMI = c(24, 31),
#'   DON_HGT_CM = c(165, 180),
#'   DON_COD_DON_STROKE = c(0L, 1L),
#'   REC_PA_PRESERV_TM = c(10, 14),
#'   DON_NON_HR_BEAT = c("N", "Y")
#' )
#' add_pdri(donors, variant = "KP")
#'
#' \dontrun{
#' # Default: auto-detect PA vs KP
#' kp |>
#'   dplyr::group_by(REC_TX_YEAR) |>
#'   add_pdri(mean_impute = TRUE)
#'
#' # Force PA
#' pa |> add_pdri(variant = "PA")
#'
#' # Inspect term breakdown (QA)
#' # tmp <- kp |> dplyr::slice(1:3)
#' # res <- add_pdri(tmp, return_terms = TRUE)
#' # res$PDRI_terms[[1]]  # additive components for the first row
#' }
#' @export
add_pdri <- function(
  df,
  variant = NULL,
  mean_impute = FALSE,
  pdri_col = "PDRI",
  verbose = FALSE,
  return_terms = FALSE
) {
  # ---- helpers --------------------------------------------------------------
  infer_pdri_variant <- function(df, verbose = FALSE) {
    pick <- function(v, why = NULL) {
      if (verbose) {
        srtr_inform(
          c(
            "Using PDRI variant {.val {v}}.",
            "i" = if (!is.null(why)) "Inferred from {why}."
          ),
          class = "pdri_variant_inferred"
        )
      }
      v
    }
    fk <- attr(df, "file_key", exact = TRUE)
    if (is.character(fk) && length(fk)) {
      key <- tolower(paste(fk, collapse = " "))
      if (grepl("\\bkp\\b|kidney[ -_]?pancreas|tx_kp|trr_kp", key)) {
        return(pick("KP", "file_key"))
      }
      if (grepl("\\bpa\\b|pancreas[ -_]?alone|tx_pa|trr_pa", key)) {
        return(pick("PA", "file_key"))
      }
    }
    if ("DATASET" %in% names(df)) {
      ds <- tolower(paste(unique(df$DATASET), collapse = " "))
      if (grepl("\\bkp\\b|kidney[ -_]?pancreas", ds)) {
        return(pick("KP", "DATASET"))
      }
      if (grepl("\\bpa\\b|pancreas[ -_]?alone", ds)) {
        return(pick("PA", "DATASET"))
      }
    }
    sig_names <- c(
      "REC_TX_DT_KI",
      "REC_TX_KI",
      "REC_KI_SIMUL",
      "REC_SIM_KI",
      "REC_SIMULT_KI",
      "REC_SIMULT"
    )
    if (any(sig_names %in% names(df))) {
      return(pick("KP", "index-KI signal"))
    }
    ki_like <- grep("(^|_)KI(_|$)", names(df), value = TRUE)
    ki_like <- setdiff(ki_like, "REC_PREV_KI")
    if (length(ki_like) >= 5) {
      return(pick("KP", "many _KI columns"))
    }
    if (verbose) {
      srtr_inform(
        c(
          "Using PDRI variant {.val KP}.",
          "i" = "Could not tell KP from PA, so used the default."
        ),
        class = "pdri_variant_inferred"
      )
    }
    "KP"
  }

  # normalize flags and encodings
  norm_flag <- function(x) {
    if (is.logical(x)) {
      return(x)
    }
    y <- tolower(trimws(as.character(x)))
    out <- ifelse(
      y %in% c("1", "y", "yes", "true", "t"),
      TRUE,
      ifelse(y %in% c("0", "n", "no", "false", "f"), FALSE, NA)
    )
    out
  }
  norm_gender_f <- function(x) {
    y <- toupper(trimws(as.character(x)))
    out <- ifelse(
      y %in% c("F", "FEMALE"),
      1,
      ifelse(y %in% c("M", "MALE"), 0, NA_real_)
    )
    out
  }
  # Race (format RACE): code 16 is Black or African American, code 64 is
  # Asian. Raw codes (numeric or character) and labels are read alike; a
  # label is matched by its code or, for other wordings, by text. A missing
  # race stays missing, so PDRI is missing unless `mean_impute = TRUE`.
  race_flag <- function(x, code, pattern) {
    if (is.numeric(x)) {
      return(x == as.numeric(code))
    }
    z <- tolower(trimws(as.character(x)))
    flag <- .srtr_has_code(x, code, "RACE") | grepl(pattern, z)
    # The format's own missing code (".", labelled "Missing") is missing too.
    flag[is.na(x) | .srtr_has_code(x, ".", "RACE")] <- NA
    flag
  }
  race_black_flag <- function(x) race_flag(x, "16", "black|african")
  race_asian_flag <- function(x) race_flag(x, "64", "\\basian\\b")

  compute_bmi <- function(weight_kg, height_cm) {
    h_m <- height_cm / 100
    ifelse(
      is.na(weight_kg) | is.na(h_m) | h_m <= 0,
      NA_real_,
      weight_kg / (h_m^2)
    )
  }
  # Numeric mean imputation within dplyr groups (or overall if ungrouped).
  group_id <- if (inherits(df, c("grouped_df", "rowwise_df"))) {
    dplyr::group_indices(df)
  } else {
    rep(1L, nrow(df))
  }
  impute_num <- function(x) {
    if (!mean_impute) {
      return(x)
    }
    x <- as.numeric(x)
    stats::ave(x, group_id, FUN = function(v) {
      v[is.na(v)] <- mean(v, na.rm = TRUE)
      v
    })
  }
  # Indicator helper (NA -> 0 only if mean_impute=TRUE)
  ind_01 <- function(cond) {
    if (mean_impute) {
      as.numeric(ifelse(is.na(cond), FALSE, cond))
    } else {
      as.numeric(cond)
    }
  }

  # ---- variant & requirements ----------------------------------------------
  v <- if (is.null(variant) || identical(tolower(variant), "auto")) {
    infer_pdri_variant(df, verbose = verbose)
  } else {
    match.arg(variant, c("PA", "KP"))
  }

  has_bmi <- "DON_BMI" %in% names(df)
  required_base <- c(
    "DON_GENDER",
    "DON_AGE_IN_MONTHS",
    "DON_CREAT",
    "DON_RACE",
    "DON_HGT_CM",
    "DON_COD_DON_STROKE",
    "REC_PA_PRESERV_TM",
    "DON_NON_HR_BEAT"
  )
  if (!has_bmi) {
    required_base <- c(required_base, "DON_WGT_KG")
  }

  check_columns(df, required_base)
  continuous <- intersect(
    c(
      "DON_AGE_IN_MONTHS",
      "DON_CREAT",
      "DON_HGT_CM",
      "REC_PA_PRESERV_TM",
      "DON_BMI",
      "DON_WGT_KG"
    ),
    names(df)
  )
  not_numeric <- continuous[!vapply(df[continuous], is.numeric, logical(1))]
  if (length(not_numeric) > 0) {
    srtr_abort(
      c(
        "{.arg df} has {length(not_numeric)} continuous input{?s} that {?is/are} not numeric: {.field {not_numeric}}.",
        "i" = "Convert {cli::qty(length(not_numeric))}{?it/them} to numbers first; a factor's level positions are not its values."
      ),
      class = "non_numeric_columns",
      columns = not_numeric
    )
  }

  if (verbose) {
    if (!has_bmi) {
      srtr_inform(
        "{.field DON_BMI} not found; computing it from {.field DON_WGT_KG} and {.field DON_HGT_CM}.",
        class = "pdri_bmi_computed"
      )
    } else if (
      any(is.na(df$DON_BMI)) &&
        all(c("DON_WGT_KG", "DON_HGT_CM") %in% names(df))
    ) {
      srtr_inform(
        "Filling missing {.field DON_BMI} from {.field DON_WGT_KG} and {.field DON_HGT_CM} where available.",
        class = "pdri_bmi_computed"
      )
    }
    bad_h <- !is.na(df$DON_HGT_CM) & df$DON_HGT_CM <= 0
    if (any(bad_h)) {
      n_bad <- sum(bad_h)
      srtr_warn(
        "{.field DON_HGT_CM} is 0 or negative in {n_bad} row{?s}; BMI set to {.val {NA}} there.",
        class = "pdri_bad_height"
      )
    }
  }

  if (pdri_col %in% names(df)) {
    srtr_warn(
      "Overwriting existing column {.field {pdri_col}}.",
      class = "column_overwritten"
    )
  }
  out_name <- rlang::ensym(pdri_col)
  has_prev_ki <- "REC_PREV_KI" %in% names(df)

  # ---- compute predictors & PDRI -------------------------------------------
  # Intermediate values are kept apart from the caller's data, so no column of
  # `df` is overwritten or dropped, whatever its name (#99).
  col <- function(nm) df[[nm]]
  bmi <- if (has_bmi) {
    if (all(c("DON_WGT_KG", "DON_HGT_CM") %in% names(df))) {
      dplyr::coalesce(
        as.numeric(col("DON_BMI")),
        compute_bmi(col("DON_WGT_KG"), col("DON_HGT_CM"))
      )
    } else {
      col("DON_BMI")
    }
  } else {
    compute_bmi(col("DON_WGT_KG"), col("DON_HGT_CM"))
  }
  stroke <- col("DON_COD_DON_STROKE")
  p <- list(
    # numeric (optionally imputed)
    age = impute_num(col("DON_AGE_IN_MONTHS")),
    creat = impute_num(col("DON_CREAT")),
    hgt = impute_num(col("DON_HGT_CM")),
    cit = impute_num(col("REC_PA_PRESERV_TM")),
    bmi = impute_num(bmi),
    # indicators via normalization layer
    gender_f = ind_01(norm_flag(norm_gender_f(col("DON_GENDER")) == 1)),
    race_black = ind_01(race_black_flag(col("DON_RACE"))),
    race_asian = ind_01(race_asian_flag(col("DON_RACE"))),
    stroke = if (is.numeric(stroke)) ind_01(stroke == 1) else ind_01(norm_flag(stroke)),
    dcd = ind_01(norm_flag(col("DON_NON_HR_BEAT"))),
    prev_ki = if (has_prev_ki) ind_01(norm_flag(col("REC_PREV_KI"))) else 0
  )
  p$age_lt_240 <- as.numeric(p$age < 240)
  p$interaction <- if (v == "PA" && has_prev_ki) {
    -0.28137 * (p$stroke * p$prev_ki)
  } else {
    rep(0, nrow(df))
  }
  # linear predictor (coefficients as provided)
  linpred <- with(
    p,
    -0.13792 *
      gender_f +
      -0.034455 * age_lt_240 * ((age - 240) / 12) +
      0.026149 * ((age - 336) / 12) +
      0.19490 * (creat > 2.5) +
      0.23951 * race_black +
      0.15711 * race_asian -
      0.000986347 * (bmi - 24) +
      0.033274 * (bmi > 25) * (bmi - 25) -
      0.006073879 * (hgt - 173) +
      0.21018 * stroke +
      0.014678 * (cit - 12) +
      0.33172 * dcd +
      interaction
  )
  pdri_nm <- rlang::as_string(out_name)
  pdri <- exp(linpred)

  # --- warn if PDRI is Inf (likely due to extreme/miscoded inputs) ------------
  inf_idx <- which(is.infinite(pdri))
  if (length(inf_idx)) {
    # Show up to 5 example row numbers and their linear predictors
    ex_rows <- paste(utils::head(inf_idx, 5), collapse = ", ")
    ex_lp <- paste(
      round(utils::head(linpred[inf_idx], 5), 3),
      collapse = ", "
    )
    n_inf <- length(inf_idx)
    srtr_warn(
      c(
        "{n_inf} row{?s} gave {.val {Inf}} in {.field {pdri_nm}} (the linear predictor overflowed).",
        "i" = "Check inputs in {cli::qty(n_inf)}{?that row/those rows} for unit or coding errors or extreme values.",
        "i" = "First rows: {ex_rows}; linear predictors: {ex_lp}."
      ),
      class = "pdri_infinite"
    )
  }

  out <- df
  out[[pdri_nm]] <- pdri
  attr(out[[pdri_nm]], "label") <- "Pancreas Donor Risk Index"

  if (return_terms) {
    out[["PDRI_terms"]] <- lapply(seq_len(nrow(df)), function(i) {
      with(lapply(p, `[`, i), list(
        gender = -0.13792 * gender_f,
        age_lt240 = -0.034455 * age_lt_240 * ((age - 240) / 12),
        age_slope = 0.026149 * ((age - 336) / 12),
        creat = 0.19490 * (creat > 2.5),
        race_blk = 0.23951 * race_black,
        race_asn = 0.15711 * race_asian,
        bmi_lin = -0.000986347 * (bmi - 24),
        bmi_gt25 = 0.033274 * (bmi > 25) * (bmi - 25),
        height = -0.006073879 * (hgt - 173),
        stroke = 0.21018 * stroke,
        cit = 0.014678 * (cit - 12),
        dcd = 0.33172 * dcd,
        inter = interaction
      ))
    })
  }

  out
}
