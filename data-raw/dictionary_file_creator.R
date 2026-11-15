## code to prepare `dictionary` dataset goes here

library(rvest)
library(dplyr)
library(purrr)
library(stringr)

# Load saved HTML snapshot of SRTR SAF Data Dictionary
html <- read_html("data-raw/dataDictionary.html")

# Extract variable tables per dataset
dictionary <- html %>%
  html_elements("div[id^='data_']") %>%
  map_df(function(div) {
    ds <- div %>% html_attr("id") %>% str_replace("^data_[^_]+_", "")
    # The section id can be cut short (MPEXCEPT_ORIG_TUMO for the
    # MPEXCEPT_ORIG_TUMORS file), so use the "Data File:" name when there is one.
    data_file <- div %>% html_text() %>%
      str_match("Data File:\\s*([A-Za-z0-9_]+)") %>% .[, 2]
    if (!is.na(data_file)) ds <- data_file
    div %>% html_elements("table.dataTable tr") %>% .[-1] %>%
      map_df(~{
        cells <- .x %>% html_elements("td")
        tibble(
          Dataset = ds,
          Variable = html_text(cells[1], trim = TRUE),
          Type     = html_text(cells[2], trim = TRUE),
          Length   = html_text(cells[3], trim = TRUE),
          FormatID = html_text(cells[4], trim = TRUE),
          Label    = html_text(cells[5], trim = TRUE)
        )
      })
  })

dictionary <- dictionary %>%
  mutate(FormatID = str_remove(FormatID, "^\\$"))

# Save as internal package data
usethis::use_data(dictionary, overwrite = TRUE)
