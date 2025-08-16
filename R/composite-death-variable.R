#' Composite death date (OPTN > SSA > TFL)
#'
#' Builds a composite death date column using precedence across the typical SRTR
#' sources: OPTN (PERS_OPTN_DEATH_DT), SSA (PERS_SSA_DEATH_DT), then TFL (TFL_DEATH_DT).
#' By default it respects this precedence using `dplyr::coalesce()`. Optionally,
#' set `prefer_earliest = TRUE` to pick the earliest non-missing date instead.
#'
#' Columns are parsed with `.srtr_as_date()` to accept YYYYMMDD integers/strings.
#' You can also keep a "which source won" indicator and a conflict flag when
#' multiple sources disagree.
#'
#' @param df A data frame.
#' @param optn,ssa,tfl Character column names for OPTN, SSA, and TFL death dates.
#' @param out Name of the output composite column to create.
#' @param parse If TRUE, parse the three inputs with `.srtr_as_date()`.
#' @param keep_source If TRUE, add `{out}_source` with the chosen source label.
#' @param add_conflict_flag If TRUE, add `{out}_conflict` when sources disagree.
#' @param prefer_earliest If TRUE, ignore precedence and choose the earliest date.
#' @return `df` with added composite column (and optional source/conflict columns).
#' @export
#' @examples
#' \dontrun{
#' df <- srtr_composite_death(df)
#' }
srtr_composite_death <- function(df,
                                 optn = "PERS_OPTN_DEATH_DT",
                                 ssa  = "PERS_SSA_DEATH_DT",
                                 tfl  = "TFL_DEATH_DT",
                                 out  = "REC_DEATH_DT_COMPOSITE",
                                 parse = TRUE,
                                 keep_source = TRUE,
                                 add_conflict_flag = TRUE,
                                 prefer_earliest = FALSE) {
  cols <- c(optn, ssa, tfl)
  stopifnot(all(cols %in% names(df)))

  vals <- lapply(cols, function(nm) df[[nm]])
  if (parse) vals <- lapply(vals, .srtr_as_date)

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
        take <- is.na(src) & !is.na(vals[[k]]) & !is.na(comp) & vals[[k]] == comp
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
