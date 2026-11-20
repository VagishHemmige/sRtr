#' Stored versions of the SRTR data dictionary
#'
#' Every version of SRTR's public SAF data dictionary page that sRtr has
#' stored, kept as runs: each variable or format code appears once for each
#' unbroken sequence of stored versions in which it was the same. Use
#' [srtr_dictionary()] to get the dictionary for a release; this dataset is
#' what it reads.
#'
#' Versions are added by a monthly check of
#' <https://www.srtr.org/docs/datadictionary.html>. A snapshot is named by the
#' release and a revision number (`"2609-1"`), since SRTR can revise a page
#' without changing its release.
#'
#' @seealso Guides:
#' * [What a release between two copies can and cannot know](https://vagishhemmige.github.io/sRtr/articles/releases-and-warnings.html#what-a-release-between-two-copies-can-and-cannot-know)
#' @format A list of three tibbles:
#' \describe{
#'   \item{releases}{One row per stored snapshot: `snapshot`, `release`,
#'     `revision`, `title`, `sha256`, `encoding`, `last_modified`,
#'     `retrieved` and `source`.}
#'   \item{dictionary}{Variables: `Dataset`, `Variable`, `Type`, `Length`,
#'     `FormatID`, `Label`, and `first` and `last`, the first and last
#'     snapshots of the run.}
#'   \item{formats}{Format codes: `Format`, `Code`, `Meaning`, `Position` (the
#'     code's place within its format), `first` and `last`.}
#' }
#' @source SRTR SAF data dictionary pages, stored in
#'   `data-raw/dictionary-versions/`.
#' @docType data
#' @keywords datasets
#' @name dictionary_versions
NULL
