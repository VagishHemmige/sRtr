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

# Save as internal package data
usethis::use_data(dictionary, overwrite = TRUE)
