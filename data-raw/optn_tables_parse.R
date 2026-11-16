# Parse the OPTN KDRI-to-KDPI and EPTS mapping tables from their PDFs.
#
# Run by hand only when OPTN publishes a new table. The PDFs are not kept in
# the repository: download them to a folder outside it, add each new file to
# data-raw/optn-tables/manifest.csv (address, size, sha256), then run
#
#   Rscript data-raw/optn_tables_parse.R path/to/pdf-folder
#
# The script checks every PDF against its manifest hash, parses it, checks the
# table's shape and writes
#
#   data-raw/optn-tables/optn_tables.csv        one row per table
#   data-raw/optn-tables/optn_table_rows.csv    one row per interval
#
# Those two CSVs are the source for the `optn_mapping_tables` dataset, which
# data-raw/optn_tables_data.R builds on GitHub (regenerate-data workflow).
#
# Sources: the OPTN mapping tables listed in the manifest, from
# https://www.hrsa.gov/optn/data/allocation-calculators/archived-allocation-calculator-resources
# and the current tables linked from the OPTN KDPI and EPTS guides.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1 || !dir.exists(args[[1]])) {
  stop("Usage: Rscript data-raw/optn_tables_parse.R <folder with the PDFs>")
}
pdf_dir <- args[[1]]
out_dir <- file.path("data-raw", "optn-tables")

manifest <- utils::read.csv(
  file.path(out_dir, "manifest.csv"),
  colClasses = "character"
)

# Formula each KDPI table was built with. OPTN does not print this on the
# table. Tables before the October 2024 refit use Rao 2009 (KDPI guide, 2020
# edition). The table labelled 2024 (OPTN data as of 2024-09-06) re-maps the
# 2023 donors with a different scaling factor from the 2023 table, weeks before
# the refit took effect on 2024-10-31; it is taken to be the refit table. That
# reading is an inference, recorded in `formula_basis`.
kdri_formula <- function(label, data_as_of) {
  if (label == "current") {
    return(c("refit2024", "printed after the refit (KDPI guide, 2026)"))
  }
  if (label == "2024") {
    return(c("refit2024", "inferred: 2023 donors re-mapped 2024-09-06"))
  }
  c("rao2009", "before the refit (2024-10-31)")
}

month_date <- function(x) {
  x <- gsub("\\s+", " ", trimws(x))
  as.Date(x, format = "%B %d, %Y")
}

parse_one <- function(file) {
  text <- paste(pdftools::pdf_text(file.path(pdf_dir, file)), collapse = "\n")
  text <- gsub("\r", "", text)
  # Newer tables print the arrow with an en dash; one 2016 table has stray
  # dots between the arrow and the percentile.
  text <- gsub("\u2013", "-", text, fixed = TRUE)
  score <- if (grepl("epts", file, ignore.case = TRUE)) "epts" else "kdpi"

  rows <- regmatches(
    text,
    gregexpr(
      "(-?[0-9]+(\\.[0-9]+)?)\\s+(-?[0-9]+(\\.[0-9]+)?)\\s*-+>[\\s.]*([0-9]+(\\.[0-9]+)?)\\s*%",
      text,
      perl = TRUE
    )
  )[[1]]
  parts <- regmatches(rows, regexec(
    "(-?[0-9.]+)\\s+(-?[0-9.]+)\\s*-+>[\\s.]*([0-9.]+)\\s*%",
    rows,
    perl = TRUE
  ))
  intervals <- data.frame(
    # Bounds are kept as printed, so the CSV matches the PDF digit for digit.
    lower = vapply(parts, `[`, "", 2),
    upper = vapply(parts, `[`, "", 3),
    percentile = as.numeric(vapply(parts, `[`, "", 4))
  )

  as_of <- regmatches(text, regexec("as of\\s+([A-Za-z]+\\s+[0-9]{1,2},\\s*[0-9]{4})", text))[[1]][2]
  flat <- gsub("\\s+", " ", text)
  label <- sub("^.*?((20[0-9]{2})|31dec(20[0-9]{2})).*$", "\\2\\3", file)
  if (!grepl("^20[0-9]{2}$", label)) label <- "current"

  if (score == "kdpi") {
    ref_year <- regmatches(flat, regexec("Recovered (for the Purpose of Transplantation )?in ([0-9]{4})", flat, ignore.case = TRUE))[[1]][3]
    sf <- regmatches(flat, regexec("scaling factor for converting KDRI[ _]RAO to [A-Za-z_ ]+?:\\s*([0-9.]+)", flat, ignore.case = TRUE))[[1]][2]
    diab <- regmatches(flat, regexec("Diabetes percentage[^:]*:\\s*([0-9.]+)%", flat))[[1]][2]
    hyp <- regmatches(flat, regexec("Hypertension percentage[^:]*:\\s*([0-9.]+)%", flat))[[1]][2]
    formula <- kdri_formula(label, as_of)
    reference <- ref_year
  } else {
    reference <- regmatches(flat, regexec("Waiting List on (December 31, [0-9]{4})", flat))[[1]][2]
    sf <- diab <- hyp <- NA_character_
    formula <- c(NA_character_, NA_character_)
  }

  meta <- data.frame(
    score = score,
    label = label,
    reference = if (score == "kdpi") reference else format(month_date(reference)),
    data_as_of = format(month_date(as_of)),
    scaling_factor = as.numeric(sf),
    diabetes_pct = as.numeric(diab),
    hypertension_pct = as.numeric(hyp),
    kdri_formula = formula[[1]],
    formula_basis = formula[[2]],
    file = file,
    n_rows = nrow(intervals)
  )
  list(meta = meta, rows = cbind(score = score, label = label, row = seq_len(nrow(intervals)), intervals))
}

check_table <- function(x) {
  r <- x$rows
  name <- paste(x$meta$score, x$meta$label)
  problems <- c(
    if (nrow(r) < 101) "fewer than 101 intervals",
    if (r$percentile[1] != 0) "does not start at 0%",
    if (r$percentile[nrow(r)] != 100) "does not end at 100%",
    if (any(diff(r$percentile) < 0)) "percentiles decrease",
    if (any(as.numeric(r$lower[-1]) != as.numeric(r$upper[-nrow(r)]))) "intervals are not contiguous",
    if (any(as.numeric(r$upper) <= as.numeric(r$lower))) "an interval is empty",
    if (!setequal(r$percentile, 0:100)) "percentiles are not exactly 0 to 100",
    if (is.na(x$meta$data_as_of)) "no data-as-of date",
    if (is.na(x$meta$reference)) "no reference population"
  )
  if (length(problems)) stop(name, ": ", paste(problems, collapse = "; "))
}

parsed <- lapply(manifest$file[grepl("mapping", manifest$file)], function(file) {
  path <- file.path(pdf_dir, file)
  if (!file.exists(path)) stop("Missing PDF: ", file)
  hash <- digest::digest(file = path, algo = "sha256")
  expected <- manifest$sha256[manifest$file == file]
  if (!identical(hash, expected)) stop("Hash does not match the manifest: ", file)
  x <- parse_one(file)
  check_table(x)
  x
})

tables <- do.call(rbind, lapply(parsed, `[[`, "meta"))
rows <- do.call(rbind, lapply(parsed, `[[`, "rows"))
tables <- tables[order(tables$score, tables$data_as_of), ]
rows <- rows[order(rows$score, rows$label, rows$row), ]

utils::write.csv(tables, file.path(out_dir, "optn_tables.csv"), row.names = FALSE, na = "")
utils::write.csv(rows, file.path(out_dir, "optn_table_rows.csv"), row.names = FALSE, quote = FALSE)
cat("Parsed", nrow(tables), "tables,", nrow(rows), "intervals.\n")
