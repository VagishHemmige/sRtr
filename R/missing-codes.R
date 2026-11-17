#' Missing-value codes in the SRTR formats, by type
#'
#' SRTR formats record missing information in several ways, and the same code
#' number means different things in different formats: code `4` is "Unknown"
#' in one format, "N/A" in another and "Not tested" in a third. Many flag
#' columns have no format at all, so the dictionary does not say which of
#' their values mean missing. This dataset classifies both kinds of code, so
#' that each can be handled by what it means.
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
#' * `"sas_missing"`: the SAS missing value. For numbers that is `.`, which
#'   a format labels "Missing"; for text it is a blank.
#' * `"none"`: an ordinary value.
#'
#' @format A list of two tibbles.
#'
#' `formats` has one row per classified format code:
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
#'
#' `variables` has one row per variable and raw value, for values that no
#' format of the variable lists. Most are one-character flag columns with no
#' format:
#' \describe{
#'   \item{Variable}{The variable name, in whichever file it appears.}
#'   \item{Code}{The raw value, as text. A blank is the empty string. A
#'     blank or text value listed for a variable the dictionary types as
#'     numeric cannot occur as stored; such rows are kept from the hand
#'     list, and their `note` says so.}
#'   \item{missing_type}{The type, as above. Never `"none"` or
#'     `"partial"`.}
#'   \item{source}{Where the row comes from. `"hand list"` rows were carried
#'     over from the hand-written list that `srtr_normalize_missing()` used
#'     before this dataset existed. The SRTR dictionary does not document
#'     these values, and they have not yet been checked against SAF data.}
#'   \item{note}{Anything else worth knowing about the row.}
#' }
#' @source `formats`: meanings from the SRTR SAF data dictionary pages
#'   stored in [dictionary_versions], classified by hand in
#'   `data-raw/missing-codes/format_codes.csv`. `variables`:
#'   `data-raw/missing-codes/variable_codes.csv`, which is not taken from
#'   the dictionary.
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

.srtr_missing_variable_columns <- c(
  "Variable",
  "Code",
  "missing_type",
  "source",
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
.srtr_missing_read <- function(path, columns = .srtr_missing_columns) {
  codes <- tibble::as_tibble(utils::read.csv(
    path,
    colClasses = "character",
    na.strings = character(),
    check.names = FALSE,
    encoding = "UTF-8"
  ))
  codes[columns]
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

# Everything wrong with the classification of raw values by variable.
# `variables` is every variable name the stored dictionary versions know.
# These rows list missing values only, so "none" and "partial" are not
# allowed, and each row must say where it comes from. `numeric` is the
# variables the dictionary types as numeric everywhere: a blank or text
# value cannot be stored in one, so such a row must say so in its note.
.srtr_missing_variable_problems <- function(
  codes,
  variables,
  numeric = character()
) {
  key <- paste(codes$Variable, codes$Code, sep = "\r")
  allowed <- setdiff(.srtr_missing_types, c("none", "partial"))
  is_text <- is.na(suppressWarnings(as.numeric(codes$Code)))
  unexplained <- codes$Variable %in% numeric &
    is_text &
    !grepl("numeric", codes$note, fixed = TRUE)

  problem <- function(name, rows) {
    tibble::tibble(
      problem = rep(name, nrow(rows)),
      Variable = rows$Variable,
      Code = rows$Code
    )
  }
  dplyr::bind_rows(
    problem("not_in_dictionary", codes[!codes$Variable %in% variables, ]),
    problem("duplicate", codes[duplicated(key), ]),
    problem("invalid_type", codes[!codes$missing_type %in% allowed, ]),
    problem("no_source", codes[!nzchar(codes$source), ]),
    problem("text_code_for_numeric", codes[unexplained, ])
  )
}

# Variables a dictionary table (columns Variable and Type) types as numeric
# in every dataset that has them.
.srtr_numeric_variables <- function(dictionary) {
  not_numeric <- unique(dictionary$Variable[dictionary$Type != "num"])
  setdiff(unique(dictionary$Variable), not_numeric)
}
