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

# Report rows whose score could not be computed because an input is missing.
.inform_missing_score <- function(value, score) {
  n <- sum(is.na(value))
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
# "in_force": the table built from the year before `date`. OPTN states that
# KDPI is scaled to donors recovered in the previous calendar year, and that
# each EPTS table is built from the waiting list on December 31 of the year
# before it is used. Rows whose table is not stored get NA.
.optn_pick_labels <- function(table, score, n, date = NULL, kdri_formula = NULL) {
  if (!table %in% c("latest", "in_force")) {
    return(rep(table, n))
  }
  labels <- .optn_labels(score, kdri_formula)
  if (table == "latest") {
    return(rep(utils::tail(labels, 1), n))
  }
  tabs <- sRtr::optn_mapping_tables$tables
  tabs <- tabs[tabs$score == score & tabs$label %in% labels, ]
  ref_year <- as.integer(substr(tabs$reference, 1, 4))
  want <- as.integer(format(date, "%Y")) - 1L
  tabs$label[match(want, ref_year)]
}
