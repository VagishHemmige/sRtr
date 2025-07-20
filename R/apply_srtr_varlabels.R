#' Apply SRTR variable labels to a data frame
#'
#' Adds human-readable variable labels to an SRTR dataset using the SRTR data
#' dictionary.
#'
#' If `file_key` is not explicitly provided, the function will first check
#' for a `file_key` attribute on the data frame. If not found, it will attempt
#' to infer it from the object name.
#'
#' @param df A data frame loaded from an SRTR SAF file.
#' @param file_key Optional. The dataset name (e.g., "CAND_KIPA", "TX_KI").
#' If the file was loaded via the `load_srtr_file` function, this argument
#' should be unnecessary.
#' @param verbose Logical. If TRUE, print each variable being labeled.
#'
#' @return A data frame with variable labels applied.
#' @export
#'
#' @importFrom stats setNames
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
  # ---- Use attribute if file_key not provided ----
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

  # ---- Ensure dictionary exists ----
  if (!exists("dictionary", envir = asNamespace("sRtr"))) {
    stop("The `dictionary` dataset must be available in the sRtr package.")
  }
  dict <- get("dictionary", envir = asNamespace("sRtr"))

  # ---- Check if already labeled ----
  already_labelled <- any(!vapply(df, function(x) is.null(labelled::var_label(x)), logical(1)))
  if (already_labelled) {
    warning("Some variables already have labels. Skipping re-labeling.")
    return(df)
  }

  # ---- Uppercase names and match to dictionary ----
  df_names_upper <- toupper(names(df))

  vars_to_label <- dict |>
    dplyr::filter(Dataset == file_key) |>
    dplyr::mutate(variable_upper = toupper(Variable)) |>
    dplyr::filter(variable_upper %in% df_names_upper)

  if (nrow(vars_to_label) == 0) {
    if (verbose) message("No variable labels applied for ", file_key)
    return(df)
  }

  for (i in seq_len(nrow(vars_to_label))) {
    var_upper <- vars_to_label$variable_upper[i]
    label_text <- vars_to_label$Label[i]
    var_match <- names(df)[toupper(names(df)) == var_upper][1]

    labelled::var_label(df[[var_match]]) <- label_text

    if (verbose) {
      message("Labeled variable: ", var_match, " - ", label_text)
    }
  }

  return(df)
}
