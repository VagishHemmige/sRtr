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
#' @param range_formats What to do with numeric variables whose format is a
#'   set of bands rather than a code list: the age formats `AGE8A`, `AGE8C`
#'   and `AGE9A`, used by `REC_AGE_AT_TX` and `CAN_AGE_AT_LISTING`.
#'   `"keep"` (the default) leaves the numbers as they are. `"bin"` turns them
#'   into a factor of bands. The page lists only each band's lower bound, so
#'   `"bin"` treats each listed code as the start of a band that runs to the
#'   next one; this reading is a convention, not stated by SRTR.
#' @param unknown_codes What to do with a value that is not a code in the
#'   variable's format (and is not covered by a catch-all entry, see `other`).
#'   `"keep"` (the default) keeps it as an extra level named by the raw code
#'   followed by `": not in format"`, so it cannot be mistaken for a label;
#'   `"na"` turns it into `NA`. Both warn
#'   (class `sRtr_warning_unknown_codes`). `"error"` stops
#'   (class `sRtr_error_unknown_codes`).
#' @param other What to do with a format's catch-all entry (`**OTHER**`, as in
#'   `RACE`, where it means "Multi-Racial"). `"sas"` (the default) gives every
#'   value not otherwise listed the catch-all label, as a SAS format does.
#'   `"keep"` ignores the catch-all, so those values are handled by
#'   `unknown_codes`.
#' @param release Optional. The SAF release `df` comes from, as year and month
#'   (`"2609"`), to use that release's dictionary and formats (see
#'   [srtr_dictionary()]). If `NULL` (the default), the release recorded by
#'   [load_srtr_file()] is used, or the bundled [dictionary] and [formats] if
#'   there is none.
#'
#' @details
#' Values are read as codes. A value that is not a code in the format is
#' outside it, even if it reads like one of the format's labels.
#'
#' A column converted by an earlier call carries an `srtr_format` attribute
#' and is left as it is, so calling the function twice changes nothing. dplyr
#' and tibble operations keep the attribute; base R subsetting such as
#' `df[rows, ]` on a data frame drops it, and the column is then read as codes
#' again, with every value reported as outside the format (also when the
#' format has a catch-all: for a factor input, values given the catch-all label
#' are reported too; raw codes get it silently, as in SAS). Convert again from
#' the raw codes, or keep working with dplyr. Attributes on each column, such
#' as a variable label, are kept.
#'
#' When codes that are not in the format are kept, the column also carries
#' an `srtr_kept_codes` attribute: a named vector giving, for each such
#' level, the original code. [srtr_missing_report()] uses it to recognise
#' those codes after labelling.
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

apply_srtr_factors <- function(
  df,
  file_key = NULL,
  verbose = FALSE,
  range_formats = c("keep", "bin"),
  unknown_codes = c("keep", "na", "error"),
  other = c("sas", "keep"),
  release = NULL
) {
  range_formats <- rlang::arg_match(range_formats)
  unknown_codes <- rlang::arg_match(unknown_codes)
  other <- rlang::arg_match(other)

  # ---- Work out the dataset ----
  file_key <- .srtr_resolve_file_key(df, file_key, substitute(df), verbose)
  if (is.null(file_key)) {
    return(df)
  }
  attr(df, "file_key") <- file_key

  # ---- Dictionary and formats for the release ----
  tables <- .srtr_tables_for(df, release, file_key)
  dictionary <- tables$dictionary
  formats <- tables$formats |>
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

    df[[var_match]] <- .srtr_factor_column(
      df[[var_match]],
      fmt_map,
      fmt = fmt,
      var = var_match,
      range_formats = range_formats,
      unknown_codes = unknown_codes,
      other = other
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

# Formats that band a numeric value (age) instead of listing codes. Their
# tables list each band's lower bound as its code, plus a catch-all, plus
# rows mapping each band label to itself.
.srtr_range_formats <- c("AGE8A", "AGE8C", "AGE9A")

.srtr_other_code <- "**OTHER**"

# Added to a code that is not in its format when it is kept as a level, so
# it cannot equal one of the format's labels. It is a name only: text ending
# in it is never taken as a sign of an earlier conversion.
.srtr_unknown_suffix <- ": not in format"

# Convert one column with its format's codes. `fmt_map` has columns Value
# (code) and Label, in the format's order.
#
# A column that was not converted already is read as codes, since SAF columns
# hold codes: a value that is not a code is outside the format, even when it
# reads like one of the format's labels. It gets the catch-all label when
# `other = "sas"` and the format has one, and otherwise follows
# `unknown_codes`.
.srtr_factor_column <- function(
  x,
  fmt_map,
  fmt,
  var,
  range_formats = "keep",
  unknown_codes = "keep",
  other = "sas",
  call = rlang::caller_env()
) {
  if (fmt %in% .srtr_range_formats) {
    if (range_formats == "keep" || !is.numeric(x)) {
      return(x)
    }
    return(.srtr_keep_attributes(.srtr_bin_range(x, fmt_map), x, fmt))
  }

  has_other <- other == "sas" && .srtr_other_code %in% fmt_map$Value
  other_label <- fmt_map$Label[fmt_map$Value == .srtr_other_code][1]
  listed <- fmt_map[fmt_map$Value != .srtr_other_code | has_other, ]
  codes <- listed$Value[listed$Value != .srtr_other_code]
  labels <- listed$Label[listed$Value != .srtr_other_code]
  all_labels <- unique(listed$Label)

  if (.srtr_already_factored(x)) {
    return(x)
  }

  values <- as.character(x)
  mapped <- labels[match(values, codes)]
  outside <- !is.na(values) & is.na(mapped)
  kept_codes <- NULL

  if (has_other && !is.factor(x)) {
    # Raw codes: as a SAS format does, values not listed get the catch-all
    # label without comment.
    mapped[outside] <- other_label
  } else if (has_other) {
    # A factor without the marker may be an earlier result that lost it, so
    # its labels would land in the catch-all; report them.
    unknown <- sort(unique(values[outside]))
    if (length(unknown) > 0) {
      .srtr_report_unknown_codes(
        unknown, sum(outside), var, fmt, unknown_codes, call,
        kept_as = other_label
      )
    }
    if (unknown_codes == "keep") {
      mapped[outside] <- other_label
    }
  } else {
    unknown <- sort(unique(values[outside]))
    if (length(unknown) > 0) {
      .srtr_report_unknown_codes(unknown, sum(outside), var, fmt, unknown_codes, call)
    }
    if (unknown_codes == "keep") {
      mapped[outside] <- .srtr_unknown_name(values[outside], all_labels)
      kept <- !duplicated(values[outside])
      kept_codes <- stats::setNames(
        values[outside][kept],
        mapped[outside][kept]
      )
    }
  }
  extra <- sort(setdiff(unique(mapped[!is.na(mapped)]), all_labels))
  new <- .srtr_keep_attributes(
    factor(mapped, levels = c(all_labels, extra)),
    x,
    fmt
  )
  # Which level stands for which kept code: the name alone cannot say,
  # since a raw value may itself end in the suffix.
  if (length(kept_codes) > 0) {
    attr(new, "srtr_kept_codes") <- kept_codes
  }
  new
}

# Level names for kept codes: each distinct code gets the code plus the
# suffix, with the suffix added again until the name is neither a format
# label nor a name already given to another code. Repeats of a code get the
# same name.
.srtr_unknown_name <- function(codes, labels) {
  distinct <- unique(codes)
  taken <- labels
  names_out <- character(length(distinct))
  for (i in seq_along(distinct)) {
    name <- paste0(distinct[i], .srtr_unknown_suffix)
    while (name %in% taken) {
      name <- paste0(name, .srtr_unknown_suffix)
    }
    names_out[i] <- name
    taken <- c(taken, name)
  }
  names_out[match(codes, distinct)]
}

# A column converted by an earlier call carries the marker this function
# sets. Nothing else counts: no pattern in the values or levels can show a
# column was converted, so a column that lost its marker (base R subsetting
# drops it) is read as codes again, and its values are reported as outside
# the format rather than passed through.
.srtr_already_factored <- function(x) {
  !is.null(attr(x, "srtr_format"))
}

# Band numeric values by the format's numeric codes, read as lower bounds.
.srtr_bin_range <- function(x, fmt_map) {
  bounds <- suppressWarnings(as.numeric(fmt_map$Value))
  bands <- fmt_map[!is.na(bounds), ]
  bands$bound <- bounds[!is.na(bounds)]
  bands <- bands[order(bands$bound), ]
  other_label <- fmt_map$Label[fmt_map$Value == .srtr_other_code]
  position <- findInterval(x, bands$bound)
  labels <- ifelse(position == 0, NA, bands$Label[pmax(position, 1)])
  factor(labels, levels = unique(c(bands$Label, other_label)))
}

.srtr_keep_attributes <- function(new, old, fmt) {
  keep <- setdiff(names(attributes(old)), c("class", "levels", "names", "contrasts"))
  for (a in keep) {
    attr(new, a) <- attr(old, a)
  }
  attr(new, "srtr_format") <- fmt
  new
}

.srtr_report_unknown_codes <- function(unknown, n, var, fmt, action, call, kept_as = NULL) {
  shown <- utils::head(unknown, 5)
  if (action == "error") {
    srtr_abort(
      c(
        "{.var {var}} has {length(unknown)} code{?s} not in format {.val {fmt}}: {.val {shown}}{if (length(unknown) > 5) ', ...' else ''}.",
        "i" = "Use {.code unknown_codes = \"keep\"} or {.code \"na\"} to continue."
      ),
      class = "unknown_codes",
      variable = var,
      format = fmt,
      codes = unknown,
      call = call
    )
  }
  what <- if (action != "keep") {
    "set to {.code NA}"
  } else if (!is.null(kept_as)) {
    "given the catch-all label {.val {kept_as}}"
  } else {
    "kept as {?its/their} own level{?s}"
  }
  if (action == "keep" && is.null(kept_as)) {
    shown <- paste0(shown, .srtr_unknown_suffix)
  }
  srtr_warn(
    c(
      paste0(
        "{.var {var}}: {n} value{?s} with {length(unknown)} code{?s} not in format {.val {fmt}}, ",
        what, ": {.val {shown}}{if (length(unknown) > 5) ', ...' else ''}."
      )
    ),
    class = "unknown_codes",
    variable = var,
    format = fmt,
    codes = unknown
  )
}
