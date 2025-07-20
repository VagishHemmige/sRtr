## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)

## ----installation-------------------------------------------------------------
# # install.packages("devtools")
# devtools::install_github("VagishHemmige/sRtr")

## ----setup--------------------------------------------------------------------
# library(sRtr)
# library(dplyr)
# library(labelled)

## ----temp_setup---------------------------------------------------------------
# # Point to your SRTR data directory for this session only
# set_srtr_wd("path/to/your/srtr/files")

## ----permanent_setup----------------------------------------------------------
# # Set the directory permanently across R sessions
# set_srtr_wd("path/to/your/srtr/files", permanent = TRUE)

## ----basic_loading------------------------------------------------------------
# # Load a transplant file (liver transplants)
# tx_li <- load_srtr_file("TX_LI")
# 
# # Load a waiting list file (kidney candidates)
# cand_kida <- load_srtr_file("CAND_KIDA")
# 
# # Load a donor file
# donor <- load_srtr_file("DONOR")

## ----var_labels---------------------------------------------------------------
# # Load with variable labels
# tx_li <- load_srtr_file("TX_LI", var_labels = TRUE)
# 
# # View variable labels
# var_label(tx_li$DON_RACE)
# var_label(tx_li$REC_AGE_AT_TX)
# var_label(tx_li$GRAFT_STAT)

## ----factor_labels------------------------------------------------------------
# # Load with factor labels
# tx_li <- load_srtr_file("TX_LI", factor_labels = TRUE)
# 
# # View factor levels
# str(tx_li$DON_RACE)
# levels(tx_li$DON_RACE)
# 
# # View factor labels for transplant status
# str(tx_li$GRAFT_STAT)

## ----complete_labels----------------------------------------------------------
# # Load with both variable and factor labels
# tx_li <- load_srtr_file("TX_LI", var_labels = TRUE, factor_labels = TRUE)
# 
# # Now you have both descriptive variable names and meaningful factor levels
# str(tx_li$DON_RACE)
# var_label(tx_li$DON_RACE)

## ----explore_data-------------------------------------------------------------
# # Basic data exploration
# dim(tx_li)
# names(tx_li)
# 
# # View the first few rows
# head(tx_li)
# 
# # Summary statistics with meaningful labels
# summary(tx_li$DON_RACE)
# summary(tx_li$REC_AGE_AT_TX)

## ----preserve_labels----------------------------------------------------------
# # Filter data while preserving labels
# recent_tx <- tx_li %>%
#   filter(TX_DATE >= as.Date("2020-01-01")) %>%
#   select(TX_DATE, DON_RACE, REC_AGE_AT_TX, GRAFT_STAT)
# 
# # Labels are preserved
# var_label(recent_tx$DON_RACE)

## ----apply_factors------------------------------------------------------------
# # Load raw data
# df <- read_sas("TX_KI.sas7bdat")
# 
# # Apply factor labels
# df <- apply_srtr_factors(df, filekey = "TX_KI")
# 
# # View the result
# str(df$DON_RACE)

## ----apply_varlabels----------------------------------------------------------
# # Apply variable labels
# df <- apply_srtr_varlabels(df, filekey = "TX_KI")
# 
# # View variable labels
# var_label(df$DON_RACE)
# var_label(df$REC_AGE_AT_TX)

## ----auto_detect--------------------------------------------------------------
# # Load data with matching name
# TX_KI <- read_sas("TX_KI.sas7bdat")
# 
# # Apply labels without specifying filekey
# TX_KI <- TX_KI %>%
#   apply_srtr_factors() %>%
#   apply_srtr_varlabels()

## ----eval=FALSE---------------------------------------------------------------
# tx_li <- load_srtr_file("TX_LI", var_labels = TRUE, factor_labels = TRUE)
# 
# # Replace common SRTR missing codes (e.g., "U", "", "ND") with NA
# tx_li <- srtr_normalize_missing(tx_li)
# 
# # Replace missing codes and NAs with an explicit label
# tx_li <- srtr_normalize_missing(tx_li, replacement = "Missing")

## ----eval=FALSE---------------------------------------------------------------
# 
# # Load the data
# tx_li <- load_srtr_file("TX_LI", var_labels = TRUE, factor_labels = TRUE)
# 
# # Define custom missing codes for specific variables
# custom_missing_vals <- list(
#   REC_HIV_STAT = c("U", ""),              # "Unknown" or blank
#   REC_HCV_STAT = c("ND: Not Done", "U"),  # Custom-labeled values
#   REC_CMVD = c(-1, 999),                  # Numeric codes
#   DON_RACE = c("99", "Unknown")           # Other arbitrary codes
# )
# 
# # Apply normalization, replacing with NA
# tx_li_clean <- srtr_normalize_missing(tx_li, missing_vals = custom_missing_vals)
# 
# # Or, replace all with an explicit label
# tx_li_labeled <- srtr_normalize_missing(tx_li, missing_vals = custom_missing_vals, replacement = "Missing")
# 

## ----file_examples------------------------------------------------------------
# # Examples of loading different file types
# liver_tx <- load_srtr_file("TX_LI", var_labels = TRUE, factor_labels = TRUE)
# kidney_cand <- load_srtr_file("CAND_KIDA", var_labels = TRUE, factor_labels = TRUE)
# donors <- load_srtr_file("DONOR", var_labels = TRUE, factor_labels = TRUE)

## ----best_practice_labels-----------------------------------------------------
# # Recommended approach
# data <- load_srtr_file("TX_LI", var_labels = TRUE, factor_labels = TRUE)

## ----best_practice_check------------------------------------------------------
# # Check dimensions
# dim(data)
# 
# # Check variable labels
# var_label(data[1:5])
# 
# # Check factor levels for key variables
# str(data$DON_RACE)
# str(data$GRAFT_STAT)

## ----best_practice_document---------------------------------------------------
# # Good practice: document your data sources
# # TX_LI file loaded from SRTR SAF 2024Q1
# # Contains liver transplant data from 1987-2023
# tx_li <- load_srtr_file("TX_LI", var_labels = TRUE, factor_labels = TRUE)

