# test_loader.R
#
# Unit tests for the `get_SRTR_table()` function in the sRtr package.
# These tests validate that the SRTR loader function:
#   - Returns a data frame
#   - Loads expected columns
#   - Handles missing or invalid input gracefully
#
# These tests need real SAF files: they run only when SRTR_LIVE_TESTS=true and
# SRTR_WD are set (see helper-srtr.R).

test_that("load_srtr_file loads expected data and attaches metadata", {
  skip_if_no_srtr_data()

  result <- load_srtr_file("TX_HR", factor_labels = TRUE, var_labels = TRUE)

  # Check return type and content
  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)
  expect_true("PX_ID" %in% names(result)) # Adjust to match a known column

  # Check attached attributes
  expect_true(!is.null(attr(result, "source_path")))
  expect_true(!is.null(attr(result, "file_key")))
  expect_match(attr(result, "file_key"), "TX_HR", ignore.case = TRUE)
  expect_type(attr(result, "source_path"), "character")
  expect_true(file.exists(attr(result, "source_path")))
})

# Offline tests below: empty placeholder files in a temporary folder, with the
# file readers mocked. No real or realistic SAF is read or written.

local_srtr_folder <- function(files, env = parent.frame()) {
  dir <- withr::local_tempdir(.local_envir = env)
  file.create(file.path(dir, files))
  withr::local_envvar(SRTR_WD = dir, .local_envir = env)
  saved <- as.list(.srtr_env, all.names = TRUE)
  rm(list = ls(.srtr_env, all.names = TRUE), envir = .srtr_env)
  withr::defer(
    {
      rm(list = ls(.srtr_env, all.names = TRUE), envir = .srtr_env)
      list2env(saved, envir = .srtr_env)
    },
    envir = env
  )
  dir
}

fake_read_sas <- function(data_file, ...) {
  tibble::tibble(trr_id = 900001, source = basename(data_file))
}

load_fake <- function(file_key) {
  load_srtr_file(file_key, factor_labels = FALSE, var_labels = FALSE)
}

test_that("the folder is scanned on first use, without set_srtr_wd()", {
  local_srtr_folder("TX_KI.sas7bdat")
  local_mocked_bindings(read_sas = fake_read_sas, .package = "haven")

  out <- load_fake("TX_KI")

  expect_equal(out$SOURCE, "TX_KI.sas7bdat")
  expect_equal(attr(out, "file_key"), "TX_KI")
})

test_that("a file added after the first scan is found", {
  dir <- local_srtr_folder("TX_KI.sas7bdat")
  local_mocked_bindings(read_sas = fake_read_sas, .package = "haven")
  load_fake("TX_KI")

  file.create(file.path(dir, "TX_LI.sas7bdat"))
  out <- load_fake("TX_LI")

  expect_equal(out$SOURCE, "TX_LI.sas7bdat")
})

test_that("changing SRTR_WD switches to the new folder", {
  local_srtr_folder("TX_KI.sas7bdat")
  local_mocked_bindings(read_sas = fake_read_sas, .package = "haven")
  load_fake("TX_KI")

  new_dir <- withr::local_tempdir()
  file.create(file.path(new_dir, "TX_KI.sas7bdat"))
  withr::local_envvar(SRTR_WD = new_dir)
  out <- load_fake("TX_KI")

  expect_equal(attr(out, "source_path"), file.path(new_dir, "TX_KI.sas7bdat"))
})

test_that("an unset SRTR_WD gives an error that says what to do", {
  local_srtr_folder(character())
  withr::local_envvar(SRTR_WD = NA)
  expect_error(load_fake("TX_KI"), class = "sRtr_error_srtr_wd_unset")
  expect_snapshot(error = TRUE, load_fake("TX_KI"))
})

test_that("an SRTR_WD folder that does not exist gives an error", {
  dir <- local_srtr_folder(character())
  # A short relative path keeps the snapshot the same on every OS.
  withr::local_dir(dir)
  withr::local_envvar(SRTR_WD = "no-such-folder")
  expect_error(load_fake("TX_KI"), class = "sRtr_error_srtr_wd_missing")
  expect_snapshot(error = TRUE, load_fake("TX_KI"))
})

test_that("an unknown file key names the folder searched", {
  dir <- local_srtr_folder("TX_KI.sas7bdat")
  expect_error(load_fake("TX_LI"), class = "sRtr_error_file_not_found")
  # The path sits on its own line of the message, so a long temporary
  # folder (macOS, Windows) cannot change where the text wraps.
  expect_snapshot(
    error = TRUE,
    load_fake("TX_LI"),
    transform = function(x) gsub(dir, "<SRTR_WD>", x, fixed = TRUE)
  )
})

test_that("trr_id_filter uses the TRR_ID column, never a global object", {
  local_srtr_folder("TX_KI.sas7bdat")
  local_mocked_bindings(
    read_sas = function(data_file, ...) tibble::tibble(source = c("a", "b")),
    .package = "haven"
  )
  assign("TRR_ID", 900001, envir = globalenv())
  withr::defer(rm("TRR_ID", envir = globalenv()))

  expect_error(
    load_srtr_file(
      "TX_KI",
      trr_id_filter = 900001,
      factor_labels = FALSE,
      var_labels = FALSE
    ),
    class = "rlang_error"
  )
})

test_that("arrow.skip_nul is set only while a parquet file is read", {
  local_srtr_folder("TX_KI.parquet")
  withr::local_options(arrow.skip_nul = NULL)
  local_mocked_bindings(
    read_parquet = function(file, ...) {
      tibble::tibble(skip_nul = getOption("arrow.skip_nul", FALSE))
    },
    .package = "arrow"
  )

  out <- load_fake("TX_KI")

  expect_equal(out$SKIP_NUL, TRUE)
  expect_null(getOption("arrow.skip_nul"))
})
