#' Normalize Missing Value Representations in SRTR Data
#'
#' Replaces common non-standard representations of missing values (e.g., -1, 999, "Unknown")
#' with either `NA` or a user-specified string (e.g., `"Missing"`). This includes both
#' explicit missing codes (provided via `missing_vals`) and, if `replacement` is not `NA`,
#' any existing `NA` values in the specified columns.
#'
#' This function is helpful for harmonizing SRTR datasets, which may use multiple codes
#' to represent missingness (e.g., -1 for numeric fields, "U" or "Unknown" for character or factor fields).
#'
#' @param df A data frame from an SRTR SAF file.
#' @param missing_vals An optional named list. The `srtr_normalize_missing()` function defaults to an internal list of
#'   variables to normalize and values to convert to the specified replacement value.
#'   Each name corresponds to a column in `df`, and each element is a vector of values to treat as missing in that column.
#'   Any values matched will be replaced by `replacement`. Columns not present in `df` are silently skipped.
#' @param replacement The value to use in place of the missing representations. Defaults to `NA`.
#'   If a string is provided (e.g., `"Missing"`), both missing codes and `NA` values will be replaced.
#'   If the column is a factor and `replacement` is not `NA`, the replacement will be added as a new factor level.
#' @param verbose Logical. If `TRUE`, the function prints a message for each column it modifies,
#'   including skipped columns that are not found in `df`.
#'
#' @return A modified version of `df`, with all specified missing values (and possibly `NA`s) replaced by `replacement`.
#' @export
#'
#' @examples
#' \dontrun{
#' df <- load_srtr_file("TX_LI")
#'
#' # Use default SRTR-wide missing definitions
#' srtr_normalize_missing(df)
#'
#' # Explicitly define missing values and convert all missing to "Missing"
#' missing_vals <- list(
#'   REC_HIV_STAT = c("U", ""),
#'   REC_HCV_STAT = c("U", ""),
#' )
#' srtr_normalize_missing(df, missing_vals, replacement = "Missing")
#' }
srtr_normalize_missing <- function(df,
                                   missing_vals = NULL,
                                   replacement = NA,
                                   verbose = FALSE) {

  if (is.null(missing_vals)) {
    # Internal default — deferred until runtime
    missing_vals <- default_missing_vars
  }

  for (col in names(missing_vals)) {
    if (!col %in% names(df)) {
      if (verbose) message("Skipping column not found: ", col)
      next
    }

    values_to_replace <- missing_vals[[col]]
    vec <- df[[col]]

    if (verbose) message("Processing column: ", col)

    # Factor support: add replacement level if needed
    if (is.factor(vec) && !is.na(replacement)) {
      if (!replacement %in% levels(vec)) {
        levels(vec) <- c(levels(vec), replacement)
      }
    }

    # Replace matching values
    vec[vec %in% values_to_replace] <- replacement

    # Optional: Replace existing NA values
    if (!is.na(replacement)) {
      vec[is.na(vec)] <- replacement
    }

    # Assign back
    df[[col]] <- if (is.factor(df[[col]])) factor(vec, levels = unique(vec)) else vec
  }

  df
}
