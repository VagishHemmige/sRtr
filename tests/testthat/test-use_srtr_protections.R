test_that("use_srtr_gitignore() adds the SAF patterns once", {
  dir <- local_project_folder()
  writeLines(c("*.Rhistory", "*.[pP][aA][rR][qQ][uU][eE][tT]"), file.path(dir, ".gitignore"))

  expect_message(use_srtr_gitignore(dir), class = "sRtr_message_gitignore_updated")
  lines <- readLines(file.path(dir, ".gitignore"))
  expect_equal(lines[1:2], c("*.Rhistory", "*.[pP][aA][rR][qQ][uU][eE][tT]"))
  expect_setequal(intersect(lines, .srtr_gitignore_patterns()), .srtr_gitignore_patterns())
  expect_equal(sum(lines == "*.[pP][aA][rR][qQ][uU][eE][tT]"), 1)

  expect_message(use_srtr_gitignore(dir), class = "sRtr_message_gitignore_unchanged")
  expect_equal(readLines(file.path(dir, ".gitignore")), lines)
})

test_that("use_srtr_gitignore() creates a .gitignore and keeps a last line intact", {
  dir <- local_project_folder()
  suppressMessages(use_srtr_gitignore(dir))
  lines <- readLines(file.path(dir, ".gitignore"))
  expect_equal(lines[1], .srtr_gitignore_header)
  expect_equal(lines[-1], .srtr_gitignore_patterns())

  other <- local_project_folder()
  cat("*.log", file = file.path(other, ".gitignore"))
  suppressMessages(use_srtr_gitignore(other))
  expect_equal(readLines(file.path(other, ".gitignore"))[1:3], c("*.log", "", .srtr_gitignore_header))
})

test_that("the patterns make git ignore every SAF format in any case", {
  skip_if_not(nzchar(Sys.which("git")), "git is not installed")
  dir <- local_project_folder()
  system2("git", c("-C", shQuote(dir), "init", "-q"))
  suppressMessages(use_srtr_gitignore(dir))
  probes <- c(
    paste0("tx.", .srtr_saf_extensions),
    paste0("TX.", toupper(.srtr_saf_extensions)),
    "sub/Tx.Sas7Bdat"
  )
  ignored <- vapply(probes, \(f) .srtr_git_ok(dir, c("check-ignore", "-q", "--no-index", f)), logical(1))
  expect_equal(unname(ignored), rep(TRUE, length(probes)))
  expect_equal(.srtr_git_ok(dir, c("check-ignore", "-q", "--no-index", "tx.csv")), FALSE)
})

test_that("use_srtr_commit_check() installs the hook once and keeps other hooks", {
  skip_if_not(nzchar(Sys.which("git")), "git is not installed")
  dir <- local_project_folder()
  system2("git", c("-C", shQuote(dir), "init", "-q"))

  expect_message(
    hook <- use_srtr_commit_check(dir),
    class = "sRtr_message_commit_check_installed"
  )
  expect_equal(readLines(hook), .srtr_hook_script())
  expect_equal(normalizePath(dirname(hook)), normalizePath(file.path(dir, ".git", "hooks")))
  expect_message(use_srtr_commit_check(dir), class = "sRtr_message_commit_check_unchanged")

  writeLines(c("#!/bin/sh", "echo mine"), hook)
  expect_error(use_srtr_commit_check(dir), class = "sRtr_error_commit_hook_exists")
  expect_equal(readLines(hook), c("#!/bin/sh", "echo mine"))
})

test_that("the helpers need an existing folder, and the hook a git repository", {
  expect_error(use_srtr_gitignore(file.path(tempdir(), "no-such")), class = "sRtr_error_folder_not_found")
  expect_error(use_srtr_commit_check(file.path(tempdir(), "no-such")), class = "sRtr_error_folder_not_found")
  dir <- local_project_folder()
  expect_error(use_srtr_commit_check(dir), class = "sRtr_error_not_a_git_repository")
  expect_snapshot(
    error = TRUE,
    use_srtr_commit_check(dir),
    transform = \(x) gsub(dir, "<project>", x, fixed = TRUE)
  )
})
