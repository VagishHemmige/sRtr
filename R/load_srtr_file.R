#' Load an SRTR file and optionally apply labels
#'
#' Loads a file from the SRTR dataset registry and optionally applies:
#' - Factor labels using the `formats` dataset
#' - Variable labels using the `dictionary` dataset
#'
#' All variable names are standardized to uppercase after loading.
#' The returned tibble includes two attributes:
#' - `source_path`: the full path to the file on disk
#' - `file_key`: the canonical dataset key used to load it
#'
#' @param file_key Character. Canonical dataset key (e.g., "TX_LI", "CAND_KIPA").
#' @param factor_labels Logical. Whether to apply factor labels. Default = TRUE.
#' @param var_labels Logical. Whether to apply variable labels. Default = FALSE.
#' @param col_select Optional. Tidyselect expression or character vector for selecting columns.
#' @param ... Additional arguments passed to the file reader (e.g., `as_factor` for `read_sas()`).
#'
#' @return A tibble with the loaded file contents, optionally labeled.
#'   The tibble includes attributes `source_path` and `file_key`.
#' @export
#'
#' @examples
#' \dontrun{
#' df <- load_srtr_file("TX_LI", factor_labels = TRUE, var_labels = TRUE)
#' }

load_srtr_file <- function(file_key,
                           factor_labels = TRUE,
                           var_labels = TRUE,
                           col_select = NULL,
                           ...) {
  # ---- Check registry ----
  if (is.null(.srtr_env$file_list)) {
    stop("SRTR file list not initialized. Please set up the file registry.")
  }

  # ---- Lookup metadata ----
  file_key_input <- toupper(file_key)

  match <- .srtr_env$file_list |>
    dplyr::filter(toupper(.data$file_root) == file_key_input) |>
    dplyr::slice(1)

  if (nrow(match) == 0) {
    stop("File key '", file_key, "' not found.")
  }

  full_path <- match$file_path
  suffix <- tolower(match$file_suffix)

  if (!file.exists(full_path)) {
    stop("File not found: ", full_path)
  }

  # ---- Read file ----
  df <- switch(
    suffix,
    "sas7bdat" = {
      if (is.null(col_select)) {
        haven::read_sas(full_path, ...)
      } else {
        haven::read_sas(full_path, col_select = col_select, ...)
      }
    },
    "parquet" = {
      if (is.null(col_select)) {
        arrow::read_parquet(full_path, ...)
      } else {
        dummy <- arrow::open_dataset(full_path)$head(1) |> as.data.frame()
        selected_names <- tidyselect::eval_select(rlang::enquo(col_select), dummy) |> names()
        arrow::read_parquet(full_path, columns = selected_names, ...)
      }
    },
    stop("Unsupported file type: ", suffix)
  )

  # ---- Standardize column names ----
  names(df) <- toupper(names(df))

  # ---- Apply factor labels ----
  if (factor_labels) {
    df <- apply_srtr_factors(df, file_key = file_key_input)
  }

  # ---- Apply variable labels ----
  if (var_labels) {
    df <- apply_srtr_varlabels(df, file_key = file_key_input)
  }

  # ---- Attach metadata ----
  attr(df, "source_path") <- full_path
  attr(df, "file_key") <- file_key_input

  return(df)
}
