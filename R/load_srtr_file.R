#' Load an SRTR file and optionally apply labels
#'
#' Loads a file from the SRTR dataset registry and optionally applies:
#' - Factor labels using the `formats` dataset
#' - Variable labels using the `dictionary` dataset
#'
#' Files are looked up in the folder set with [set_srtr_wd()] (the `SRTR_WD`
#' environment variable). The folder is scanned the first time a file is
#' loaded, and again if a file is not found, so files added during the session
#' are picked up.
#'
#' All variable names are standardized to uppercase after loading.
#' The returned tibble includes two attributes:
#' - `source_path`: the full path to the file on disk
#' - `file_key`: the canonical dataset key used to load it
#'
#' @param file_key Character. Canonical dataset key (e.g., "TX_LI", "CAND_KIPA").
#' @param trr_id_filter Optional vector of TRR_IDs to keep..
#' If not NULL, will filter by `TRR_ID' vector passed to this option.
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
                           trr_id_filter=NULL,
                           factor_labels = TRUE,
                           var_labels = TRUE,
                           col_select = NULL,
                           ...) {
  # ---- Lookup metadata ----
  # Scans SRTR_WD on first use; rescans once if the file is not in the list
  # or has gone, so files added or moved during the session are found.
  file_key_input <- toupper(file_key)
  find_file <- function(file_list) {
    file_list |>
      dplyr::filter(toupper(.data$file_root) == file_key_input) |>
      dplyr::slice(1)
  }

  match <- find_file(.srtr_file_list())
  if (nrow(match) == 0 || !file.exists(match$file_path)) {
    match <- find_file(.srtr_file_list(refresh = TRUE))
  }
  if (nrow(match) == 0) {
    stop(
      "File key '", file_key, "' not found in SRTR_WD (",
      Sys.getenv("SRTR_WD"), ").",
      call. = FALSE
    )
  }

  full_path <- match$file_path
  suffix <- tolower(match$file_suffix)

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
      # Drop embedded NUL characters in text instead of failing. Set only for
      # this read; the caller's option is restored on exit.
      old_options <- options(arrow.skip_nul = TRUE)
      on.exit(options(old_options), add = TRUE)
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

  # ---- Apply TRR_ID filter -----
  if (!is.null(trr_id_filter)) {
    df <- dplyr::filter(df, .data$TRR_ID %in% trr_id_filter)
  }

  # ---- Add TFL_LAFUDATE to KP (which has separate TFL_LAFUDATEKI and TFL_LAFUDATEPA variables) -----
if (file_key_input=="TX_KP") {
    df <- df |>
    dplyr::mutate(TFL_LAFUDATE = dplyr::if_else(
      is.na(.data$TFL_LAFUDATEPA) | (!is.na(.data$TFL_LAFUDATEKI) & .data$TFL_LAFUDATEKI >= .data$TFL_LAFUDATEPA),
      .data$TFL_LAFUDATEKI,        # pick date1 when it's >= date2 (or date2 is NA)
      .data$TFL_LAFUDATEPA         # otherwise pick date2
    ))
}

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
