## code to prepare `formats` dataset goes here

library(rvest)
library(dplyr)
library(purrr)
library(stringr)

# Load saved HTML snapshot of SRTR SAF Data Dictionary
html <- read_html("data-raw/dataDictionary.html")

# Extract format tables (e.g., ABO, CIT, etc.)
formats <- html %>%
  html_elements("div[id^='fmt_']") %>%
  map_df(function(div) {
    fmt <- div %>% html_attr("id") %>% str_remove("^fmt_")
    div %>% html_elements("table.dataTable tr") %>% .[-1] %>%
      map_df(~{
        cells <- .x %>% html_elements("td")
        tibble(
          Format = fmt,
          Code   = html_text(cells[1], trim = TRUE),
          Meaning= html_text(cells[2], trim = TRUE)
        )
      })
  })


# Save to package
usethis::use_data(formats, overwrite = TRUE)
