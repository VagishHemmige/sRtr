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
add_pdri <- function(df,
                     variant = NULL,
                     mean_impute = FALSE,
                     pdri_col = "PDRI",
                     verbose = FALSE,
                     return_terms = FALSE) {

  # ---- helpers --------------------------------------------------------------
  infer_pdri_variant <- function(df, verbose = FALSE) {
    pick <- function(v, why = NULL) {
      if (verbose) message("add_pdri(): inferred variant = ", v,
                           if (!is.null(why)) paste0(" (", why, ")"))
      v
    }
    fk <- attr(df, "file_key", exact = TRUE)
    if (is.character(fk) && length(fk)) {
      key <- tolower(paste(fk, collapse = " "))
      if (grepl("\\bkp\\b|kidney[ -_]?pancreas|tx_kp|trr_kp", key)) return(pick("KP", "file_key"))
      if (grepl("\\bpa\\b|pancreas[ -_]?alone|tx_pa|trr_pa", key))   return(pick("PA", "file_key"))
    }
    if ("DATASET" %in% names(df)) {
      ds <- tolower(paste(unique(df$DATASET), collapse = " "))
      if (grepl("\\bkp\\b|kidney[ -_]?pancreas", ds)) return(pick("KP", "DATASET"))
      if (grepl("\\bpa\\b|pancreas[ -_]?alone", ds))   return(pick("PA", "DATASET"))
    }
    sig_names <- c("REC_TX_DT_KI","REC_TX_KI","REC_KI_SIMUL","REC_SIM_KI","REC_SIMULT_KI","REC_SIMULT")
    if (any(sig_names %in% names(df))) return(pick("KP", "index-KI signal"))
    ki_like <- grep("(^|_)KI(_|$)", names(df), value = TRUE)
    ki_like <- setdiff(ki_like, "REC_PREV_KI")
    if (length(ki_like) >= 5) return(pick("KP", "many _KI columns"))
    if (verbose) message("add_pdri(): unable to infer confidently; defaulting to KP")
    "KP"
  }

  # normalize flags and encodings
  norm_flag <- function(x) {
    if (is.logical(x)) return(x)
    y <- tolower(trimws(as.character(x)))
    out <- ifelse(y %in% c("1","y","yes","true","t"), TRUE,
                  ifelse(y %in% c("0","n","no","false","f"), FALSE, NA))
    out
  }
  norm_gender_f <- function(x) {
    y <- toupper(trimws(as.character(x)))
    out <- ifelse(y %in% c("F","FEMALE"), 1,
                  ifelse(y %in% c("M","MALE"),   0, NA_real_))
    out
  }
  # Internal handling for race (no user input needed):
  # - numeric codes: treat 16 as Black, 64 as Asian (common SRTR encodings)
  # - labeled/factor/character: regex on strings
  race_black_flag <- function(x) {
    if (is.numeric(x)) {
      x == 16
    } else {
      z <- tolower(trimws(as.character(x)))
      grepl("black|african", z)
    }
  }
  race_asian_flag <- function(x) {
    if (is.numeric(x)) {
      x == 64
    } else {
      z <- tolower(trimws(as.character(x)))
      grepl("\\basian\\b", z)
    }
  }

  compute_bmi <- function(weight_kg, height_cm) {
    h_m <- height_cm / 100
    ifelse(is.na(weight_kg) | is.na(h_m) | h_m <= 0, NA_real_, weight_kg / (h_m^2))
  }
  # Group-aware numeric imputation (respects dplyr grouping)
  impute_num <- function(x) {
    if (!mean_impute) return(x)
    m <- mean(x, na.rm = TRUE)
    x[is.na(x)] <- m
    x
  }
  # Indicator helper (NA -> 0 only if mean_impute=TRUE)
  ind_01 <- function(cond) {
    if (mean_impute) as.numeric(ifelse(is.na(cond), FALSE, cond)) else as.numeric(cond)
  }

  # ---- variant & requirements ----------------------------------------------
  v <- if (is.null(variant) || identical(tolower(variant), "auto")) {
    infer_pdri_variant(df, verbose = verbose)
  } else {
    match.arg(variant, c("PA", "KP"))
  }

  has_bmi <- "DON_BMI" %in% names(df)
  required_base <- c(
    "DON_GENDER", "DON_AGE_IN_MONTHS", "DON_CREAT", "DON_RACE",
    "DON_HGT_CM", "DON_COD_DON_STROKE", "REC_PA_PRESERV_TM", "DON_NON_HR_BEAT"
  )
  if (!has_bmi) required_base <- c(required_base, "DON_WGT_KG")

  missing_base <- setdiff(required_base, names(df))
  if (length(missing_base)) {
    stop("Missing required columns: ", paste(missing_base, collapse = ", "), call. = FALSE)
  }

  if (verbose) {
    if (!has_bmi) {
      message("add_pdri(): DON_BMI not found; computing from DON_WGT_KG and DON_HGT_CM.")
    } else if (any(is.na(df$DON_BMI)) && all(c("DON_WGT_KG","DON_HGT_CM") %in% names(df))) {
      message("add_pdri(): filling missing DON_BMI from DON_WGT_KG and DON_HGT_CM where available.")
    }
    bad_h <- !is.na(df$DON_HGT_CM) & df$DON_HGT_CM <= 0
    if (any(bad_h)) warning("DON_HGT_CM <= 0 for n = ", sum(bad_h), " rows; BMI set to NA there.", call. = FALSE)
  }

  if (pdri_col %in% names(df)) {
    warning("Overwriting existing column: ", pdri_col, call. = FALSE)
  }
  out_name <- rlang::ensym(pdri_col)
  has_prev_ki <- "REC_PREV_KI" %in% names(df)

  # ---- compute predictors & PDRI -------------------------------------------
  df2 <- df |>
    dplyr::mutate(
      # numeric (optionally imputed)
      .DON_AGE_IN_MONTHS = impute_num(.data$DON_AGE_IN_MONTHS),
      .DON_CREAT         = impute_num(.data$DON_CREAT),
      .DON_HGT_CM        = impute_num(.data$DON_HGT_CM),
      .REC_PA_PRESERV_TM = impute_num(.data$REC_PA_PRESERV_TM),

      # BMI: use existing, fill missing, or compute fully
      .DON_BMI = impute_num(
        if (has_bmi) {
          if (all(c("DON_WGT_KG","DON_HGT_CM") %in% names(df))) {
            dplyr::coalesce(.data$DON_BMI, compute_bmi(.data$DON_WGT_KG, .data$DON_HGT_CM))
          } else {
            .data$DON_BMI
          }
        } else {
          compute_bmi(.data$DON_WGT_KG, .data$DON_HGT_CM)
        }
      ),

      # indicators via normalization layer
      .GENDER_F   = ind_01(norm_flag(norm_gender_f(.data$DON_GENDER) == 1)),
      .RACE_BLACK = ind_01(race_black_flag(.data$DON_RACE)),
      .RACE_ASIAN = ind_01(race_asian_flag(.data$DON_RACE)),
      .STROKE     = {
        x <- .data$DON_COD_DON_STROKE
        if (is.numeric(x)) ind_01(x == 1) else ind_01(norm_flag(x))
      },
      .DCD        = ind_01(norm_flag(.data$DON_NON_HR_BEAT)),
      .PREV_KI    = if (has_prev_ki) ind_01(norm_flag(.data$REC_PREV_KI)) else 0,

      .AGE_LT_240 = as.numeric(.data$.DON_AGE_IN_MONTHS < 240),

      .interaction_term = if (v == "PA" && has_prev_ki) {
        -0.28137 * (.data$.STROKE * .data$.PREV_KI)
      } else { 0 },

      # linear predictor (coefficients as provided)
      .linpred =
        -0.13792     * .data$.GENDER_F +
        -0.034455    * .data$.AGE_LT_240 * ((.data$.DON_AGE_IN_MONTHS - 240) / 12) +
        0.026149    * ((.data$.DON_AGE_IN_MONTHS - 336) / 12) +
        0.19490     * (.data$.DON_CREAT > 2.5) +
        0.23951     * .data$.RACE_BLACK +
        0.15711     * .data$.RACE_ASIAN -
        0.000986347 * (.data$.DON_BMI - 24) +
        0.033274    * (.data$.DON_BMI > 25) * (.data$.DON_BMI - 25) -
        0.006073879 * (.data$.DON_HGT_CM - 173) +
        0.21018     * .data$.STROKE +
        0.014678    * (.data$.REC_PA_PRESERV_TM - 12) +
        0.33172     * .data$.DCD +
        .data$.interaction_term,

      !!out_name := exp(.data$.linpred)
    )

  # --- warn if PDRI is Inf (likely due to extreme/miscoded inputs) ------------
  pdri_nm <- rlang::as_string(out_name)
  inf_idx <- which(is.infinite(df2[[pdri_nm]]))
  if (length(inf_idx)) {
    # Show up to 5 example row numbers and their linear predictors
    ex_rows <- paste(head(inf_idx, 5), collapse = ", ")
    ex_lp   <- paste(round(head(df2$.linpred[inf_idx], 5), 3), collapse = ", ")
    warning(
      sprintf(
        "add_pdri(): %d row(s) produced Inf in %s (exp(linear predictor) overflow). ",
        length(inf_idx), pdri_nm
      ),
      "Validate inputs for those rows (possible unit/coding errors or extreme values). ",
      sprintf("Examples — rows: [%s]; linear predictors: [%s].", ex_rows, ex_lp),
      call. = FALSE
    )
  }


  if (return_terms) {
    terms_list <- lapply(seq_len(nrow(df2)), function(i) {
      G   <- df2$.GENDER_F[i]
      AGE <- df2$.DON_AGE_IN_MONTHS[i]
      AGE_LT <- df2$.AGE_LT_240[i]
      CREAT  <- df2$.DON_CREAT[i]
      RB <- df2$.RACE_BLACK[i]
      RA <- df2$.RACE_ASIAN[i]
      BMI <- df2$.DON_BMI[i]
      HGT <- df2$.DON_HGT_CM[i]
      STR <- df2$.STROKE[i]
      CIT <- df2$.REC_PA_PRESERV_TM[i]
      DCD <- df2$.DCD[i]
      INT <- df2$.interaction_term[i]
      list(
        gender   = -0.13792    * G,
        age_lt240= -0.034455   * AGE_LT * ((AGE - 240)/12),
        age_slope=  0.026149   * ((AGE - 336)/12),
        creat    =  0.19490    * (CREAT > 2.5),
        race_blk =  0.23951    * RB,
        race_asn =  0.15711    * RA,
        bmi_lin  = -0.000986347* (BMI - 24),
        bmi_gt25 =  0.033274   * (BMI > 25) * (BMI - 25),
        height   = -0.006073879* (HGT - 173),
        stroke   =  0.21018    * STR,
        cit      =  0.014678   * (CIT - 12),
        dcd      =  0.33172    * DCD,
        inter    =  INT
      )
    })
    df2[["PDRI_terms"]] <- terms_list
  }

  # Drop scratch columns, preserve grouping
  keep_terms <- if (return_terms) "PDRI_terms" else NULL
  # Drop scratch columns safely, keep optional PDRI_terms

  out <- df2
  scratch <- grep("^\\.", names(out), value = TRUE)
  if (length(scratch)) out <- dplyr::select(out, -dplyr::all_of(scratch))

  # (Optional) move PDRI_terms to the end for readability
  if ("PDRI_terms" %in% names(out)) {
    out <- dplyr::relocate(out, PDRI_terms, .after = dplyr::last_col())
  }

pdri_nm <- rlang::as_string(out_name)
attr(out[[pdri_nm]], "label") <- "Pancreas Donor Risk Index"

out
}
