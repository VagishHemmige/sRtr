## code to prepare `dictionary_versions` dataset goes here

# The stored dictionary versions (data-raw/dictionary-versions/, #26) as one
# dataset, read by srtr_dictionary() and load_srtr_file(). Built on GitHub by
# the regenerate-data workflow.

pkgload::load_all(".", quiet = TRUE, export_all = TRUE)

dictionary_versions <- .srtr_versions_read("data-raw/dictionary-versions")

usethis::use_data(dictionary_versions, overwrite = TRUE)
