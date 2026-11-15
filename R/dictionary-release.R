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

# The dictionary and formats for a release. `columns` and `file_key`: the
# file's column names and dataset, used to decide entries seen on only one
# side of a gap; without them, such entries are left out. Returns
# list(dictionary, formats, snapshot, basis); `snapshot` is the stored
# snapshot used, or NA when none is used as a whole.
.srtr_dictionary_for <- function(
  release = NULL,
  versions = .srtr_bundled_versions(),
  columns = NULL,
  file_key = NULL,
  gaps = c("warn", "error", "nearest"),
  call = rlang::caller_env()
) {
  gaps <- rlang::arg_match(gaps)
  if (is.null(release)) {
    return(list(
      dictionary = sRtr::dictionary,
      formats = sRtr::formats,
      snapshot = NA_character_,
      basis = "default"
    ))
  }
  release <- .srtr_check_release(release, call = call)

  snapshots <- .srtr_sort_snapshots(versions$releases$snapshot)
  snapshot_release <- substr(snapshots, 1, 4)
  whole <- function(id, basis) {
    list(
      dictionary = .srtr_versions_view(versions, id, "dictionary"),
      formats = .srtr_versions_view(versions, id, "formats"),
      snapshot = id,
      basis = basis
    )
  }

  if (release %in% snapshot_release) {
    return(whole(utils::tail(snapshots[snapshot_release == release], 1), "observed"))
  }
  r <- as.integer(release)
  if (r > max(as.integer(snapshot_release)) || r < min(as.integer(snapshot_release))) {
    id <- if (r > max(as.integer(snapshot_release))) utils::tail(snapshots, 1) else snapshots[1]
    srtr_warn(
      c(
        "No stored SRTR dictionary is close to release {.val {release}}; using snapshot {.val {id}}.",
        "i" = "Stored snapshots: {.val {snapshots}}."
      ),
      class = "release_outside_snapshots",
      release = release,
      snapshot = id
    )
    return(whole(id, "nearest snapshot"))
  }

  dictionary <- .srtr_interpolate(
    versions$dictionary, snapshots, r, .srtr_versions_keys$dictionary,
    keep_gap = function(gap) {
      gap$Variable %in% columns && (is.null(file_key) || gap$Dataset %in% toupper(file_key))
    }
  )
  formats <- .srtr_interpolate(
    versions$formats, snapshots, r, .srtr_versions_keys$formats,
    keep_gap = function(gap) rep(TRUE, nrow(gap))
  )
  uncertain <- c(
    paste(dictionary$uncertain[[1]], dictionary$uncertain[[2]]),
    paste(formats$uncertain[[1]], formats$uncertain[[2]])
  )
  uncertain <- uncertain[nzchar(trimws(uncertain))]
  if (length(uncertain) > 0 && gaps != "nearest") {
    text <- c(
      "{length(uncertain)} dictionary entr{?y/ies} changed between the stored snapshots around release {.val {release}}, so {?its/their} value at that release is not known: {.val {uncertain}}.",
      "i" = "Using the earlier snapshot's value. Set {.code gaps = \"nearest\"} to do so without this warning, or {.code gaps = \"error\"} to stop."
    )
    if (gaps == "error") {
      srtr_abort(text, class = "dictionary_gap", entries = uncertain, call = call)
    }
    srtr_warn(text, class = "dictionary_gap", entries = uncertain)
  }

  dict <- dictionary$table
  dict <- dict[order(dict$Dataset, dict$Variable, method = "radix"), ]
  fmt <- formats$table
  fmt <- fmt[order(fmt$Format, as.integer(fmt$Position), method = "radix"), ]
  list(
    dictionary = dict,
    formats = fmt[setdiff(names(fmt), "Position")],
    snapshot = NA_character_,
    basis = "interpolated"
  )
}

# Entries for release `r` (an integer) between stored snapshots: runs that
# cover `r`, plus, for keys with no covering run that `keep_gap` keeps, the
# nearest run (the earlier one when there is one). Keys whose earlier and
# later runs differ are returned in `uncertain`.
.srtr_interpolate <- function(runs, snapshots, r, key, keep_gap) {
  first <- as.integer(substr(runs$first, 1, 4))
  last <- as.integer(substr(runs$last, 1, 4))
  attrs <- setdiff(names(runs), c(key, "first", "last"))
  covering <- runs[first <= r & last >= r, ]
  rest <- runs[!(first <= r & last >= r), ]
  rest_first <- first[!(first <= r & last >= r)]
  rest_last <- last[!(first <= r & last >= r)]
  covered_keys <- do.call(paste, c(covering[key], sep = "\r"))
  rest_keys <- do.call(paste, c(rest[key], sep = "\r"))
  gap <- rest[!rest_keys %in% covered_keys, ]
  gap_first <- rest_first[!rest_keys %in% covered_keys]
  gap_last <- rest_last[!rest_keys %in% covered_keys]
  gap_keys <- rest_keys[!rest_keys %in% covered_keys]

  chosen <- list()
  uncertain <- rep(list(character()), length(key))
  for (k in unique(gap_keys)) {
    rows <- which(gap_keys == k)
    before <- rows[gap_last[rows] < r]
    after <- rows[gap_first[rows] > r]
    pick <- if (length(before) > 0) before[which.max(gap_last[before])] else after[which.min(gap_first[after])]
    if (!keep_gap(gap[pick, ])) {
      next
    }
    if (length(before) > 0 && length(after) > 0) {
      a <- gap[before[which.max(gap_last[before])], attrs]
      b <- gap[after[which.min(gap_first[after])], attrs]
      if (!isTRUE(all.equal(as.list(a), as.list(b), check.attributes = FALSE))) {
        for (i in seq_along(key)) {
          uncertain[[i]] <- c(uncertain[[i]], gap[[key[i]]][pick])
        }
      }
    }
    chosen[[length(chosen) + 1]] <- gap[pick, ]
  }
  table <- dplyr::bind_rows(c(list(covering), chosen))
  list(
    table = table[setdiff(names(table), c("first", "last"))],
    uncertain = uncertain
  )
}

# The dictionary and formats for a data frame: the `release` argument, else
# the release recorded on `df` by load_srtr_file(), else the bundled tables.
# Results are cached for the session by release, dataset and columns, so a
# warning about a gap is given once, by the first function that meets it.
.srtr_tables_for <- function(df, release, file_key, gaps = "warn",
                             columns = names(df),
                             call = rlang::caller_env()) {
  if (is.null(release)) {
    recorded <- attr(df, "srtr_release")$release
    if (!is.null(recorded) && !is.na(recorded)) {
      release <- recorded
    }
  }
  if (is.null(release)) {
    return(.srtr_dictionary_for(NULL))
  }
  columns <- sort(toupper(columns))
  stored <- paste(.srtr_bundled_versions()$releases$sha256, collapse = ",")
  key <- paste(stored, release, toupper(file_key), paste(columns, collapse = ","), sep = "|")
  cache <- .srtr_env$dictionary_cache
  if (is.null(cache)) {
    cache <- list()
  }
  if (!is.null(cache[[key]])) {
    return(cache[[key]])
  }
  out <- .srtr_dictionary_for(
    release,
    columns = columns,
    file_key = file_key,
    gaps = gaps,
    call = call
  )
  cache[[key]] <- out
  .srtr_env$dictionary_cache <- cache
  out
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
#'   format code whose meaning changed between them: `"warn"` (the default)
#'   uses the earlier version with a warning, `"nearest"` does so silently, and
#'   `"error"` stops. Variables seen in only one of the two versions are left
#'   out, since whether they existed at that release cannot be known without
#'   the file; [load_srtr_file()] decides them from the file's columns.
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
