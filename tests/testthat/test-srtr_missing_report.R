# Made-up rows built from real dictionary column names of TX_KI:
#   DON_ANTI_CMV  character, format SRLSTT
#   DON_HIST_DIAB numeric, format HSTDBDR
#   CAN_MALIG     character flag with no format (variables table)
fake_tx_ki <- function() {
  tibble::tibble(
    FAKE_ID = 1:8,
    DON_ANTI_CMV = c("P", "N", "U", "U", "ND", "PD", "C", NA),
    DON_HIST_DIAB = c(1, 2, 5, 998, 998, NA, 1, 3),
    CAN_MALIG = c("Y", "N", "", "U", "u", "ND", "Y", NA)
  )
}

count_of <- function(report, variable, type) {
  n <- report$n[report$variable == variable & report$missing_type == type]
  if (length(n) == 0) 0L else n
}

test_that("raw codes are counted by what they mean", {
  report <- srtr_missing_report(fake_tx_ki(), file_key = "TX_KI")

  expect_equal(count_of(report, "DON_ANTI_CMV", "unknown"), 2L)
  expect_equal(count_of(report, "DON_ANTI_CMV", "not_done"), 1L)
  expect_equal(count_of(report, "DON_ANTI_CMV", "pending"), 1L)
  expect_equal(count_of(report, "DON_ANTI_CMV", "cannot_disclose"), 1L)
  expect_equal(count_of(report, "DON_HIST_DIAB", "unknown"), 2L)
  expect_equal(count_of(report, "DON_HIST_DIAB", "partial"), 1L)
})

test_that("values that are already NA are counted apart from coded ones", {
  report <- srtr_missing_report(fake_tx_ki(), file_key = "TX_KI")

  expect_equal(count_of(report, "DON_ANTI_CMV", "na"), 1L)
  expect_equal(count_of(report, "DON_HIST_DIAB", "na"), 1L)
})

test_that("flag columns with no format use the variables table", {
  report <- srtr_missing_report(fake_tx_ki(), file_key = "TX_KI")

  expect_equal(count_of(report, "CAN_MALIG", "sas_missing"), 1L)
  expect_equal(count_of(report, "CAN_MALIG", "unknown"), 2L)
  expect_equal(count_of(report, "CAN_MALIG", "not_done"), 1L)
  expect_true(all(is.na(report$format[report$variable == "CAN_MALIG"])))
})

test_that("labelled columns give the same counts as raw codes", {
  raw <- fake_tx_ki()
  labelled <- suppressWarnings(apply_srtr_factors(raw, file_key = "TX_KI"))

  expect_s3_class(labelled$DON_ANTI_CMV, "factor")
  expect_equal(
    srtr_missing_report(labelled),
    srtr_missing_report(raw, file_key = "TX_KI")
  )
})

test_that("columns the tables do not cover are left out, and percent is of all rows", {
  report <- srtr_missing_report(fake_tx_ki(), file_key = "TX_KI")

  expect_false("FAKE_ID" %in% report$variable)
  expect_equal(
    report$percent[
      report$variable == "DON_ANTI_CMV" & report$missing_type == "unknown"
    ],
    25
  )
  expect_named(
    report,
    c("variable", "format", "missing_type", "n", "percent")
  )
})

test_that("a value its format does not list is reported as not in the format", {
  df <- tibble::tibble(DON_ANTI_CMV = c("P", "ZQ", "ZQ"))

  report <- srtr_missing_report(df, file_key = "TX_KI")

  expect_equal(count_of(report, "DON_ANTI_CMV", "not_in_format"), 2L)
})

test_that("detail = 'code' lists every classified code, with zero counts", {
  report <- srtr_missing_report(
    fake_tx_ki(),
    cols = "DON_ANTI_CMV",
    file_key = "TX_KI",
    detail = "code"
  )

  expect_named(
    report,
    c("variable", "format", "code", "meaning", "missing_type", "n", "percent")
  )
  expect_equal(report$n[report$code %in% "U"], 2L)
  expect_equal(report$n[report$code %in% "I"], 0L)
  expect_equal(report$meaning[report$code %in% "ND"], "ND: Not Done")
  expect_false(any(report$code %in% c("P", "N")))
})

test_that("cols limits the report and unknown columns are an error", {
  report <- srtr_missing_report(
    fake_tx_ki(),
    cols = "CAN_MALIG",
    file_key = "TX_KI"
  )

  expect_equal(unique(report$variable), "CAN_MALIG")
  expect_error(
    srtr_missing_report(fake_tx_ki(), cols = "NOT_THERE", file_key = "TX_KI"),
    class = "sRtr_error_columns_not_found"
  )
})

test_that("without a file key, variables are looked up by name", {
  expect_message(
    report <- srtr_missing_report(fake_tx_ki()),
    class = "sRtr_message_no_file_key"
  )

  expect_equal(count_of(report, "DON_ANTI_CMV", "unknown"), 2L)
})

test_that("without a file key, a variable whose format differs by file is skipped", {
  # CAN_DGN2 has format PADGN in CAND_KIPA and DGN in CAND_LIIN.
  df <- tibble::tibble(CAN_DGN2 = c(1999, 1999), DON_ANTI_CMV = c("U", "P"))

  expect_message(
    report <- srtr_missing_report(df),
    regexp = "CAN_DGN2",
    class = "sRtr_message_no_file_key"
  )

  expect_false("CAN_DGN2" %in% report$variable)
  with_key <- srtr_missing_report(df, file_key = "CAND_LIIN")
  expect_equal(count_of(with_key, "CAN_DGN2", "unknown"), 2L)
})

test_that("an unknown file key is an error", {
  expect_error(
    srtr_missing_report(fake_tx_ki(), file_key = "NOT_A_FILE"),
    class = "sRtr_error_unknown_file_key"
  )
})

test_that("a data frame with nothing to report gives an empty report", {
  report <- srtr_missing_report(
    tibble::tibble(FAKE_ID = 1:3),
    file_key = "TX_KI"
  )

  expect_equal(nrow(report), 0L)
  expect_named(
    report,
    c("variable", "format", "missing_type", "n", "percent")
  )
})

test_that("unlisted values take the type of a classified catch-all", {
  rows <- tibble::tibble(
    Code = c("1", "**OTHER**"),
    Meaning = c("1: Somewhere", "NA"),
    missing_type = c(NA, "unknown")
  )

  found <- .srtr_missing_match(c("1", "77", NA), rows, NULL, "FAKEFMT")

  expect_equal(found$type, c(NA, "unknown", "na"))
  expect_equal(found$code, c(NA, "**OTHER**", NA))
})

test_that("numeric values of an age-band format are not read as codes", {
  rows <- tibble::tibble(
    Code = c("0", "18", "**OTHER**"),
    Meaning = c("<18", "18+", "Unknown"),
    missing_type = c(NA, NA, "unknown")
  )

  found <- .srtr_missing_match(c(3, 40, NA), rows, NULL, "AGE8A")

  expect_equal(found$type, c(NA, NA, "na"))
})

test_that("no missing meaning doubles as an ordinary code of its format", {
  codes <- sRtr::missing_codes$formats
  missing <- codes[codes$missing_type != "none", ]
  stored <- unique(sRtr::dictionary_versions$formats[c("Format", "Code")])
  both <- merge(missing, stored, by = "Format", suffixes = c("", "_other"))
  clash <- both[
    both$Meaning == both$Code_other & both$Code != both$Code_other,
  ]
  clash_type <- codes$missing_type[match(
    paste(clash$Format, clash$Code_other),
    paste(codes$Format, codes$Code)
  )]

  expect_true(all(clash_type %in% clash$missing_type & !is.na(clash_type)))
})
