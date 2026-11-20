#' Normalize missing-value codes in SRTR data
#'
#' SRTR variables record missing information in many ways: "Unknown", "Not
#' done", "N/A", "Pending", blanks, and codes whose number differs from
#' variable to variable. `srtr_normalize_missing()` recognises these codes
#' from [missing_codes], by what they mean in each variable's own format,
#' and turns the ones you choose into `NA`.
#'
#' Which kinds become `NA` is a judgement that depends on the analysis, so
#' it is a choice. `policy` picks a sensible set in one word; `actions` and
#' `overrides` adjust it by kind of missing value and by variable. Run
#' [srtr_missing_report()] first to see what the data hold.
#'
#' @seealso Guides:
#' * [Choosing what becomes NA](https://vagishhemmige.github.io/sRtr/articles/missing-data.html#choosing-what-becomes-na)
#' * [Adjusting a policy](https://vagishhemmige.github.io/sRtr/articles/missing-data.html#adjusting-a-policy)
#' @details
#' # Policies
#'
#' | Kind (type) | `"analysis"` | `"strict"` | `"tag_only"` |
#' | --- | --- | --- | --- |
#' | `unknown`, `pending`, `cannot_disclose` | `NA` | `NA` | kept |
#' | `sas_missing` (blank) | `NA` | `NA` | kept |
#' | `not_done` (not done, not tested) | `NA` | `NA` | kept |
#' | `not_applicable` | kept | `NA` | kept |
#' | `indeterminate` | kept | `NA` | kept |
#' | `partial` (such as "Yes, duration unknown") | kept | `NA` | kept |
#'
#' * `"analysis"` removes what carries no information about the patient and
#'   keeps what does: "not applicable" and "indeterminate" are findings, and
#'   a partly known answer still says yes.
#' * `"strict"` leaves only substantive values.
#' * `"tag_only"` changes no value and adds a reason column for each
#'   variable that holds a recognised code.
#'
#' Whether "not done" is information depends on the question: a test that
#' was not ordered can itself be informative. Use
#' `actions = c(not_done = "keep")` to keep it.
#'
#' Values that are already `NA` stay `NA`. Values that a format does not
#' list are left alone.
#'
#' # Reason columns
#'
#' Once "unknown" and "not done" have both become `NA`, they can no longer
#' be told apart. `reason = "changed"` keeps that information: a column
#' named after the variable with `_MISS` added records the kind of each
#' value that was changed. It is `NA` for values that were not changed,
#' including values that were `NA` already, and a variable gets the column
#' only if one of its values changed. No reason columns are added by
#' default, because a wide file can gain hundreds of them.
#'
#' @param df A data frame from an SRTR SAF file. Raw codes and labelled
#'   columns (from [apply_srtr_factors()]) are handled alike.
#' @param cols Names of the columns to normalize. `NULL` (the default)
#'   takes every column that [missing_codes] covers.
#' @param policy The set of rules to start from: `"analysis"` (the
#'   default), `"strict"` or `"tag_only"`. See Policies.
#' @param actions Changes to the policy by kind of missing value: a named
#'   character vector such as `c(not_done = "keep", indeterminate = "na")`.
#'   Names are types from [missing_codes]; values are `"na"` or `"keep"`.
#' @param overrides Changes for single variables: a named list with one
#'   element per column, each a vector like `actions`, such as
#'   `list(REC_HIV_STAT = c(not_done = "keep"))`. These win over `actions`.
#' @param output `"replace"` (the default) changes the columns in place.
#'   `"append"` leaves them as they are and adds the normalized values in
#'   new columns named with `_NORM` added.
#' @param reason Which reason columns to add: `"none"` adds no columns;
#'   `"changed"` records the kind of each changed value; `"all"` records
#'   the kind of every recognised code, changed or not. `NULL` (the
#'   default) means `"none"`, except under `policy = "tag_only"`, where it
#'   means `"all"`. See Reason columns.
#' @param na_level A string, such as `"Missing"`, to use in place of `NA`
#'   in the normalized factor and character columns, so that missing values
#'   form their own group in a table. It covers values that were `NA`
#'   already. For a factor it becomes the last level. Numeric columns keep
#'   `NA`. `NULL` (the default) leaves `NA`.
#' @inheritParams srtr_missing_report
#' @param verbose If `TRUE`, report how many values were changed in how
#'   many variables.
#'
#' @return `df` with the chosen codes replaced, and any reason columns
#'   added at the end. For factors, the levels that became `NA` are removed; the
#'   other levels keep their order, so the reference level does not depend
#'   on the order of the rows. Ordered factors stay ordered, and attributes
#'   such as variable labels are kept.
#' @seealso [srtr_missing_report()], [missing_codes]
#' @export
#'
#' @examples
#' # Made-up rows using TX_KI column names
#' df <- data.frame(
#'   DON_ANTI_CMV = c("P", "N", "U", "ND", "I"),
#'   DON_HIST_DIAB = c(1, 5, 998, 998, 2)
#' )
#'
#' srtr_normalize_missing(df, file_key = "TX_KI")
#'
#' # Keep "not done" as a value
#' srtr_normalize_missing(
#'   df,
#'   actions = c(not_done = "keep"),
#'   file_key = "TX_KI"
#' )
#'
#' # Only substantive values, recording why each value became NA
#' srtr_normalize_missing(
#'   df,
#'   policy = "strict",
#'   reason = "changed",
#'   file_key = "TX_KI"
#' )
srtr_normalize_missing <- function(
  df,
  cols = NULL,
  policy = c("analysis", "strict", "tag_only"),
  actions = NULL,
  overrides = NULL,
  output = c("replace", "append"),
  reason = NULL,
  na_level = NULL,
  file_key = NULL,
  release = NULL,
  extra_codes = NULL,
  verbose = FALSE
) {
  if (is.list(cols)) {
    srtr_abort(
      c(
        "{.arg cols} must be a character vector of column names.",
        "i" = "The {.arg missing_vals} list was removed: codes are now recognised from {.code missing_codes}.",
        "i" = "Use {.arg extra_codes} for your own codes, and {.arg actions} or {.arg overrides} to choose what becomes {.code NA}."
      ),
      class = "missing_vals_removed"
    )
  }
  policy <- rlang::arg_match(policy)
  output <- rlang::arg_match(output)
  if (is.null(reason)) {
    reason <- if (policy == "tag_only") "all" else "none"
  }
  reason <- rlang::arg_match(reason, c("none", "changed", "all"))
  if (!is.null(na_level) && !rlang::is_string(na_level)) {
    srtr_abort(
      "{.arg na_level} must be a single string or {.code NULL}.",
      class = "invalid_na_level"
    )
  }

  rules <- .srtr_missing_rules(policy, actions, "actions")
  lookup <- .srtr_missing_lookup(df, cols, file_key, release, extra_codes)
  if (!is.null(overrides)) {
    if (!is.list(overrides) || !rlang::is_named(overrides)) {
      srtr_abort(
        "{.arg overrides} must be a named list, one element per column.",
        class = "invalid_actions"
      )
    }
    absent <- setdiff(names(overrides), names(df))
    if (length(absent) > 0) {
      srtr_abort(
        "Column{?s} in {.arg overrides} not in {.arg df}: {.field {absent}}.",
        class = "columns_not_found"
      )
    }
  }

  planned <- list()
  n_changed <- 0L
  n_variables <- 0L
  for (column in lookup) {
    name <- column$name
    x <- df[[name]]
    column_rules <- rules
    if (!is.null(overrides[[name]])) {
      column_rules <- .srtr_missing_rules(
        rules,
        overrides[[name]],
        "overrides"
      )
    }
    to_na <- names(column_rules)[column_rules == "na"]
    found <- .srtr_missing_match(
      x,
      column$format_rows,
      column$variable_rows,
      column$format,
      column$extra_rows
    )
    change <- found$type %in% to_na
    recognised <- found$type %in% names(column_rules)

    new <- x
    if (any(change)) {
      new[change] <- NA
      n_changed <- n_changed + sum(change)
      n_variables <- n_variables + 1L
    }
    if (is.factor(new)) {
      new <- .srtr_drop_levels(
        new,
        .srtr_missing_levels(new, column, to_na)
      )
    }
    fill <- !is.null(na_level) &&
      (is.factor(new) || is.character(new)) &&
      anyNA(new)
    if (fill) {
      if (is.factor(new) && !na_level %in% levels(new)) {
        levels(new) <- c(levels(new), na_level)
      }
      new[is.na(new)] <- na_level
    }

    tagged <- if (reason == "all") recognised else change
    planned[[name]] <- list(
      value = if (!identical(new, x)) new,
      reason = if (reason != "none" && any(tagged)) {
        ifelse(tagged, found$type, NA_character_)
      }
    )
  }

  added <- unlist(lapply(names(planned), function(name) {
    c(
      if (!is.null(planned[[name]]$reason)) paste0(name, "_MISS"),
      if (output == "append" && !is.null(planned[[name]]$value)) {
        paste0(name, "_NORM")
      }
    )
  }))
  clash <- intersect(added, names(df))
  if (length(clash) > 0) {
    srtr_abort(
      c(
        "{.arg df} already has column{?s} {.field {clash}}.",
        "i" = "Rename or remove {cli::qty(length(clash))}{?it/them} first."
      ),
      class = "column_exists"
    )
  }

  for (name in names(planned)) {
    value <- planned[[name]]$value
    if (!is.null(value)) {
      target <- if (output == "append") paste0(name, "_NORM") else name
      df[[target]] <- value
    }
  }
  for (name in names(planned)) {
    if (!is.null(planned[[name]]$reason)) {
      df[[paste0(name, "_MISS")]] <- planned[[name]]$reason
    }
  }

  if (verbose) {
    srtr_inform(
      "Changed {n_changed} value{?s} to {.code NA} in {n_variables} variable{?s}.",
      class = "missing_normalized"
    )
  }
  df
}

# What each policy does with each type: "na" or "keep".
.srtr_missing_policies <- list(
  analysis = c(
    unknown = "na",
    not_applicable = "keep",
    not_done = "na",
    pending = "na",
    cannot_disclose = "na",
    indeterminate = "keep",
    partial = "keep",
    sas_missing = "na"
  ),
  strict = c(
    unknown = "na",
    not_applicable = "na",
    not_done = "na",
    pending = "na",
    cannot_disclose = "na",
    indeterminate = "na",
    partial = "na",
    sas_missing = "na"
  ),
  tag_only = c(
    unknown = "keep",
    not_applicable = "keep",
    not_done = "keep",
    pending = "keep",
    cannot_disclose = "keep",
    indeterminate = "keep",
    partial = "keep",
    sas_missing = "keep"
  )
)

# The rules to use: `base` is a policy name or a full set of rules, and
# `changes` a named vector of the types to set differently. `arg` names the
# argument `changes` came from, for the error message.
.srtr_missing_rules <- function(
  base,
  changes,
  arg,
  call = rlang::caller_env()
) {
  rules <- if (is.character(base) && is.null(names(base))) {
    .srtr_missing_policies[[base]]
  } else {
    base
  }
  if (is.null(changes)) {
    return(rules)
  }
  valid <- is.character(changes) &&
    rlang::is_named(changes) &&
    all(names(changes) %in% names(rules)) &&
    all(changes %in% c("na", "keep"))
  if (!valid) {
    srtr_abort(
      c(
        "{.arg {arg}} must be a named character vector of {.val na} or {.val keep}.",
        "i" = "For example {.code c(not_done = \"keep\")}.",
        "i" = "Allowed names: {.val {names(rules)}}."
      ),
      class = "invalid_actions",
      call = call
    )
  }
  rules[names(changes)] <- changes
  rules
}

# The levels of factor `x` that stand for a type in `to_na`, whether or not
# any row still holds them, so that no empty "Unknown" level is left behind.
.srtr_missing_levels <- function(x, column, to_na) {
  found <- .srtr_missing_match(
    levels(x),
    column$format_rows,
    column$variable_rows,
    column$format,
    column$extra_rows,
    labelled = .srtr_already_factored(x),
    kept = attr(x, "srtr_kept_codes")
  )
  levels(x)[found$type %in% to_na]
}

# Remove `drop` from the levels of factor `x`. Values must already have been
# replaced, so no observation holds a dropped level. Attributes other than
# levels (class, variable label, ...) are kept; contrasts are removed because
# they are tied to the old set of levels.
.srtr_drop_levels <- function(x, drop) {
  keep <- setdiff(levels(x), as.character(drop))
  if (identical(keep, levels(x))) {
    return(x)
  }
  attrs <- attributes(x)
  attrs$contrasts <- NULL
  attrs$levels <- keep
  kept_codes <- attrs$srtr_kept_codes
  if (!is.null(kept_codes)) {
    kept_codes <- kept_codes[names(kept_codes) %in% keep]
    attrs$srtr_kept_codes <- if (length(kept_codes) > 0) kept_codes
  }
  codes <- match(levels(x)[x], keep)
  attributes(codes) <- attrs
  codes
}
