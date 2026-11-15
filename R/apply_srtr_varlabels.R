#' Apply SRTR variable labels to a data frame
#'
#' Adds human-readable variable labels to an SRTR dataset using the SRTR data
#' dictionary.
#'
#' If `file_key` is not explicitly provided, the function will first check
#' for a `file_key` attribute on the data frame. If not found, it will attempt
#' to infer it from the object name.
#'
#' The key is matched in upper case. A key that is not a dataset in the
#' bundled [dictionary], or a key that cannot be worked out (no attribute and
#' no object name, as when `df` is an expression), gives a warning. A known key
#' whose columns are not in `df` is not a problem: nothing is changed.
#'
#' @param df A data frame loaded from an SRTR SAF file.
#' @param file_key Optional. The dataset name (e.g., "CAND_KIPA", "TX_KI").
#' If the file was loaded via the `load_srtr_file` function, this argument
#' should be unnecessary.
#' @param verbose Logical. If TRUE, print each variable being labeled.
#'
#' @return A data frame with variable labels applied, and a `file_key`
#'   attribute holding the dataset key in upper case, so the key carries
#'   through a chain of calls. If no usable key is found, `df` is returned
#'   unchanged with a warning.
#' @export
#'
#' @examples
#' \dontrun{
#' # Explicit file_key
#' df <- read_sas("TX_KI.sas7bdat")
#' df <- apply_srtr_varlabels(df, file_key = "TX_KI", verbose = TRUE)
#'
#' # Implicit file_key from attribute (if loaded via load_srtr_file)
#' df <- load_srtr_file("TX_KI")
#' df <- apply_srtr_varlabels(df)
#'
#' # Fallback to object name inference
#' TX_KI <- read_sas("TX_KI.sas7bdat")
#' TX_KI <- apply_srtr_varlabels(TX_KI)
#' }

apply_srtr_varlabels <- function(df, file_key = NULL, verbose = FALSE) {
  # ---- Work out the dataset ----
  file_key <- .srtr_resolve_file_key(df, file_key, substitute(df), verbose)
  if (is.null(file_key)) {
    return(df)
  }
  attr(df, "file_key") <- file_key

  # ---- Bundled dictionary ----
  dict <- sRtr::dictionary

  # ---- Check if already labeled ----
  already_labelled <- any(
    !vapply(df, function(x) is.null(labelled::var_label(x)), logical(1))
  )
  if (already_labelled) {
    srtr_warn(
      "Some variables already have labels, so none were relabeled.",
      class = "already_labelled"
    )
    return(df)
  }

  # ---- Uppercase names and match to dictionary ----
  df_names_upper <- toupper(names(df))

  vars_to_label <- dict |>
    dplyr::filter(.data$Dataset == file_key) |>
    dplyr::mutate(variable_upper = toupper(.data$Variable)) |>
    dplyr::filter(.data$variable_upper %in% df_names_upper)

  if (nrow(vars_to_label) == 0) {
    if (verbose) {
      srtr_inform(
        "No variable labels applied for {.val {file_key}}.",
        class = "nothing_to_label"
      )
    }
    return(df)
  }

  for (i in seq_len(nrow(vars_to_label))) {
    var_upper <- vars_to_label$variable_upper[i]
    label_text <- vars_to_label$Label[i]
    var_match <- names(df)[toupper(names(df)) == var_upper][1]

    labelled::var_label(df[[var_match]]) <- label_text

    if (verbose) {
      srtr_inform(
        c("v" = "Labeled variable: {.var {var_match}} ({label_text})."),
        class = "variable_labeled"
      )
    }
  }

  return(df)
}
