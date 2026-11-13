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

# The fake files below are not whole SAFs, so the dictionary column check is
# turned off; it has its own tests at the end of this file.
load_fake <- function(file_key) {
  load_srtr_file(
    file_key,
    factor_labels = FALSE,
    var_labels = FALSE,
    column_check = "none"
  )
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
      var_labels = FALSE,
      column_check = "none"
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

# Column selection (#98). Small synthetic files written to a temporary
# folder; the values are made up and only the column names come from the
# data dictionary.

fake_tx <- function() {
  tibble::tibble(
    TRR_ID = c(900001, 900002, 900003),
    PX_ID = c(800001, 800002, 800003),
    REC_AGE_AT_TX = c(1, 2, 3),
    REC_BMI = c(10, 20, 30)
  )
}

fake_tx_kp <- function() {
  tibble::tibble(
    TRR_ID = c(900001, 900002, 900003),
    REC_AGE_AT_TX = c(1, 2, 3),
    TFL_LAFUDATEKI = as.Date(c("2001-01-01", NA, "2001-01-01")),
    TFL_LAFUDATEPA = as.Date(c("2002-01-01", "2002-01-01", NA))
  )
}

local_sas_file <- function(data, file_key, env = parent.frame()) {
  dir <- local_srtr_folder(character(), env = env)
  withr::local_options(lifecycle_verbosity = "quiet")
  haven::write_sas(data, file.path(dir, paste0(file_key, ".sas7bdat")))
  dir
}

load_cols <- function(file_key, ..., column_check = "none") {
  load_srtr_file(
    file_key,
    factor_labels = FALSE,
    var_labels = FALSE,
    column_check = column_check,
    ...
  )
}

test_that("col_select takes a character vector", {
  local_sas_file(fake_tx(), "TX_KI")

  out <- load_cols("TX_KI", col_select = c("REC_BMI", "TRR_ID"))

  expect_named(out, c("REC_BMI", "TRR_ID"))
  expect_equal(out$REC_BMI, c(10, 20, 30))
})

test_that("col_select takes a tidyselect expression", {
  local_sas_file(fake_tx(), "TX_KI")

  out <- load_cols("TX_KI", col_select = tidyselect::starts_with("REC_"))
  expect_named(out, c("REC_AGE_AT_TX", "REC_BMI"))

  out <- load_cols("TX_KI", col_select = c(TRR_ID, REC_BMI))
  expect_named(out, c("TRR_ID", "REC_BMI"))
})

test_that("col_select uses the upper-case names the result has", {
  data <- fake_tx()
  names(data) <- tolower(names(data))
  local_sas_file(data, "TX_KI")

  out <- load_cols("TX_KI", col_select = c("TRR_ID", "REC_BMI"))

  expect_named(out, c("TRR_ID", "REC_BMI"))
})

test_that("col_select naming a column the file lacks is an error", {
  local_sas_file(fake_tx(), "TX_KI")

  expect_error(
    load_cols("TX_KI", col_select = "NOT_A_COLUMN"),
    class = "vctrs_error_subscript_oob"
  )
})

test_that("col_select can't rename columns", {
  local_sas_file(fake_tx(), "TX_KI")

  expect_error(
    load_cols("TX_KI", col_select = c(age = REC_AGE_AT_TX)),
    class = "rlang_error"
  )
})

test_that("trr_id_filter works when col_select leaves out TRR_ID", {
  local_sas_file(fake_tx(), "TX_KI")

  out <- load_cols("TX_KI", col_select = "REC_BMI", trr_id_filter = 900002)

  expect_named(out, "REC_BMI")
  expect_equal(out$REC_BMI, 20)
})

test_that("trr_id_filter on a file with no TRR_ID column is an error", {
  data <- fake_tx()
  data$TRR_ID <- NULL
  local_sas_file(data, "TX_KI")

  expect_error(
    load_cols("TX_KI", col_select = "REC_BMI", trr_id_filter = 900002),
    class = "sRtr_error_missing_columns"
  )
  expect_snapshot(
    error = TRUE,
    load_cols("TX_KI", col_select = "REC_BMI", trr_id_filter = 900002)
  )
})

test_that("TX_KP without col_select still gets TFL_LAFUDATE", {
  local_sas_file(fake_tx_kp(), "TX_KP")

  out <- load_cols("TX_KP")

  expect_equal(
    out$TFL_LAFUDATE,
    as.Date(c("2002-01-01", "2002-01-01", "2001-01-01"))
  )
})

test_that("a TX_KP subset without the follow-up dates loads", {
  local_sas_file(fake_tx_kp(), "TX_KP")

  out <- load_cols("TX_KP", col_select = "TRR_ID")

  expect_named(out, "TRR_ID")
})

test_that("TX_KP col_select can ask for TFL_LAFUDATE by name", {
  local_sas_file(fake_tx_kp(), "TX_KP")

  out <- load_cols("TX_KP", col_select = c("TRR_ID", "TFL_LAFUDATE"))

  expect_named(out, c("TRR_ID", "TFL_LAFUDATE"))
  expect_equal(
    out$TFL_LAFUDATE,
    as.Date(c("2002-01-01", "2002-01-01", "2001-01-01"))
  )
})

test_that("TX_KP selecting both follow-up dates still adds TFL_LAFUDATE", {
  local_sas_file(fake_tx_kp(), "TX_KP")

  out <- load_cols("TX_KP", col_select = c("TFL_LAFUDATEKI", "TFL_LAFUDATEPA"))

  expect_named(out, c("TFL_LAFUDATEKI", "TFL_LAFUDATEPA", "TFL_LAFUDATE"))
})

test_that("TFL_LAFUDATE can't be derived without both follow-up dates", {
  data <- fake_tx_kp()
  data$TFL_LAFUDATEPA <- NULL
  local_sas_file(data, "TX_KP")

  expect_error(
    load_cols("TX_KP", col_select = "TFL_LAFUDATE"),
    class = "sRtr_error_missing_columns"
  )
  expect_snapshot(error = TRUE, load_cols("TX_KP", col_select = "TFL_LAFUDATE"))
})

test_that("TX_KP without col_select and a follow-up date missing is an error", {
  data <- fake_tx_kp()
  data$TFL_LAFUDATEPA <- NULL
  local_sas_file(data, "TX_KP")

  expect_error(load_cols("TX_KP"), class = "sRtr_error_missing_columns")
  expect_snapshot(error = TRUE, load_cols("TX_KP"))
})

test_that("parquet col_select is passed to read_parquet() as col_select", {
  local_srtr_folder("TX_KI.parquet")
  seen <- NULL
  local_mocked_bindings(.srtr_file_template = function(...) fake_tx()[0, ])
  local_mocked_bindings(
    read_parquet = function(file, col_select = NULL, ...) {
      seen <<- names(tidyselect::eval_select(rlang::enquo(col_select), fake_tx()))
      fake_tx()[seen]
    },
    .package = "arrow"
  )

  out <- load_cols("TX_KI", col_select = tidyselect::starts_with("REC_"))

  expect_equal(seen, c("REC_AGE_AT_TX", "REC_BMI"))
  expect_named(out, c("REC_AGE_AT_TX", "REC_BMI"))
})

test_that("a parquet file round-trips with col_select", {
  skip_if_not_installed("arrow")
  skip_if_not(
    isTRUE(tryCatch(arrow::arrow_with_parquet(), error = function(e) FALSE)),
    "arrow cannot read or write parquet here"
  )
  dir <- local_srtr_folder(character())
  arrow::write_parquet(fake_tx_kp(), file.path(dir, "TX_KP.parquet"))

  out <- load_cols(
    "TX_KP",
    col_select = c(tidyselect::starts_with("REC_"), "TFL_LAFUDATE"),
    trr_id_filter = c(900001, 900003)
  )

  expect_named(out, c("REC_AGE_AT_TX", "TFL_LAFUDATE"))
  expect_equal(out$REC_AGE_AT_TX, c(1, 3))
  expect_equal(out$TFL_LAFUDATE, as.Date(c("2002-01-01", "2001-01-01")))
})

# Columns compared with the data dictionary (#4). Synthetic IMMUNO files:
# column names from the dictionary, made-up values.

load_immuno <- function(...) {
  load_srtr_file("IMMUNO", factor_labels = FALSE, var_labels = FALSE, ...)
}

test_that("a file with every dictionary column loads quietly", {
  local_sas_file(fake_immuno(), "IMMUNO")

  expect_no_warning(expect_no_message(out <- load_immuno()))
  expect_named(out, names(fake_immuno()))
})

test_that("a column missing from the file gives a warning naming it", {
  data <- fake_immuno()
  data$REC_DRUG_DAYS <- NULL
  local_sas_file(data, "IMMUNO")

  expect_warning(out <- load_immuno(), class = "sRtr_warning_missing_columns")
  expect_named(out, names(data))
  expect_snapshot(out <- load_immuno())
})

test_that("column_check = \"error\" makes a missing column an error", {
  data <- fake_immuno()
  data$REC_DRUG_DAYS <- NULL
  local_sas_file(data, "IMMUNO")

  expect_error(
    load_immuno(column_check = "error"),
    class = "sRtr_error_missing_columns"
  )
  expect_snapshot(error = TRUE, load_immuno(column_check = "error"))
})

test_that("a column not in the dictionary gives a message naming it", {
  withr::local_options(rlib_message_verbosity = "verbose")
  data <- fake_immuno()
  data$NOT_A_DICTIONARY_COLUMN <- c(1, 2)
  local_sas_file(data, "IMMUNO")

  cnd <- expect_message(out <- load_immuno(), class = "sRtr_message_extra_columns")
  expect_equal(cnd$extra, "NOT_A_DICTIONARY_COLUMN")
  expect_equal(out$NOT_A_DICTIONARY_COLUMN, c(1, 2))
  expect_named(out, names(data))
  expect_snapshot(out <- load_immuno())
})

test_that("column_check = \"none\" skips the comparison", {
  data <- fake_immuno()
  data$REC_DRUG_DAYS <- NULL
  data$NOT_A_DICTIONARY_COLUMN <- c(1, 2)
  local_sas_file(data, "IMMUNO")

  expect_no_warning(expect_no_message(load_immuno(column_check = "none")))
})

test_that("col_select skips the comparison", {
  data <- fake_immuno()
  data$REC_DRUG_DAYS <- NULL
  local_sas_file(data, "IMMUNO")

  expect_no_warning(out <- load_immuno(col_select = "TRR_ID"))
  expect_named(out, "TRR_ID")
})

test_that("a file the dictionary does not list is not compared", {
  local_sas_file(fake_immuno(), "NOT_A_SAF")

  expect_no_warning(expect_no_message(
    load_srtr_file("NOT_A_SAF", factor_labels = FALSE, var_labels = FALSE)
  ))
})

test_that("parquet files are compared with the dictionary too", {
  skip_if_not_installed("arrow")
  skip_if_not(
    isTRUE(tryCatch(arrow::arrow_with_parquet(), error = function(e) FALSE)),
    "arrow cannot read or write parquet here"
  )
  dir <- local_srtr_folder(character())
  data <- fake_immuno()
  data$REC_DRUG_DAYS <- NULL
  arrow::write_parquet(data, file.path(dir, "IMMUNO.parquet"))

  expect_warning(load_immuno(), class = "sRtr_warning_missing_columns")
})

test_that("a parquet column not in the dictionary gives a message naming it", {
  skip_if_not_installed("arrow")
  skip_if_not(
    isTRUE(tryCatch(arrow::arrow_with_parquet(), error = function(e) FALSE)),
    "arrow cannot read or write parquet here"
  )
  withr::local_options(rlib_message_verbosity = "verbose")
  dir <- local_srtr_folder(character())
  data <- fake_immuno()
  data$NOT_A_DICTIONARY_COLUMN <- c(7, 8)
  arrow::write_parquet(data, file.path(dir, "IMMUNO.parquet"))

  cnd <- expect_message(out <- load_immuno(), class = "sRtr_message_extra_columns")
  expect_equal(cnd$extra, "NOT_A_DICTIONARY_COLUMN")
  expect_equal(out$NOT_A_DICTIONARY_COLUMN, c(7, 8))
})
