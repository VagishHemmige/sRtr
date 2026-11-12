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

  # Unit conversion
  denom_days <- switch(units,
                       "years"  = 365.25,
                       "months" = 30.4375,
                       "days"   = 1)

  out <- df |>
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

  out[[time_col]] <- time_days / denom_days

  out
}



#' Add time-to-event follow-up outcomes to a transplant cohort
#'
#' Uses the cohort's `file_key` attribute (as set by your SRTR load helpers)
#' to locate and load the corresponding follow-up table, then derives:
#'
#' * `FIRST_FU_MALIG_DATE` — first follow-up malignancy date per `TRR_ID`
#' * `FIRST_FU_REJ_DATE_{ORG}` — first acute rejection date per organ code
#'   (e.g., `FIRST_FU_REJ_DATE_KI`, `FIRST_FU_REJ_DATE_PA`)
#'
#' The function limits the follow-up load to the cohort's `TRR_ID`s for
#' efficiency, and merges the derived dates back into `df`.
#'
#' @param df A data frame representing a transplant cohort (one row per recipient
#'   or transplant). Must include a `TRR_ID` column and have an attribute
#'   `file_key` (a string) indicating the originating SRTR table key (e.g.,
#'   `"KI_txf"`). The companion follow-up key is inferred as the same prefix
#'   with `"F"` inserted after the first two characters (e.g., `"KI_Ftxf"`).
#'
#' @return The input `df` with additional columns:
#'   \describe{
#'     \item{FIRST_FU_MALIG_DATE}{Date of first follow-up malignancy (per TRR).}
#'     \item{FIRST_FU_REJ_DATE_{ORG}}{Date of first acute rejection per organ
#'       (wide columns by organ code).}
#'   }
#'   Existing columns/attributes of `df` are preserved.
#'
#' @details
#' This helper:
#' \enumerate{
#'   \item Infers the follow-up table key from `attr(df, "file_key")`.
#'   \item Loads the follow-up subset for the cohort's `TRR_ID`s via
#'         `load_srtr_file()`.
#'   \item Normalizes organ to a two-letter code (`ORG_TYPE` := first two
#'         characters of `ORG_TY`), selects core follow-up fields, and orders
#'         by `TRR_ID` and `TFL_PX_STAT_DT`.
#'   \item Computes the earliest malignancy date per `TRR_ID` where
#'         `TFL_MALIG == "Y"`.
#'   \item Computes the earliest acute rejection date per (`TRR_ID`, `ORG_TYPE`)
#'         where `TFL_ACUTE_REJ_EPISODE` indicates at least one treated episode,
#'         and pivots to wide organ-specific columns.
#'   \item Left-joins both results back to `df`.
#' }
#'
#' **Assumptions/requirements**
#' * The follow-up table contains: `TRR_ID`, `ORG_TY`, `TFL_PX_STAT_DT`,
#'   `TFL_MALIG`, and `TFL_ACUTE_REJ_EPISODE`.
#' * `TFL_PX_STAT_DT` should be a `Date`; if stored as `YYYYMMDD`, convert
#'   upstream (e.g., `as.Date(as.character(x), "%Y%m%d")`).
#' * Rejection is identified by the labeled value
#'   `"1: Yes, at least one episode treated with anti-rejection agent"`.
#'   Adjust the filter if your coding differs.
#'
#' **Notes**
#' * Combined organ codes (e.g., `"HL"`) are not split; they will produce a
#'   column `FIRST_FU_REJ_DATE_HL`. If you prefer to split into heart/lung,
#'   duplicate those rows before pivoting.
#' * This function only derives event *dates*. To build full time-to-event variables
#'   (censor date, indicator, elapsed time), pass these dates to your
#'   `srtr_time_to_event()` helper along with transplant and last-follow-up dates.
#'
#' @seealso \code{\link{srtr_time_to_event}}, \code{\link{load_srtr_file}}
#'
#' @examples
#' \dontrun{
#' # df loaded earlier, e.g., df <- load_srtr_file("KI_txf")
#' attr(df, "file_key")
#' #> "KI_txf"
#'
#' df2 <- add_txf_outcomes(df)
#' names(df2)
#' # ... includes FIRST_FU_MALIG_DATE, FIRST_FU_REJ_DATE_KI, etc.
#'
#' # Then compute time-to-event from transplant date:
#' df2 <- srtr_time_to_event(
#'   df2,
#'   event_date  = FIRST_FU_MALIG_DATE,
#'   start_date  = REC_TX_DT,
#'   censor_date = TFL_LAFUDATEKI,
#'   prefix      = "REC_MALIG"
#' )
#' }
#'
#' @export

add_txf_outcomes <- function(
    df)
{
  #Save the key of the file passed to the function as well as the key of the appropriate follow-up file
  file_key<-attr(df, "file_key")
  follow_up_key<-paste0(substr(file_key, 1, 2), "F", substring(file_key, 3L))
  #Create a vector of follow-up IDs to limit the size of the follow up file uploaded
  filter_vector<-df|>
    dplyr::distinct(TRR_ID)|>
    dplyr::pull()

  #Create follow up data set with malignancy and acute rejection episode variables
  follow_up_df<-load_srtr_file(follow_up_key, trr_id_filter = filter_vector)|>
    dplyr::mutate(ORG_TYPE=stringr::str_sub(ORG_TY, 1, 2))|>
    #Choose ID, date of follow up, whether or not had malignancy
    dplyr::select(TRR_ID, TFL_MALIG, TFL_ACUTE_REJ_EPISODE, TFL_PX_STAT_DT, ORG_TYPE)|>
    dplyr::arrange(TRR_ID, TFL_PX_STAT_DT)

  #First form date per TRR_ID among `rows`, matched to the cohort's rows.
  #NA where a recipient has no such form (no warning when `rows` is empty).
  first_date <- function(rows) {
    if (nrow(rows) == 0) return(rep(as.Date(NA), nrow(df)))
    dates <- rows|>
      dplyr::group_by(TRR_ID)|>
      dplyr::summarise(date = min(TFL_PX_STAT_DT, na.rm = TRUE), .groups = "drop")
    dates$date[match(df$TRR_ID, dates$TRR_ID)]
  }

  out <- df

  #Add first malignancy variable
  out$FIRST_FU_MALIG_DATE <- first_date(dplyr::filter(follow_up_df, TFL_MALIG == "Y"))

  #Add first rejection date. The output columns depend on the file, not on
  #which organs happen to have rejections (#16): TX_KP gets one column per
  #organ, every other file gets a single FIRST_FU_REJ_DATE.
  rejections<-follow_up_df|>
    dplyr::filter(TFL_ACUTE_REJ_EPISODE=="1: Yes, at least one episode treated with anti-rejection agent")

  if (identical(file_key, "TX_KP")) {
    #ORG_TY uses the WLORG format, which also allows "KP". Rows coded
    #anything other than KI or PA cannot be assigned to one organ.
    other <- setdiff(unique(stats::na.omit(follow_up_df$ORG_TYPE)), c("KI", "PA"))
    if (length(other) > 0) {
      warning(
        "TXF_KP follow-up rows with ORG_TY ",
        paste0("'", other, "'", collapse = ", "),
        " are not KI or PA; their rejections are not assigned to an organ.",
        call. = FALSE
      )
    }
    for (organ in c("KI", "PA")) {
      out[[paste0("FIRST_FU_REJ_DATE_", organ)]] <-
        first_date(dplyr::filter(rejections, ORG_TYPE == organ))
    }
  } else {
    out$FIRST_FU_REJ_DATE <- first_date(rejections)
  }


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
#'
#' @details
#' `REC_DEATH_DT_COMPOSITE` keeps every death date from every source. Only the
#' event and censoring columns (`REC_DEATH_DT_COMPOSITE_BINARY`, `_CENSOR`,
#' `_days`) depend on `death_window`. Counting deaths found after last
#' follow-up while censoring survivors at last follow-up would overstate
#' mortality (#18).
#'
add_time_to_event_outcomes <- function(
    df,
    death_window = c("follow_up", "ascertainment"),
    ascertainment_date = NULL)
{
  death_window <- match.arg(death_window)
  if (death_window == "ascertainment") {
    if (is.null(ascertainment_date) || length(ascertainment_date) != 1 ||
        is.na(suppressWarnings(as.Date(ascertainment_date)))) {
      stop(
        "`death_window = \"ascertainment\"` needs `ascertainment_date`: ",
        "one date up to which deaths are ascertained in the SAF release.",
        call. = FALSE
      )
    }
    ascertainment_date <- as.Date(ascertainment_date)
  }

  is_kp <- identical(attr(df, "file_key"), "TX_KP")

  needed <- if (is_kp) c("TFL_LAFUDATEKI", "TFL_LAFUDATEPA") else "TFL_LAFUDATE"
  missing <- setdiff(needed, names(df))
  if (length(missing) > 0) {
    stop(
      "`df` is missing the follow-up date column(s) ",
      paste0("`", missing, "`", collapse = ", "),
      " needed to censor outcomes.",
      call. = FALSE
    )
  }

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
  in_window <- !is.na(death) & !is.na(df$.death_censor) & death <= df$.death_censor
  df$.death_event <- dplyr::if_else(in_window, death, as.Date(NA))

#Death added here
  df<-df|>
    srtr_time_to_event(
      event_date=.death_event,
      start_date=REC_TX_DT,
      censor_date=.death_censor,
      prefix="REC_DEATH_DT_COMPOSITE",
      units = "days",
    )

#Death-censored graft failure added here:
  if ("TFL_GRAFT_DT_KI" %in% names(df)) {
    df<-df|>
      srtr_time_to_event(
        event_date=TFL_GRAFT_DT_KI,
        start_date=REC_TX_DT,
        censor_date=TFL_LAFUDATEKI,
        prefix="TFL_GRAFT_DT_KI",
        units = "days",
      )

  }

  if ("TFL_GRAFT_DT_PA" %in% names(df)) {
    df<-df|>
      srtr_time_to_event(
        event_date=TFL_GRAFT_DT_PA,
        start_date=REC_TX_DT,
        censor_date=TFL_LAFUDATEPA,
        prefix="TFL_GRAFT_DT_PA",
        units = "days",
      )

  }

  if ("TFL_GRAFT_DT" %in% names(df)) {
    df<-df|>
      srtr_time_to_event(
        event_date=TFL_GRAFT_DT,
        start_date=REC_TX_DT,
        censor_date=TFL_LAFUDATE,
        prefix="TFL_GRAFT_DT",
        units = "days",
      )

  }


  #Add rejection and malignancy from follow up database
  df<-add_txf_outcomes(df)

  #Rejection can be both in acute admission as well as in follow up.  So we create a rejection date variable:

  if (is_kp){
    df<-df|>
      dplyr::mutate(
        FIRST_REJ_DATE=
          dplyr::case_when(
            REC_ACUTE_REJ_EPISODE=="1: Yes, at least one episode treated with anti-rejection agent"~
              REC_TX_DT+REC_POSTX_LOS,
            TRUE~FIRST_FU_REJ_DATE_KI)
      )|>
      dplyr::mutate(
        FIRST_REJ_DATE_PA=
          dplyr::case_when(
            REC_ACUTE_REJ_EPISODE_PA=="1: Yes, at least one episode treated with anti-rejection agent"~
              REC_TX_DT+REC_POSTX_LOS,
            TRUE~FIRST_FU_REJ_DATE_PA)
      )

  }

  if (!is_kp){
    df<-df|>
      dplyr::mutate(
        FIRST_REJ_DATE=
          dplyr::case_when(
            REC_ACUTE_REJ_EPISODE=="1: Yes, at least one episode treated with anti-rejection agent"~REC_TX_DT+REC_POSTX_LOS,
            TRUE~FIRST_FU_REJ_DATE)
        )
  }




  if ("FIRST_FU_MALIG_DATE" %in% names(df)) {
    df<-df|>
      srtr_time_to_event(
        event_date=FIRST_FU_MALIG_DATE,
        start_date=REC_TX_DT,
        censor_date=.patient_lafu,
        prefix="FIRST_FU_MALIG_DATE",
        units = "days",
      )

  }

  if ("FIRST_REJ_DATE" %in% names(df)) {
    df<-df|>
      srtr_time_to_event(
        event_date=FIRST_REJ_DATE,
        start_date=REC_TX_DT,
        censor_date=.graft_lafu,
        prefix="FIRST_REJ_DATE",
        units = "days",
      )

  }

  if ("FIRST_REJ_DATE_PA" %in% names(df)) {
    df<-df|>
      srtr_time_to_event(
        event_date=FIRST_REJ_DATE_PA,
        start_date=REC_TX_DT,
        censor_date=TFL_LAFUDATEPA,
        prefix="FIRST_REJ_DATE_PA",
        units = "days",
      )

  }

  df$.patient_lafu <- NULL
  df$.graft_lafu <- NULL
  df$.death_event <- NULL
  df$.death_censor <- NULL
  df
}
