## code to prepare `formats` dataset goes here

# Built from the stored dictionary versions in data-raw/dictionary-versions/
# (#26); see dictionary_file_creator.R. Codes keep their order on the page.

# The release the bundled `formats` describes. It stays 2203 until a newer
# release has been checked against real SAFs.
snapshot <- "2203-1"

source("data-raw/dictionary_versions_view.R")
formats <- formats_view(snapshot)

# Save to package
usethis::use_data(formats, overwrite = TRUE)
