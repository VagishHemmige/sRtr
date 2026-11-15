# Add one saved copy of the SRTR SAF data dictionary page to the stored
# versions in data-raw/dictionary-versions/ (#26).
#
# Run from the repository root:
#
#   Rscript data-raw/dictionary_versions_add.R <page.html> [source] [last_modified] [retrieved]
#
# * page.html: the page exactly as downloaded.
# * source: where it came from (default: the live SRTR address).
# * last_modified: the server's Last-Modified time, if known (ISO 8601, UTC).
# * retrieved: when it was downloaded (ISO 8601, UTC; default: now).
#
# The release comes from the page title. A page whose hash is already stored
# changes nothing. A new hash for a stored release is added as its next
# revision ("2609-2"), so the earlier copy stays reproducible.
#
# Writes only inside data-raw/dictionary-versions/: releases.csv,
# dictionary_runs.csv, formats_runs.csv and pages/<snapshot>.html.gz.
# The maintainer regenerates data/ separately.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
  stop("Usage: Rscript data-raw/dictionary_versions_add.R <page.html> [source] [last_modified] [retrieved]")
}
page_path <- args[[1]]
source_url <- if (length(args) >= 2) args[[2]] else "https://www.srtr.org/docs/datadictionary.html"
last_modified <- if (length(args) >= 3) args[[3]] else ""
retrieved <- if (length(args) >= 4) args[[4]] else format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")

pkgload::load_all(".", quiet = TRUE, export_all = TRUE)

dir <- "data-raw/dictionary-versions"
dir.create(file.path(dir, "pages"), recursive = TRUE, showWarnings = FALSE)

read_table <- function(file, cols) {
  path <- file.path(dir, file)
  if (!file.exists(path)) {
    return(tibble::as_tibble(stats::setNames(
      rep(list(character()), length(cols)),
      cols
    )))
  }
  tibble::as_tibble(utils::read.csv(
    path,
    colClasses = "character",
    na.strings = character(),
    check.names = FALSE,
    encoding = "UTF-8"
  ))
}
# Written as UTF-8 bytes whatever the session's locale; write.csv's own
# fileEncoding re-encodes from the locale and garbles non-ASCII text in a
# C or Latin-1 session.
write_table <- function(x, file) {
  quote <- function(v) paste0('"', gsub('"', '""', enc2utf8(v), fixed = TRUE), '"')
  lines <- c(
    paste(quote(names(x)), collapse = ","),
    do.call(paste, c(lapply(x, quote), sep = ","))
  )
  con <- file(file.path(dir, file), open = "wb")
  on.exit(close(con))
  writeLines(enc2utf8(lines), con, useBytes = TRUE)
}

release_cols <- c(
  "snapshot", "release", "revision", "title", "sha256", "encoding",
  "last_modified", "retrieved", "source"
)
dict_key <- c("Dataset", "Variable")
fmt_key <- c("Format", "Code")
dict_cols <- c(dict_key, "Type", "Length", "FormatID", "Label", "first", "last")
# Codes keep their order on the page, which sets factor level order, so each
# code's position within its format is stored with it. A code that moves is a
# new run. Variables need no position: the page lists datasets and variables
# in sorted order, and the views sort the same way (checked below).
fmt_cols <- c(fmt_key, "Meaning", "Position", "first", "last")

releases <- read_table("releases.csv", release_cols)
dict_runs <- read_table("dictionary_runs.csv", dict_cols)
fmt_runs <- read_table("formats_runs.csv", fmt_cols)

sha256 <- digest::digest(file = page_path, algo = "sha256")
if (sha256 %in% releases$sha256) {
  message("This page is already stored as ", releases$snapshot[releases$sha256 == sha256], "; nothing changed.")
  quit(save = "no", status = 0)
}

page <- .srtr_parse_dictionary_page(page_path)
if (nrow(page$problems) > 0) {
  message("Problems found on the page (stored as is):")
  print(as.data.frame(page$problems))
}
dict_order <- order(page$dictionary$Dataset, page$dictionary$Variable, method = "radix")
unsorted <- !identical(dict_order, seq_len(nrow(page$dictionary)))
if (unsorted) {
  message(
    "This page does not list variables in sorted order; the dictionary views ",
    "built from the stored runs will be sorted, so check data-raw/dictionary_file_creator.R."
  )
}
page$formats <- page$formats |>
  dplyr::mutate(Position = as.character(dplyr::row_number()), .by = "Format")

revision <- sum(releases$release == page$release) + 1L
id <- paste0(page$release, "-", revision)
stored <- releases$snapshot

if (length(stored) == 0) {
  dict_runs <- .srtr_runs_build(stats::setNames(list(page$dictionary), id), dict_key)
  fmt_runs <- .srtr_runs_build(stats::setNames(list(page$formats), id), fmt_key)
} else {
  dict_runs <- .srtr_runs_add(dict_runs, stored, page$dictionary, id, dict_key)$runs
  fmt_runs <- .srtr_runs_add(fmt_runs, stored, page$formats, id, fmt_key)$runs
}

releases <- dplyr::bind_rows(
  releases,
  tibble::tibble(
    snapshot = id,
    release = page$release,
    revision = as.character(revision),
    title = page$title,
    sha256 = sha256,
    encoding = page$encoding,
    last_modified = last_modified,
    retrieved = retrieved,
    source = source_url
  )
)
releases <- releases[match(.srtr_sort_snapshots(releases$snapshot), releases$snapshot), ]

gz <- gzfile(file.path(dir, "pages", paste0(id, ".html.gz")), "wb")
writeBin(readBin(page_path, "raw", file.size(page_path)), gz)
close(gz)

write_table(releases, "releases.csv")
write_table(dict_runs, "dictionary_runs.csv")
write_table(fmt_runs, "formats_runs.csv")
message("Added ", id, " (", page$title, ").")
