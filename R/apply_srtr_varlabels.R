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
#' @param overwrite `FALSE` (the default) keeps a label a column already has,
#'   such as the variable labels stored in a SAS file, and labels only the
#'   columns without one. `TRUE` replaces every label with the dictionary's.
#' @param release Optional. The SAF release `df` comes from, as year and month
#'   (`"2609"`), to label it with that release's dictionary (see
#'   [srtr_dictionary()]). If `NULL` (the default), the release recorded by
#'   [load_srtr_file()] is used, or the bundled [dictionary] if there is none.
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

apply_srtr_varlabels <- function(df, file_key = NULL, verbose = FALSE,
                                 release = NULL, overwrite = FALSE) {
  if (!rlang::is_bool(overwrite)) {
    srtr_abort(
      "{.arg overwrite} must be {.code TRUE} or {.code FALSE}.",
      class = "bad_overwrite"
    )
  }

  # ---- Work out the dataset ----
  file_key <- .srtr_resolve_file_key(df, file_key, substitute(df), verbose)
  if (is.null(file_key)) {
    return(df)
  }
  attr(df, "file_key") <- file_key

  # ---- Dictionary for the release ----
  dict <- .srtr_tables_for(df, release, file_key)$dictionary

  # ---- Columns that keep their own label ----
  # SAF files carry SAS variable labels, so labelled columns are normal.
  has_label <- !vapply(
    df,
    function(x) is.null(labelled::var_label(x)),
    logical(1)
  )
  kept <- if (overwrite) character() else names(df)[has_label]
  if (verbose && length(kept) > 0) {
    srtr_inform(
      c(
        "i" = "Kept the existing label on {length(kept)} variable{?s}.",
        " " = "Use {.code overwrite = TRUE} to replace {cli::qty(length(kept))}{?it/them} with dictionary labels."
      ),
      class = "labels_kept"
    )
  }

  # ---- Match each eligible column to the dictionary ----
  # By column position, so two names differing only in case are handled
  # separately and a kept label is never overwritten through the other one.
  entries <- dict[dict$Dataset == file_key, c("Variable", "Label")]
  eligible <- if (overwrite) seq_along(df) else which(!has_label)
  at <- match(toupper(names(df)[eligible]), toupper(entries$Variable))
  to_label <- eligible[!is.na(at)]
  label_texts <- entries$Label[at[!is.na(at)]]

  if (length(to_label) == 0) {
    if (verbose) {
      srtr_inform(
        "No variable labels applied for {.val {file_key}}.",
        class = "nothing_to_label"
      )
    }
    return(df)
  }

  for (i in seq_along(to_label)) {
    var_match <- names(df)[to_label[i]]
    label_text <- label_texts[i]

    labelled::var_label(df[[to_label[i]]]) <- label_text

    if (verbose) {
      srtr_inform(
        c("v" = "Labeled variable: {.var {var_match}} ({label_text})."),
        class = "variable_labeled"
      )
    }
  }

  return(df)
}
