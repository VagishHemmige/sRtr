# Column names in dplyr code follow "Using dplyr in packages"
# (vignette("in-packages", package = "dplyr")): `.data$col` in data-masking
# verbs (filter, mutate, summarise, group_by, arrange) and "col" strings in
# tidy-selection verbs (select, relocate, rename). There is no
# utils::globalVariables() list: a name listed there would also hide a missing
# column or a missing pkg:: prefix from R CMD check.

# No .onLoad(): loading sRtr does not scan SRTR_WD or change options. The
# folder is scanned when load_srtr_file() first needs it (.srtr_file_list()).

# .onAttach() runs the data safety check on the working directory's git
# repository (see .srtr_attach_check()). It only reads, and never stops
# library(sRtr): any error inside the check is dropped. It is skipped while a
# document is knitted, so the message never lands in a report or article.
.onAttach <- function(libname, pkgname) {
  if (!.srtr_safety_check_on() || isTRUE(getOption("knitr.in.progress"))) {
    return(invisible())
  }
  tryCatch(
    .srtr_attach_check(getwd()),
    error = function(e) invisible()
  )
  invisible()
}

#' @importFrom rlang .data :=
#' @noRd
NULL
