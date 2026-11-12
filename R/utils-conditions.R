# Conditions signalled by sRtr
#
# Every error, warning and message from sRtr goes through these three
# wrappers around cli. Each condition carries two classes:
#   * a general one: "sRtr_error", "sRtr_warning" or "sRtr_message";
#   * a specific one built from `class`, e.g. class = "file_not_found" gives
#     "sRtr_error_file_not_found".
# Code and tests can then catch a condition by class instead of by its
# wording, so wording can improve without breaking anyone.
#
# `message` uses cli inline markup, interpolated in the caller's environment.

srtr_abort <- function(
  message,
  class = NULL,
  ...,
  call = rlang::caller_env(),
  .envir = parent.frame()
) {
  cli::cli_abort(
    message,
    class = .srtr_condition_class("error", class),
    ...,
    call = call,
    .envir = .envir
  )
}

srtr_warn <- function(message, class = NULL, ..., .envir = parent.frame()) {
  cli::cli_warn(
    message,
    class = .srtr_condition_class("warning", class),
    ...,
    .envir = .envir
  )
}

srtr_inform <- function(message, class = NULL, ..., .envir = parent.frame()) {
  cli::cli_inform(
    message,
    class = .srtr_condition_class("message", class),
    ...,
    .envir = .envir
  )
}

.srtr_condition_class <- function(type, class) {
  general <- paste0("sRtr_", type)
  if (is.null(class)) {
    return(general)
  }
  c(paste0(general, "_", class), general)
}

# Error if `data` lacks any of `cols`. Returns `data` invisibly.
check_columns <- function(
  data,
  cols,
  why = NULL,
  arg = rlang::caller_arg(data),
  call = rlang::caller_env()
) {
  missing <- setdiff(cols, names(data))
  if (length(missing) == 0) {
    return(invisible(data))
  }
  srtr_abort(
    c(
      "{.arg {arg}} is missing {length(missing)} required column{?s}: {.field {missing}}.",
      "i" = why
    ),
    class = "missing_columns",
    missing = missing,
    call = call
  )
}
