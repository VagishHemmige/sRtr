#' Keep SAF files out of a project's git commits
#'
#' @description
#' \ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}}
#'
#' Two opt-in helpers for your own analysis project. Each writes only inside
#' the project folder you give it.
#'
#' - `use_srtr_gitignore()` adds patterns for the file formats SAFs come in
#'   (`.sas7bdat`, `.sas7bcat`, `.xpt`, `.parquet`, `.feather`, `.arrow`,
#'   `.dta`, `.sav`, in any letter case) to the project's `.gitignore`,
#'   creating the file if needed. Patterns already there are not added again.
#' - `use_srtr_commit_check()` installs a git pre-commit hook that runs
#'   [check_repo_for_srtr_data()] on the files staged for each commit and
#'   stops the commit when it finds any that look like SRTR data. It will not
#'   replace a pre-commit hook it did not write.
#'
#' @section Limits:
#' The `.gitignore` patterns catch the usual SAF formats only: not `.rds`,
#' `.RData` or `.csv` files made from a SAF, and `git add -f` overrides them.
#'
#' The commit hook lives in the project's own `.git` folder, so it is not
#' copied when someone clones the project; each person runs
#' `use_srtr_commit_check()` in their own copy. `git commit --no-verify`
#' skips it. It checks each staged file as it was staged, even when the
#' copy in the folder has changed since. It needs `Rscript` on the path that git uses
#' and sRtr installed in that R; if either is missing, it stops the commit
#' and says so. On Windows, Git for Windows runs the hook with its own shell,
#' so check once that a commit with a made-up `.sas7bdat` file is stopped.
#'
#' None of this makes a repository a safe place for SRTR data, and a private
#' repository is still a disclosure. See the
#' [data protection guide](https://vagishhemmige.github.io/sRtr/articles/data-protection.html).
#'
#' @param path The project folder. There is no default: these functions
#'   change files in the folder you name. For `use_srtr_commit_check()`, the
#'   folder must be inside a git repository; the hook is installed for that
#'   repository.
#'
#' @return The path of the file written, invisibly.
#'
#' @family data protection
#' @export
#'
#' @examples
#' project <- file.path(tempdir(), "made-up-project")
#' dir.create(project, showWarnings = FALSE)
#' use_srtr_gitignore(project)
#' readLines(file.path(project, ".gitignore"))
#'
#' # A second call adds nothing.
#' use_srtr_gitignore(project)
#'
#' unlink(project, recursive = TRUE)
use_srtr_gitignore <- function(path) {
  .srtr_check_project_path(path)
  gitignore <- file.path(path, ".gitignore")
  existing <- if (file.exists(gitignore)) {
    readLines(gitignore, warn = FALSE)
  } else {
    character()
  }

  patterns <- .srtr_gitignore_patterns()
  new <- setdiff(patterns, trimws(existing))
  if (length(new) == 0) {
    srtr_inform(
      c("v" = "{.file .gitignore} already has sRtr's SAF patterns:", " " = "{.path {gitignore}}"),
      class = "gitignore_unchanged"
    )
    return(invisible(gitignore))
  }

  block <- c("", .srtr_gitignore_header, new)
  if (length(existing) == 0) {
    block <- block[-1]
  }
  # Opened for appending so lines already in the file are left exactly as
  # they are; a file without a final newline gets one first.
  if (file.exists(gitignore) && .srtr_lacks_final_newline(gitignore)) {
    block <- c("", block)
  }
  con <- file(gitignore, open = "a")
  on.exit(close(con), add = TRUE)
  writeLines(block, con)

  srtr_inform(
    c(
      "v" = "Added {length(new)} SAF pattern{?s} to {.file .gitignore}:",
      " " = "{.path {gitignore}}",
      "i" = "Files git already tracks stay tracked; remove them with {.code git rm --cached <file>}."
    ),
    class = "gitignore_updated"
  )
  invisible(gitignore)
}

#' @rdname use_srtr_gitignore
#' @export
use_srtr_commit_check <- function(path) {
  .srtr_check_project_path(path)
  hook_rel <- .srtr_git(path, c("rev-parse", "--git-path", "hooks/pre-commit"))
  if (is.null(hook_rel) || length(hook_rel) != 1) {
    srtr_abort(
      c(
        "{.arg path} must be inside a git repository, and git must be installed.",
        "x" = "No git repository found for:",
        " " = "{.path {path}}"
      ),
      class = "not_a_git_repository"
    )
  }
  # --git-path gives a path relative to `path` unless it is absolute.
  hook <- if (.srtr_is_absolute(hook_rel)) hook_rel else file.path(path, hook_rel)

  if (file.exists(hook)) {
    current <- readLines(hook, warn = FALSE)
    if (any(current == .srtr_hook_marker)) {
      srtr_inform(
        c("v" = "The sRtr commit check is already installed:", " " = "{.path {hook}}"),
        class = "commit_check_unchanged"
      )
      return(invisible(hook))
    }
    command <- .srtr_hook_command
    srtr_abort(
      c(
        "The repository already has a pre-commit hook that sRtr did not write, so it was left unchanged:",
        " " = "{.path {hook}}",
        "i" = "To add the check to it, add this line to that hook:",
        " " = "{.code {command}}"
      ),
      class = "commit_hook_exists"
    )
  }

  dir.create(dirname(hook), showWarnings = FALSE, recursive = TRUE)
  writeLines(.srtr_hook_script(), hook)
  Sys.chmod(hook, mode = "0755")
  srtr_inform(
    c(
      "v" = "Installed the sRtr commit check:",
      " " = "{.path {hook}}",
      "i" = "Each commit is now stopped when a staged file looks like SRTR data. {.code git commit --no-verify} skips the check."
    ),
    class = "commit_check_installed"
  )
  invisible(hook)
}

.srtr_gitignore_header <- "# SRTR data: never commit (added by sRtr::use_srtr_gitignore())"

# One case-insensitive pattern per SAF format, as in sRtr's own .gitignore.
.srtr_gitignore_patterns <- function() {
  vapply(.srtr_saf_extensions, function(ext) {
    letters <- strsplit(ext, "")[[1]]
    bracketed <- ifelse(
      grepl("[a-z]", letters),
      paste0("[", letters, toupper(letters), "]"),
      letters
    )
    paste0("*.", paste(bracketed, collapse = ""))
  }, character(1), USE.NAMES = FALSE)
}

.srtr_hook_marker <- "# sRtr commit check (installed by sRtr::use_srtr_commit_check())"

# One line that runs the check on the staged files and exits non-zero when it
# finds anything, or when R or sRtr cannot be found. Single quotes only, so it
# survives being pasted into another hook.
.srtr_hook_command <- paste0(
  "Rscript -e 'if (!requireNamespace(\"sRtr\", quietly = TRUE)) ",
  "{ message(\"sRtr commit check: sRtr is not installed in this R.\"); quit(status = 1) }; ",
  "x <- suppressMessages(sRtr::check_repo_for_srtr_data(\".\", staged = TRUE)); ",
  "if (nrow(x) > 0) quit(status = 1)' || exit 1"
)

.srtr_hook_script <- function() {
  c(
    "#!/bin/sh",
    .srtr_hook_marker,
    "# Stops a commit when a staged file looks like SRTR data.",
    "# Skip once with: git commit --no-verify",
    "if ! command -v Rscript >/dev/null 2>&1; then",
    "  echo \"sRtr commit check: Rscript was not found, so the commit was stopped.\" >&2",
    "  echo \"Put R on the path git uses, or skip once with git commit --no-verify.\" >&2",
    "  exit 1",
    "fi",
    "cd \"$(git rev-parse --show-toplevel)\" || exit 1",
    .srtr_hook_command
  )
}

.srtr_check_project_path <- function(path, call = rlang::caller_env()) {
  if (!rlang::is_string(path) || !dir.exists(path)) {
    srtr_abort(
      c(
        "{.arg path} must be an existing folder.",
        "x" = "Folder not found:",
        " " = "{.path {path}}"
      ),
      class = "folder_not_found",
      call = call
    )
  }
  invisible(path)
}

.srtr_is_absolute <- function(path) {
  grepl("^(/|[A-Za-z]:[/\\\\]|\\\\\\\\)", path)
}

.srtr_lacks_final_newline <- function(file) {
  size <- file.size(file)
  if (is.na(size) || size == 0) {
    return(FALSE)
  }
  con <- file(file, open = "rb")
  on.exit(close(con), add = TRUE)
  seek(con, size - 1)
  readBin(con, "raw", n = 1) != as.raw(10)
}
