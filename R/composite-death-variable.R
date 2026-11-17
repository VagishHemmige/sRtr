#' Composite death date (OPTN > SSA > TFL)
#'
#' Builds a composite death date column using precedence across the typical SRTR
#' sources: OPTN (PERS_OPTN_DEATH_DT), SSA (PERS_SSA_DEATH_DT), then TFL (TFL_DEATH_DT).
#' By default it respects this precedence using `dplyr::coalesce()`. Optionally,
#' set `prefer_earliest = TRUE` to pick the earliest non-missing date instead.
#'
#' The three columns must be stored as `Date`, which is how [load_srtr_file()]
#' returns SAS date columns. You can also keep a "which source won" indicator
#' and a conflict flag when multiple sources disagree.
#'
#' @section How the sources compare in real data:
#' In the 2303 liver transplant file (TX_LI):
#'
#' * Among recipients with both dates, `TFL_DEATH_DT` matched the OPTN date on
#'   the same day in over 99%. Deaths recorded only in `TFL_DEATH_DT` were
#'   very rare (19 of about 87,000 recipients with any death date).
#' * Among recipients with both dates, the SSA date matched OPTN on the same
#'   day in about 82% and within a week in about 94%; differences ran in both
#'   directions.
#' * SSA recorded far fewer deaths than OPTN in recent years (under a quarter
#'   as many from 2015 on), consistent with the 2011 change to the SSA Death
#'   Master File. So for recent deaths a missing SSA date is weak evidence
#'   against a death reported to OPTN.
#' * Conflicts between sources were more frequent among earlier transplants.
#' * `prefer_earliest = TRUE` changed the date for under 5% of recipients with
#'   a death date, mostly by a week or less.
#'
#' Other releases and organs may differ.
#'
#' @param df A data frame.
#' @param optn,ssa,tfl Character column names for OPTN, SSA, and TFL death
#'   dates. Each must be a `Date` column.
#' @param out Name of the output composite column to create.
#' @param keep_source If TRUE, add `{out}_source` with the chosen source label.
#' @param add_conflict_flag If TRUE, add `{out}_conflict` when sources disagree.
#' @param prefer_earliest If TRUE, ignore precedence and choose the earliest date.
#' @return `df` with added composite column (and optional source/conflict columns).
#' @export
#' @examples
#' \dontrun{
#' df <- srtr_composite_death(df)
#' }
srtr_composite_death <- function(
  df,
  optn = "PERS_OPTN_DEATH_DT",
  ssa = "PERS_SSA_DEATH_DT",
  tfl = "TFL_DEATH_DT",
  out = "REC_DEATH_DT_COMPOSITE",
  keep_source = TRUE,
  add_conflict_flag = TRUE,
  prefer_earliest = FALSE
) {
  cols <- c(optn, ssa, tfl)
  check_columns(df, cols)
  check_date_columns(df, cols)

  vals <- lapply(cols, function(nm) df[[nm]])

  n <- NROW(df)

  if (prefer_earliest) {
    # earliest non-missing across sources
    comp <- do.call(pmin, c(vals, list(na.rm = TRUE)))
    # rows where all are NA should remain NA
    nn <- Reduce(`+`, lapply(vals, function(v) !is.na(v)))
    comp[nn == 0] <- as.Date(NA)
  } else {
    # precedence: OPTN > SSA > TFL
    comp <- do.call(dplyr::coalesce, vals)
  }

  df[[out]] <- comp

  if (keep_source) {
    src <- rep(NA_character_, n)
    if (!prefer_earliest) {
      i1 <- !is.na(vals[[1]])
      src[i1] <- cols[1]
      i2 <- !i1 & !is.na(vals[[2]])
      src[i2] <- cols[2]
      i3 <- !i1 & !i2 & !is.na(vals[[3]])
      src[i3] <- cols[3]
    } else {
      # choose the source whose date equals the selected earliest date (first tie wins by order)
      for (k in seq_along(vals)) {
        take <- is.na(src) &
          !is.na(vals[[k]]) &
          !is.na(comp) &
          vals[[k]] == comp
        src[take] <- cols[k]
      }
    }
    df[[paste0(out, "_source")]] <- src
  }

  if (add_conflict_flag) {
    # flag when more than one *distinct* non-missing date appears across sources
    num_mat <- do.call(cbind, lapply(vals, function(v) as.integer(v)))
    conflict <- apply(num_mat, 1, function(r) {
      u <- unique(r[!is.na(r)])
      length(u) > 1
    })
    df[[paste0(out, "_conflict")]] <- as.logical(conflict)
  }

  df
}
