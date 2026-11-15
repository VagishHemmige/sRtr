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
#'   `"keep"` (the default) keeps it as an extra level named by the raw code;
#'   `"na"` turns it into `NA`. Both warn
#'   (class `sRtr_warning_unknown_codes`). `"error"` stops
#'   (class `sRtr_error_unknown_codes`).
#' @param other What to do with a format's catch-all entry (`**OTHER**`, as in
#'   `RACE`, where it means "Multi-Racial"). `"sas"` (the default) gives every
#'   value not otherwise listed the catch-all label, as a SAS format does.
#'   `"keep"` ignores the catch-all, so those values are handled by
#'   `unknown_codes`.
#'
#' @details
#' A column that is already a factor of this format's labels, for example
#' from an earlier call, is left as it is, so calling the function twice
#' changes nothing. Attributes on each column, such as a variable label, are
#' kept.
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
  other = c("sas", "keep")
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

# Convert one column with its format's codes. `fmt_map` has columns Value
# (code) and Label, in the format's order.
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
  if (.srtr_already_factored(x, fmt_map)) {
    return(x)
  }
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

  values <- as.character(x)
  outside <- !is.na(values) & !values %in% codes
  if (has_other) {
    out <- factor(
      ifelse(outside, other_label, labels[match(values, codes)]),
      levels = unique(listed$Label)
    )
    return(.srtr_keep_attributes(out, x, fmt))
  }

  unknown <- sort(unique(values[outside]))
  if (length(unknown) > 0) {
    .srtr_report_unknown_codes(unknown, sum(outside), var, fmt, unknown_codes, call)
  }
  levels_out <- unique(labels)
  mapped <- labels[match(values, codes)]
  if (unknown_codes == "keep" && length(unknown) > 0) {
    mapped[outside] <- values[outside]
    levels_out <- c(levels_out, setdiff(unknown, levels_out))
  }
  .srtr_keep_attributes(factor(mapped, levels = levels_out), x, fmt)
}

# A factor whose levels are this format's labels (and no code that maps to a
# different label) was converted already. Raw SAF columns are never factors.
.srtr_already_factored <- function(x, fmt_map) {
  if (!is.null(attr(x, "srtr_format"))) {
    return(TRUE)
  }
  if (!is.factor(x)) {
    return(FALSE)
  }
  lev <- levels(x)
  code_only <- lev %in% fmt_map$Value & !lev %in% fmt_map$Label
  !any(code_only)
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

.srtr_report_unknown_codes <- function(unknown, n, var, fmt, action, call) {
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
  what <- if (action == "keep") "kept as {?its/their} own level{?s}" else "set to {.code NA}"
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
