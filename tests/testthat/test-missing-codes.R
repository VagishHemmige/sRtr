test_that("the screen finds codes that may be missing values", {
  formats <- fake_format_codes(
    Format = "FAKEFMT",
    Code = c("1", "2", "998", "5", "4", "3", ".", "**OTHER**", "7"),
    Meaning = c(
      "1: Yes",
      "2: No",
      "998: UNKNOWN",
      "5: Yes, duration unknown",
      "4: N/A",
      "3: Not Done",
      "Missing",
      "Multiple Choices",
      "7: Pending"
    )
  )

  expect_equal(
    formats$Code[.srtr_missing_candidates(formats)],
    c("998", "5", "4", "3", ".", "**OTHER**", "7")
  )
})

test_that("the screen does not match inside other words", {
  formats <- fake_format_codes(
    Format = "FAKEFMT",
    Code = c("1", "2", "3"),
    Meaning = c("1: Banana", "2: Nasal", "3: Expanded criteria")
  )

  expect_equal(.srtr_missing_candidates(formats), c(FALSE, FALSE, FALSE))
})

test_that("a complete classification has no problems", {
  formats <- fake_format_codes(
    Format = "FAKEFMT",
    Code = c("1", "5", "998"),
    Meaning = c("1: Yes", "5: Yes, duration unknown", "998: UNKNOWN")
  )
  codes <- fake_missing_codes(
    Format = "FAKEFMT",
    Code = c("5", "998"),
    Meaning = c("5: Yes, duration unknown", "998: UNKNOWN"),
    missing_type = c("partial", "unknown"),
    collapses_to = c("Yes", "")
  )

  expect_equal(nrow(.srtr_missing_problems(codes, formats)), 0L)
})

test_that("a candidate code with no classification is reported", {
  formats <- fake_format_codes(
    Format = "FAKEFMT",
    Code = c("1", "998"),
    Meaning = c("1: Yes", "998: UNKNOWN")
  )
  codes <- fake_missing_codes(
    Format = character(),
    Code = character(),
    Meaning = character(),
    missing_type = character(),
    collapses_to = character(),
    note = character()
  )

  problems <- .srtr_missing_problems(codes, formats)

  expect_equal(problems$problem, "unclassified")
  expect_equal(problems$Code, "998")
})

test_that("a code whose meaning changed needs a new classification", {
  formats <- fake_format_codes(
    Format = "FAKEFMT",
    Code = "998",
    Meaning = "998: Unknown if performed"
  )
  codes <- fake_missing_codes(
    Format = "FAKEFMT",
    Code = "998",
    Meaning = "998: UNKNOWN",
    missing_type = "unknown"
  )

  problems <- .srtr_missing_problems(codes, formats)

  expect_setequal(problems$problem, c("unclassified", "not_in_formats"))
})

test_that("a reviewed ordinary value is accepted as 'none'", {
  formats <- fake_format_codes(
    Format = "FAKEFMT",
    Code = "NA",
    Meaning = "NA: FOREIGN PLACE"
  )
  codes <- fake_missing_codes(
    Format = "FAKEFMT",
    Code = "NA",
    Meaning = "NA: FOREIGN PLACE",
    missing_type = "none"
  )

  expect_equal(nrow(.srtr_missing_problems(codes, formats)), 0L)
})

test_that("invalid, repeated and inconsistent rows are reported", {
  formats <- fake_format_codes(
    Format = "FAKEFMT",
    Code = c("5", "998", "4"),
    Meaning = c("5: Yes, duration unknown", "998: UNKNOWN", "4: N/A")
  )
  codes <- fake_missing_codes(
    Format = "FAKEFMT",
    Code = c("5", "998", "998", "4"),
    Meaning = c(
      "5: Yes, duration unknown",
      "998: UNKNOWN",
      "998: UNKNOWN",
      "4: N/A"
    ),
    missing_type = c("partial", "unknown", "unknown", "absent"),
    collapses_to = c("", "Yes", "Yes", "")
  )

  problems <- .srtr_missing_problems(codes, formats)

  expect_setequal(
    problems$problem,
    c("invalid_type", "duplicate", "partial_without_target", "target_without_partial")
  )
  expect_equal(problems$Code[problems$problem == "invalid_type"], "4")
  expect_equal(problems$Code[problems$problem == "partial_without_target"], "5")
})

test_that("reading a classification file keeps blank codes and the text NA", {
  path <- withr::local_tempfile(fileext = ".csv")
  writeLines(
    c(
      '"Format","Code","Meaning","missing_type","collapses_to","note"',
      '"FAKEFMT","",": Not Reported","unknown","",""',
      '"FAKEFMT","NA","NA: FOREIGN PLACE","none","",""'
    ),
    path
  )

  codes <- .srtr_missing_read(path)

  expect_equal(codes$Code, c("", "NA"))
  expect_equal(codes$collapses_to, c("", ""))
})

test_that("every stored format code that may be a missing value is classified", {
  problems <- .srtr_missing_problems(
    sRtr::missing_codes$formats,
    sRtr::dictionary_versions$formats
  )

  expect_equal(nrow(problems), 0L, info = format(problems))
})

test_that("the same code number is classified by its format, not its number", {
  codes <- sRtr::missing_codes$formats
  type_of <- function(format, code) {
    codes$missing_type[codes$Format == format & codes$Code == code]
  }

  expect_equal(type_of("CLNLTY", "4"), "unknown")
  expect_equal(type_of("ASCITES", "4"), "not_applicable")
  expect_equal(type_of("AUXMRSLT", "4"), "not_done")
  expect_equal(type_of("PEPULCER", "4"), "partial")
  expect_equal(type_of("STATE", "NA"), "none")
})
