#' Helper function to add a time-to-event outcome from a date function
#'
#' Creates three columns for an outcome defined by an event date and a censor date:
#' - `{prefix}_CENSOR`: event date if present, otherwise censor date
#' - `{prefix}_BINARY`: 1 if event date present, else 0
#' - `{prefix}_{unit}`: numeric time from start_date to `{prefix}_CENSOR` in chosen units
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
#'   `{prefix}_CENSOR`, `{prefix}_BINARY`, `{prefix}_{units-suffix}`.
#'
#' @details
#' Units suffix mapping: `years -> "_yrs"`, `months -> "_months"`, `days -> "_days"`.
#' Negative times (e.g., when `start_date > censor/event`) trigger a warning,
#' and the numeric time is set to `NA`.#'
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
  event_q <- rlang::enquo(event_date)
  start_q <- rlang::enquo(start_date)
  censor_q <- rlang::enquo(censor_date)

  # Output names
  censor_col <- paste0(prefix, "_CENSOR")
  status_col <- paste0(prefix, "_BINARY")
  time_suffix <- switch(
    units,
    "years" = "yrs",
    "months" = "months",
    "days" = "days"
  )
  time_col <- paste0(prefix, "_", time_suffix)

  # Unit conversion
  denom_days <- switch(units, "years" = 365.25, "months" = 30.4375, "days" = 1)

  out <- df |>
    dplyr::mutate(
      !!censor_col := dplyr::if_else(is.na(!!event_q), !!censor_q, !!event_q),
      !!status_col := dplyr::if_else(is.na(!!event_q), 0L, 1L)
    )

  # Compute days
  time_days <- as.numeric(difftime(
    out[[censor_col]],
    rlang::eval_tidy(start_q, out),
    units = "days"
  ))

  # Back-compat: accept logical for add_epsilon
  eps_days <- if (is.logical(add_epsilon)) {
    if (isTRUE(add_epsilon)) 1 else 0
  } else {
    as.numeric(add_epsilon)
  }
  if (!is.finite(eps_days) || is.na(eps_days)) {
    eps_days <- 0
  }
  if (eps_days != 0) {
    time_days <- time_days + eps_days
  }

  # Negative times
  neg <- is.finite(time_days) & (time_days < 0)
  if (isTRUE(warn_negative) && any(neg, na.rm = TRUE)) {
    n_neg <- sum(neg, na.rm = TRUE)
    srtr_warn(
      "{n_neg} row{?s} had a negative {.field {prefix}} time; set to {.val {NA}}.",
      class = "negative_time"
    )
  }
  time_days[neg] <- NA_real_

  out[[time_col]] <- time_days / denom_days

  out
}


#' Add time-to-event follow-up outcomes to a transplant cohort
#'
#' Uses the cohort's `file_key` attribute (as set by [load_srtr_file()]) to
#' load the matching follow-up file (`TX_KI` to `TXF_KI`, and so on), limited
#' to the cohort's `TRR_ID`s and to the columns used here, and adds what the
#' follow-up forms say about malignancy and acute rejection.
#'
#' @param df A transplant data frame from [load_srtr_file()], with a `TRR_ID`
#'   column and a `file_key` attribute.
#'
#' @return `df` with these columns added. For `TX_KP`, each rejection column
#'   comes once per graft, with the suffix `_KI` or `_PA`
#'   (`FIRST_FU_REJ_DATE_KI`, `FIRST_FU_REJ_STATUS_PA`, ...); malignancy is
#'   patient-level and uses the forms for both grafts.
#'   \describe{
#'     \item{`FIRST_FU_MALIG_DATE`}{Date of the first form reporting a
#'       malignancy (`TFL_MALIG` `"Y"`).}
#'     \item{`FIRST_FU_MALIG_STATUS`}{What the forms say: `"event"` (at least
#'       one form reports a malignancy), `"no event"` (none does, and at least
#'       one says `"N"`), `"unknown"` (forms exist, but none says `"Y"` or
#'       `"N"`), or `"no follow-up"` (no form).}
#'     \item{`FIRST_FU_MALIG_LAST_NEG_DATE`}{Date of the last form saying
#'       `"N"`, strictly before `FIRST_FU_MALIG_DATE`; with no report, the
#'       last such form at all.}
#'     \item{`FIRST_FU_REJ_DATE`}{Date of the first form reporting a treated
#'       acute rejection (`TFL_ACUTE_REJ_EPISODE` code 1 of format `ACREJEPF`,
#'       raw or labelled).}
#'     \item{`FIRST_FU_REJ_STATUS`}{`"event"` (a treated rejection),
#'       `"untreated"` (no treated rejection, but at least one untreated,
#'       code 2), `"no event"` (at least one form says no rejection, code 3),
#'       `"unknown"` (only code 998 or no answer), or `"no follow-up"`.}
#'     \item{`FIRST_FU_REJ_LAST_NEG_DATE`}{Date of the last form saying no
#'       rejection (code 3), strictly before `FIRST_FU_REJ_DATE`; with no
#'       report, the last such form at all. An untreated rejection is
#'       evidence of rejection, so it is not a negative form.}
#'   }
#'
#'   The result also carries a `txf_report` attribute, a list of counts from
#'   the merge for a methods section. Counts are of transplant registrations
#'   (distinct `TRR_ID`s), not people, and of form rows:
#'   \describe{
#'     \item{`follow_up_file`}{The follow-up file read, such as `"TXF_KI"`.}
#'     \item{`cohort_rows`}{Rows of `df`.}
#'     \item{`registrations`}{Distinct non-missing `TRR_ID`s in `df`.}
#'     \item{`registrations_with_forms`}{Of those, how many have at least
#'       one follow-up form.}
#'     \item{`forms`}{Follow-up form rows for those registrations.}
#'     \item{`forms_undated`}{Of those, how many have no `TFL_PX_STAT_DT`.}
#'     \item{`outcomes`}{A tibble with one row per outcome (`"malignancy"`,
#'       `"rejection"`, or for `TX_KP` `"rejection, kidney"` and
#'       `"rejection, pancreas"`): `column`, the date column;
#'       `positive_forms`, forms reporting it; `registrations_with_report`,
#'       registrations with a positive form (status `"event"`); and
#'       `registrations_with_dated_report`, those whose first report is
#'       dated.}
#'   }
#'   The report describes the cohort at the time of the merge: filtering the
#'   result afterwards does not update it.
#'
#' @details
#' **The dates are report dates.** A follow-up form covers a period, and its
#' date (`TFL_PX_STAT_DT`, the patient status date) is when the status was
#' recorded, not when the malignancy or rejection began. The event happened
#' at some time after the last negative form and on or before the first
#' report, so `..._LAST_NEG_DATE` and the report date bound it for
#' interval-censored or discrete-time models. Whether that interval bounds
#' clinical onset depends on what each form asked.
#'
#' **Evidence and timing are kept apart.** A status of `"event"` with a
#' missing date means a form reports the event but no positive form is dated;
#' `..._LAST_NEG_DATE` is then missing too, since the bound is unknown. A
#' missing date alone does not mean no event: read the status column.
#'
#' Forms for every period count here, whenever they are dated.
#' [add_time_to_event_outcomes()] counts a report as an event only inside
#' the follow-up window.
#'
#' Combined organ codes in `TXF_KP` (`ORG_TY` other than `KI` or `PA`) cannot
#' be assigned to one graft, and give a warning.
#'
#' @seealso [add_time_to_event_outcomes()], [srtr_time_to_event()],
#'   [load_srtr_file()]
#'
#' @examples
#' \dontrun{
#' tx <- load_srtr_file("TX_KI")
#' tx <- add_txf_outcomes(tx)
#' table(tx$FIRST_FU_REJ_STATUS)
#' }
#'
#' @export
add_txf_outcomes <- function(
  df
) {
  #Save the key of the file passed to the function as well as the key of the appropriate follow-up file
  file_key <- attr(df, "file_key")
  follow_up_key <- paste0(substr(file_key, 1, 2), "F", substring(file_key, 3L))
  #Create a vector of follow-up IDs to limit the size of the follow up file uploaded
  filter_vector <- df |>
    dplyr::distinct(.data$TRR_ID) |>
    dplyr::pull()

  #Create follow up data set with malignancy and acute rejection episode variables
  #Read only the columns used here: the follow-up files are large, and
  #labelling every column took most of the run time.
  follow_up_df <- load_srtr_file(
    follow_up_key,
    col_select = c(
      "TRR_ID",
      "ORG_TY",
      "TFL_MALIG",
      "TFL_ACUTE_REJ_EPISODE",
      "TFL_PX_STAT_DT"
    ),
    trr_id_filter = filter_vector
  ) |>
    dplyr::mutate(ORG_TYPE = stringr::str_sub(.data$ORG_TY, 1, 2)) |>
    #Choose ID, date of follow up, whether or not had malignancy
    dplyr::select(
      "TRR_ID",
      "TFL_MALIG",
      "TFL_ACUTE_REJ_EPISODE",
      "TFL_PX_STAT_DT",
      "ORG_TYPE"
    ) |>
    dplyr::arrange(.data$TRR_ID, .data$TFL_PX_STAT_DT)

  out <- df

  #Malignancy is patient-level: every form counts. TFL_MALIG has no format;
  #"Y" and "N" are the explicit answers, anything else is unknown.
  malig <- .srtr_txf_endpoint(
    follow_up_df,
    ids = df$TRR_ID,
    positive = follow_up_df$TFL_MALIG %in% "Y",
    negative = follow_up_df$TFL_MALIG %in% "N"
  )
  out$FIRST_FU_MALIG_DATE <- malig$date
  out$FIRST_FU_MALIG_STATUS <- malig$status
  out$FIRST_FU_MALIG_LAST_NEG_DATE <- malig$last_neg
  endpoints <- list(malig)
  endpoint_names <- c(FIRST_FU_MALIG_DATE = "malignancy")

  #Rejection (format ACREJEPF, raw codes or labels): code 1 treated, 2
  #untreated, 3 no, 998 unknown. Only code 3 is a negative form: an untreated
  #rejection is evidence of rejection, so it cannot bound the interval.
  episode <- follow_up_df$TFL_ACUTE_REJ_EPISODE
  rejection_endpoint <- function(rows) {
    ep <- episode[rows]
    .srtr_txf_endpoint(
      follow_up_df[rows, ],
      ids = df$TRR_ID,
      positive = .srtr_has_code(ep, "1", "ACREJEPF"),
      negative = .srtr_has_code(ep, "3", "ACREJEPF"),
      untreated = .srtr_has_code(ep, "2", "ACREJEPF")
    )
  }
  set_rejection <- function(out, result, suffix) {
    out[[paste0("FIRST_FU_REJ_DATE", suffix)]] <- result$date
    out[[paste0("FIRST_FU_REJ_STATUS", suffix)]] <- result$status
    out[[paste0("FIRST_FU_REJ_LAST_NEG_DATE", suffix)]] <- result$last_neg
    out
  }

  #The output columns depend on the file, not on which organs happen to have
  #rejections (#16): TX_KP gets one set per organ, every other file one set.
  if (identical(file_key, "TX_KP")) {
    #ORG_TY uses the WLORG format, which also allows "KP". Rows coded
    #anything other than KI or PA cannot be assigned to one organ.
    other <- setdiff(
      unique(stats::na.omit(follow_up_df$ORG_TYPE)),
      c("KI", "PA")
    )
    if (length(other) > 0) {
      srtr_warn(
        c(
          "{.file TXF_KP} follow-up rows with {.field ORG_TY} {.val {other}} are not {.val KI} or {.val PA}.",
          "i" = "Their rejections are not assigned to an organ."
        ),
        class = "kp_unknown_organ"
      )
    }
    graft <- c(KI = "kidney", PA = "pancreas")
    for (organ in names(graft)) {
      result <- rejection_endpoint(follow_up_df$ORG_TYPE %in% organ)
      out <- set_rejection(out, result, paste0("_", organ))
      endpoints <- c(endpoints, list(result))
      endpoint_names[[paste0("FIRST_FU_REJ_DATE_", organ)]] <-
        paste0("rejection, ", graft[[organ]])
    }
  } else {
    result <- rejection_endpoint(rep(TRUE, nrow(follow_up_df)))
    out <- set_rejection(out, result, "")
    endpoints <- c(endpoints, list(result))
    endpoint_names[["FIRST_FU_REJ_DATE"]] <- "rejection"
  }

  attr(out, "txf_report") <- .srtr_txf_report(
    df,
    follow_up_df,
    follow_up_key,
    endpoints,
    endpoint_names
  )

  #In future, consider use of nested join for other values such as hospitalization counts
  #  df<-df |>
  #  nest_join(follow_up_df, by="TRR_ID", name = "follow_up")

  return(out)
}

#' Add appropriate time-to-event outcome variables to a data frame based on the df attributes, if the file was
#' loaded using a load function.
#'
#' Uses the helper functions to create three columns for an outcome defined by an event date and a censor date:
#' - `{prefix}_CENSOR`: event date if present, otherwise censor date
#' - `{prefix}_BINARY`: 1 if event date present, else 0
#' - `{prefix}_{unit}`: numeric time from start_date to `{prefix}_CENSOR` in chosen units
#'
#' @param df A transplant data frame from [load_srtr_file()]. Its `file_key`
#'   attribute decides which follow-up file and outcome columns are used.
#' @param death_window Which deaths count as events, and where recipients
#'   without one are censored:
#'   * `"follow_up"` (default): deaths on or before the recipient's last
#'     follow-up date count; everyone else is censored at last follow-up.
#'   * `"ascertainment"`: the SRTR program-specific report method for patient
#'     survival. Deaths from any source on or before `ascertainment_date`
#'     count; everyone else is assumed alive and censored at that date.
#' @param ascertainment_date One date up to which deaths are ascertained in
#'   your SAF release, from its release notes. Required when
#'   `death_window = "ascertainment"`.
#' @param graft_death_same_day How to treat a graft failure dated on the day
#'   the recipient died:
#'   * `"censor"` (default): as death with a functioning graft. The graft is
#'     censored at death, not counted as failed.
#'   * `"event"`: as a graft failure.
#'
#'   The default is a package assumption, not an SRTR rule: the data
#'   dictionary does not say whether the graft failure date is filled in with
#'   the death date when a recipient dies with a functioning graft. A real
#'   failure and death can also fall on the same day. Run both settings to see
#'   how much your results depend on it.
#'
#' @details
#' `REC_DEATH_DT_COMPOSITE` keeps every death date from every source. Only the
#' event and censoring columns (`REC_DEATH_DT_COMPOSITE_BINARY`, `_CENSOR`,
#' `_days`) depend on `death_window`. Counting deaths found after last
#' follow-up while censoring survivors at last follow-up would overstate
#' mortality (#18).
#'
#' Graft failure (`TFL_GRAFT_DT`, or `TFL_GRAFT_DT_KI` and `TFL_GRAFT_DT_PA`
#' for `TX_KP`) is death-censored, whatever `death_window` is: a graft failure
#' dated after the recipient's death from any source (`REC_DEATH_DT_COMPOSITE`)
#' is not counted, and a graft without a failure is censored at the earlier of
#' its last follow-up date and death. Death with a functioning graft is a
#' censoring time, not a graft failure. A graft failure dated after the last
#' follow-up date but before death is still counted, at its own date.
#'
#' First rejection (`FIRST_REJ_DATE`, and `FIRST_REJ_DATE_PA` for `TX_KP`)
#' counts a treated rejection (code 1 of format `ACREJEP`, raw or labelled)
#' during the transplant admission (`REC_ACUTE_REJ_EPISODE`, or
#' `REC_ACUTE_REJ_EPISODE_PA`) first, else the first follow-up form reporting
#' one. An admission rejection is dated at discharge, a proxy: the transplant
#' date plus `REC_POSTX_LOS`, else `REC_DISCHRG_DT`; a date before the
#' transplant is not used. `FIRST_REJ_DATE_SOURCE` (`"admission_los"`,
#' `"admission_discharge"`, `"admission_undated"` or `"follow_up"`) says which
#' rule applied (`"follow_up_undated"` is described below). Here a missing
#' date does not always mean no event: an
#' admission rejection with no usable date keeps `_BINARY = 1` with a missing
#' censoring date and time, with a warning, so it drops out of time-to-event
#' models instead of counting as rejection-free. A later follow-up rejection
#' stays in `FIRST_FU_REJ_DATE` (`FIRST_FU_REJ_DATE_KI` and
#' `FIRST_FU_REJ_DATE_PA` for `TX_KP`, with `FIRST_REJ_DATE_PA_SOURCE` for the
#' pancreas) and is never used in its place. A date is unusable when it falls
#' before the transplant; with no transplant date, the discharge date is kept,
#' and the elapsed time is missing.
#'
#' Malignancy (`FIRST_FU_MALIG_DATE`) and rejection count only inside the
#' window the recipient or graft is followed for: from the transplant date
#' up to the earlier of the last follow-up date and death from any source
#' (`REC_DEATH_DT_COMPOSITE`), both inclusive, whatever `death_window` is. Malignancy uses the patient's last
#' follow-up (for `TX_KP`, the later of the two graft dates); rejection uses
#' the graft's own (`TFL_LAFUDATEKI` or `TFL_LAFUDATEPA` for `TX_KP`). Without
#' an event, the recipient is censored at the end of the window. A report
#' dated after it is not an event, but its date stays in the date column, so
#' `!is.na(FIRST_FU_MALIG_DATE) & FIRST_FU_MALIG_DATE_BINARY == 0` finds the
#' reports left out. Only the first report is kept, so when it falls before
#' the transplant date, a later report is not used in its place. With no last
#' follow-up date the window's end is unknown: death is not used in its place,
#' and the time is missing.
#'
#' A malignancy or rejection reported only on follow-up forms with no date
#' (status `"event"` with a missing date in [add_txf_outcomes()]) is treated
#' like an undated admission rejection: `_BINARY = 1` with a missing
#' censoring date and time, with a warning, so it does not add event-free
#' time. For rejection, `FIRST_REJ_DATE_SOURCE` is then
#' `"follow_up_undated"`.
#'
#' Follow-up dates are report dates (see [add_txf_outcomes()]). A report
#' dated on the day of death may come from the form filed at death, so the
#' event may have happened earlier. `FIRST_FU_MALIG_DATE_DEATH_DAY` and
#' `FIRST_REJ_DATE_DEATH_DAY` (and `FIRST_REJ_DATE_PA_DEATH_DAY`) are `TRUE`
#' when the date is the day of death, `FALSE` when it is another day, and
#' `NA` with no date, so you can run a sensitivity analysis without those
#' events. Such reports count as events by default when follow-up covers the
#' day of death. The status columns from [add_txf_outcomes()] say what the
#' forms report, before the window is applied.
#'
add_time_to_event_outcomes <- function(
  df,
  death_window = c("follow_up", "ascertainment"),
  ascertainment_date = NULL,
  graft_death_same_day = c("censor", "event")
) {
  death_window <- match.arg(death_window)
  graft_death_same_day <- match.arg(graft_death_same_day)
  if (death_window == "ascertainment") {
    if (
      is.null(ascertainment_date) ||
        length(ascertainment_date) != 1 ||
        is.na(suppressWarnings(as.Date(ascertainment_date)))
    ) {
      srtr_abort(
        c(
          "{.code death_window = \"ascertainment\"} needs {.arg ascertainment_date}.",
          "i" = "Give one date up to which deaths are ascertained in the SAF release."
        ),
        class = "ascertainment_date_missing"
      )
    }
    ascertainment_date <- as.Date(ascertainment_date)
  }

  is_kp <- identical(attr(df, "file_key"), "TX_KP")

  needed <- if (is_kp) c("TFL_LAFUDATEKI", "TFL_LAFUDATEPA") else "TFL_LAFUDATE"
  check_columns(df, needed, why = "Follow-up dates are needed to censor outcomes.")

  #Patient-level outcomes (death, malignancy) are censored at the patient's
  #last follow-up. TX_KP has no TFL_LAFUDATE, only one date per graft, so use
  #the later of the two: the last date the patient was known to be followed.
  df$.patient_lafu <- if (is_kp) {
    pmax(df$TFL_LAFUDATEKI, df$TFL_LAFUDATEPA, na.rm = TRUE)
  } else {
    df$TFL_LAFUDATE
  }
  #Kidney (or single-organ) rejection is censored at that graft's follow-up.
  df$.graft_lafu <- if (is_kp) df$TFL_LAFUDATEKI else df$TFL_LAFUDATE

  #Add composite death
  df <- srtr_composite_death(df)

  #Deaths count only inside the window survivors are followed for (#18).
  #"follow_up": up to the patient's last follow-up date.
  #"ascertainment": up to one closing date for everyone (SRTR PSR method).
  df$.death_censor <- if (death_window == "follow_up") {
    df$.patient_lafu
  } else {
    rep(ascertainment_date, nrow(df))
  }
  death <- df$REC_DEATH_DT_COMPOSITE
  in_window <- !is.na(death) &
    !is.na(df$.death_censor) &
    death <= df$.death_censor
  df$.death_event <- dplyr::if_else(in_window, death, as.Date(NA))

  #Death added here
  df <- df |>
    srtr_time_to_event(
      event_date = .data$.death_event,
      start_date = .data$REC_TX_DT,
      censor_date = .data$.death_censor,
      prefix = "REC_DEATH_DT_COMPOSITE",
      units = "days",
    )

  #Death-censored graft failure (#22), whatever death_window is: a graft
  #failure dated after death from any source is not an event; one dated on
  #the day of death follows graft_death_same_day. Without a failure, the graft
  #is censored at the earlier of its last follow-up and death. A failure after
  #last follow-up but before death still counts.
  graft_lafu_cols <- c(
    TFL_GRAFT_DT_KI = "TFL_LAFUDATEKI",
    TFL_GRAFT_DT_PA = "TFL_LAFUDATEPA",
    TFL_GRAFT_DT = "TFL_LAFUDATE"
  )
  for (graft_col in names(graft_lafu_cols)) {
    if (!graft_col %in% names(df)) {
      next
    }
    censored <- .srtr_death_censor(
      event = df[[graft_col]],
      censor = df[[graft_lafu_cols[[graft_col]]]],
      death = death,
      same_day = graft_death_same_day
    )
    df$.graft_event <- censored$event
    df$.graft_censor <- censored$censor
    df <- df |>
      srtr_time_to_event(
        event_date = .data$.graft_event,
        start_date = .data$REC_TX_DT,
        censor_date = .data$.graft_censor,
        prefix = graft_col,
        units = "days",
      )
  }
  df$.graft_event <- NULL
  df$.graft_censor <- NULL

  #Add rejection and malignancy from follow up database
  df <- add_txf_outcomes(df)

  #Rejection can be found during the transplant admission or on a follow-up
  #form. An admission rejection is dated at discharge: the transplant date
  #plus the length of stay, else the discharge date. With neither, it stays a
  #rejection with an unknown time (#213); a later follow-up rejection is kept
  #in its own column and never substituted for it.
  if (is_kp) {
    rejection <- .srtr_first_rejection(
      df, "REC_ACUTE_REJ_EPISODE", df$FIRST_FU_REJ_DATE_KI,
      df$FIRST_FU_REJ_STATUS_KI
    )
    df$FIRST_REJ_DATE <- rejection$date
    df$FIRST_REJ_DATE_SOURCE <- rejection$source
    rejection <- .srtr_first_rejection(
      df, "REC_ACUTE_REJ_EPISODE_PA", df$FIRST_FU_REJ_DATE_PA,
      df$FIRST_FU_REJ_STATUS_PA
    )
    df$FIRST_REJ_DATE_PA <- rejection$date
    df$FIRST_REJ_DATE_PA_SOURCE <- rejection$source
  } else {
    rejection <- .srtr_first_rejection(
      df, "REC_ACUTE_REJ_EPISODE", df$FIRST_FU_REJ_DATE,
      df$FIRST_FU_REJ_STATUS
    )
    df$FIRST_REJ_DATE <- rejection$date
    df$FIRST_REJ_DATE_SOURCE <- rejection$source
  }

  #Malignancy and rejection are first reports on follow-up forms. They count
  #only through the end of the window everyone is followed for (#215): the
  #earlier of the applicable last follow-up and death from any source,
  #inclusive, and from the transplant date. Malignancy uses the patient's
  #follow-up, rejection the graft's. A report outside the window stays in its
  #date column, for auditing.
  report_lafu <- list(
    FIRST_FU_MALIG_DATE = df$.patient_lafu,
    FIRST_REJ_DATE = df$.graft_lafu,
    FIRST_REJ_DATE_PA = if (is_kp) df$TFL_LAFUDATEPA
  )
  for (prefix in names(report_lafu)) {
    if (!prefix %in% names(df)) {
      next
    }
    windowed <- .srtr_report_window(
      df[[prefix]],
      df$REC_TX_DT,
      report_lafu[[prefix]],
      death
    )
    df$.report_event <- windowed$event
    df$.report_censor <- windowed$censor
    df <- df |>
      srtr_time_to_event(
        event_date = .data$.report_event,
        start_date = .data$REC_TX_DT,
        censor_date = .data$.report_censor,
        prefix = prefix,
        units = "days",
      )
    #Whether the report is dated on the day of death: such a report may come
    #from the form filed at death, so the event may be earlier.
    report <- df[[prefix]]
    df[[paste0(prefix, "_DEATH_DAY")]] <- dplyr::if_else(
      is.na(report),
      NA,
      !is.na(death) & report == death
    )
  }
  df$.report_event <- NULL
  df$.report_censor <- NULL

  #A known event with no usable date keeps status 1 with a missing time, so
  #it drops out of time-to-event models instead of adding event-free time:
  #an admission rejection with no discharge date (#213), and an event
  #reported only on undated follow-up forms.
  for (prefix in c("FIRST_REJ_DATE", "FIRST_REJ_DATE_PA")) {
    source <- df[[paste0(prefix, "_SOURCE")]]
    if (is.null(source)) {
      next
    }
    df <- .srtr_mark_undated(
      df,
      prefix,
      source %in% "admission_undated",
      what = "had a treated rejection during the transplant admission with no usable length of stay or discharge date",
      noun = "rejection",
      class = "undated_admission_rejection"
    )
    df <- .srtr_mark_undated(
      df,
      prefix,
      source %in% "follow_up_undated",
      what = "had a rejection reported only on follow-up forms with no date",
      noun = "rejection",
      class = "undated_follow_up_report"
    )
  }
  if ("FIRST_FU_MALIG_STATUS" %in% names(df)) {
    df <- .srtr_mark_undated(
      df,
      "FIRST_FU_MALIG_DATE",
      df$FIRST_FU_MALIG_STATUS %in% "event" & is.na(df$FIRST_FU_MALIG_DATE),
      what = "had a malignancy reported only on follow-up forms with no date",
      noun = "malignancy",
      class = "undated_follow_up_report"
    )
  }

  df$.patient_lafu <- NULL
  df$.graft_lafu <- NULL
  df$.death_event <- NULL
  df$.death_censor <- NULL
  df
}

#' Censor an outcome at death
#'
#' An event counts only if it is dated before death (or on the day of death
#' when `same_day = "event"`). Follow-up ends at death when death comes before
#' the censor date. A missing censor date stays missing: without a follow-up
#' date it is not known that the outcome was followed up to death.
#'
#' @param event,censor,death `Date` vectors of the same length.
#' @param same_day `"censor"` or `"event"`: how to treat an event dated on the
#'   day of death.
#' @return A list with `event` and `censor` `Date` vectors.
#' @noRd
.srtr_death_censor <- function(event, censor, death, same_day) {
  before_death <- if (same_day == "event") event <= death else event < death
  keep_event <- !is.na(event) & (is.na(death) | before_death)
  died_first <- !is.na(death) & !is.na(censor) & death < censor
  list(
    event = dplyr::if_else(keep_event, event, as.Date(NA)),
    censor = dplyr::if_else(died_first, death, censor)
  )
}

#' Count a follow-up report only inside the observation window
#'
#' The window runs from the transplant date to the earlier of the last
#' follow-up date and death from any source, both inclusive. A report outside
#' it is not an event; the registration is censored at the window's end
#' instead. A missing last follow-up date leaves the window's end missing:
#' death is not substituted, because the forms do not show follow-up up to
#' death. With no transplant date the start cannot be checked; the elapsed
#' time is missing anyway.
#'
#' @param report,start,lafu,death `Date` vectors of the same length.
#' @return A list with `event` and `censor` `Date` vectors.
#' @noRd
.srtr_report_window <- function(report, start, lafu, death) {
  end <- dplyr::if_else(!is.na(death) & !is.na(lafu) & death < lafu, death, lafu)
  after_start <- is.na(start) | report >= start
  inside <- !is.na(report) & !is.na(end) & report <= end & after_start
  list(
    event = dplyr::if_else(inside, report, as.Date(NA)),
    censor = end
  )
}

#' First rejection date: at the transplant admission, else on follow-up
#'
#' @param df The transplant data frame.
#' @param episode_col The admission rejection column (`REC_ACUTE_REJ_EPISODE`
#'   or `REC_ACUTE_REJ_EPISODE_PA`), with format labels applied.
#' @param follow_up_date The first follow-up rejection date for this graft.
#' @param follow_up_status The follow-up rejection status for this graft,
#'   from [add_txf_outcomes()].
#' @return A list with `date` (a `Date` vector) and `source` (`"admission_los"`,
#'   `"admission_discharge"`, `"admission_undated"`, `"follow_up"`,
#'   `"follow_up_undated"` or `NA`).
#' @noRd
.srtr_first_rejection <- function(df, episode_col, follow_up_date,
                                  follow_up_status = NULL) {
  if (is.null(follow_up_status)) {
    follow_up_status <- rep(NA_character_, nrow(df))
  }
  check_columns(
    df,
    c("REC_TX_DT", "REC_POSTX_LOS", episode_col),
    why = "They date a rejection during the transplant admission."
  )
  #Code 1 of format ACREJEP: at least one episode treated with an
  #anti-rejection agent. Raw codes and labelled columns alike.
  at_admission <- .srtr_has_code(df[[episode_col]], "1", "ACREJEP")
  #A date before the transplant cannot date an admission event. With no
  #transplant date it cannot be checked, and is kept: the elapsed time is
  #unknown anyway.
  usable <- function(date) {
    before <- !is.na(df$REC_TX_DT) & date < df$REC_TX_DT
    dplyr::if_else(!is.na(date) & !before, date, as.Date(NA))
  }
  los_date <- usable(df$REC_TX_DT + df$REC_POSTX_LOS)
  discharge_date <- if ("REC_DISCHRG_DT" %in% names(df)) {
    usable(df$REC_DISCHRG_DT)
  } else {
    rep(as.Date(NA), nrow(df))
  }
  source <- dplyr::case_when(
    at_admission & !is.na(los_date) ~ "admission_los",
    at_admission & !is.na(discharge_date) ~ "admission_discharge",
    at_admission ~ "admission_undated",
    !is.na(follow_up_date) ~ "follow_up",
    follow_up_status %in% "event" ~ "follow_up_undated",
    .default = NA_character_
  )
  date <- dplyr::if_else(
    at_admission,
    dplyr::coalesce(los_date, discharge_date),
    follow_up_date
  )
  list(date = date, source = source)
}

#' Which values of a coded column are a given format code
#'
#' A raw column holds the code; a labelled one holds the code's meaning in
#' the format. Both are matched, so raw and labelled columns give the same
#' answer. The meaning comes from the bundled [formats].
#' @noRd
.srtr_has_code <- function(x, code, format) {
  meaning <- sRtr::formats$Meaning[
    sRtr::formats$Format == format & sRtr::formats$Code == code
  ]
  as.character(x) %in% c(code, meaning)
}

#' Keep a known event with no usable date as an event
#'
#' [srtr_time_to_event()] reads a missing event date as no event. A known
#' event with no date is still an event: it gets status 1 and a missing
#' censoring date and time, so it drops out of time-to-event models instead
#' of counting as event-free. Warns with the count.
#' @param undated Logical, one per row: the rows to mark.
#' @param what,noun,class The warning's description of the rows, the event's
#'   name, and the warning's class.
#' @noRd
.srtr_mark_undated <- function(df, prefix, undated, what, noun, class) {
  if (!any(undated)) {
    return(df)
  }
  time_col <- grep(
    paste0("^", prefix, "_(days|months|yrs)$"),
    names(df),
    value = TRUE
  )
  df[[paste0(prefix, "_BINARY")]][undated] <- 1L
  df[[paste0(prefix, "_CENSOR")]][undated] <- as.Date(NA)
  for (col in time_col) {
    df[[col]][undated] <- NA_real_
  }
  n <- sum(undated)
  as_what <- if (n == 1) paste("a", noun) else paste0(noun, "s")
  srtr_warn(
    c(
      "{n} recipient{?s} {what}.",
      "i" = "{cli::qty(n)}{?It counts/They count} as {as_what} with an unknown time: {.field {prefix}_BINARY} is 1 and the time is {.code NA}."
    ),
    class = class,
    n = n
  )
  df
}

#' The merge report attached to the result of add_txf_outcomes()
#'
#' Counts are of transplant registrations (distinct non-missing `TRR_ID`s),
#' not people, and of form rows, at the time of the merge.
#' @noRd
.srtr_txf_report <- function(df, forms, follow_up_key, endpoints, labels) {
  ids <- df$TRR_ID
  registration <- !is.na(ids) & !duplicated(ids)
  matched <- !is.na(forms$TRR_ID) & forms$TRR_ID %in% ids[registration]
  per_endpoint <- function(endpoint, measure) {
    switch(
      measure,
      positive_forms = endpoint$positive_forms,
      with_report = sum(endpoint$status[registration] == "event"),
      dated = sum(!is.na(endpoint$date[registration]))
    )
  }
  count <- function(measure) {
    vapply(endpoints, per_endpoint, numeric(1), measure = measure)
  }
  list(
    follow_up_file = follow_up_key,
    cohort_rows = nrow(df),
    registrations = sum(registration),
    registrations_with_forms = sum(ids[registration] %in% forms$TRR_ID[matched]),
    forms = sum(matched),
    forms_undated = sum(matched & is.na(forms$TFL_PX_STAT_DT)),
    outcomes = tibble::tibble(
      outcome = unname(labels),
      column = names(labels),
      positive_forms = count("positive_forms"),
      registrations_with_report = count("with_report"),
      registrations_with_dated_report = count("dated")
    )
  )
}

#' Summarise one follow-up endpoint per transplant registration
#'
#' Keeps what the forms say about an endpoint apart from when it was first
#' reported: a positive form with no date is still an event, with a missing
#' date.
#'
#' @param forms Follow-up forms with `TRR_ID` and `TFL_PX_STAT_DT`.
#' @param ids The cohort's `TRR_ID`s, in row order.
#' @param positive,negative,untreated Logical vectors, one per form: the form
#'   reports the endpoint, explicitly reports its absence, or (rejection only)
#'   reports an untreated rejection. Missing counts as `FALSE`.
#' @return A list of vectors matched to `ids`: `date`, the first dated
#'   positive form; `status`, one of `"event"`, `"untreated"`, `"no event"`,
#'   `"unknown"` or `"no follow-up"`; and `last_neg`, the last explicitly
#'   negative form strictly before `date`, or the last one at all when there
#'   is no positive form. `last_neg` is missing when every positive form is
#'   undated, since the bound is then unknown. Also `positive_forms`, the
#'   number of positive forms for the cohort, for the merge report.
#' @noRd
.srtr_txf_endpoint <- function(forms, ids, positive, negative, untreated = NULL) {
  n <- length(ids)
  result <- list(
    date = rep(as.Date(NA), n),
    status = rep("no follow-up", n),
    last_neg = rep(as.Date(NA), n)
  )
  result$positive_forms <- 0
  if (nrow(forms) == 0) {
    return(result)
  }
  if (is.null(untreated)) {
    untreated <- rep(FALSE, nrow(forms))
  }
  positive <- positive %in% TRUE
  negative <- negative %in% TRUE
  untreated <- untreated %in% TRUE
  form_date <- forms$TFL_PX_STAT_DT
  #Registrations are matched by TRR_ID value, so a registration listed more
  #than once in the cohort gets the same values on every row.
  key <- forms$TRR_ID
  in_cohort <- !is.na(key) & key %in% ids
  result$positive_forms <- sum(positive & in_cohort)

  #Per registration: any positive, untreated or negative form, and the first
  #dated positive form.
  by_id <- tibble::tibble(
    key = key,
    positive = positive,
    untreated = untreated,
    negative = negative,
    positive_date = dplyr::if_else(positive, form_date, as.Date(NA))
  )[in_cohort, ] |>
    dplyr::summarise(
      any_positive = any(.data$positive),
      any_untreated = any(.data$untreated),
      any_negative = any(.data$negative),
      #All positive forms undated: NA, not the Inf (with a warning) min() gives.
      first = if (all(is.na(.data$positive_date))) {
        as.Date(NA)
      } else {
        min(.data$positive_date, na.rm = TRUE)
      },
      .by = "key"
    )

  row <- match(ids, by_id$key)
  seen <- !is.na(row)
  result$date <- by_id$first[row]
  result$status[seen] <- dplyr::case_when(
    by_id$any_positive[row[seen]] ~ "event",
    by_id$any_untreated[row[seen]] ~ "untreated",
    by_id$any_negative[row[seen]] ~ "no event",
    .default = "unknown"
  )

  #Last explicitly negative form: strictly before the first dated positive
  #form, or any negative form when there is no positive form at all.
  form_row <- match(key, by_id$key)
  form_first <- by_id$first[form_row]
  form_any_positive <- by_id$any_positive[form_row] %in% TRUE
  bounds <- negative &
    in_cohort &
    !is.na(form_date) &
    dplyr::if_else(
      form_any_positive,
      !is.na(form_first) & form_date < form_first,
      TRUE
    )
  if (any(bounds)) {
    last <- tibble::tibble(key = key[bounds], date = form_date[bounds]) |>
      dplyr::summarise(date = max(.data$date), .by = "key")
    result$last_neg <- last$date[match(ids, last$key)]
  }
  result
}
