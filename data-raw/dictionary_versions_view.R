# Rebuild the dictionary or formats table of one stored snapshot from the runs
# in data-raw/dictionary-versions/ (#26). Sourced by dictionary_file_creator.R
# and formats_file_creator.R; writes nothing.

pkgload::load_all(".", quiet = TRUE, export_all = TRUE)

dictionary_versions <- .srtr_versions_read("data-raw/dictionary-versions")
dictionary_view <- function(snapshot) {
  .srtr_versions_view(dictionary_versions, snapshot, "dictionary")
}
formats_view <- function(snapshot) {
  .srtr_versions_view(dictionary_versions, snapshot, "formats")
}
