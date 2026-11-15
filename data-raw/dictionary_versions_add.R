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
# The work is done by sRtr:::.srtr_versions_add_page(): the release comes
# from the page title; a page whose hash is already stored changes nothing; a
# new hash for a stored release is added as its next revision ("2609-2"); a
# page that was not read completely is refused. It writes only inside
# data-raw/dictionary-versions/. The maintainer regenerates data/ separately.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
  stop("Usage: Rscript data-raw/dictionary_versions_add.R <page.html> [source] [last_modified] [retrieved]")
}
page_path <- args[[1]]
source_url <- if (length(args) >= 2) args[[2]] else "https://www.srtr.org/docs/datadictionary.html"
last_modified <- if (length(args) >= 3) args[[3]] else ""
retrieved <- if (length(args) >= 4) args[[4]] else format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")

pkgload::load_all(".", quiet = TRUE, export_all = TRUE)

result <- .srtr_versions_add_page(
  "data-raw/dictionary-versions",
  page_path,
  source = source_url,
  last_modified = last_modified,
  retrieved = retrieved
)

if (result$status == "unchanged") {
  message("This page is already stored as ", result$snapshot, "; nothing changed.")
} else {
  message("Added ", result$snapshot, ".")
  if (nrow(result$problems) > 0) {
    message("Problems found on the page (stored as is):")
    print(as.data.frame(result$problems))
  }
}
