## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 10,
  fig.height = 8
)

## ----setup, eval=FALSE--------------------------------------------------------
# library(sRtr)
# library(dplyr)

## ----basic_example, eval=FALSE------------------------------------------------
# TX_KI %>%
#   strobe_initialize(inclusion_label = "All kidney transplants") %>%
#   strobe_filter(
#     condition = "DON_AGE > 18",
#     inclusion_label = "Donor over 18 years old",
#     exclusion_reason = "Excluded: Donor age ≤ 18"
#   ) %>%
#   strobe_filter(
#     condition = "DON_ABO == 'B'",
#     inclusion_label = "Donor blood type B",
#     exclusion_reason = "Excluded: Donor blood type is not B"
#   ) %>%
#   strobe_filter(
#     condition = "REC_AGE >= 18 & REC_AGE <= 65",
#     inclusion_label = "Recipient age 18-65",
#     exclusion_reason = "Excluded: Recipient age outside 18-65 range"
#   )

## ----review_log, eval=FALSE---------------------------------------------------
# # View the complete filtering log
# get_strobe_log()

## ----basic_diagram, eval=FALSE------------------------------------------------
# plot_strobe_diagram()

## ----custom_dimensions, eval=FALSE--------------------------------------------
# plot_strobe_diagram(
#   incl_width_min = 3,
#   incl_height = 1,
#   excl_width_min = 2.5,
#   excl_height = 1,
#   lock_width_min = TRUE,
#   lock_height = TRUE
# )
# 
# plot_strobe_diagram(
#   incl_width_min = 3,
#   excl_width_min = 2.5,
#   incl_fontsize = 16,
#   excl_fontsize = 14,
#   lock_width_min = TRUE
# )

## ----custom_fonts, eval=FALSE-------------------------------------------------
# plot_strobe_diagram(
#   incl_fontsize = 16,
#   excl_fontsize = 14
# )

## ----publication_ready, eval=FALSE--------------------------------------------
# plot_strobe_diagram(
#   incl_width_min = 4,
#   excl_width_min = 3,
#   incl_height = 1.2,
#   excl_height = 1,
#   incl_fontsize = 12,
#   excl_fontsize = 10,
#   lock_width_min = TRUE,
#   lock_height = TRUE
# )

## ----export_diagrams, eval=FALSE----------------------------------------------
# plot_strobe_diagram(
#   export_file = "strobe_diagram.png",
#   incl_width_min = 4,
#   excl_width_min = 3,
#   incl_fontsize = 14,
#   excl_fontsize = 12
# )
# 
# plot_strobe_diagram(
#   export_file = "strobe_diagram.svg",
#   incl_width_min = 4,
#   excl_width_min = 3,
#   incl_fontsize = 14,
#   excl_fontsize = 12
# )

## ----complex_example, eval=FALSE----------------------------------------------
# TX_KI %>%
#   strobe_initialize(inclusion_label = "All kidney transplants\n(N=XXX)") %>%
#   strobe_filter(
#     condition = "DON_AGE >= 18 & DON_AGE <= 70",
#     inclusion_label = "Donor age 18-70 years",
#     exclusion_reason = "Excluded: Donor age\noutside 18-70 range"
#   ) %>%
#   strobe_filter(
#     condition = "REC_AGE >= 18",
#     inclusion_label = "Adult recipients\n(≥18 years)",
#     exclusion_reason = "Excluded: Pediatric\nrecipients"
#   ) %>%
#   strobe_filter(
#     condition = "TX_TYPE == 'KIDNEY'",
#     inclusion_label = "Kidney-only transplants",
#     exclusion_reason = "Excluded: Multi-organ\ntransplants"
#   ) %>%
#   strobe_filter(
#     condition = "!is.na(GRAFT_STAT) & !is.na(GRAFT_FAIL_DATE)",
#     inclusion_label = "Complete graft\noutcome data",
#     exclusion_reason = "Excluded: Missing graft\noutcome data"
#   ) %>%
#   strobe_filter(
#     condition = "GRAFT_FAIL_DATE >= 365 | is.na(GRAFT_FAIL_DATE)",
#     inclusion_label = "≥1 year follow-up\nor event",
#     exclusion_reason = "Excluded: <1 year\nfollow-up without event"
#   )

## ----presentation_diagram, eval=FALSE-----------------------------------------
# plot_strobe_diagram(
#   incl_width_min = 5,
#   excl_width_min = 4,
#   incl_height = 1.5,
#   excl_height = 1.2,
#   incl_fontsize = 18,
#   excl_fontsize = 16,
#   lock_width_min = TRUE,
#   lock_height = TRUE
# )

## ----sizing_issues, eval=FALSE------------------------------------------------
# plot_strobe_diagram(
#   incl_width_min = 4,
#   excl_width_min = 3,
#   lock_width_min = TRUE
# )
# 
# plot_strobe_diagram(
#   incl_height = 1.5,
#   excl_height = 1.2,
#   lock_height = TRUE
# )

