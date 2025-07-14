## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 10,
  fig.height = 8
)

## ----eval=FALSE---------------------------------------------------------------
# # Install devtools if needed
# install.packages("devtools")
# 
# # Install sRtr (and strobe, a suggested package)
# devtools::install_github("VagishHemmige/sRtr", dependencies = TRUE)

## ----setup, eval=FALSE--------------------------------------------------------
# library(sRtr)
# library(dplyr)
# library(strobe)

## ----basic_example, eval=FALSE------------------------------------------------
# TX_KI %>%
#   strobe::strobe_initialize(inclusion_label = "All kidney transplants") %>%
#   strobe::strobe_filter(
#     condition = "DON_AGE > 18",
#     inclusion_label = "Donor over 18 years old",
#     exclusion_reason = "Excluded: Donor age ≤ 18"
#   ) %>%
#   strobe::strobe_filter(
#     condition = "DON_ABO == 'B'",
#     inclusion_label = "Donor blood type B",
#     exclusion_reason = "Excluded: Donor blood type is not B"
#   ) %>%
#   strobe::strobe_filter(
#     condition = "REC_AGE >= 18 & REC_AGE <= 65",
#     inclusion_label = "Recipient age 18-65",
#     exclusion_reason = "Excluded: Recipient age outside 18-65 range"
#   )

## ----review_log, eval=FALSE---------------------------------------------------
# # View the complete filtering log
# strobe::get_strobe_log()

## ----custom_dimensions, eval=FALSE--------------------------------------------
# strobe::plot_strobe_diagram(
#   incl_width_min = 3,
#   incl_height = 1,
#   excl_width_min = 2.5,
#   excl_height = 1,
#   lock_width_min = TRUE,
#   lock_height = TRUE,
#   incl_fontsize = 16,
#   excl_fontsize = 14
# 
# )
# 

