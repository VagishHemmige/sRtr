#' Find files in a project that look like SRTR data
#'
#' @description
#' \ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}}
#'
#' Scans a project folder for files that look like SRTR standard analysis
#' file (SAF) data and that could be committed to git. It applies the same
#' three rules as the check that runs on sRtr's own repository on GitHub:
#'
#' - **Data formats:** files in the formats SAFs come in or are converted to
#'   (`.sas7bdat`, `.sas7bcat`, `.xpt`, `.parquet`, `.feather`, `.arrow`,
#'   `.dta`, `.sav`), in any letter case.
#' - **Identifier columns:** `.csv`, `.tsv` and `.txt` files whose first line
#'   names an SRTR identifier column (`TRR_ID`, `TRR_FOL_ID`, `PX_ID`,
#'   `PERS_ID`, `DONOR_ID`, `CAN_ID`, `TX_ID` or `REC_ID`). Files under
#'   `tests/testthat/fixtures/` whose names start with `synthetic-` are
#'   skipped, as in sRtr's own repository.
#' - **Large files:** any file over 5 MB, which may hold data in another
#'   format.
#'
#' The scan only reads: it lists files and reads the first line of text
#' files. It changes nothing.
#'
#' @section Which files are scanned:
#' In a git repository, the scan covers the files git would commit: tracked
#' files and untracked files that `.gitignore` does not exclude. A SAF that is
#' ignored is not reported. When `path` is not in a git repository, or git is
#' not installed, every file under `path` is scanned, except those in hidden
#' folders such as `.git`.
#'
#' The scan finds the usual formats and headers only. It does not find SRTR
#' data saved as `.rds` or `.RData` files, or text files without an
#' identifier column, so an empty result is not proof that a project holds no
#' SRTR data. See the
#' [data protection guide](https://vagishhemmige.github.io/sRtr/articles/data-protection.html).
#'
#' @param path The project folder to scan. Defaults to the working
#'   directory.
#' @param files Optional. Paths of files to check, relative to `path`,
#'   instead of the file list described under "Which files are scanned".
#'   Files that do not exist are skipped.
#' @param staged If `TRUE`, check the files staged for the next commit in
#'   the git repository that holds `path`, as they are staged rather than as
#'   they are in the folder. Paths in the result are then relative to the
#'   top of the repository. This is what [use_srtr_commit_check()]'s hook
#'   runs. Cannot be used with `files`.
#'
#' @return A tibble with one row per finding, returned invisibly: `path`
#'   (relative to the folder scanned), `problem` (`"data format"`,
#'   `"identifier column"`, `"unreadable file"` or `"large file"`) and
#'   `detail`. A text file whose first line cannot be read is reported as
#'   unreadable rather than passed as clean. A file can appear
#'   more than once. The scan warns, naming the paths only, when it finds
#'   anything, and gives a message when it finds nothing.
#'
#' @family data protection
#' @export
#'
#' @examples
#' # A made-up project with one file that looks like data
#' project <- file.path(tempdir(), "made-up-project")
#' dir.create(project, showWarnings = FALSE)
#' writeLines("TRR_ID,AGE", file.path(project, "cohort.csv"))
#' writeLines("x <- 1", file.path(project, "analysis.R"))
#'
#' findings <- check_repo_for_srtr_data(project)
#' findings
#'
#' unlink(project, recursive = TRUE)
check_repo_for_srtr_data <- function(path = ".", files = NULL, staged = FALSE) {
  if (!rlang::is_string(path) || !dir.exists(path)) {
    srtr_abort(
      c(
        "{.arg path} must be an existing folder.",
        "x" = "Folder not found:",
        " " = "{.path {path}}"
      ),
      class = "folder_not_found"
    )
  }
  if (!is.null(files) && !is.character(files)) {
    srtr_abort(
      "{.arg files} must be a character vector of paths, not {.obj_type_friendly {files}}.",
      class = "invalid_files"
    )
  }

  if (!rlang::is_bool(staged)) {
    srtr_abort("{.arg staged} must be `TRUE` or `FALSE`.", class = "invalid_staged")
  }
  if (staged && !is.null(files)) {
    srtr_abort("Give {.arg files} or {.code staged = TRUE}, not both.", class = "invalid_staged")
  }

  if (staged) {
    scan <- .srtr_staged_copy(path)
    on.exit(unlink(scan$copy, recursive = TRUE), add = TRUE)
    path <- scan$root
    findings <- .srtr_scan_for_data(scan$copy, scan$files)
  } else {
    scan <- if (is.null(files)) {
      .srtr_project_files(path)
    } else {
      list(files = files, method = "the files given")
    }
    candidates <- scan$files[file.exists(file.path(path, scan$files))]
    findings <- .srtr_scan_for_data(path, candidates)
  }

  if (nrow(findings) == 0) {
    srtr_inform(
      "No files that look like SRTR data in {.path {path}} ({scan$method}).",
      class = "no_srtr_data_found"
    )
    return(invisible(findings))
  }

  found <- unique(findings$path)
  srtr_warn(
    c(
      "{length(found)} file{?s} look{?s/} like SRTR data and could be committed from {.path {path}} ({scan$method}):",
      rlang::set_names(
        paste0("{.path ", .srtr_escape_braces(found), "} (",
          vapply(found, \(f) paste(findings$problem[findings$path == f], collapse = ", "), ""),
          ")"),
        rep("*", length(found))
      ),
      "i" = "Move SAFs and files made from them out of the project, or add them to {.file .gitignore}."
    ),
    class = "srtr_data_in_project",
    findings = findings
  )
  invisible(findings)
}

# The files git would commit (tracked, plus untracked and not ignored), or
# every file outside hidden folders when git cannot be used. Paths are
# relative to `path`.
.srtr_project_files <- function(path) {
  git_files <- .srtr_git_files(path)
  if (!is.null(git_files)) {
    return(list(files = git_files, method = "files git would commit"))
  }
  files <- fs::dir_ls(path, recurse = TRUE, type = "file", all = FALSE)
  files <- as.character(fs::path_rel(files, path))
  list(files = files, method = "folder scan; not a git repository")
}

# NULL when git is not installed or `path` is not inside a work tree.
.srtr_git_files <- function(path) {
  if (!identical(.srtr_git(path, c("rev-parse", "--is-inside-work-tree")), "true")) {
    return(NULL)
  }
  files <- .srtr_git_z(path, c("ls-files", "-z", "--cached", "--others", "--exclude-standard"))
  if (is.null(files)) NULL else unique(files)
}

# The files staged for the next commit (added, copied, modified or renamed),
# written as staged into a temporary folder under their repository paths.
# Returns list(root, copy, files, method); the caller deletes the copy.
# Errors when git cannot list or copy them, so a
# commit check never passes without having looked.
.srtr_staged_copy <- function(path, call = rlang::caller_env()) {
  root <- .srtr_git_root(path)
  if (is.null(root)) {
    srtr_abort(
      c(
        "{.code staged = TRUE} needs {.arg path} inside a git repository, and git installed.",
        "x" = "No git repository found for:",
        " " = "{.path {path}}"
      ),
      class = "not_a_git_repository",
      call = call
    )
  }
  fail <- function() {
    srtr_abort(
      "git could not list or copy the staged files, so they were not checked.",
      class = "staged_files_unavailable",
      call = call
    )
  }
  files <- .srtr_git_z(root, c("diff", "--cached", "--name-only", "-z", "--diff-filter=ACMR"))
  if (is.null(files)) {
    fail()
  }
  copy <- tempfile("srtr-staged-")
  dir.create(copy)
  copy <- normalizePath(copy, winslash = "/")
  if (length(files) > 0) {
    # Paths go to git on stdin, NUL-separated, so no name is ever quoted or
    # split by a shell.
    list_file <- tempfile("srtr-staged-list-")
    on.exit(unlink(list_file), add = TRUE)
    writeBin(unlist(lapply(files, \(f) c(charToRaw(f), as.raw(0)))), list_file)
    status <- suppressWarnings(tryCatch(
      system2(
        Sys.which("git"),
        c("-C", shQuote(root), "checkout-index", "-z", "--stdin",
          shQuote(paste0("--prefix=", copy, "/"))),
        stdin = list_file, stdout = FALSE, stderr = FALSE
      ),
      error = function(e) 1L
    ))
    if (!identical(as.integer(status), 0L) || !all(file.exists(file.path(copy, files)))) {
      unlink(copy, recursive = TRUE)
      fail()
    }
  }
  list(root = root, copy = copy, files = files, method = "staged files, as staged")
}

# Output of a git command run with -z, split on NUL as raw bytes (R strings
# cannot hold NUL, so the output goes through a temporary file). NULL when
# git is missing or the command fails.
.srtr_git_z <- function(path, args) {
  git <- Sys.which("git")
  if (!nzchar(git)) {
    return(NULL)
  }
  listing <- tempfile("srtr-git-")
  on.exit(unlink(listing), add = TRUE)
  status <- suppressWarnings(tryCatch(
    system2(git, c("-C", shQuote(path), args), stdout = listing, stderr = FALSE),
    error = function(e) 1L
  ))
  if (!identical(as.integer(status), 0L) || !file.exists(listing)) {
    return(NULL)
  }
  bytes <- readBin(listing, "raw", n = file.size(listing))
  ends <- which(bytes == as.raw(0))
  starts <- c(1L, utils::head(ends, -1) + 1L)
  files <- vapply(
    seq_along(ends),
    \(i) rawToChar(bytes[seq_len(ends[i] - starts[i]) + starts[i] - 1L]),
    character(1)
  )
  Encoding(files) <- "UTF-8"
  files[nzchar(files)]
}

.srtr_saf_extensions <- c(
  "sas7bdat", "sas7bcat", "xpt", "parquet", "feather", "arrow", "dta", "sav"
)
.srtr_id_columns <- c(
  "TRR_ID", "TRR_FOL_ID", "PX_ID", "PERS_ID", "DONOR_ID", "CAN_ID", "TX_ID",
  "REC_ID"
)
.srtr_large_file_bytes <- 5 * 1024^2

# Applies the three rules to `files` (relative to `path`).
.srtr_scan_for_data <- function(path, files) {
  empty <- tibble::tibble(
    path = character(), problem = character(), detail = character()
  )
  if (length(files) == 0) {
    return(empty)
  }
  ext <- tolower(tools::file_ext(files))
  full <- file.path(path, files)

  format_hits <- files[ext %in% .srtr_saf_extensions]
  formats <- tibble::tibble(
    path = format_hits,
    problem = rep("data format", length(format_hits)),
    detail = paste0(".", tools::file_ext(format_hits), " file")
  )

  # Paths from git use "/" on every platform; folder scans do too (fs).
  synthetic <- grepl("^tests/testthat/fixtures/synthetic-", files)
  text <- ext %in% c("csv", "tsv", "txt") & !synthetic
  id_cols <- lapply(full[text], .srtr_header_ids)
  unreadable <- vapply(id_cols, \(x) anyNA(x), logical(1))
  has_ids <- lengths(id_cols) > 0 & !unreadable
  ids <- tibble::tibble(
    path = files[text][has_ids],
    problem = rep("identifier column", sum(has_ids)),
    detail = vapply(id_cols[has_ids], paste, "", collapse = ", ")
  )
  failed <- tibble::tibble(
    path = files[text][unreadable],
    problem = rep("unreadable file", sum(unreadable)),
    detail = rep("its first line could not be read, so it was not checked", sum(unreadable))
  )

  size <- file.size(full)
  big <- !is.na(size) & size > .srtr_large_file_bytes
  large <- tibble::tibble(
    path = files[big],
    problem = rep("large file", sum(big)),
    detail = sprintf("%.1f MB", size[big] / 1024^2)
  )

  out <- dplyr::bind_rows(empty, formats, ids, failed, large)
  out[order(out$path, out$problem), ]
}

# The SRTR identifier columns named in a text file's first line, matched as
# whole fields in any letter case. NA when the line cannot be read, so a
# failed read is reported instead of passing as a clean file.
.srtr_header_ids <- function(file) {
  header <- tryCatch(
    suppressWarnings(.srtr_read_first_line(file)),
    error = function(e) NULL
  )
  if (is.null(header)) {
    return(NA_character_)
  }
  if (length(header) == 0) {
    return(character())
  }
  fields <- strsplit(header, "[,;\t]", useBytes = TRUE)[[1]]
  fields <- toupper(trimws(gsub("\"", "", fields, useBytes = TRUE)))
  intersect(.srtr_id_columns, fields)
}

# Separate so tests can make a read fail.
.srtr_read_first_line <- function(file) {
  readLines(file, n = 1, warn = FALSE, encoding = "bytes")
}

# cli interpolates braces, so literal braces in file names are doubled.
.srtr_escape_braces <- function(x) {
  gsub("\\}", "}}", gsub("\\{", "{{", x))
}
