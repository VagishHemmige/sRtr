# Work out which SRTR dataset a data frame comes from, for the label
# functions. In order: the `file_key` argument, the data frame's `file_key`
# attribute, then the name of the object passed as `df`. Returns the key in
# upper case, or NULL (after a warning) when there is no usable key, so the
# caller can return the data unchanged.
.srtr_resolve_file_key <- function(
  df,
  file_key,
  df_arg,
  verbose,
  call = rlang::caller_env()
) {
  from <- "argument"
  if (is.null(file_key)) {
    file_key <- attr(df, "file_key")
    from <- "attribute"
  }
  if (is.null(file_key)) {
    if (!is.symbol(df_arg)) {
      srtr_warn(
        c(
          "Could not work out {.arg file_key}, so nothing was labeled.",
          "i" = "The data frame has no {.code file_key} attribute and was not passed by name.",
          "i" = "Supply {.arg file_key}, for example {.code file_key = \"TX_KI\"}."
        ),
        class = "file_key_not_inferred"
      )
      return(NULL)
    }
    file_key <- as.character(df_arg)
    from <- "name"
  }

  if (!rlang::is_string(file_key)) {
    srtr_abort(
      "{.arg file_key} must be a single string.",
      class = "invalid_file_key",
      call = call
    )
  }
  file_key <- toupper(file_key)

  if (verbose && from == "attribute") {
    srtr_inform(
      "Using {.arg file_key} {.val {file_key}} from the data frame's attribute.",
      class = "file_key_inferred"
    )
  }
  if (verbose && from == "name") {
    srtr_inform(
      "Using {.arg file_key} {.val {file_key}} from the object name.",
      class = "file_key_inferred"
    )
  }

  if (!file_key %in% sRtr::dictionary$Dataset) {
    srtr_warn(
      c(
        "{.val {file_key}} is not a dataset in the bundled SRTR data dictionary, so nothing was labeled.",
        "i" = "Supply {.arg file_key}, for example {.code file_key = \"TX_KI\"}."
      ),
      class = "unknown_file_key"
    )
    return(NULL)
  }

  file_key
}
