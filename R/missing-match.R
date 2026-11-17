# Finding missing-value codes in data. Shared by srtr_missing_report() and
# the normalizer, so both agree on what counts as which kind of missing.

# For each column of `df` that the classification covers, the rows of the
# two tables that apply to it. Returns a list with one element per column:
#   name          the column name as it is in `df`
#   format        the variable's format, or NA
#   format_rows   the format's codes (Code, Meaning, missing_type); the type
#                 is NA for an ordinary code
#   variable_rows the variable's rows of the variables table
#   extra_rows    the caller's own codes for the variable (Code,
#                 missing_type); these win over the two tables
.srtr_missing_lookup <- function(
  df,
  cols,
  file_key,
  release,
  extra_codes = NULL,
  call = rlang::caller_env()
) {
  if (!is.data.frame(df)) {
    srtr_abort(
      "{.arg df} must be a data frame.",
      class = "invalid_data",
      call = call
    )
  }
  if (is.null(cols)) {
    cols <- names(df)
  } else {
    absent <- setdiff(cols, names(df))
    if (length(absent) > 0) {
      srtr_abort(
        "Column{?s} not in {.arg df}: {.field {absent}}.",
        class = "columns_not_found",
        call = call
      )
    }
  }

  extra_codes <- .srtr_missing_extra(extra_codes, names(df), call)

  if (is.null(file_key)) {
    file_key <- attr(df, "file_key")
  }
  if (!is.null(file_key)) {
    if (!rlang::is_string(file_key)) {
      srtr_abort(
        "{.arg file_key} must be a single string.",
        class = "invalid_file_key",
        call = call
      )
    }
    file_key <- toupper(file_key)
    if (!file_key %in% sRtr::dictionary$Dataset) {
      srtr_abort(
        "{.val {file_key}} is not a dataset in the SRTR data dictionary.",
        class = "unknown_file_key",
        call = call
      )
    }
    tables <- .srtr_tables_for(df, release, file_key, call = call)
  } else {
    if (is.null(release)) {
      release <- attr(df, "srtr_release")$release
      if (!is.null(release) && is.na(release)) {
        release <- NULL
      }
    }
    tables <- .srtr_dictionary_for(release, call = call)
  }

  dictionary <- tables$dictionary
  dictionary <- dictionary[
    !is.na(dictionary$FormatID) & dictionary$FormatID != "",
  ]
  if (!is.null(file_key)) {
    dictionary <- dictionary[dictionary$Dataset == file_key, ]
  }
  dictionary <- unique(data.frame(
    Variable = toupper(dictionary$Variable),
    Format = sub("^fmt_", "", dictionary$FormatID)
  ))
  dictionary <- dictionary[dictionary$Format %in% tables$formats$Format, ]

  classified <- sRtr::missing_codes$formats
  classified <- classified[classified$missing_type != "none", ]
  by_variable <- sRtr::missing_codes$variables
  class_key <- paste(
    classified$Format,
    classified$Code,
    classified$Meaning,
    sep = "\r"
  )

  ambiguous <- character()
  lookup <- list()
  for (name in cols) {
    x <- df[[name]]
    upper <- toupper(name)
    format <- attr(x, "srtr_format")
    if (is.null(format)) {
      format <- dictionary$Format[dictionary$Variable == upper]
    }
    if (length(format) > 1) {
      ambiguous <- c(ambiguous, name)
      next
    }
    if (length(format) == 0) {
      format <- NA_character_
    }
    codes <- tables$formats[tables$formats$Format %in% format, ]
    format_rows <- data.frame(
      Code = codes$Code,
      Meaning = codes$Meaning,
      missing_type = classified$missing_type[match(
        paste(codes$Format, codes$Code, codes$Meaning, sep = "\r"),
        class_key
      )]
    )
    variable_rows <- by_variable[
      by_variable$Variable == upper,
      c("Code", "missing_type")
    ]
    extra_rows <- extra_codes[[name]]
    if (
      all(is.na(format_rows$missing_type)) &&
        nrow(variable_rows) == 0 &&
        is.null(extra_rows)
    ) {
      next
    }
    lookup[[length(lookup) + 1]] <- list(
      name = name,
      format = format,
      format_rows = format_rows,
      variable_rows = variable_rows,
      extra_rows = extra_rows
    )
  }

  if (is.null(file_key)) {
    srtr_inform(
      c(
        "No {.arg file_key}, so variables were looked up by name alone.",
        if (length(ambiguous) > 0) {
          c(
            "!" = "Skipped, because the format differs between datasets: {.field {ambiguous}}.",
            "i" = "Supply {.arg file_key}, for example {.code file_key = \"TX_KI\"}, to include {cli::qty(length(ambiguous))}{?it/them}."
          )
        }
      ),
      class = "no_file_key"
    )
  }
  lookup
}

# What each value of one column stands for. Returns list(type, code), each
# as long as `x`: `type` is a missing type, "not_in_format", "na" for a
# value that is already NA, or NA for an ordinary value; `code` is the
# classified code that matched, and NA otherwise. `code` never holds a value
# from the data that is not a classified code, so that nothing but
# documented codes can reach a report.
#
# A value is compared with both the codes and the meanings of the format,
# so raw and labelled columns give the same answer; a test checks that no
# missing meaning doubles as an ordinary code of the same format. A value
# the format does not list takes the type of the format's catch-all when
# that is classified, and is "not_in_format" when there is no catch-all.
#
# apply_srtr_factors() keeps a code its format does not list under a name
# made of the code and a suffix, and records which level stands for which
# code in the `srtr_kept_codes` attribute. `kept` is that record: through it
# a level is turned back into its code before the variables table and the
# caller's own codes are consulted, so labelling does not change the
# answer. The name is never parsed, because a raw value may itself end in
# the suffix; a column without the record is not guessed at.
.srtr_missing_match <- function(
  x,
  format_rows,
  variable_rows,
  format,
  extra_rows = NULL,
  labelled = .srtr_already_factored(x),
  kept = attr(x, "srtr_kept_codes")
) {
  is_na <- is.na(x)
  values <- as.character(x)
  type <- rep(NA_character_, length(values))
  code <- rep(NA_character_, length(values))
  outside <- rep(FALSE, length(values))

  banded <- format %in% .srtr_range_formats && !labelled
  if (!is.null(format_rows) && nrow(format_rows) > 0 && !banded) {
    other <- format_rows[format_rows$Code == .srtr_other_code, ]
    listed <- format_rows[format_rows$Code != .srtr_other_code, ]
    by_code <- match(values, listed$Code)
    by_meaning <- match(values, listed$Meaning)
    row <- if (labelled) {
      dplyr::coalesce(by_meaning, by_code)
    } else {
      dplyr::coalesce(by_code, by_meaning)
    }
    type <- listed$missing_type[row]
    code <- ifelse(is.na(type), NA_character_, listed$Code[row])
    outside <- !is_na & is.na(row)
    if (nrow(other) > 0) {
      # An unlisted value belongs to the catch-all, as does its label.
      type[outside] <- other$missing_type[1]
      code[outside & !is.na(type)] <- .srtr_other_code
      outside[] <- FALSE
    }
  }

  plain <- values
  if (labelled && !is.null(kept)) {
    is_kept <- values %in% names(kept)
    plain[is_kept] <- unname(kept[values[is_kept]])
  }

  if (!is.null(variable_rows) && nrow(variable_rows) > 0) {
    row <- match(plain, variable_rows$Code)
    use <- !is.na(row) & is.na(type)
    type[use] <- variable_rows$missing_type[row[use]]
    code[use] <- variable_rows$Code[row[use]]
    outside[use] <- FALSE
  }

  if (!is.null(extra_rows) && nrow(extra_rows) > 0) {
    row <- match(plain, extra_rows$Code)
    use <- !is.na(row)
    type[use] <- extra_rows$missing_type[row[use]]
    code[use] <- extra_rows$Code[row[use]]
    outside[use] <- FALSE
  }

  type[outside] <- "not_in_format"
  code[outside] <- NA_character_
  type[is_na] <- "na"
  code[is_na] <- NA_character_
  list(type = type, code = code)
}

# Check the caller's own codes: a named list, one element per column of the
# data, each a named character vector of the form c(value = "type").
# Returns a list of data frames (Code, missing_type) by column name.
.srtr_missing_extra <- function(extra_codes, columns, call) {
  if (is.null(extra_codes)) {
    return(list())
  }
  allowed <- setdiff(.srtr_missing_types, c("none", "partial"))
  well_formed <- is.list(extra_codes) &&
    rlang::is_named(extra_codes) &&
    all(vapply(
      extra_codes,
      function(codes) {
        is.character(codes) &&
          rlang::is_named(codes) &&
          all(codes %in% allowed)
      },
      logical(1)
    ))
  if (!well_formed) {
    srtr_abort(
      c(
        "{.arg extra_codes} must be a named list of named character vectors.",
        "i" = "For example {.code list(MY_VAR = c(\"9\" = \"unknown\"))}.",
        "i" = "Allowed types: {.val {allowed}}."
      ),
      class = "invalid_extra_codes",
      call = call
    )
  }
  absent <- setdiff(names(extra_codes), columns)
  if (length(absent) > 0) {
    srtr_abort(
      "Column{?s} in {.arg extra_codes} not in {.arg df}: {.field {absent}}.",
      class = "columns_not_found",
      call = call
    )
  }
  lapply(extra_codes, function(codes) {
    data.frame(Code = names(codes), missing_type = unname(codes))
  })
}
