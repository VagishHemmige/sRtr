## code to prepare `optn_mapping_tables` dataset goes here

# The OPTN KDRI-to-KDPI and EPTS mapping tables as one dataset, read by
# add_kdpi() and add_epts(). The two CSVs come from the OPTN PDFs through
# data-raw/optn_tables_parse.R; this script only joins them. Built on GitHub by
# the regenerate-data workflow.

dir <- file.path("data-raw", "optn-tables")

tables <- utils::read.csv(
  file.path(dir, "optn_tables.csv"),
  colClasses = c(
    score = "character",
    label = "character",
    reference = "character",
    data_as_of = "Date",
    scaling_factor = "numeric",
    diabetes_pct = "numeric",
    hypertension_pct = "numeric",
    kdri_formula = "character",
    formula_basis = "character",
    file = "character",
    n_rows = "integer"
  ),
  na.strings = ""
)
rows <- utils::read.csv(
  file.path(dir, "optn_table_rows.csv"),
  colClasses = c(
    score = "character",
    label = "character",
    row = "integer",
    lower = "numeric",
    upper = "numeric",
    percentile = "numeric"
  )
)
manifest <- utils::read.csv(file.path(dir, "manifest.csv"), colClasses = "character")

tables$sha256 <- manifest$sha256[match(tables$file, manifest$file)]
tables$url <- manifest$url[match(tables$file, manifest$file)]
stopifnot(!anyNA(tables$sha256))

optn_mapping_tables <- list(
  tables = tibble::as_tibble(tables[, c(
    "score", "label", "reference", "data_as_of", "scaling_factor",
    "diabetes_pct", "hypertension_pct", "kdri_formula", "formula_basis",
    "file", "url", "sha256"
  )]),
  rows = tibble::as_tibble(rows)
)

usethis::use_data(optn_mapping_tables, overwrite = TRUE)
