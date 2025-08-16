#' Parse SRTR YYYYMMDD-style dates to Date
#' @param x Vector: Date, POSIXt, numeric/integer, character, or factor.
#' @param invalid_codes Values to treat as missing.
#' @param quiet If FALSE, warn about unparsable values.
#' @return Date vector
#' @keywords internal
#' @noRd
.srtr_as_date <- function(
    x,
    invalid_codes = c("", "0", "00000000", "99999999", "NA", "N/A"),
    quiet = TRUE
) {
  if (inherits(x, "Date"))   return(x)
  if (inherits(x, "POSIXt")) return(as.Date(x))
  if (is.factor(x))          x <- as.character(x)

  # Numeric/integer like 20240131
  if (is.numeric(x)) {
    nx  <- suppressWarnings(as.integer(x))
    out <- rep(NA_Date_, length(nx))
    ok  <- !is.na(nx) & !(nx %in% c(0L, 99999999L))
    if (any(ok)) {
      s <- sprintf("%08d", nx[ok])
      iso <- paste0(substr(s,1,4), "-", substr(s,5,6), "-", substr(s,7,8))
      out[ok] <- as.Date(iso)
    }
    return(out)
  }

  # Character
  if (is.character(x)) {
    s <- trimws(x)
    s[s %in% invalid_codes] <- NA_character_

    # Strip non-digits to catch "YYYY-MM-DD" or "YYYY/MM/DD"
    d <- gsub("[^0-9]", "", s)
    out <- rep(NA_Date_, length(s))

    eight <- which(!is.na(d) & nchar(d) == 8L)
    if (length(eight)) {
      iso <- paste0(substr(d[eight],1,4), "-", substr(d[eight],5,6), "-", substr(d[eight],7,8))
      out[eight] <- as.Date(iso)
    }

    # Fallback: let as.Date try (e.g., already "YYYY-MM-DD")
    left <- which(is.na(out) & !is.na(s))
    if (length(left)) suppressWarnings(out[left] <- as.Date(s[left]))

    if (!quiet) {
      n_bad <- sum(!is.na(s) & is.na(out))
      if (n_bad > 0) warning(sprintf(".srtr_as_date: %d values could not be parsed; set to NA", n_bad))
    }
    return(out)
  }

  suppressWarnings(as.Date(x))
}

