#' Add the Kidney Donor Risk Index and Kidney Donor Profile Index
#'
#' Computes the donor-only Kidney Donor Risk Index (KDRI) and the Kidney Donor
#' Profile Index (KDPI) for deceased kidney donors from Standard Analysis File
#' (SAF) columns, and appends three columns: the unscaled KDRI (`KDRI_RAO`),
#' the KDRI scaled to the median donor of the reference year (`KDRI`), and the
#' KDPI, a percentile from 0 to 100.
#'
#' Two formulas are available. `"refit2024"` is the formula OPTN has used
#' since 2024-10-31, refit without donor race or hepatitis C. `"rao2009"` is
#' the original 10-factor donor-only formula, used by OPTN before then. The
#' KDPI comes from an OPTN mapping table (see [optn_mapping_tables]); only
#' tables built with the chosen formula are used.
#'
#' Input columns (codes as in the SRTR data dictionary; labelled factors from
#' [apply_srtr_factors()] also work):
#' * `DON_AGE` (years), `DON_HGT_CM`, `DON_WGT_KG`, `DON_CREAT` (mg/dL);
#' * `DON_HIST_HYPERTEN`, `DON_HIST_DIAB`: 1 no, 2 to 5 yes, 998 unknown;
#' * `DON_CAD_DON_COD` (2 = cerebrovascular/stroke; 1, 3, 4, 999 = other;
#'   998 = unknown), or `DON_COD_DON_STROKE` (1 = yes, 0 = no) when
#'   `DON_CAD_DON_COD` is absent;
#' * `DON_NON_HR_BEAT` (Y = donation after circulatory death);
#' * for `"rao2009"` only: `DON_RACE_BLACK_AFRICAN_AMERICAN` (Y/N), or
#'   `DON_RACE` (16 = Black or African American; 1024 = unknown) when that
#'   column is absent;
#'   and at least one of `DON_ANTI_HCV`, `DON_HCV_NAT` (P = positive) and
#'   `DON_HCV_STAT` (1 = positive);
#' * for `table = "in_force"`: `DON_RECOV_DT`.
#'
#' As in the OPTN calculator, creatinine above 8 mg/dL counts as 8, and for
#' `"rao2009"` an unknown, pending or not-done HCV result counts as negative.
#' Any other missing or unknown input, including an unknown cause of death or
#' race and a creatinine that is not a positive number, gives a missing KDRI
#' and KDPI. A multiracial donor (a `DON_RACE` code that is a sum of single
#' codes) is not counted as Black by the `DON_RACE` fallback.
#'
#' @param df A data frame of deceased donors or transplants, one row each.
#' @param version KDRI formula: `"refit2024"` (default) or `"rao2009"`.
#' @param table Which mapping table to use: `"latest"` (default), the newest
#'   stored table for `version`; `"in_force"`, for each row the table OPTN was
#'   using on `DON_RECOV_DT`; or a table label such as `"2018"` (see
#'   [optn_mapping_tables]). For `"in_force"`, each table's start date is
#'   OPTN's published date where one exists (2024-05-29, the refit on
#'   2024-10-31, and 2025-05-21); otherwise it is June 1 of the year after
#'   the reference year, the deadline OPTN Policy 8.4.B sets, which is a
#'   convention. Rao 2009 tables end on 2024-10-31 and refit tables start
#'   then. Rows with no stored table in force, such as refit KDPI from
#'   2025-05-21, when OPTN used a table it has not archived, get a missing
#'   KDPI, with a warning. The dates and their basis are in
#'   `optn_mapping_tables$effective`.
#' @param unknown_history How to treat unknown hypertension or diabetes
#'   history (code 998). `"optn"` (default) follows the OPTN calculator: the
#'   term is weighted by the share of reference donors with that history,
#'   printed on the mapping table. The 2012 and 2013 tables do not print
#'   these shares, so with them unknown history gives a missing KDRI. `"na"`
#'   always gives a missing KDRI.
#' @param kdri_rao_col,kdri_col,kdpi_col Names of the output columns.
#' @param return_terms If `TRUE`, also add a list-column `KDRI_terms` with each
#'   row's linear predictor components.
#'
#' @return `df` with three new columns. The KDPI column carries attributes
#'   `optn_table` (the table label used for each row) and `kdri_formula`.
#'
#' @references
#' Rao PS, Schaubel DE, Guidinger MK, et al. A comprehensive risk
#' quantification score for deceased donor kidneys: the kidney donor risk
#' index. *Transplantation* 2009;88:231-236. \doi{10.1097/TP.0b013e3181ac620b}
#'
#' OPTN. *A Guide to Calculating and Interpreting the Kidney Donor Profile
#' Index (KDPI).* Updated 2020-03-23 (Table 1, Rao 2009 coefficients) and
#' 2026-04-23 (Table 1, refit coefficients).
#'
#' @examples
#' donors <- data.frame(
#'   DON_AGE = c(52, 30),
#'   DON_HGT_CM = c(183, 165),
#'   DON_WGT_KG = c(81, 70),
#'   DON_HIST_HYPERTEN = c(2, 1),
#'   DON_HIST_DIAB = c(1, 1),
#'   DON_CAD_DON_COD = c(2, 3),
#'   DON_CREAT = c(1.7, 0.9),
#'   DON_NON_HR_BEAT = c("Y", "N")
#' )
#' add_kdpi(donors)
#' @export
add_kdpi <- function(
  df,
  version = c("refit2024", "rao2009"),
  table = "latest",
  unknown_history = c("optn", "na"),
  kdri_rao_col = "KDRI_RAO",
  kdri_col = "KDRI",
  kdpi_col = "KDPI",
  return_terms = FALSE
) {
  version <- rlang::arg_match(version)
  unknown_history <- rlang::arg_match(unknown_history)
  table <- .check_table_arg(table, "kdpi", version)

  required <- c(
    "DON_AGE", "DON_HGT_CM", "DON_WGT_KG", "DON_CREAT",
    "DON_HIST_HYPERTEN", "DON_HIST_DIAB", "DON_NON_HR_BEAT"
  )
  check_columns(df, required)
  if (!any(c("DON_CAD_DON_COD", "DON_COD_DON_STROKE") %in% names(df))) {
    check_columns(df, "DON_CAD_DON_COD", why = "Or supply {.field DON_COD_DON_STROKE}.")
  }
  if (version == "rao2009") {
    if (!any(c("DON_RACE_BLACK_AFRICAN_AMERICAN", "DON_RACE") %in% names(df))) {
      check_columns(df, "DON_RACE", why = "Or supply {.field DON_RACE_BLACK_AFRICAN_AMERICAN}.")
    }
    hcv_cols <- intersect(c("DON_ANTI_HCV", "DON_HCV_NAT", "DON_HCV_STAT"), names(df))
    if (!length(hcv_cols)) {
      check_columns(
        df,
        "DON_ANTI_HCV",
        why = "Or supply {.field DON_HCV_NAT} or {.field DON_HCV_STAT}."
      )
    }
  }
  if (table == "in_force") {
    check_columns(df, "DON_RECOV_DT", why = "{.code table = \"in_force\"} needs the recovery date.")
  }
  .warn_overwrite(df, c(kdri_rao_col, kdri_col, kdpi_col, if (return_terms) "KDRI_terms"))

  n <- nrow(df)
  date <- if (table == "in_force") as.Date(df$DON_RECOV_DT) else NULL
  labels <- .optn_pick_labels(table, "kdpi", n, date, version)
  if (table == "in_force" && any(is.na(labels) & !is.na(date))) {
    n_missing <- sum(is.na(labels) & !is.na(date))
    stored <- .optn_labels("kdpi", version)
    srtr_warn(
      c(
        "No stored {version} KDPI table was in force on the recovery date for {n_missing} row{?s}; KDPI set to {.val {NA}}.",
        "i" = "Stored {version} tables: {.val {stored}}. See {.code optn_mapping_tables$effective} for the dates."
      ),
      class = "table_not_stored"
    )
  }
  meta <- sRtr::optn_mapping_tables$tables
  meta <- meta[meta$score == "kdpi", ]
  m <- match(labels, meta$label)
  scaling <- meta$scaling_factor[m]
  hyp_share <- meta$hypertension_pct[m] / 100
  diab_share <- meta$diabetes_pct[m] / 100

  coef <- .kdri_coefficients[[version]]
  age <- as.numeric(df$DON_AGE)
  hgt <- as.numeric(df$DON_HGT_CM)
  wgt <- as.numeric(df$DON_WGT_KG)
  creat <- pmin(.positive_finite(df$DON_CREAT), 8)

  history <- function(x, share) {
    code <- .srtr_code(x)
    out <- ifelse(code == 1, 0, ifelse(code %in% 2:5, 1, NA_real_))
    if (unknown_history == "optn") {
      out <- ifelse(code == 998, share, out)
    }
    out
  }
  hyp <- history(df$DON_HIST_HYPERTEN, hyp_share)
  diab <- history(df$DON_HIST_DIAB, diab_share)

  # Cause of death (format DONCOD): 2 is cerebrovascular/stroke; 1, 3, 4 and
  # 999 are other known causes; 998 (unknown) gives NA.
  cva <- if ("DON_CAD_DON_COD" %in% names(df)) {
    .srtr_code_in(df$DON_CAD_DON_COD, yes = 2, no = c(1, 3, 4, 999))
  } else {
    .srtr_code_in(df$DON_COD_DON_STROKE, yes = 1, no = 0)
  }
  dcd <- as.numeric(.srtr_yes(df$DON_NON_HR_BEAT))

  terms <- list(
    age = coef[["age"]] * (age - 40) +
      coef[["age_lt18"]] * (age - 18) * (age < 18) +
      coef[["age_gt50"]] * (age - 50) * (age > 50),
    height = coef[["height"]] * (hgt - 170) / 10,
    weight = coef[["weight"]] * (wgt - 80) / 5 * (wgt < 80),
    hypertension = coef[["hypertension"]] * hyp,
    diabetes = coef[["diabetes"]] * diab,
    cva = coef[["cva"]] * cva,
    creatinine = coef[["creat"]] * (creat - 1) +
      coef[["creat_gt15"]] * (creat - 1.5) * (creat > 1.5),
    dcd = coef[["dcd"]] * dcd
  )
  if (version == "rao2009") {
    terms$race <- coef[["black"]] * .donor_black(df)
    terms$hcv <- coef[["hcv"]] * .kdri_hcv_positive(df, hcv_cols)
  }

  xb <- Reduce(`+`, terms)
  kdri_rao <- exp(xb)
  kdri <- kdri_rao / scaling
  kdpi <- rep(NA_real_, n)
  for (lab in unique(labels[!is.na(labels)])) {
    i <- which(labels == lab)
    kdpi[i] <- .optn_percentile(kdri[i], "kdpi", lab)
  }
  .inform_missing_score(kdri_rao, "KDRI")

  attr(kdpi, "optn_table") <- labels
  attr(kdpi, "kdri_formula") <- version
  attr(kdri_rao, "label") <- "Kidney Donor Risk Index (unscaled, KDRI_RAO)"
  attr(kdri, "label") <- "Kidney Donor Risk Index (scaled to the reference median)"
  attr(kdpi, "label") <- "Kidney Donor Profile Index"

  df[[kdri_rao_col]] <- kdri_rao
  df[[kdri_col]] <- kdri
  df[[kdpi_col]] <- kdpi
  if (return_terms) {
    df[["KDRI_terms"]] <- lapply(seq_len(n), function(i) {
      vapply(terms, `[`, numeric(1), i)
    })
  }
  df
}

# Coefficients from Table 1 of the OPTN KDPI guide: the 2020-03-23 edition
# for Rao 2009, the 2026-04-23 edition for the refit.
.kdri_coefficients <- list(
  rao2009 = c(
    age = 0.0128, age_lt18 = -0.0194, age_gt50 = 0.0107,
    height = -0.0464, weight = -0.0199,
    black = 0.1790, hypertension = 0.1260, diabetes = 0.1300, cva = 0.0881,
    creat = 0.2200, creat_gt15 = -0.2090, hcv = 0.2400, dcd = 0.1330
  ),
  refit2024 = c(
    age = 0.0092, age_lt18 = 0.0113, age_gt50 = 0.0067,
    height = -0.0557, weight = -0.0333,
    hypertension = 0.1106, diabetes = 0.2577, cva = 0.0743,
    creat = 0.2128, creat_gt15 = -0.2199, dcd = 0.1966
  )
)

# HCV positive if any serology or NAT result is positive; anything else,
# including unknown, counts as negative (KDPI guide, 2020).
.kdri_hcv_positive <- function(df, cols) {
  pos <- rep(FALSE, nrow(df))
  for (col in cols) {
    x <- df[[col]]
    hit <- if (col == "DON_HCV_STAT") {
      .srtr_code(x) == 1
    } else {
      toupper(trimws(sub(":.*$", "", as.character(x)))) == "P"
    }
    pos <- pos | (!is.na(hit) & hit)
  }
  as.numeric(pos)
}
