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
#' @param trr_id_filter Optional vector of `TRR_ID` values. If not `NULL`, only
#'   rows whose `TRR_ID` is in this vector are kept.
#' @param factor_labels Logical. Whether to apply factor labels. Default = TRUE.
#' @param var_labels Logical. Whether to apply variable labels. Default = TRUE.
#' @param col_select Optional. Columns to keep, as a character vector or a
#'   tidyselect expression such as `starts_with("REC_")`. Names are matched in
#'   upper case, as in the result, whatever their case in the file. Columns
#'   come back in the order selected. Columns needed only for `trr_id_filter`
#'   are read and then dropped. For `"TX_KP"`, `TFL_LAFUDATE` (derived on
#'   loading) can be selected like any other column; it is derived when
#'   `col_select` is `NULL`, includes it, or includes both `TFL_LAFUDATEKI` and
#'   `TFL_LAFUDATEPA`. Renaming (`c(new = OLD)`) is not
#'   supported; rename after loading.
#' @param column_check What to do when the file's columns differ from the
#'   columns the bundled data dictionary ([dictionary]) lists for `file_key`.
#'   `"warn"` (the default) warns about columns the file is missing; `"error"`
#'   makes that an error; `"none"` skips the comparison. Either way, columns
#'   the dictionary does not list are named in a message, once per file key
#'   per session, and loaded as they are. The comparison runs only when every
#'   column is read (`col_select = NULL`) and only for file keys the dictionary
#'   lists. A file from a different SAF release than the dictionary can differ
#'   in its columns.
#' @param ... Additional arguments passed to the file reader
#'   ([haven::read_sas()] or [arrow::read_parquet()]), e.g. `encoding` for
#'   `read_sas()`.
#'
#' @return A tibble with the loaded file contents, optionally labeled.
#'   The tibble includes attributes `source_path` and `file_key`.
#' @export
#'
#' @examples
#' \dontrun{
#' df <- load_srtr_file("TX_LI", factor_labels = TRUE, var_labels = TRUE)
#' }

load_srtr_file <- function(
  file_key,
  trr_id_filter = NULL,
  factor_labels = TRUE,
  var_labels = TRUE,
  col_select = NULL,
  column_check = c("warn", "error", "none"),
  ...
) {
  column_check <- match.arg(column_check)

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
    srtr_wd <- Sys.getenv("SRTR_WD")
    srtr_abort(
      c(
        "No file for {.arg file_key} {.val {file_key}}.",
        "i" = "Looked for a {.file .sas7bdat} or {.file .parquet} file in {.envvar SRTR_WD}:",
        " " = "{.path {srtr_wd}}"
      ),
      class = "file_not_found"
    )
  }

  full_path <- match$file_path
  suffix <- tolower(match$file_suffix)
  if (!suffix %in% c("sas7bdat", "parquet")) {
    srtr_abort(
      "Can't read {.file .{suffix}} files; only {.file .sas7bdat} and {.file .parquet}.",
      class = "unsupported_file_type"
    )
  }

  is_kp <- file_key_input == "TX_KP"
  kp_dates <- c("TFL_LAFUDATEKI", "TFL_LAFUDATEPA")
  col_select <- rlang::enquo(col_select)

  # ---- Choose columns ----
  # NULL reads every column. Otherwise the selection is evaluated against the
  # file's column names in upper case (the names the result has), and columns
  # needed only to filter rows or derive TFL_LAFUDATE are read as well, then
  # dropped unless they were selected.
  read_cols <- NULL
  derive_kp <- is_kp
  if (!rlang::quo_is_null(col_select)) {
    template <- .srtr_file_template(full_path, suffix)
    file_names <- names(template)
    upper_names <- toupper(file_names)
    names(template) <- upper_names
    if (is_kp && !"TFL_LAFUDATE" %in% names(template)) {
      # TX_KP has no TFL_LAFUDATE of its own; it can still be asked for.
      template$TFL_LAFUDATE <- as.Date(character())
    }
    keep <- names(
      tidyselect::eval_select(col_select, template, allow_rename = FALSE)
    )
    # Derived when asked for by name, or when both dates it comes from are
    # selected (then added at the end, as when every column is read).
    derive_kp <- is_kp &&
      ("TFL_LAFUDATE" %in% keep || all(kp_dates %in% keep))
    if (derive_kp && !"TFL_LAFUDATE" %in% keep) {
      keep <- c(keep, "TFL_LAFUDATE")
    }

    needed <- keep
    if (!is.null(trr_id_filter)) {
      needed <- c(needed, "TRR_ID")
    }
    if (derive_kp) {
      needed <- c(needed, kp_dates)
    }
    needed <- unique(needed)
    if (!is.null(trr_id_filter) && !"TRR_ID" %in% upper_names) {
      .srtr_abort_no_trr_id(file_key_input)
    }
    if (derive_kp) {
      .srtr_check_kp_dates(upper_names, kp_dates)
    }
    read_cols <- file_names[match(intersect(needed, upper_names), upper_names)]
  }

  # ---- Read file ----
  df <- switch(
    suffix,
    "sas7bdat" = {
      if (is.null(read_cols)) {
        haven::read_sas(full_path, ...)
      } else {
        haven::read_sas(full_path, col_select = tidyselect::all_of(read_cols), ...)
      }
    },
    "parquet" = {
      # Drop embedded NUL characters in text instead of failing. Set only for
      # this read; the caller's option is restored on exit.
      old_options <- options(arrow.skip_nul = TRUE)
      on.exit(options(old_options), add = TRUE)
      if (is.null(read_cols)) {
        arrow::read_parquet(full_path, ...)
      } else {
        arrow::read_parquet(full_path, col_select = tidyselect::all_of(read_cols), ...)
      }
    }
  )

  # ---- Standardize column names ----
  names(df) <- toupper(names(df))

  # ---- Compare columns with the data dictionary ----
  # Only when every column is read: with col_select, a selected column the
  # file lacks is already an error from tidyselect.
  if (rlang::quo_is_null(col_select)) {
    .srtr_check_dictionary_columns(names(df), file_key_input, column_check)
  }

  # ---- Apply TRR_ID filter -----
  if (!is.null(trr_id_filter)) {
    if (!"TRR_ID" %in% names(df)) {
      .srtr_abort_no_trr_id(file_key_input)
    }
    df <- dplyr::filter(df, .data$TRR_ID %in% trr_id_filter)
  }

  # ---- Add TFL_LAFUDATE to KP (which has separate TFL_LAFUDATEKI and TFL_LAFUDATEPA variables) -----
  if (derive_kp) {
    .srtr_check_kp_dates(names(df), kp_dates)
    df <- df |>
      dplyr::mutate(
        TFL_LAFUDATE = dplyr::if_else(
          is.na(.data$TFL_LAFUDATEPA) |
            (!is.na(.data$TFL_LAFUDATEKI) &
              .data$TFL_LAFUDATEKI >= .data$TFL_LAFUDATEPA),
          .data$TFL_LAFUDATEKI, # pick date1 when it's >= date2 (or date2 is NA)
          .data$TFL_LAFUDATEPA # otherwise pick date2
        )
      )
  }

  # ---- Keep the selected columns, in the order selected ----
  if (!rlang::quo_is_null(col_select)) {
    df <- df[keep]
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

# A zero-row data frame with the file's columns and types, read without
# loading any rows. Used to evaluate `col_select` before the real read.
.srtr_file_template <- function(path, suffix) {
  if (suffix == "sas7bdat") {
    haven::read_sas(path, n_max = 0)
  } else {
    arrow::open_dataset(path) |>
      utils::head(0) |>
      dplyr::collect()
  }
}

# Compares a file's columns with those the bundled data dictionary lists for
# its file key. Missing columns warn or error (`column_check`); columns the
# dictionary does not list get a message once per file key per session. File
# keys the dictionary does not list are not compared.
.srtr_check_dictionary_columns <- function(
  file_names,
  file_key,
  column_check,
  call = rlang::caller_env()
) {
  if (column_check == "none") {
    return(invisible())
  }
  dictionary <- sRtr::dictionary
  expected <- dictionary$Variable[dictionary$Dataset == file_key]
  if (length(expected) == 0) {
    return(invisible())
  }

  missing <- setdiff(expected, file_names)
  if (length(missing) > 0) {
    text <- c(
      "The {.val {file_key}} file is missing {length(missing)} column{?s} that the bundled SRTR data dictionary lists: {.field {missing}}.",
      "i" = "The file may come from a different SAF release than the dictionary. Code that needs these columns will not work with this file.",
      "i" = "Set {.code column_check = \"none\"} to skip this check."
    )
    if (column_check == "error") {
      srtr_abort(text, class = "missing_columns", missing = missing, call = call)
    }
    srtr_warn(text, class = "missing_columns", missing = missing)
  }

  extra <- setdiff(file_names, expected)
  if (length(extra) > 0) {
    srtr_inform(
      c(
        "The {.val {file_key}} file has {length(extra)} column{?s} that the bundled SRTR data dictionary does not list: {.field {extra}}.",
        "i" = "They are loaded as they are, without variable labels or factor levels."
      ),
      class = "extra_columns",
      extra = extra,
      .frequency = "once",
      .frequency_id = paste0("sRtr_extra_columns_", file_key)
    )
  }
  invisible()
}

# TX_KP's TFL_LAFUDATE is derived from the kidney and pancreas follow-up dates;
# both must be in the file.
.srtr_check_kp_dates <- function(file_names, kp_dates, call = rlang::caller_env()) {
  missing <- setdiff(kp_dates, file_names)
  if (length(missing) == 0) {
    return(invisible())
  }
  srtr_abort(
    c(
      "Can't derive {.field TFL_LAFUDATE}: the {.val TX_KP} file has no {.field {missing}} column{?s}.",
      "i" = "{.field TFL_LAFUDATE} is the later of {.field {kp_dates}}."
    ),
    class = "missing_columns",
    missing = missing,
    call = call
  )
}

.srtr_abort_no_trr_id <- function(file_key, call = rlang::caller_env()) {
  srtr_abort(
    c(
      "{.arg trr_id_filter} needs a {.field TRR_ID} column, and the {.val {file_key}} file has none.",
      "i" = "Leave {.arg trr_id_filter} as {.code NULL} for this file."
    ),
    class = "missing_columns",
    missing = "TRR_ID",
    call = call
  )
}
