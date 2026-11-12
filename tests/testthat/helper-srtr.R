# Tests that read real SRTR SAF files run only when both are set:
#   SRTR_LIVE_TESTS=true
#   SRTR_WD=<folder with the SAF files>
# Everywhere else (CI, CRAN, a machine without the data) they skip.
skip_if_no_srtr_data <- function() {
  live <- identical(Sys.getenv("SRTR_LIVE_TESTS"), "true")
  has_wd <- nzchar(Sys.getenv("SRTR_WD"))
  testthat::skip_if_not(
    live && has_wd,
    "Live SRTR tests need SRTR_LIVE_TESTS=true and SRTR_WD"
  )
}
