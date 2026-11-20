#' Add the Estimated Post-Transplant Survival score
#'
#' Computes the raw Estimated Post-Transplant Survival (EPTS) value for adult
#' kidney candidates or recipients from Standard Analysis File (SAF) columns
#' and maps it to the EPTS score, a percentile from 0 to 100, with an OPTN
#' mapping table (see [optn_mapping_tables]).
#'
#' EPTS uses four factors: age, current diabetes, any prior solid organ
#' transplant, and years on dialysis. They are read from these columns
#' (labelled factors from [apply_srtr_factors()] also work):
#'
#' | Factor | `at = "listing"` | `at = "transplant"` |
#' |---|---|---|
#' | Date scored | `CAN_LISTING_DT` | `REC_TX_DT` |
#' | Age | `CAN_AGE_IN_MONTHS_AT_LISTING` / 12 | `REC_AGE_IN_MONTHS_AT_TX` / 12 |
#' | Dialysis start | `CAN_DIAL_DT` | `REC_DIAL_DT` |
#' | Dialysis status | `CAN_DIAL` | `REC_DIAL_TY` |
#'
#' Diabetes comes from `CAN_DIAB_TY` (1 no; 2 to 5 yes; 998 unknown), or
#' `CAN_DIAB` when that column is absent. A prior solid organ transplant is
#' any value above 0 (or `Y`) among the organ columns `*_PREV_HL`, `*_PREV_HR`,
#' `*_PREV_IN`, `*_PREV_KI`, `*_PREV_KP`, `*_PREV_LI`, `*_PREV_LU` and
#' `*_PREV_PA` that are present: `REC_PREV_*` at transplant when any are
#' present, otherwise `CAN_PREV_*`. It is none when every column present is 0
#' (or `N`), and missing otherwise. `CAN_PREV_TX` is used only when no organ
#' column is present, because it may count non-organ transplants. The
#' dictionary gives these columns no format, so whether they are counts or
#' flags is read the same way.
#'
#' OPTN measures age in fractional years from the date of birth. SAFs carry
#' age in whole months, so age here is months / 12, which can differ from
#' OPTN's by up to one month (a raw EPTS difference of at most 0.004).
#' Years on dialysis is the days from dialysis start to the date scored,
#' divided by 365.25, and 0 if dialysis starts later.
#'
#' @seealso Guides:
#' * [Which mapping table: KDPI and EPTS](https://vagishhemmige.github.io/sRtr/articles/adding-columns.html#which-mapping-table-kdpi-and-epts)
#' * [Missing and unknown inputs](https://vagishhemmige.github.io/sRtr/articles/adding-columns.html#missing-and-unknown-inputs)
#' @param df A data frame of candidates or recipients, one row each.
#' @param at Score the candidate at `"listing"` (default) or at
#'   `"transplant"`.
#' @param table Which mapping table to use: `"latest"` (default), the newest
#'   stored table; `"in_force"`, for each row the table OPTN was using on the
#'   date scored; or a table label such as `"2018"`. For `"in_force"`, each
#'   table's start date is OPTN's published date where one exists
#'   (2024-05-29 and 2025-05-21); otherwise it is June 1 of the year after
#'   the snapshot, the deadline in OPTN Policy 8.4.B, which is a convention.
#'   Rows with no stored table in force get a missing score, with a warning.
#'   The dates and their basis are in `optn_mapping_tables$effective`.
#' @param unknown_diabetes How to treat unknown diabetes status (code 998).
#'   `"na"` (default) gives a missing score. `"no"` counts it as no diabetes;
#'   this is a convention some analyses use, not part of the OPTN definition.
#' @param missing_dialysis_date How to treat a missing dialysis start date.
#'   `"status"` (default) counts it as 0 years when the dialysis status column
#'   says the candidate was not on dialysis (code 1), and otherwise gives a
#'   missing score. `"zero"` always counts it as 0 years, a convention.
#' @param adults_only If `TRUE` (default), candidates under 18 get a missing
#'   score: OPTN assigns EPTS to adults only.
#' @param epts_col,raw_col Names of the output columns for the score and the
#'   raw value.
#' @param return_terms If `TRUE`, also add a list-column `EPTS_terms` with
#'   each row's inputs.
#'
#' @return `df` with two new columns. The score column carries an
#'   `optn_table` attribute with the table label used for each row.
#'
#' @references
#' OPTN. *A Guide to Calculating and Interpreting the Estimated
#' Post-Transplant Survival (EPTS) Score Used in the Kidney Allocation
#' System.* Updated 2026-04-07 (formula and worked examples).
#'
#' @examples
#' candidates <- data.frame(
#'   CAN_AGE_IN_MONTHS_AT_LISTING = c(600, 300),
#'   CAN_LISTING_DT = as.Date(c("2025-01-01", "2025-01-01")),
#'   CAN_DIAL_DT = as.Date(c("2020-01-01", NA)),
#'   CAN_DIAL = c(2, 1),
#'   CAN_DIAB_TY = c(1, 3),
#'   CAN_PREV_KI = c("N", "Y")
#' )
#' add_epts(candidates)
#' @export
add_epts <- function(
  df,
  at = c("listing", "transplant"),
  table = "latest",
  unknown_diabetes = c("na", "no"),
  missing_dialysis_date = c("status", "zero"),
  adults_only = TRUE,
  epts_col = "EPTS",
  raw_col = "EPTS_RAW",
  return_terms = FALSE
) {
  at <- rlang::arg_match(at)
  unknown_diabetes <- rlang::arg_match(unknown_diabetes)
  missing_dialysis_date <- rlang::arg_match(missing_dialysis_date)
  table <- .check_table_arg(table, "epts")

  cols <- switch(
    at,
    listing = c(
      date = "CAN_LISTING_DT",
      age = "CAN_AGE_IN_MONTHS_AT_LISTING",
      dial_dt = "CAN_DIAL_DT",
      dial_status = "CAN_DIAL"
    ),
    transplant = c(
      date = "REC_TX_DT",
      age = "REC_AGE_IN_MONTHS_AT_TX",
      dial_dt = "REC_DIAL_DT",
      dial_status = "REC_DIAL_TY"
    )
  )
  needed <- cols[c("date", "age", "dial_dt")]
  if (missing_dialysis_date == "status") {
    needed <- c(needed, cols[["dial_status"]])
  }
  check_columns(df, unname(needed))
  if (!any(c("CAN_DIAB_TY", "CAN_DIAB") %in% names(df))) {
    check_columns(df, "CAN_DIAB_TY", why = "Or supply {.field CAN_DIAB}.")
  }
  organs <- c("HL", "HR", "IN", "KI", "KP", "LI", "LU", "PA")
  organ_cols <- intersect(paste0("REC_PREV_", organs), names(df))
  if (at == "listing" || !length(organ_cols)) {
    organ_cols <- intersect(paste0("CAN_PREV_", organs), names(df))
  }
  if (!length(organ_cols) && !"CAN_PREV_TX" %in% names(df)) {
    check_columns(df, "CAN_PREV_KI", why = "Supply the {.field CAN_PREV_*} columns or {.field CAN_PREV_TX}.")
  }
  .warn_overwrite(df, c(epts_col, raw_col, if (return_terms) "EPTS_terms"))

  date <- as.Date(df[[cols[["date"]]]])
  age <- as.numeric(df[[cols[["age"]]]]) / 12

  dial_dt <- as.Date(df[[cols[["dial_dt"]]]])
  years <- pmax(as.numeric(date - dial_dt) / 365.25, 0)
  no_date <- is.na(dial_dt)
  if (missing_dialysis_date == "zero") {
    years[no_date] <- 0
  } else {
    not_on_dialysis <- .srtr_code(df[[cols[["dial_status"]]]]) == 1
    years[no_date & !is.na(not_on_dialysis) & not_on_dialysis] <- 0
  }

  diabetes <- if ("CAN_DIAB_TY" %in% names(df)) {
    code <- .srtr_code(df$CAN_DIAB_TY)
    ifelse(code == 1, 0, ifelse(code %in% 2:5, 1, NA_real_))
  } else {
    code <- .srtr_code(df$CAN_DIAB)
    ifelse(code == 1, 0, ifelse(code %in% 2:4, 1, NA_real_))
  }
  if (unknown_diabetes == "no") {
    diabetes[!is.na(code) & code == 998] <- 0
  }

  prior_tx <- if (length(organ_cols)) {
    flags <- vapply(organ_cols, function(col) .any_prior(df[[col]]), numeric(nrow(df)))
    flags <- matrix(flags, nrow = nrow(df))
    any_yes <- rowSums(!is.na(flags) & flags == 1) > 0
    all_known <- rowSums(is.na(flags)) == 0
    ifelse(any_yes, 1, ifelse(all_known, 0, NA_real_))
  } else {
    .any_prior(df$CAN_PREV_TX)
  }

  raw <- .epts_raw(age, diabetes, prior_tx, years)
  if (adults_only) {
    raw[!is.na(age) & age < 18] <- NA_real_
  }

  labels <- .optn_pick_labels(table, "epts", nrow(df), date)
  if (table == "in_force" && any(is.na(labels) & !is.na(date))) {
    n_missing <- sum(is.na(labels) & !is.na(date))
    stored <- .optn_labels("epts")
    srtr_warn(
      c(
        "No stored EPTS table was in force on the date scored for {n_missing} row{?s}; EPTS set to {.val {NA}}.",
        "i" = "Stored tables: {.val {stored}}. See {.code optn_mapping_tables$effective} for the dates."
      ),
      class = "table_not_stored"
    )
  }
  score <- rep(NA_real_, nrow(df))
  for (lab in unique(labels[!is.na(labels)])) {
    i <- which(labels == lab)
    score[i] <- .optn_percentile(raw[i], "epts", lab)
  }
  .inform_missing_score(raw, "EPTS")

  attr(raw, "label") <- "Raw Estimated Post-Transplant Survival"
  attr(score, "label") <- "Estimated Post-Transplant Survival score"
  attr(score, "optn_table") <- labels

  df[[raw_col]] <- raw
  df[[epts_col]] <- score
  if (return_terms) {
    df[["EPTS_terms"]] <- lapply(seq_len(nrow(df)), function(i) {
      c(age = age[i], diabetes = diabetes[i], prior_tx = prior_tx[i], years_dialysis = years[i])
    })
  }
  df
}

# Raw EPTS formula, from the OPTN EPTS guide (updated 2026-04-07).
.epts_raw <- function(age, diabetes, prior_tx, years_dialysis) {
  age25 <- pmax(age - 25, 0)
  log_dial <- log(years_dialysis + 1)
  none <- as.numeric(years_dialysis == 0)
  0.047 * age25 -
    0.015 * diabetes * age25 +
    0.398 * prior_tx -
    0.237 * diabetes * prior_tx +
    0.315 * log_dial -
    0.099 * diabetes * log_dial +
    0.130 * none -
    0.348 * diabetes * none +
    1.262 * diabetes
}

# Prior transplants from a count or a flag: 1 for any (a number above 0, or
# Y), 0 for none (0 or N), NA otherwise.
.any_prior <- function(x) {
  if (is.numeric(x)) {
    return(ifelse(x > 0, 1, ifelse(x == 0, 0, NA_real_)))
  }
  code <- .srtr_code(x)
  flag <- as.numeric(.srtr_yes(x))
  ifelse(!is.na(code), as.numeric(code > 0), flag)
}
