#' SRTR Format Lookup Table
#'
#' Lookup table used to convert coded values in SRTR datasets to human-readable factor labels.
#'
#' @format A data frame with 3 columns:
#' \describe{
#'   \item{Format}{The name of the format group (e.g., ABO, CMV)}
#'   \item{Code}{The coded value (as a string or numeric)}
#'   \item{Meaning}{The human-readable label for that code}
#' }
#'
#' @source Derived from official SRTR format tables
"formats"
