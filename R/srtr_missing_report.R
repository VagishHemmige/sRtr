#' Count the missing-value codes in SRTR data
#'
#' Reports, for each variable, how many values stand for missing
#' information and of which kind: unknown, not done, not applicable and so
#' on. Nothing in the data is changed. Use it to see what is there before
#' deciding how to handle it.
#'
#' Codes are recognised from [missing_codes], by what they mean in the
#' variable's own format: the same code number can be "Unknown" in one
#' format and an ordinary value in another. Raw codes and labelled columns
#' (from [apply_srtr_factors()]) give the same counts. Flag columns that
#' have no format are recognised from the `variables` table of
#' [missing_codes], which is not taken from the SRTR dictionary.
#'
#' The report holds counts, and the codes and meanings that [missing_codes]
#' lists. It never holds a value taken from the data: values a format does
#' not list are counted together and not shown. Counts from SRTR data can
#' still be small cells; treat them as you would any other table made from
#' the data.
#'
#' @seealso Guides:
#' * [What is in the data](https://vagishhemmige.github.io/sRtr/articles/missing-data.html#what-is-in-the-data)
#' @param df A data frame from an SRTR SAF file.
#' @param cols Names of the columns to report. `NULL` (the default) reports
#'   every column that [missing_codes] covers.
#' @param file_key The dataset `df` comes from, such as `"TX_KI"`. `NULL`
#'   uses the `file_key` attribute that [load_srtr_file()] sets. If there
#'   is none, variables are looked up by name alone, and a variable whose
#'   format differs between datasets is skipped, with a message.
#' @param detail `"type"` (the default) gives one row per variable and
#'   kind of missing value found. `"code"` gives one row per classified
#'   code, including codes that do not occur (`n` is 0), which shows
#'   whether the codes in [missing_codes] match the data.
#' @param release The SAF release, as in [load_srtr_file()]. `NULL` uses
#'   the release recorded on `df`, or else the bundled dictionary.
#' @param extra_codes Your own codes, for values that [missing_codes] does
#'   not cover: a named list with one element per column, each a named
#'   character vector giving the type of each value, such as
#'   `list(MY_VAR = c("9" = "unknown"))`. These win over [missing_codes],
#'   and apply alike to raw codes and to labelled columns. If two codes of
#'   a format share one label, both must be given the same type.
#'
#' @return A tibble with one row per variable and kind of missing value:
#' \describe{
#'   \item{variable}{The column name.}
#'   \item{format}{The variable's SRTR format, or `NA` if it has none.}
#'   \item{missing_type}{A type from [missing_codes], or `"not_in_format"`
#'     for a value the variable's format does not list, or `"na"` for a
#'     value that is already `NA`.}
#'   \item{n}{The number of rows.}
#'   \item{percent}{`n` as a percentage of all rows of `df`.}
#' }
#' With `detail = "code"`, `code` and `meaning` columns identify each code;
#' they are `NA` in the `"not_in_format"` and `"na"` rows.
#' Partly known codes (type `"partial"`) are reported too, although they
#' are not wholly missing.
#' @seealso [missing_codes], [srtr_normalize_missing()]
#' @export
#'
#' @examples
#' # Made-up rows using TX_KI column names
#' df <- data.frame(
#'   DON_ANTI_CMV = c("P", "N", "U", "ND", NA),
#'   DON_HIST_DIAB = c(1, 5, 998, 998, 2)
#' )
#' srtr_missing_report(df, file_key = "TX_KI")
#' srtr_missing_report(df, file_key = "TX_KI", detail = "code")
srtr_missing_report <- function(
  df,
  cols = NULL,
  file_key = NULL,
  detail = c("type", "code"),
  release = NULL,
  extra_codes = NULL
) {
  detail <- rlang::arg_match(detail)
  lookup <- .srtr_missing_lookup(df, cols, file_key, release, extra_codes)
  total <- nrow(df)

  rows <- lapply(lookup, function(column) {
    found <- .srtr_missing_match(
      df[[column$name]],
      column$format_rows,
      column$variable_rows,
      column$format,
      column$extra_rows
    )
    .srtr_missing_count(found, column, detail)
  })
  report <- dplyr::bind_rows(c(list(.srtr_missing_empty(detail)), rows))
  report$percent <- if (total > 0) 100 * report$n / total else NA_real_
  report
}

# Report order for the kinds of missing value.
.srtr_missing_report_types <- c(
  setdiff(.srtr_missing_types, "none"),
  "not_in_format",
  "na"
)

.srtr_missing_empty <- function(detail) {
  report <- tibble::tibble(
    variable = character(),
    format = character(),
    code = character(),
    meaning = character(),
    missing_type = character(),
    n = integer()
  )
  if (detail == "type") {
    report$code <- NULL
    report$meaning <- NULL
  }
  report
}

# Counts for one column, from the per-row result of .srtr_missing_match().
.srtr_missing_count <- function(found, column, detail) {
  present <- !is.na(found$type)
  if (detail == "type") {
    n <- table(factor(found$type[present], .srtr_missing_report_types))
    n <- n[n > 0]
    return(tibble::tibble(
      variable = rep(column$name, length(n)),
      format = rep(column$format, length(n)),
      missing_type = names(n),
      n = as.integer(n)
    ))
  }

  known <- rbind(
    column$format_rows[
      !is.na(column$format_rows$missing_type),
      c("Code", "Meaning", "missing_type")
    ],
    data.frame(
      Code = column$variable_rows$Code,
      Meaning = rep(NA_character_, nrow(column$variable_rows)),
      missing_type = column$variable_rows$missing_type
    ),
    data.frame(
      Code = column$extra_rows$Code,
      Meaning = rep(NA_character_, NROW(column$extra_rows)),
      missing_type = column$extra_rows$missing_type
    )
  )
  seen <- unique(data.frame(
    Code = found$code[present],
    Meaning = rep(NA_character_, sum(present)),
    missing_type = found$type[present]
  ))
  extra <- seen[
    !paste(seen$Code, seen$missing_type) %in%
      paste(known$Code, known$missing_type),
  ]
  listed <- rbind(known, extra)
  listed <- listed[!duplicated(paste(listed$Code, listed$missing_type)), ]
  listed <- listed[
    order(match(listed$missing_type, .srtr_missing_report_types)),
  ]
  tibble::tibble(
    variable = rep(column$name, nrow(listed)),
    format = rep(column$format, nrow(listed)),
    code = listed$Code,
    meaning = listed$Meaning,
    missing_type = listed$missing_type,
    n = vapply(
      seq_len(nrow(listed)),
      function(i) {
        sum(
          found$type[present] == listed$missing_type[i] &
            found$code[present] %in% listed$Code[i]
        )
      },
      integer(1)
    )
  )
}
