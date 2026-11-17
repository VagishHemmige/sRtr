#' Missing-value codes in the SRTR formats, by type
#'
#' SRTR formats record missing information in several ways, and the same code
#' number means different things in different formats: code `4` is "Unknown"
#' in one format, "N/A" in another and "Not tested" in a third. This dataset
#' classifies each format code that may stand for missing information, so
#' that code can be handled by what it means.
#'
#' The classification describes what a code means. It does not say what an
#' analysis should do with it.
#'
#' @details
#' A code is listed when its meaning matches a broad screen (words such as
#' "unknown", "not done", "N/A" or "pending"), when it is the SAS missing
#' value `.`, or when it is a format's catch-all. Each listed code was then
#' classified by hand from its meaning in the SRTR data dictionary. A code
#' the screen picked up that turned out to be an ordinary value is kept, with
#' type `"none"`, so that it is known to have been looked at. Codes that are
#' not listed did not match the screen.
#'
#' The types are sRtr's own grouping of the dictionary's meanings, not an
#' SRTR classification:
#'
#' * `"unknown"`: the information is not known.
#' * `"not_applicable"`: the question does not apply to this person.
#' * `"not_done"`: the test or assessment was not done.
#' * `"pending"`: a result was awaited.
#' * `"cannot_disclose"`: the result is withheld.
#' * `"indeterminate"`: the test was done and gave no clear result.
#' * `"partial"`: part of the answer is known, such as "Yes, duration
#'   unknown". `collapses_to` names the part that is known.
#' * `"sas_missing"`: the SAS missing value `.`, which the format labels
#'   "Missing".
#' * `"none"`: an ordinary value.
#'
#' @format A list holding one tibble, `formats`, with one row per classified
#'   format code:
#' \describe{
#'   \item{Format, Code, Meaning}{The format code, as in
#'     [dictionary_versions]. A classification applies only to this exact
#'     meaning.}
#'   \item{missing_type}{The type, one of those listed in Details.}
#'   \item{collapses_to}{For `"partial"` codes, the part of the answer that
#'     is known. Empty otherwise.}
#'   \item{note}{Why the code was classified this way, where that is not
#'     plain from its meaning.}
#' }
#' @source Meanings from the SRTR SAF data dictionary pages stored in
#'   [dictionary_versions]; classified by hand in
#'   `data-raw/missing-codes/format_codes.csv`.
#' @docType data
#' @keywords datasets
#' @name missing_codes
NULL

.srtr_missing_types <- c(
  "unknown",
  "not_applicable",
  "not_done",
  "pending",
  "cannot_disclose",
  "indeterminate",
  "partial",
  "sas_missing",
  "none"
)

.srtr_missing_columns <- c(
  "Format",
  "Code",
  "Meaning",
  "missing_type",
  "collapses_to",
  "note"
)

# Words that suggest a code may stand for missing information. The screen is
# deliberately broad: it only decides which codes a person must classify, so
# a false match costs one "none" row and a miss leaves a code unreviewed.
.srtr_missing_screen <- paste(
  c(
    "unknown",
    "\\bunk\\b",
    paste0(
      "not (done|tested|applicable|performed|assessed|reported|available|",
      "specified|collected|obtained|known|stated|determined|recorded|",
      "entered|provided|sure)"
    ),
    "\\bn/?a\\b",
    "missing",
    "pending",
    "disclos",
    "indetermina",
    "unspecified",
    "unable",
    "refus",
    "inconclusive",
    "equivocal",
    "no data",
    "converted",
    "uncertain",
    "undetermined",
    "not elsewhere",
    "\\bnos\\b",
    "invalid",
    "error",
    "blank",
    "none given"
  ),
  collapse = "|"
)

# Which rows of a formats table (columns Code and Meaning) must be
# classified: the SAS missing value, a format's catch-all, and any meaning
# the screen matches.
.srtr_missing_candidates <- function(formats) {
  formats$Code %in%
    c(".", "**OTHER**") |
    grepl(.srtr_missing_screen, formats$Meaning, ignore.case = TRUE, perl = TRUE)
}

# Read a classification file. Every column is text; a blank stays "" and the
# text "NA" stays "NA", because both are real format codes.
.srtr_missing_read <- function(path) {
  codes <- tibble::as_tibble(utils::read.csv(
    path,
    colClasses = "character",
    na.strings = character(),
    check.names = FALSE,
    encoding = "UTF-8"
  ))
  codes[.srtr_missing_columns]
}

# Everything wrong with a classification, measured against a formats table
# (the stored runs, so every snapshot's codes count). No rows means every
# candidate code has exactly one valid classification of its current
# meaning. A code whose meaning changed shows up twice: its new meaning is
# unclassified, and its old row no longer matches any stored code.
.srtr_missing_problems <- function(codes, formats) {
  key <- function(x) paste(x$Format, x$Code, x$Meaning, sep = "\r")
  stored <- unique(formats[c("Format", "Code", "Meaning")])
  candidates <- stored[.srtr_missing_candidates(stored), ]
  is_partial <- codes$missing_type == "partial"
  has_target <- nzchar(codes$collapses_to)

  problem <- function(name, rows) {
    tibble::tibble(
      problem = rep(name, nrow(rows)),
      Format = rows$Format,
      Code = rows$Code,
      Meaning = rows$Meaning
    )
  }
  dplyr::bind_rows(
    problem(
      "unclassified",
      candidates[!key(candidates) %in% key(codes), ]
    ),
    problem("not_in_formats", codes[!key(codes) %in% key(stored), ]),
    problem("duplicate", codes[duplicated(key(codes)), ]),
    problem(
      "invalid_type",
      codes[!codes$missing_type %in% .srtr_missing_types, ]
    ),
    problem("partial_without_target", codes[is_partial & !has_target, ]),
    problem("target_without_partial", codes[!is_partial & has_target, ])
  )
}
