#' Apply SRTR factor labels to a data frame
#'
#' Converts coded variables in an SRTR dataset into human-readable factors
#' using the SRTR data dictionary and associated format tables.
#'
#' If `file_key` is not explicitly provided, the function will first check
#' for a `file_key` attribute on the data frame (e.g., from `load_srtr_file()`).
#' If not found, it will attempt to infer it from the object name.
#'
#' The key is matched in upper case. A key that is not a dataset in the
#' bundled [dictionary], or a key that cannot be worked out (no attribute and
#' no object name, as when `df` is an expression), gives a warning. A known key
#' whose columns are not in `df` is not a problem: nothing is changed.
#'
#' @param df A data frame loaded from an SRTR SAF file.
#' @param file_key Optional. The dataset name (e.g., "CAND_KIPA", "TX_KI").
#'   If not provided, the function will use a `file_key` attribute or object name.
#' @param verbose Logical. If TRUE, print each variable being labeled.
#'
#' @return A data frame with factor levels applied to coded variables, and a
#'   `file_key` attribute holding the dataset key in upper case, so the key
#'   carries through a chain of calls. If no usable key is found, `df` is
#'   returned unchanged with a warning.
#' @export
#'
#' @examples
#' \dontrun{
#' # Explicit file_key
#' df <- read_sas("TX_KI.sas7bdat")
#' df <- apply_srtr_factors(df, file_key = "TX_KI", verbose = TRUE)
#'
#' # Implicit file_key from attribute (if loaded via load_srtr_file)
#' df <- load_srtr_file("TX_KI")
#' df <- apply_srtr_factors(df)
#'
#' # Fallback to object name inference
#' TX_KI <- read_sas("TX_KI.sas7bdat")
#' TX_KI <- apply_srtr_factors(TX_KI)
#' }

apply_srtr_factors <- function(df, file_key = NULL, verbose = FALSE) {
  # ---- Work out the dataset ----
  file_key <- .srtr_resolve_file_key(df, file_key, substitute(df), verbose)
  if (is.null(file_key)) {
    return(df)
  }
  attr(df, "file_key") <- file_key

  # ---- Bundled dictionary and formats ----
  dictionary <- sRtr::dictionary
  formats <- sRtr::formats |>
    dplyr::rename_with(tolower) |>
    dplyr::rename(
      Format = "format",
      Value = "code",
      Label = "meaning"
    )

  # ---- Normalize variable names ----
  df_names_upper <- toupper(names(df))

  # ---- Lookup variables to convert ----
  vars_to_factor <- dictionary |>
    dplyr::filter(
      .data$Dataset == file_key,
      !is.na(.data$FormatID),
      .data$FormatID != ""
    ) |>
    dplyr::mutate(
      format_clean = stringr::str_remove(.data$FormatID, "^fmt_"),
      variable_upper = toupper(.data$Variable)
    ) |>
    dplyr::filter(.data$variable_upper %in% df_names_upper)

  if (nrow(vars_to_factor) == 0) {
    if (verbose) {
      srtr_inform(
        "No variables to convert to factors for {.val {file_key}}.",
        class = "nothing_to_label"
      )
    }
    return(df)
  }

  # ---- Apply factor conversion ----
  for (i in seq_len(nrow(vars_to_factor))) {
    var_upper <- vars_to_factor$variable_upper[i]
    fmt <- vars_to_factor$format_clean[i]
    var_match <- names(df)[toupper(names(df)) == var_upper][1]

    fmt_map <- formats |>
      dplyr::filter(.data$Format == fmt)

    if (nrow(fmt_map) == 0) {
      if (verbose) {
        srtr_inform(
          "No codes found for format {.val {fmt}}; {.var {var_match}} left as is.",
          class = "format_not_found"
        )
      }
      next
    }

    code_vec <- stats::setNames(fmt_map$Label, fmt_map$Value)

    df[[var_match]] <- factor(
      as.character(df[[var_match]]),
      levels = names(code_vec),
      labels = code_vec
    )

    if (verbose) {
      srtr_inform(
        c("v" = "Labeled variable: {.var {var_match}} (format {.val {fmt}})."),
        class = "variable_labeled"
      )
    }
  }

  return(df)
}
