# Helpers shared by the score calculators (add_kdpi(), add_epts(),
# add_donor_egfr(), add_pvr()).
#
# SAF columns arrive in three shapes: raw codes (numbers or short strings),
# factors made by apply_srtr_factors() whose labels start with the code
# ("2: YES, 0-5 YEARS"), and Y/N flags. These helpers read all three.

# The SRTR code of each value: the number itself, or the code in front of
# "<code>: " in a label. Anything else is NA.
.srtr_code <- function(x) {
  if (is.numeric(x)) {
    return(as.numeric(x))
  }
  x <- trimws(as.character(x))
  code <- sub("^([0-9]+)(:.*)?$", "\\1", x)
  out <- suppressWarnings(as.numeric(code))
  out[!grepl("^[0-9]+(:.*)?$", x)] <- NA_real_
  out
}

# Y/N flag as TRUE/FALSE/NA. Accepts Y/N, Yes/No, 1/0, TRUE/FALSE and labels
# such as "Y: Yes".
.srtr_yes <- function(x) {
  if (is.logical(x)) {
    return(x)
  }
  if (is.numeric(x)) {
    return(ifelse(x %in% c(0, 1), x == 1, NA))
  }
  y <- toupper(trimws(sub(":.*$", "", as.character(x))))
  ifelse(
    y %in% c("Y", "YES", "1", "TRUE", "T"),
    TRUE,
    ifelse(y %in% c("N", "NO", "0", "FALSE", "F"), FALSE, NA)
  )
}

# 1 for codes in `yes`, 0 for codes in `no`, NA for anything else, including
# unknown codes (such as 998) and values that are not codes.
.srtr_code_in <- function(x, yes, no) {
  code <- .srtr_code(x)
  ifelse(code %in% yes, 1, ifelse(code %in% no, 0, NA_real_))
}

# Donor recorded as Black or African American: 1, 0 or NA. Uses
# DON_RACE_BLACK_AFRICAN_AMERICAN (Y/N) when present, otherwise DON_RACE
# (format RACE): 16 is 1; the other single codes and 2000 (Hispanic/Latino)
# are 0; 1024 (unknown) and anything unrecognised are NA. A multiracial donor,
# coded as a sum of single codes, is 0: the sum is not decomposed here.
.donor_black <- function(df) {
  if ("DON_RACE_BLACK_AFRICAN_AMERICAN" %in% names(df)) {
    return(as.numeric(.srtr_yes(df$DON_RACE_BLACK_AFRICAN_AMERICAN)))
  }
  code <- .srtr_code(df$DON_RACE)
  single <- c(8, 32, 64, 128, 256, 512, 2000)
  multi <- !is.na(code) & code > 0 & code < 1024 & code %% 8 == 0 &
    !code %in% c(single, 16)
  ifelse(code %in% 16, 1, ifelse(code %in% single | multi, 0, NA_real_))
}

# Numeric values that must be positive and finite (creatinine, for example);
# anything else becomes NA.
.positive_finite <- function(x) {
  x <- as.numeric(x)
  x[!is.finite(x) | x <= 0] <- NA_real_
  x
}

# Warn once if the output column is about to be overwritten.
.warn_overwrite <- function(df, cols) {
  hit <- intersect(cols, names(df))
  if (length(hit)) {
    srtr_warn(
      "Overwriting existing column{?s} {.field {hit}}.",
      class = "column_overwritten"
    )
  }
  invisible(NULL)
}

# Report rows whose score could not be computed because an input is missing
# or unusable.
.inform_missing_score <- function(value, score) {
  n <- sum(!is.finite(value))
  if (n > 0) {
    srtr_inform(
      "{score} is missing for {n} row{?s} with a missing or unusable input.",
      class = "score_missing_inputs"
    )
  }
  invisible(NULL)
}

# ---- OPTN mapping tables ----------------------------------------------------

# Labels of the stored tables for one score, oldest first.
.optn_labels <- function(score, kdri_formula = NULL) {
  tabs <- sRtr::optn_mapping_tables$tables
  tabs <- tabs[tabs$score == score, ]
  if (score == "kdpi") {
    # The 2010 and 2011 tables did not print their scaling factor.
    tabs <- tabs[!is.na(tabs$scaling_factor), ]
  }
  if (!is.null(kdri_formula)) {
    tabs <- tabs[tabs$kdri_formula %in% kdri_formula, ]
  }
  tabs$label[order(tabs$data_as_of)]
}

# Check a `table` argument and return it as a single string.
.check_table_arg <- function(table, score, kdri_formula = NULL, call = rlang::caller_env()) {
  labels <- .optn_labels(score, kdri_formula)
  ok <- is.character(table) && length(table) == 1 && !is.na(table) &&
    (table %in% c("latest", "in_force") || table %in% labels)
  if (!ok) {
    for_formula <- if (is.null(kdri_formula)) "" else paste0(" for ", kdri_formula)
    srtr_abort(
      c(
        "{.arg table} must be {.val latest}, {.val in_force} or one of the stored labels.",
        "i" = "Stored {score} tables{for_formula}: {.val {labels}}."
      ),
      class = "bad_table",
      call = call
    )
  }
  table
}

# Metadata row for one stored table.
.optn_table_meta <- function(score, label) {
  tabs <- sRtr::optn_mapping_tables$tables
  tabs[tabs$score == score & tabs$label == label, ]
}

# Percentile for each value from one stored table. OPTN intervals are open
# below and closed above: a value v maps to the row with lower < v <= upper.
.optn_percentile <- function(value, score, label) {
  rows <- sRtr::optn_mapping_tables$rows
  rows <- rows[rows$score == score & rows$label == label, ]
  rows <- rows[order(rows$row), ]
  i <- findInterval(value, rows$upper, left.open = TRUE) + 1L
  i[i > nrow(rows)] <- NA_integer_
  out <- rows$percentile[i]
  out[is.na(value)] <- NA_real_
  out
}

# Label of the table to use for each row.
#
# "latest": the newest stored table (for KDPI, the newest built with
# `kdri_formula`).
# "in_force": the table in effect in allocation on `date`, from the
# `effective` element of optn_mapping_tables. For KDPI, Rao 2009 tables end
# when the refit took effect. Rows before the first table, or whose table is
# not stored or not usable, get NA.
.optn_pick_labels <- function(table, score, n, date = NULL, kdri_formula = NULL) {
  if (!table %in% c("latest", "in_force")) {
    return(rep(table, n))
  }
  usable <- .optn_labels(score, kdri_formula)
  if (table == "latest") {
    return(rep(utils::tail(usable, 1), n))
  }
  eff <- sRtr::optn_mapping_tables$effective
  eff <- eff[eff$score == score, ]
  if (!is.null(kdri_formula)) {
    refit_start <- min(eff$effective_from[eff$kdri_formula == "refit2024"])
    eff <- eff[eff$kdri_formula %in% kdri_formula, ]
  }
  eff <- eff[order(eff$effective_from), ]
  i <- findInterval(as.numeric(date), as.numeric(eff$effective_from))
  out <- ifelse(is.na(i) | i == 0, NA_character_, eff$label[pmax(i, 1)])
  if (identical(kdri_formula, "rao2009")) {
    out[!is.na(date) & date >= refit_start] <- NA_character_
  }
  out[!out %in% usable] <- NA_character_
  out
}
