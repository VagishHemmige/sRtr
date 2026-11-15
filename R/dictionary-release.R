# Which dictionary a loaded file uses (#26)
#
# SRTR releases SAFs quarterly and names each release by year and month
# ("2609" is September 2026). sRtr stores the dictionary pages it has seen as
# snapshots (see R/dictionary-versions.R and the `dictionary_versions`
# dataset). For a file from a given release:
#   * a release with a stored snapshot uses it (its latest revision);
#   * a release between two snapshots uses every entry unchanged across the
#     gap, plus entries seen on only one side when the file has that column;
#     an entry whose attributes differ on the two sides is uncertain and is
#     handled by `gaps`;
#   * a release before the first or after the last snapshot uses that
#     snapshot, with a warning;
#   * no release uses the bundled `dictionary` and `formats` unchanged.
# The release comes from the `release` argument, then from set_srtr_wd(), then
# from a folder named like "pubsaf2609".

.srtr_bundled_versions <- function() {
  sRtr::dictionary_versions
}

.srtr_check_release <- function(release, call = rlang::caller_env()) {
  ok <- is.character(release) && length(release) == 1 && !is.na(release) &&
    grepl("^\\d{4}$", release) &&
    as.integer(substr(release, 3, 4)) %in% 1:12
  if (!ok) {
    srtr_abort(
      c(
        "{.arg release} must be one SAF release written as year and month, like {.val 2609}.",
        "x" = "Got {.val {release}}."
      ),
      class = "invalid_release",
      call = call
    )
  }
  release
}

# The release in a folder name like "pubsaf2609", in the folder or its
# parent, or NA.
.srtr_release_from_path <- function(path) {
  path <- gsub("\\\\", "/", path)
  for (name in c(basename(path), basename(dirname(path)))) {
    hit <- stringr::str_match(tolower(name), "^pubsaf(\\d{4})$")[, 2]
    if (!is.na(hit) && as.integer(substr(hit, 3, 4)) %in% 1:12) {
      return(hit)
    }
  }
  NA_character_
}

# The release recorded for the current SRTR_WD: set by set_srtr_wd(), or read
# from the folder name. Returns list(release, basis).
.srtr_current_release <- function() {
  wd <- Sys.getenv("SRTR_WD")
  state <- .srtr_env$release_state
  if (!is.null(state) && identical(state$wd, wd)) {
    return(list(release = state$release, basis = state$basis))
  }
  folder <- .srtr_release_from_path(wd)
  if (is.na(folder)) {
    return(list(release = NA_character_, basis = "none"))
  }
  list(release = folder, basis = "folder name")
}

.srtr_set_release_state <- function(wd, release, call = rlang::caller_env()) {
  folder <- .srtr_release_from_path(wd)
  if (!is.null(release)) {
    release <- .srtr_check_release(release, call = call)
    if (!is.na(folder) && folder != release) {
      srtr_warn(
        c(
          "The folder name gives release {.val {folder}}, but {.arg release} is {.val {release}}.",
          "i" = "Using {.val {release}}."
        ),
        class = "release_conflict"
      )
    }
    state <- list(wd = wd, release = release, basis = "supplied")
  } else if (!is.na(folder)) {
    state <- list(wd = wd, release = folder, basis = "folder name")
  } else {
    state <- list(wd = wd, release = NA_character_, basis = "none")
  }
  .srtr_env$release_state <- state
  invisible(state)
}

# The dictionary and formats for a release, with the `gaps` policy and the
# warning for a release outside the stored snapshots applied on every call.
# `columns` and `file_key`: the file's column names and dataset, used to
# decide entries seen on only one side of a gap; without them, such entries
# are left out. Returns list(dictionary, formats, snapshot, basis); `snapshot`
# is the stored snapshot used, or NA when none is used as a whole.
.srtr_dictionary_for <- function(
  release = NULL,
  versions = .srtr_bundled_versions(),
  columns = NULL,
  file_key = NULL,
  gaps = c("warn", "error", "nearest"),
  call = rlang::caller_env()
) {
  gaps <- rlang::arg_match(gaps)
  resolved <- .srtr_resolve_release(release, versions, columns, file_key, call = call)
  .srtr_enforce_release(resolved, gaps, call = call)
}

# The checks made on every use of a resolved release.
.srtr_enforce_release <- function(resolved, gaps, call = rlang::caller_env()) {
  if (!is.null(resolved$outside)) {
    srtr_warn(
      c(
        "No stored SRTR dictionary is close to release {.val {resolved$release}}; using snapshot {.val {resolved$snapshot}}.",
        "i" = "Stored snapshots: {.val {resolved$outside}}."
      ),
      class = "release_outside_snapshots",
      release = resolved$release,
      snapshot = resolved$snapshot
    )
  }
  uncertain <- resolved$uncertain
  if (length(uncertain) > 0 && gaps != "nearest") {
    release <- resolved$release
    text <- c(
      "{length(uncertain)} dictionary entr{?y/ies} changed between the stored snapshots around release {.val {release}}, so {?its/their} value at that release is not known: {.val {uncertain}}.",
      "i" = "Using the earlier snapshot's value. Set {.code gaps = \"nearest\"} to do so without this warning, or {.code gaps = \"error\"} to stop."
    )
    if (gaps == "error") {
      srtr_abort(text, class = "dictionary_gap", entries = uncertain, call = call)
    }
    srtr_warn(text, class = "dictionary_gap", entries = uncertain)
  }
  resolved[c("dictionary", "formats", "snapshot", "basis")]
}

# Work out the tables for a release without warning. Also returns `release`,
# `uncertain` (entries that changed across a gap) and `outside` (the stored
# snapshots, when the release is outside them).
.srtr_resolve_release <- function(release, versions, columns, file_key,
                                  call = rlang::caller_env()) {
  if (is.null(release)) {
    return(list(
      dictionary = sRtr::dictionary,
      formats = sRtr::formats,
      snapshot = NA_character_,
      basis = "default",
      release = NA_character_,
      uncertain = character(),
      outside = NULL
    ))
  }
  release <- .srtr_check_release(release, call = call)

  snapshots <- .srtr_sort_snapshots(versions$releases$snapshot)
  snapshot_release <- as.integer(substr(snapshots, 1, 4))
  r <- as.integer(release)
  whole <- function(id, basis, outside = NULL) {
    list(
      dictionary = .srtr_versions_view(versions, id, "dictionary"),
      formats = .srtr_versions_view(versions, id, "formats"),
      snapshot = id,
      basis = basis,
      release = release,
      uncertain = character(),
      outside = outside
    )
  }

  if (r %in% snapshot_release) {
    return(whole(utils::tail(snapshots[snapshot_release == r], 1), "observed"))
  }
  if (r > max(snapshot_release)) {
    return(whole(utils::tail(snapshots, 1), "nearest snapshot", outside = snapshots))
  }
  if (r < min(snapshot_release)) {
    return(whole(snapshots[1], "nearest snapshot", outside = snapshots))
  }

  dictionary <- .srtr_interpolate(
    versions$dictionary, snapshots, r, .srtr_versions_keys$dictionary,
    keep_one_sided = function(entry) {
      entry$Variable %in% columns &&
        (is.null(file_key) || entry$Dataset %in% toupper(file_key))
    }
  )
  formats <- .srtr_interpolate(
    versions$formats, snapshots, r, .srtr_versions_keys$formats,
    keep_one_sided = function(entry) TRUE
  )

  dict <- dictionary$table
  dict <- dict[order(dict$Dataset, dict$Variable, method = "radix"), ]
  fmt <- formats$table
  fmt <- fmt[order(fmt$Format, as.integer(fmt$Position), method = "radix"), ]
  list(
    dictionary = dict,
    formats = fmt[setdiff(names(fmt), "Position")],
    snapshot = NA_character_,
    basis = "interpolated",
    release = release,
    uncertain = c(dictionary$uncertain, formats$uncertain),
    outside = NULL
  )
}

# Entries for release `r` (an integer) that falls between stored snapshots.
#   * Runs that cover `r` (their first snapshot's release is before it and
#     their last one's after it) are kept.
#   * A key with no covering run but runs on both sides is kept with the
#     earlier side's value (the latest revision before `r`); if the two sides
#     differ, it is listed in `uncertain`.
#   * A key seen on only one side is kept when `keep_one_sided` says so.
# Snapshots are compared by their place in `snapshots` (release, then
# revision), so the latest revision of a release is preferred.
.srtr_interpolate <- function(runs, snapshots, r, key, keep_one_sided) {
  first_pos <- match(runs$first, snapshots)
  last_pos <- match(runs$last, snapshots)
  first_rel <- as.integer(substr(runs$first, 1, 4))
  last_rel <- as.integer(substr(runs$last, 1, 4))
  attrs <- setdiff(names(runs), c(key, "first", "last"))
  keys <- do.call(paste, c(runs[key], sep = "\r"))

  covers <- first_rel <= r & last_rel >= r
  covered <- unique(keys[covers])
  chosen <- list(runs[covers, ])
  uncertain <- character()

  gap_rows <- which(!covers & !keys %in% covered)
  for (k in unique(keys[gap_rows])) {
    rows <- gap_rows[keys[gap_rows] == k]
    before <- rows[last_rel[rows] < r]
    after <- rows[first_rel[rows] > r]
    earlier <- if (length(before) > 0) before[which.max(last_pos[before])] else NA
    later <- if (length(after) > 0) after[which.min(first_pos[after])] else NA
    if (!is.na(earlier) && !is.na(later)) {
      a <- as.list(runs[earlier, attrs])
      b <- as.list(runs[later, attrs])
      if (!isTRUE(all.equal(a, b, check.attributes = FALSE))) {
        uncertain <- c(uncertain, paste(unlist(runs[earlier, key]), collapse = " "))
      }
      chosen[[length(chosen) + 1]] <- runs[earlier, ]
    } else {
      pick <- if (!is.na(earlier)) earlier else later
      if (keep_one_sided(runs[pick, ])) {
        chosen[[length(chosen) + 1]] <- runs[pick, ]
      }
    }
  }
  table <- dplyr::bind_rows(chosen)
  list(
    table = table[setdiff(names(table), c("first", "last"))],
    uncertain = uncertain
  )
}

# The dictionary and formats for a data frame: the tables load_srtr_file() is
# using, while it labels the file; else the `release` argument, else the
# release recorded on `df` by load_srtr_file(), else the bundled tables. The
# resolution is cached for the session; the `gaps` policy is applied on every
# call.
.srtr_tables_for <- function(df, release, file_key, gaps = "warn",
                             columns = names(df),
                             call = rlang::caller_env()) {
  if (!is.null(.srtr_env$loading_tables)) {
    return(.srtr_env$loading_tables)
  }
  if (is.null(release)) {
    recorded <- attr(df, "srtr_release")$release
    if (!is.null(recorded) && !is.na(recorded)) {
      release <- recorded
    }
  }
  if (is.null(release)) {
    return(.srtr_dictionary_for(NULL))
  }
  versions <- .srtr_bundled_versions()
  columns <- sort(toupper(columns))
  stored <- paste(versions$releases$sha256, collapse = ",")
  key <- paste(stored, release, toupper(file_key), paste(columns, collapse = ","), sep = "|")
  cache <- .srtr_env$dictionary_cache
  if (is.null(cache)) {
    cache <- list()
  }
  if (is.null(cache[[key]])) {
    cache[[key]] <- .srtr_resolve_release(release, versions, columns, file_key, call = call)
    .srtr_env$dictionary_cache <- cache
  }
  .srtr_enforce_release(cache[[key]], gaps, call = call)
}

# Run `code` with the label and factor functions using `tables` (the
# loader's), instead of looking the dictionary up themselves.
.srtr_with_tables <- function(tables, code) {
  .srtr_env$loading_tables <- tables
  on.exit(.srtr_env$loading_tables <- NULL, add = TRUE)
  force(code)
}

#' SRTR data dictionary for a SAF release
#'
#' Returns the SRTR data dictionary, or its format code lists, as they were
#' for a SAF release. sRtr stores each version of SRTR's public dictionary
#' page it has seen (see [dictionary_versions]); a release between two stored
#' versions uses the entries that are the same in both.
#'
#' @param release The SAF release, as year and month (`"2609"` for September
#'   2026). If `NULL` (the default), the bundled [dictionary] or [formats].
#' @param table `"dictionary"` (the default) for variables, or `"formats"` for
#'   format code lists.
#' @param gaps For a release between two stored versions, what to do about a
#'   variable or format code whose definition changed between them: `"warn"`
#'   (the default) uses the earlier version with a warning, `"nearest"` does
#'   so silently, and `"error"` stops. Variables seen in only one of the two
#'   versions are left out, since whether they existed at that release cannot
#'   be known without the file; [load_srtr_file()] decides them from the file's
#'   columns. Format codes seen in only one are kept.
#'
#' @return A tibble with the columns of [dictionary] or [formats]. Its
#'   attributes `snapshot` (the stored version used, or `NA`) and `basis`
#'   (`"observed"`, `"interpolated"`, `"nearest snapshot"` or `"default"`) say
#'   where it came from. A release before the first or after the last stored
#'   version uses that version, with a warning.
#' @seealso [load_srtr_file()] and [set_srtr_wd()], which take a `release`.
#' @export
#'
#' @examples
#' current <- srtr_dictionary("2609")
#' attr(current, "snapshot")
#' head(srtr_dictionary("2609", table = "formats"))
srtr_dictionary <- function(
  release = NULL,
  table = c("dictionary", "formats"),
  gaps = c("warn", "error", "nearest")
) {
  table <- rlang::arg_match(table)
  gaps <- rlang::arg_match(gaps)
  out <- .srtr_dictionary_for(release, gaps = gaps)
  result <- out[[table]]
  attr(result, "snapshot") <- out$snapshot
  attr(result, "basis") <- out$basis
  result
}
