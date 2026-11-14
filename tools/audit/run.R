Sys.setenv(SRTR_LIVE_TESTS = "false")
Sys.unsetenv("SRTR_WD")
args <- commandArgs(TRUE)
blank <- normalizePath(args[[3]], mustWork = TRUE)
# Some R launchers clear site-startup variables under --vanilla; restore for children.
Sys.setenv(R_ENVIRON = blank, R_ENVIRON_USER = blank,
           R_PROFILE = blank, R_PROFILE_USER = blank)
audit <- normalizePath(args[[1]], mustWork = TRUE)
mode <- match.arg(args[[2]], c("contracts", "installed"))
startup <- Sys.getenv(c("R_ENVIRON", "R_ENVIRON_USER", "R_PROFILE", "R_PROFILE_USER"))
stopifnot(all(nzchar(startup)), all(file.exists(startup)),
          all(file.info(startup)$size == 0))

# A non-vanilla child must ignore harmless project startup traps too.
probe <- tempfile("synthetic-startup-")
dir.create(probe)
writeLines('stop("synthetic profile was read")', file.path(probe, ".Rprofile"))
writeLines('SRTR_AUDIT_STARTUP_TRAP=yes', file.path(probe, ".Renviron"))
child <- file.path(probe, "child.R")
writeLines(c('stopifnot(Sys.getenv("SRTR_AUDIT_STARTUP_TRAP") == "",',
             'Sys.getenv("SRTR_LIVE_TESTS") == "false",',
             'Sys.getenv("SRTR_WD") == "")'), child)
old <- setwd(probe)
status <- system2(file.path(R.home("bin"), "Rscript"), shQuote(child))
setwd(old)
stopifnot(status == 0L)
cat("Child startup isolation: PASS\n")

# Only package source/public metadata; no user folders, original tests or SAFs.
root <- normalizePath(file.path(audit, "../.."))
work <- file.path(tempdir(), "sRtr")
dir.create(work)
for (item in c("R", "data", "man", "DESCRIPTION", "NAMESPACE", "LICENSE")) {
  stopifnot(file.copy(file.path(root, item), work, recursive = TRUE))
}
cat("Runtime:", R.version.string, "on", Sys.info()[["sysname"]], "\n")
for (pkg in c("testthat", "pkgload", "dplyr", "haven", "arrow", "sf")) {
  cat(pkg, as.character(utils::packageVersion(pkg)), "\n")
}
if (mode == "installed") {
  lib <- file.path(tempdir(), "library")
  dir.create(lib)
  status <- system2(file.path(R.home("bin"), "R"), c("CMD", "INSTALL",
    paste0("--library=", shQuote(lib)), shQuote(work)))
  if (status != 0L) quit(status = status)
  Sys.setenv(SRTR_AUDIT_LIBRARY = lib)
  status <- system2(file.path(R.home("bin"), "Rscript"),
    c("--vanilla", shQuote(file.path(audit, "installed.R"))))
  quit(status = status)
}
dir.create(file.path(work, "tests", "testthat"), recursive = TRUE)
stopifnot(all(file.copy(list.files(file.path(audit, "contracts"),
  full.names = TRUE), file.path(work, "tests", "testthat"))))
options(testthat.progress.max_fails = Inf, testthat.summary.max_reports = Inf)
result <- testthat::test_local(work, reporter = "summary", stop_on_failure = FALSE)
summary <- as.data.frame(result)
print(summary[c("test", "failed", "error", "warning", "skipped", "passed")],
      row.names = FALSE)
cat("TOTAL:", nrow(summary), "cases;", sum(summary$passed), "passed expectations;",
    sum(summary$failed), "failed expectations;", sum(summary$error), "errors;",
    sum(summary$skipped), "skips;", sum(summary$warning), "warnings\n")
quit(status = as.integer(any(summary$failed > 0 | summary$error)))
