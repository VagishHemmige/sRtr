## code to prepare `dictionary` dataset goes here

# Built from the stored dictionary versions in data-raw/dictionary-versions/
# (#26), parsed from saved copies of the SRTR SAF data dictionary page by
# sRtr:::.srtr_parse_dictionary_page(). Add a new page with
# data-raw/dictionary_versions_add.R first.

# The release the bundled `dictionary` describes. It stays 2203 until a newer
# release has been checked against real SAFs.
snapshot <- "2203-1"

source("data-raw/dictionary_versions_view.R")
dictionary <- dictionary_view(snapshot)

# Save as internal package data
usethis::use_data(dictionary, overwrite = TRUE)
