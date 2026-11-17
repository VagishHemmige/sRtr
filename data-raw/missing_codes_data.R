## code to prepare `missing_codes` dataset goes here

# The hand-reviewed classifications of codes that may stand for missing
# information, checked against the stored dictionary versions. Built on
# GitHub by the regenerate-data workflow.
#
#   * data-raw/missing-codes/format_codes.csv: format codes.
#   * data-raw/missing-codes/variable_codes.csv: raw values of variables
#     that no format lists.
#
# The build stops if any stored format code that the screen picks up has no
# classification, if a classified code no longer exists with that meaning,
# or if a variable row is invalid. Fix the CSV files by hand; this script
# never edits them.

pkgload::load_all(".", quiet = TRUE, export_all = TRUE)

format_codes <- .srtr_missing_read("data-raw/missing-codes/format_codes.csv")
stored <- .srtr_versions_read("data-raw/dictionary-versions")$formats

problems <- .srtr_missing_problems(format_codes, stored)
if (nrow(problems) > 0) {
  print(problems, n = Inf)
  stop(
    nrow(problems),
    " problem(s) in data-raw/missing-codes/format_codes.csv; see above."
  )
}

variable_codes <- .srtr_missing_read(
  "data-raw/missing-codes/variable_codes.csv",
  columns = .srtr_missing_variable_columns
)
stored_variables <- unique(
  .srtr_versions_read("data-raw/dictionary-versions")$dictionary$Variable
)

variable_problems <- .srtr_missing_variable_problems(
  variable_codes,
  stored_variables
)
if (nrow(variable_problems) > 0) {
  print(variable_problems, n = Inf)
  stop(
    nrow(variable_problems),
    " problem(s) in data-raw/missing-codes/variable_codes.csv; see above."
  )
}

missing_codes <- list(formats = format_codes, variables = variable_codes)

usethis::use_data(missing_codes, overwrite = TRUE)
