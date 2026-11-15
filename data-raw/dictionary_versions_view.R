# Rebuild the dictionary or formats table of one stored snapshot from the runs
# in data-raw/dictionary-versions/ (#26). Sourced by dictionary_file_creator.R
# and formats_file_creator.R; writes nothing.

pkgload::load_all(".", quiet = TRUE, export_all = TRUE)

read_dictionary_version_table <- function(file) {
  tibble::as_tibble(utils::read.csv(
    file.path("data-raw/dictionary-versions", file),
    colClasses = "character",
    na.strings = character(),
    check.names = FALSE,
    encoding = "UTF-8"
  ))
}

dictionary_view <- function(snapshot) {
  releases <- read_dictionary_version_table("releases.csv")
  runs <- read_dictionary_version_table("dictionary_runs.csv")
  view <- .srtr_runs_at(runs, releases$snapshot, snapshot)
  view[order(view$Dataset, view$Variable, method = "radix"), ]
}

formats_view <- function(snapshot) {
  releases <- read_dictionary_version_table("releases.csv")
  runs <- read_dictionary_version_table("formats_runs.csv")
  view <- .srtr_runs_at(runs, releases$snapshot, snapshot)
  view <- view[order(view$Format, as.integer(view$Position), method = "radix"), ]
  view[setdiff(names(view), "Position")]
}
