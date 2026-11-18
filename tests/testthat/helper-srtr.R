# Tests that read real SRTR SAF files run only when both are set:
#   SRTR_LIVE_TESTS=true
#   SRTR_WD=<folder with the SAF files>
# Everywhere else (CI, CRAN, a machine without the data) they skip.
# Optionally, SRTR_RELEASE=<release such as 2303> names the release of the
# files when the folder name does not (see load_live()).
skip_if_no_srtr_data <- function() {
  live <- identical(Sys.getenv("SRTR_LIVE_TESTS"), "true")
  has_wd <- nzchar(Sys.getenv("SRTR_WD"))
  testthat::skip_if_not(
    live && has_wd,
    "Live SRTR tests need SRTR_LIVE_TESTS=true and SRTR_WD"
  )
}

# The file keys in SRTR_WD, in upper case.
srtr_live_file_keys <- function() {
  unique(toupper(.srtr_file_list(refresh = TRUE)$file_root))
}

# Like skip_if_no_srtr_data(), and also skips unless SRTR_WD has a file for
# every one of `file_keys`, so a machine with only some SAFs runs the live
# tests it can.
skip_if_no_srtr_file <- function(file_keys) {
  skip_if_no_srtr_data()
  missing <- setdiff(toupper(file_keys), srtr_live_file_keys())
  testthat::skip_if(
    length(missing) > 0,
    paste("No file in SRTR_WD for", paste(missing, collapse = ", "))
  )
}

# The ones of `file_keys` that SRTR_WD has a file for; skips when it has
# none of them.
srtr_live_keys_present <- function(file_keys) {
  skip_if_no_srtr_data()
  present <- intersect(toupper(file_keys), srtr_live_file_keys())
  testthat::skip_if(
    length(present) == 0,
    paste("No file in SRTR_WD for any of", paste(file_keys, collapse = ", "))
  )
  present
}

# The release from SRTR_RELEASE, or NULL so load_srtr_file() falls back to
# set_srtr_wd() or the folder name.
srtr_live_release <- function() {
  release <- Sys.getenv("SRTR_RELEASE")
  if (nzchar(release)) release else NULL
}

# load_srtr_file() for a live test: uses SRTR_RELEASE, and muffles the
# warnings about codes the dictionary does not list (tracked in #191), so a
# live run shows only warnings that are new.
load_live <- function(file_key, ...) {
  withCallingHandlers(
    load_srtr_file(file_key, release = srtr_live_release(), ...),
    sRtr_warning_unknown_codes = function(cnd) {
      rlang::cnd_muffle(cnd)
    }
  )
}

# Prints sizing counts from a live test, masked so they can be shared: any
# count from 1 to 10 shows as "<11". Use it only for counts that cannot be
# subtracted from one another, or from a printed total, to recover a masked
# count.
live_counts <- function(title, counts) {
  shown <- ifelse(
    counts > 0 & counts < 11,
    "<11",
    format(counts, big.mark = ",", trim = TRUE)
  )
  message(
    "\n[live] ", title, "\n",
    paste0("  ", names(counts), ": ", shown, collapse = "\n")
  )
}
