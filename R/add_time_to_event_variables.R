#' Build time-to-event variables for SRTR-style data
#'
#' Creates three columns for an outcome defined by an event date and a censor date:
#' - {prefix}_CENSOR: event date if present, otherwise censor date
#' - {prefix}_BINARY: 1 if event date present, else 0
#' - {prefix}_{unit}: numeric time from start_date to {prefix}_CENSOR in chosen units
#'
#' @param df A data frame.
#' @param event_date Event date column (unquoted).
#' @param start_date Start date column (unquoted), e.g., `REC_TX_DT`.
#' @param censor_date Censor/last-follow-up date column (unquoted), e.g., `TFL_LAFUDATEPA`.
#' @param prefix String used for new columns (e.g., "REC_DEATH").
#' @param units One of "years", "months", or "days". Default "years".
#' @param add_epsilon Numeric days to add to time (to avoid zero-time issues).
#'   Default 1. Set to 0 to disable. Logical TRUE/FALSE also accepted
#'   (treated as 1/0) for backward compatibility.
#' @param warn_negative Warn and set to NA if computed time is negative. Default TRUE.
#'
#' @return `df` with added columns:
#'   `{prefix}_CENSOR`, `{prefix}_BINARY`, `{prefix}_{units-suffix}`, `{prefix}_NEGATIVE_TIME`.
#'
#' @details
#' Units suffix mapping: `years -> "_yrs"`, `months -> "_months"`, `days -> "_days"`.
#' Negative times (e.g., when `start_date > censor/event`) are flagged in `{prefix}_NEGATIVE_TIME`,
#' and the numeric time is set to `NA`.#'
#' @importFrom dplyr mutate if_else
#' @importFrom rlang enquo .data
#' @export
srtr_time_to_event <- function(
    df,
    event_date,
    start_date,
    censor_date,
    prefix,
    units = c("years", "months", "days"),
    add_epsilon = 1,
    warn_negative = TRUE
) {
  units <- match.arg(units)
  event_q  <- rlang::enquo(event_date)
  start_q  <- rlang::enquo(start_date)
  censor_q <- rlang::enquo(censor_date)

  # Output names
  censor_col <- paste0(prefix, "_CENSOR")
  status_col <- paste0(prefix, "_BINARY")
  time_suffix <- switch(units,
                        "years"  = "yrs",
                        "months" = "months",
                        "days"   = "days")
  time_col  <- paste0(prefix, "_", time_suffix)
  neg_col   <- paste0(prefix, "_NEGATIVE_TIME")

  # Unit conversion
  denom_days <- switch(units,
                       "years"  = 365.25,
                       "months" = 30.4375,
                       "days"   = 1)

  out <- df %>%
    dplyr::mutate(
      !!censor_col := dplyr::if_else(is.na(!!event_q), !!censor_q, !!event_q),
      !!status_col := dplyr::if_else(is.na(!!event_q), 0L, 1L)
    )

  # Compute days
  time_days <- as.numeric(difftime(out[[censor_col]],
                                   rlang::eval_tidy(start_q, out),
                                   units = "days"))

  # Back-compat: accept logical for add_epsilon
  eps_days <- if (is.logical(add_epsilon)) {
    if (isTRUE(add_epsilon)) 1 else 0
  } else {
    as.numeric(add_epsilon)
  }
  if (!is.finite(eps_days) || is.na(eps_days)) eps_days <- 0
  if (eps_days != 0) time_days <- time_days + eps_days

  # Negative times
  neg <- is.finite(time_days) & (time_days < 0)
  if (isTRUE(warn_negative) && any(neg, na.rm = TRUE)) {
    warning(sprintf("%d rows had negative %s times; setting to NA.", sum(neg, na.rm = TRUE), prefix))
  }
  time_days[neg] <- NA_real_

  out[[neg_col]]  <- neg
  out[[time_col]] <- time_days / denom_days

  out
}
