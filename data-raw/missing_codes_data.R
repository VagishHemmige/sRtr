## code to prepare `missing_codes` dataset goes here

# The hand-reviewed classification of format codes that may stand for
# missing information (data-raw/missing-codes/format_codes.csv), checked
# against the stored dictionary versions. Built on GitHub by the
# regenerate-data workflow.
#
# The build stops if any stored format code that the screen picks up has no
# classification, or if a classified code no longer exists with that
# meaning. Fix format_codes.csv by hand; this script never edits it.

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

missing_codes <- list(formats = format_codes)

usethis::use_data(missing_codes, overwrite = TRUE)
