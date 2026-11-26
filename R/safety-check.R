# Data safety checks run without being asked: when sRtr is attached, and when
# set_srtr_wd() is given a folder. Both only read, name paths and never
# values, and are turned off with options(sRtr.safety_check = FALSE). They
# are skipped during R CMD check, so a package check never depends on the
# folder it runs in.

.srtr_safety_check_on <- function() {
  isTRUE(getOption("sRtr.safety_check", TRUE)) &&
    !nzchar(Sys.getenv("_R_CHECK_PACKAGE_NAME_"))
}

# At attach: if `path` is in a git repository, report files git would commit
# that look like SRTR data, SAF formats the repository's ignore rules do not
# cover, and a missing commit check. Silent when there is nothing to report.
.srtr_attach_check <- function(path) {
  root <- .srtr_git_root(path)
  if (is.null(root)) {
    return(invisible())
  }
  # Each part runs on its own, so one that fails does not hide what the
  # others found; a failure is reported without its error text.
  incomplete <- FALSE
  attempt <- function(expr, fallback) {
    tryCatch(expr, error = function(e) {
      incomplete <<- TRUE
      fallback
    })
  }
  findings <- attempt(
    {
      files <- .srtr_git_files(root)
      if (is.null(files)) {
        incomplete <- TRUE
        NULL
      } else {
        .srtr_scan_for_data(root, files)
      }
    },
    NULL
  )
  uncovered <- attempt(.srtr_uncovered_formats(root), character())
  hook <- attempt(.srtr_commit_check_installed(root), NA)

  if (NROW(findings) == 0 && length(uncovered) == 0 && !isFALSE(hook) && !incomplete) {
    return(invisible())
  }

  add_gitignore <- sprintf("sRtr::use_srtr_gitignore(\"%s\")", root)
  add_hook <- sprintf("sRtr::use_srtr_commit_check(\"%s\")", root)
  lines <- c("sRtr data safety check of the git repository at {.path {root}}:")
  if (NROW(findings) > 0) {
    found <- unique(findings$path)
    shown <- utils::head(found, 10)
    lines <- c(
      lines,
      "!" = "{length(found)} file{?s} look{?s/} like SRTR data and git would commit {?it/them}:",
      rlang::set_names(
        paste0("{.path ", .srtr_escape_braces(shown), "}"),
        rep(" ", length(shown))
      ),
      if (length(found) > length(shown)) {
        c(" " = paste("and", length(found) - length(shown), "more; run {.code sRtr::check_repo_for_srtr_data()} from the repository for the full list."))
      }
    )
  }
  if (length(uncovered) > 0) {
    lines <- c(
      lines,
      "i" = "Git does not ignore {length(uncovered)} SAF format{?s} ({.val {uncovered}}). Add the patterns with {.code {add_gitignore}}."
    )
  }
  if (isFALSE(hook)) {
    lines <- c(
      lines,
      "i" = "No commit check is installed. Add one with {.code {add_hook}}."
    )
  }
  if (incomplete) {
    lines <- c(
      lines,
      "!" = "Part of this check could not run, so the report may be incomplete. Run {.code sRtr::check_repo_for_srtr_data()} from the repository to scan it."
    )
  }
  lines <- c(
    lines,
    "i" = "Turn this check off with {.code options(sRtr.safety_check = FALSE)}."
  )
  srtr_startup_inform(
    lines,
    class = "safety_check",
    findings = findings,
    incomplete = incomplete
  )
  invisible()
}

# In set_srtr_wd(): warn when the SAF folder is inside a git repository and
# git does not ignore it.
.srtr_check_saf_folder <- function(folder) {
  if (!.srtr_safety_check_on()) {
    return(invisible())
  }
  root <- tryCatch(.srtr_git_root(folder), error = function(e) NULL)
  if (is.null(root)) {
    return(invisible())
  }
  ignored <- .srtr_git_ok(folder, c("check-ignore", "-q", "."))
  if (!isFALSE(ignored)) {
    return(invisible())
  }
  srtr_warn(
    c(
      "Your SAF folder is inside a git repository, and git does not ignore it.",
      "i" = "SAF folder:",
      " " = "{.path {folder}}",
      "i" = "Repository:",
      " " = "{.path {root}}",
      "i" = "Move the SAFs out of the repository, or add the folder to the repository's {.file .gitignore}.",
      "i" = "Turn this check off with {.code options(sRtr.safety_check = FALSE)}."
    ),
    class = "saf_folder_in_repository"
  )
  invisible()
}

# The SAF formats (as file extensions) that git would not ignore in `root`,
# in lower or upper case.
.srtr_uncovered_formats <- function(root) {
  ignored <- vapply(.srtr_saf_extensions, function(ext) {
    probes <- paste0("sRtr-probe.", c(ext, toupper(ext)))
    all(vapply(
      probes,
      \(f) isTRUE(.srtr_git_ok(root, c("check-ignore", "-q", "--no-index", f))),
      logical(1)
    ))
  }, logical(1))
  .srtr_saf_extensions[!ignored]
}

# TRUE when the repository's pre-commit hook would run sRtr's check: git
# can run it (executable, except on Windows, where Git for Windows runs hooks
# whatever their mode) and a line that is not a comment calls
# sRtr::check_repo_for_srtr_data(). FALSE otherwise, including for a hook
# sRtr cannot recognize. NA when git cannot say where the hook is.
.srtr_commit_check_installed <- function(root) {
  hook <- .srtr_git(root, c("rev-parse", "--git-path", "hooks/pre-commit"))
  if (is.null(hook) || length(hook) != 1) {
    return(NA)
  }
  if (!.srtr_is_absolute(hook)) {
    hook <- file.path(root, hook)
  }
  if (!file.exists(hook)) {
    return(FALSE)
  }
  if (.Platform$OS.type != "windows" && file.access(hook, mode = 1) != 0) {
    return(FALSE)
  }
  lines <- trimws(readLines(hook, warn = FALSE))
  active <- lines[!startsWith(lines, "#")]
  any(grepl("sRtr::check_repo_for_srtr_data(", active, fixed = TRUE))
}
