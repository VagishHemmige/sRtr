#' SRTR Variable Dictionary
#'
#' A lookup table of variable metadata extracted from the Scientific Registry of Transplant Recipients (SRTR) data dictionary.
#' This dataset describes the variable name, type, length, label, and associated format for each variable in each dataset.
#'
#' @format A data frame with 6 columns:
#' \describe{
#'   \item{Dataset}{The abbreviated SRTR dataset name (e.g., \code{kp_diab}, \code{txfu})}
#'   \item{Variable}{The name of the variable as it appears in the data}
#'   \item{Type}{The storage type (e.g., \code{character}, \code{numeric})}
#'   \item{Length}{The declared length or field width}
#'   \item{FormatID}{The format group name (used to match with \code{formats} for coded values)}
#'   \item{Label}{The descriptive label for the variable}
#' }
#'
#' @source Extracted from SRTR data dictionary HTML snapshot (\code{data-raw/dataDictionary.html}).
"dictionary"
