#' Apply SRTR factor labels to a data frame
#'
#' Converts coded variables in an SRTR dataset into human-readable factors
#' using the SRTR data dictionary and associated format tables.
#'
#' If `file_key` is not explicitly provided, the function will first check
#' for a `file_key` attribute on the data frame (e.g., from `load_srtr_file()`).
#' If not found, it will attempt to infer it from the object name.
#'
#' @param df A data frame loaded from an SRTR SAF file.
#' @param file_key Optional. The dataset name (e.g., "CAND_KIPA", "TX_KI").
#'   If not provided, the function will use a `file_key` attribute or object name.
#' @param verbose Logical. If TRUE, print each variable being labeled.
#'
#' @return A data frame with factor levels applied to coded variables.
#' @export
#'
#' @importFrom stats setNames
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
  # ---- Infer file_key if not provided ----
  if (is.null(file_key)) {
    attr_key <- attr(df, "file_key")
    if (!is.null(attr_key)) {
      file_key <- toupper(attr_key)
      if (verbose) message("Inferred file_key = '", file_key, "' from data frame attribute.")
    } else {
      file_key <- toupper(deparse(substitute(df)))
      if (verbose) message("Inferred file_key = '", file_key, "' from object name.")
    }
  }

  # ---- Check dictionary and formats availability ----
  if (!exists("dictionary", envir = asNamespace("sRtr")) ||
      !exists("formats", envir = asNamespace("sRtr"))) {
    stop("Both `dictionary` and `formats` datasets must be available in the sRtr package.")
  }

  dictionary <- get("dictionary", envir = asNamespace("sRtr"))
  formats <- get("formats", envir = asNamespace("sRtr")) |>
    dplyr::rename_with(tolower) |>
    dplyr::rename(
      Format = format,
      Value  = code,
      Label  = meaning
    )

  # ---- Normalize variable names ----
  df_names_upper <- toupper(names(df))

  # ---- Lookup variables to convert ----
  vars_to_factor <- dictionary |>
    dplyr::filter(Dataset == file_key, !is.na(FormatID), FormatID != "") |>
    dplyr::mutate(
      format_clean = stringr::str_remove(FormatID, "^fmt_"),
      variable_upper = toupper(Variable)
    ) |>
    dplyr::filter(variable_upper %in% df_names_upper)

  if (nrow(vars_to_factor) == 0) {
    if (verbose) message("No variables to convert to factor for ", file_key)
    return(df)
  }

  # ---- Apply factor conversion ----
  for (i in seq_len(nrow(vars_to_factor))) {
    var_upper <- vars_to_factor$variable_upper[i]
    fmt <- vars_to_factor$format_clean[i]
    var_match <- names(df)[toupper(names(df)) == var_upper][1]

    fmt_map <- formats |>
      dplyr::filter(Format == fmt)

    if (nrow(fmt_map) == 0) {
      if (verbose) message("No mapping found for format: ", fmt, " (variable: ", var_match, ")")
      next
    }

    code_vec <- stats::setNames(fmt_map$Label, fmt_map$Value)

    df[[var_match]] <- factor(as.character(df[[var_match]]),
                              levels = names(code_vec),
                              labels = code_vec)

    if (verbose) {
      message("Labeled variable: ", var_match, " using format: ", fmt)
    }
  }

  return(df)
}
