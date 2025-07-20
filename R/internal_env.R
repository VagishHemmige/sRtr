#' Internal environment for package-level state
#'
#' This environment is used to store internal session-specific state,
#' such as the file list loaded from `.map_SRTR_files()` or the STROBE derivation flow.
#' It is not exported and should not be accessed directly by users.
#'
#' @keywords internal
.srtr_env <- new.env(parent = emptyenv())

