local_git_project <- function(env = parent.frame()) {
  skip_if_not(nzchar(Sys.which("git")), "git is not installed")
  withr::local_envvar(`_R_CHECK_PACKAGE_NAME_` = NA, .local_envir = env)
  withr::local_options(sRtr.safety_check = NULL, .local_envir = env)
  dir <- local_project_folder(env)
  system2("git", c("-C", shQuote(dir), "init", "-q"))
  dir
}

test_that("attaching in an unprotected repository reports what is missing", {
  dir <- local_git_project()
  writeLines("made up", file.path(dir, "tx.sas7bdat"))

  cnd <- expect_message(.srtr_attach_check(dir), class = "sRtr_message_safety_check")
  expect_s3_class(cnd, "packageStartupMessage")
  expect_equal(cnd$findings$path, "tx.sas7bdat")
  expect_snapshot(
    .srtr_attach_check(dir),
    transform = \(x) gsub(dir, "<project>", x, fixed = TRUE)
  )
  expect_no_message(suppressPackageStartupMessages(.srtr_attach_check(dir)))
})

test_that("attaching in a protected repository, or outside one, is silent", {
  dir <- local_git_project()
  suppressMessages(use_srtr_gitignore(dir))
  suppressMessages(use_srtr_commit_check(dir))
  writeLines("made up", file.path(dir, "ignored.sas7bdat"))
  expect_no_message(.srtr_attach_check(dir))

  expect_no_message(.srtr_attach_check(local_project_folder()))
})

test_that("a long list of files is cut to ten", {
  dir <- local_git_project()
  for (i in 1:12) writeLines("made up", file.path(dir, sprintf("f%02d.dta", i)))
  cnd <- expect_message(.srtr_attach_check(dir), class = "sRtr_message_safety_check")
  expect_match(conditionMessage(cnd), "and 2 more")
  expect_no_match(conditionMessage(cnd), "f11.dta")
})

test_that("uncovered formats and a pasted commit check are detected", {
  dir <- local_git_project()
  writeLines(c("*.sas7bdat", "*.SAS7BDAT"), file.path(dir, ".gitignore"))
  expect_equal(.srtr_uncovered_formats(dir), setdiff(.srtr_saf_extensions, "sas7bdat"))

  expect_equal(.srtr_commit_check_installed(dir), FALSE)
  hook <- file.path(dir, ".git", "hooks", "pre-commit")
  writeLines(c("#!/bin/sh", "echo mine", .srtr_hook_command), hook)
  expect_equal(.srtr_commit_check_installed(dir), TRUE)
})

test_that("the option and R CMD check turn the checks off", {
  withr::local_envvar(`_R_CHECK_PACKAGE_NAME_` = NA)
  withr::local_options(sRtr.safety_check = NULL)
  expect_equal(.srtr_safety_check_on(), TRUE)
  withr::with_options(list(sRtr.safety_check = FALSE), expect_equal(.srtr_safety_check_on(), FALSE))
  withr::with_envvar(c(`_R_CHECK_PACKAGE_NAME_` = "sRtr"), expect_equal(.srtr_safety_check_on(), FALSE))
})

test_that(".onAttach() never stops library()", {
  withr::local_envvar(`_R_CHECK_PACKAGE_NAME_` = NA)
  withr::local_options(sRtr.safety_check = NULL)
  local_mocked_bindings(.srtr_attach_check = function(path) stop("broken"))
  expect_no_error(.onAttach("lib", "sRtr"))

  local_mocked_bindings(.srtr_attach_check = function(path) stop("should not run"))
  withr::local_options(knitr.in.progress = TRUE)
  expect_no_error(.onAttach("lib", "sRtr"))
})

test_that("set_srtr_wd() warns about a SAF folder git would commit", {
  dir <- local_git_project()
  withr::local_envvar(SRTR_WD = NA)
  saf <- file.path(dir, "safs")
  dir.create(saf)

  expect_warning(set_srtr_wd(saf), class = "sRtr_warning_saf_folder_in_repository")
  expect_snapshot(
    set_srtr_wd(saf),
    transform = \(x) gsub(dir, "<project>", x, fixed = TRUE)
  )

  writeLines("safs/", file.path(dir, ".gitignore"))
  expect_no_warning(set_srtr_wd(saf))

  writeLines("", file.path(dir, ".gitignore"))
  withr::with_options(list(sRtr.safety_check = FALSE), expect_no_warning(set_srtr_wd(saf)))
  expect_no_warning(set_srtr_wd(local_project_folder()))
})
