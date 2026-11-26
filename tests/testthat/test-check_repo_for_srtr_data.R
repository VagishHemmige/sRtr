test_that("a folder scan finds data formats, identifier headers and large files", {
  dir <- local_project_folder()
  writeLines("made up", file.path(dir, "tx.SAS7BDAT"))
  writeLines("made up", file.path(dir, "cohort.parquet"))
  writeLines("\"trr_id\",AGE", file.path(dir, "ids.csv"))
  writeLines("AGE\tSEX", file.path(dir, "no_ids.tsv"))
  writeLines("x <- 1", file.path(dir, "analysis.R"))
  dir.create(file.path(dir, "sub"))
  writeLines("PX_ID;TX_ID", file.path(dir, "sub", "nested.txt"))
  writeBin(raw(6 * 1024^2), file.path(dir, "big.bin"))

  expect_warning(
    found <- check_repo_for_srtr_data(dir),
    class = "sRtr_warning_srtr_data_in_project"
  )
  expect_equal(
    found$path,
    c("big.bin", "cohort.parquet", "ids.csv", "sub/nested.txt", "tx.SAS7BDAT")
  )
  expect_equal(
    found$problem,
    c("large file", "data format", "identifier column", "identifier column",
      "data format")
  )
  expect_equal(found$detail[found$path == "sub/nested.txt"], "PX_ID, TX_ID")
  expect_equal(found$detail[found$path == "ids.csv"], "TRR_ID")
})

test_that("the warning names paths only, and a clean folder gives a message", {
  withr::local_options(rlib_message_verbosity = "verbose")
  dir <- local_project_folder()
  writeLines("x <- 1", file.path(dir, "analysis.R"))
  expect_message(
    found <- check_repo_for_srtr_data(dir),
    class = "sRtr_message_no_srtr_data_found"
  )
  expect_equal(nrow(found), 0)
  expect_named(found, c("path", "problem", "detail"))

  writeLines("TRR_ID,AGE", file.path(dir, "{odd} name.csv"))
  writeLines("made up", file.path(dir, "tx.sas7bdat"))
  expect_snapshot(
    check_repo_for_srtr_data(dir),
    transform = \(x) gsub(dir, "<project>", x, fixed = TRUE)
  )
})

test_that("synthetic fixtures and hidden folders are skipped", {
  dir <- local_project_folder()
  fixtures <- file.path(dir, "tests", "testthat", "fixtures")
  dir.create(fixtures, recursive = TRUE)
  writeLines("TRR_ID,AGE", file.path(fixtures, "synthetic-tx.csv"))
  writeLines("TRR_ID,AGE", file.path(fixtures, "real-tx.csv"))
  dir.create(file.path(dir, ".hidden"))
  writeLines("made up", file.path(dir, ".hidden", "tx.sas7bdat"))

  expect_warning(
    found <- check_repo_for_srtr_data(dir),
    class = "sRtr_warning_srtr_data_in_project"
  )
  expect_equal(found$path, "tests/testthat/fixtures/real-tx.csv")
})

test_that("in a git repository, ignored files are not reported", {
  skip_if_not(nzchar(Sys.which("git")), "git is not installed")
  dir <- local_project_folder()
  system2("git", c("-C", shQuote(dir), "init", "-q"))
  writeLines("*.sas7bdat", file.path(dir, ".gitignore"))
  writeLines("made up", file.path(dir, "ignored.sas7bdat"))
  writeLines("made up", file.path(dir, "untracked.dta"))
  writeLines("TRR_ID", file.path(dir, "tracked.csv"))
  system2("git", c("-C", shQuote(dir), "add", "tracked.csv"))

  expect_warning(
    found <- check_repo_for_srtr_data(dir),
    "files git would commit",
    class = "sRtr_warning_srtr_data_in_project"
  )
  expect_equal(found$path, c("tracked.csv", "untracked.dta"))
})

test_that("files limits the check to the paths given", {
  dir <- local_project_folder()
  writeLines("made up", file.path(dir, "a.sas7bdat"))
  writeLines("made up", file.path(dir, "b.sas7bdat"))

  expect_warning(
    found <- check_repo_for_srtr_data(dir, files = c("b.sas7bdat", "gone.dta")),
    class = "sRtr_warning_srtr_data_in_project"
  )
  expect_equal(found$path, "b.sas7bdat")
})

test_that("bad arguments are errors", {
  expect_error(
    check_repo_for_srtr_data(file.path(tempdir(), "no-such-folder")),
    class = "sRtr_error_folder_not_found"
  )
  expect_error(
    check_repo_for_srtr_data(tempdir(), files = 1),
    class = "sRtr_error_invalid_files"
  )
  expect_snapshot(error = TRUE, check_repo_for_srtr_data(tempdir(), files = 1))
})
