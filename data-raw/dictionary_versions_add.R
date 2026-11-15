# Add one saved copy of the SRTR SAF data dictionary page to the stored
# versions in data-raw/dictionary-versions/ (#26).
#
# Run from the repository root:
#
#   Rscript data-raw/dictionary_versions_add.R <page.html> [source] [last_modified] [retrieved] [report.md]
#
# * page.html: the page exactly as downloaded.
# * source: where it came from (default: the live SRTR address).
# * last_modified: the server's Last-Modified time, if known (ISO 8601, UTC).
# * retrieved: when it was downloaded (ISO 8601, UTC; default: now).
# * report.md: if given and the page was added, a Markdown summary of what
#   changed since the previous stored snapshot is written there (used for the
#   monthly pull request), and the new snapshot id to report.md.snapshot.
#
# The work is done by sRtr:::.srtr_versions_add_page(): the release comes
# from the page title; a page whose hash is already stored changes nothing; a
# new hash for a stored release is added as its next revision ("2609-2"); a
# page that was not read completely is refused. It writes only inside
# data-raw/dictionary-versions/. The regenerate-data workflow rebuilds data/
# on the pull request (.github/workflows/regenerate-data.yaml).

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
  stop("Usage: Rscript data-raw/dictionary_versions_add.R <page.html> [source] [last_modified] [retrieved]")
}
page_path <- args[[1]]
source_url <- if (length(args) >= 2) args[[2]] else "https://www.srtr.org/docs/datadictionary.html"
last_modified <- if (length(args) >= 3) args[[3]] else ""
retrieved <- if (length(args) >= 4 && nzchar(args[[4]])) args[[4]] else format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
report_path <- if (length(args) >= 5) args[[5]] else ""

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
  if (nzchar(report_path)) {
    versions <- .srtr_versions_read("data-raw/dictionary-versions")
    order <- versions$releases$snapshot
    previous <- order[match(result$snapshot, order) - 1]
    report <- if (length(previous) == 0 || is.na(previous)) {
      "This is the first stored snapshot."
    } else {
      .srtr_versions_report(versions, previous, result$snapshot, result$problems)
    }
    writeLines(report, report_path, useBytes = TRUE)
    writeLines(result$snapshot, paste0(report_path, ".snapshot"))
  }
}
