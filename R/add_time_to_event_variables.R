#' Helper function to add a time-to-event outcome from a date function
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
#'   `{prefix}_CENSOR`, `{prefix}_BINARY`, `{prefix}_{units-suffix}`.
#'
#' @details
#' Units suffix mapping: `years -> "_yrs"`, `months -> "_months"`, `days -> "_days"`.
#' Negative times (e.g., when `start_date > censor/event`) trigger a warning,
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

  out[[time_col]] <- time_days / denom_days

  out
}



#' Add time-to-event (TTE) follow-up outcomes to a transplant cohort
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
#' * This function only derives event *dates*. To build full TTE variables
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
#' @importFrom dplyr distinct pull mutate select arrange filter group_by summarise left_join
#' @importFrom tidyr pivot_wider
#' @importFrom stringr str_sub
#' @export

add_txf_outcomes <- function(
    df)
{
  #Save the key of the file passed to the function as well as the key of the appropriate follow-up file
  file_key<-attr(df, "file_key")
  follow_up_key<-paste0(substr(file_key, 1, 2), "F", substring(file_key, 3L))
  #Create a vector of follow-up IDs to limit the size of the follow up file uploaded
  filter_vector<-df%>%
    distinct(TRR_ID)%>%
    pull()

  #Create follow up data set with malignancy and acute rejection episode variables
  follow_up_df<-load_srtr_file(follow_up_key, trr_id_filter = filter_vector)%>%
    mutate(ORG_TYPE=stringr::str_sub(ORG_TY, 1, 2))%>%
    #Choose ID, date of follow up, whether or not had malignancy
    select(TRR_ID, TFL_MALIG, TFL_ACUTE_REJ_EPISODE, TFL_PX_STAT_DT, ORG_TYPE)%>%
    arrange(TRR_ID, TFL_PX_STAT_DT)

  #Add first malignancy variable
  follow_up_malignancy_dates<-follow_up_df%>%
    filter(TFL_MALIG == "Y") %>%
    group_by(TRR_ID) %>%
    summarise(FIRST_FU_MALIG_DATE = min(TFL_PX_STAT_DT, na.rm = TRUE), .groups = "drop")

  #Add first rejection variable for each organ
  follow_up_rejection_dates<-follow_up_df%>%
    filter(TFL_ACUTE_REJ_EPISODE=="1: Yes, at least one episode treated with anti-rejection agent")%>%
    group_by(TRR_ID, ORG_TYPE)%>%
    summarise(FIRST_FU_REJ_DATE = min(TFL_PX_STAT_DT, na.rm = TRUE), .groups = "drop")%>%
    pivot_wider(
      id_cols    = TRR_ID,
      names_from = ORG_TYPE,
      values_from = FIRST_FU_REJ_DATE,
      names_glue = "FIRST_FU_REJ_DATE_{ORG_TYPE}",  # e.g., FIRST_FU_REJ_DATE_KI, _PA, ...
      values_fill = NA
    )

  #Get rid of _ORG_TYPE part if not needed in rej date
  if (length(grep("^FIRST_FU_REJ_DATE", names(follow_up_rejection_dates))) == 1) {
    oldname <- grep("^FIRST_FU_REJ_DATE", names(follow_up_rejection_dates), value = TRUE)

    follow_up_rejection_dates <- follow_up_rejection_dates %>%
      rename(FIRST_FU_REJ_DATE = all_of(oldname))
  }

  out<-df%>%
    left_join(follow_up_malignancy_dates)%>%
    left_join(follow_up_rejection_dates)


#In future, consider use of nested join for other values such as hospitalization counts
#  df<-df%>%
#  nest_join(follow_up_df, by="TRR_ID", name = "follow_up")


  return(out)

}

#' Add appropriate TTE outcome variables to a data frame based on the df attributes, if the file was
#' loaded using a load function.
#'
#' Uses the helper functions to create three columns for an outcome defined by an event date and a censor date:
#' - {prefix}_CENSOR: event date if present, otherwise censor date
#' - {prefix}_BINARY: 1 if event date present, else 0
#' - {prefix}_{unit}: numeric time from start_date to {prefix}_CENSOR in chosen units
#'
#'
add_tte_outcomes <- function(
    df)
{

#Add composite death
  df <- srtr_composite_death(df)

#Death added here
  df<-df%>%
    srtr_time_to_event(
      event_date=REC_DEATH_DT_COMPOSITE,
      start_date=REC_TX_DT,
      censor_date=TFL_LAFUDATE,
      prefix="REC_DEATH_DT_COMPOSITE",
      units = "days",
    )

#Death-censored graft failure added here:
  if ("TFL_GRAFT_DT_KI" %in% names(df)) {
    df<-df%>%
      srtr_time_to_event(
        event_date=TFL_GRAFT_DT_KI,
        start_date=REC_TX_DT,
        censor_date=TFL_LAFUDATEKI,
        prefix="TFL_GRAFT_DT_KI",
        units = "days",
      )

  }

  if ("TFL_GRAFT_DT_PA" %in% names(df)) {
    df<-df%>%
      srtr_time_to_event(
        event_date=TFL_GRAFT_DT_PA,
        start_date=REC_TX_DT,
        censor_date=TFL_LAFUDATEPA,
        prefix="TFL_GRAFT_DT_PA",
        units = "days",
      )

  }

  if ("TFL_GRAFT_DT" %in% names(df)) {
    df<-df%>%
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

  if (attr(df, "file_key")=="TX_KP"){
    df<-df%>%
      mutate(
        FIRST_REJ_DATE=
          case_when(
            REC_ACUTE_REJ_EPISODE=="1: Yes, at least one episode treated with anti-rejection agent"~
              REC_TX_DT+REC_POSTX_LOS,
            TRUE~FIRST_FU_REJ_DATE_KI)
      )%>%
      mutate(
        FIRST_REJ_DATE_PA=
          case_when(
            REC_ACUTE_REJ_EPISODE_PA=="1: Yes, at least one episode treated with anti-rejection agent"~
              REC_TX_DT+REC_POSTX_LOS,
            TRUE~FIRST_FU_REJ_DATE_PA)
      )

  }

  if (attr(df, "file_key")!="TX_KP"){
    df<-df%>%
      mutate(
        FIRST_REJ_DATE=
          case_when(
            REC_ACUTE_REJ_EPISODE=="1: Yes, at least one episode treated with anti-rejection agent"~REC_TX_DT+REC_POSTX_LOS,
            TRUE~FIRST_FU_REJ_DATE)
        )
  }




  if ("FIRST_FU_MALIG_DATE" %in% names(df)) {
    df<-df%>%
      srtr_time_to_event(
        event_date=FIRST_FU_MALIG_DATE,
        start_date=REC_TX_DT,
        censor_date=TFL_LAFUDATE,
        prefix="FIRST_FU_MALIG_DATE",
        units = "days",
      )

  }

  if ("FIRST_REJ_DATE" %in% names(df)) {
    df<-df%>%
      srtr_time_to_event(
        event_date=FIRST_REJ_DATE,
        start_date=REC_TX_DT,
        censor_date=TFL_LAFUDATE,
        prefix="FIRST_REJ_DATE",
        units = "days",
      )

  }

  if ("FIRST_REJ_DATE_PA" %in% names(df)) {
    df<-df%>%
      srtr_time_to_event(
        event_date=FIRST_REJ_DATE_PA,
        start_date=REC_TX_DT,
        censor_date=TFL_LAFUDATEPA,
        prefix="FIRST_REJ_DATEPA",
        units = "days",
      )

  }

  out<-df
  out
}
