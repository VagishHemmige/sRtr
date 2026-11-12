# Column names in dplyr code follow "Using dplyr in packages"
# (vignette("in-packages", package = "dplyr")): `.data$col` in data-masking
# verbs (filter, mutate, summarise, group_by, arrange) and "col" strings in
# tidy-selection verbs (select, relocate, rename). There is no
# utils::globalVariables() list: a name listed there would also hide a missing
# column or a missing pkg:: prefix from R CMD check.


# No .onLoad(): loading sRtr does not scan SRTR_WD or change options. The
# folder is scanned when load_srtr_file() first needs it (.srtr_file_list()).

#' @importFrom rlang .data :=
#' @noRd
NULL
