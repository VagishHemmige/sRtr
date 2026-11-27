# Small read-only wrappers around the git command line, used by the data
# protection functions. Each returns NULL when git is not installed or the
# command fails, so callers can fall back without git.

# Output lines of `git -C <path> <args>`, or NULL.
.srtr_git <- function(path, args) {
  git <- Sys.which("git")
  if (!nzchar(git)) {
    return(NULL)
  }
  out <- suppressWarnings(tryCatch(
    system2(git, c("-C", shQuote(path), args), stdout = TRUE, stderr = FALSE),
    error = function(e) NULL
  ))
  status <- attr(out, "status")
  if (is.null(out) || (!is.null(status) && status != 0)) NULL else out
}

# TRUE when `git -C <path> <args>` exits with status 0. NA without git.
.srtr_git_ok <- function(path, args) {
  git <- Sys.which("git")
  if (!nzchar(git)) {
    return(NA)
  }
  status <- suppressWarnings(tryCatch(
    system2(git, c("-C", shQuote(path), args), stdout = FALSE, stderr = FALSE),
    error = function(e) 1L
  ))
  identical(as.integer(status), 0L)
}

# The top folder of the work tree that holds `path`, or NULL.
.srtr_git_root <- function(path) {
  root <- .srtr_git(path, c("rev-parse", "--show-toplevel"))
  if (is.null(root) || length(root) != 1) NULL else root
}
