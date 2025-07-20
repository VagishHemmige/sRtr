#' Retrieve the STROBE Derivation Log
#'
#' Returns the current STROBE tracking data frame containing the sequence of
#' filtering steps, labels, and counts of included and excluded observations.
#'
#' @return A data frame with the columns: `id`, `parent`, `label`, `filter`, `remaining`, `dropped`.
#' @export
#'
#' @examples
#' get_strobe_log()


get_strobe_log <- function() {
  if (is.null(.srtr_env$strobe_df)) {
    warning("No STROBE log initialized. Use `strobe_initialize()` first.")
    return(tibble::tibble())
  }

  return(.srtr_env$strobe_df)
}
