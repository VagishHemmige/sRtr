# test_factors.R
#
# Tests for apply_srtr_factors() using real SRTR data.
# Requires:
# - SRTR_WD environment variable to be set
# - Valid SRTR files
# - sRtr::dictionary and sRtr::formats loaded

# ---- Test 1: Basic functionality with inferred file_key ----
test_that("apply_srtr_factors applies factor levels correctly", {
  skip_if_no_srtr_data()

  df <- load_srtr_file("TX_KI", factor_labels = FALSE)
  df_factored <- apply_srtr_factors(df)

  expect_true(any(sapply(df_factored, is.factor)))

  if ("SEX" %in% names(df_factored)) {
    expect_s3_class(df_factored$SEX, "factor")
    expect_true(
      "Female" %in%
        levels(df_factored$SEX) ||
        "Male" %in% levels(df_factored$SEX)
    )
  }
})

# ---- Test 2: Explicit file_key argument overrides attribute ----
test_that("apply_srtr_factors works with explicit file_key", {
  skip_if_no_srtr_data()

  df <- load_srtr_file("TX_KI", factor_labels = FALSE)
  attr(df, "file_key") <- NULL # Remove attribute to test explicit key

  df_factored <- apply_srtr_factors(df, file_key = "TX_KI")

  expect_true(any(sapply(df_factored, is.factor)))
})

# ---- Test 3: Works with other datasets ----
test_that("apply_srtr_factors works with TX_HR and CAND_KIPA", {
  skip_if_no_srtr_data()

  keys <- c("TX_HR", "CAND_KIPA")

  for (key in keys) {
    df <- load_srtr_file(key, factor_labels = FALSE)
    df_factored <- apply_srtr_factors(df)
    expect_true(
      any(sapply(df_factored, is.factor)),
      info = paste("No factors in", key)
    )
  }
})

# ---- Test 4: Verbose output shows expected messages ----
test_that("apply_srtr_factors outputs verbose messages", {
  skip_if_no_srtr_data()

  df <- load_srtr_file("TX_KI", factor_labels = FALSE)

  # Capture verbose output
  output <- capture.output(
    {
      df_factored <- apply_srtr_factors(df, verbose = TRUE)
    },
    type = "message"
  )

  expect_true(any(grepl("Labeled variable:", output)))
})

# ---- Offline tests: a tiny made-up table, no SAF needed ----

fake_tx_ki <- function() {
  tibble::tibble(CAN_ABO = c("A", "A2"), FAKE_COLUMN = c(1, 2))
}

test_that("coded columns become factors with labels from formats", {
  out <- apply_srtr_factors(fake_tx_ki(), file_key = "TX_KI")
  expect_s3_class(out$CAN_ABO, "factor")
  expect_equal(as.character(out$CAN_ABO), c("A: A", "A2: A2"))
  expect_equal(out$FAKE_COLUMN, c(1, 2))
})

test_that("verbose = FALSE is silent", {
  expect_no_message(apply_srtr_factors(fake_tx_ki(), file_key = "TX_KI"))
})

test_that("verbose = TRUE reports each labeled variable", {
  expect_message(
    apply_srtr_factors(fake_tx_ki(), file_key = "TX_KI", verbose = TRUE),
    class = "sRtr_message_variable_labeled"
  )
  expect_snapshot(
    out <- apply_srtr_factors(fake_tx_ki(), file_key = "TX_KI", verbose = TRUE)
  )
})

test_that("verbose = TRUE says where an inferred file_key came from", {
  df <- fake_tx_ki()
  attr(df, "file_key") <- "tx_ki"
  expect_snapshot(out <- apply_srtr_factors(df, verbose = TRUE))
})

test_that("verbose = TRUE says when nothing is converted", {
  df <- tibble::tibble(FAKE_COLUMN = 1)
  expect_message(
    apply_srtr_factors(df, file_key = "TX_KI", verbose = TRUE),
    class = "sRtr_message_nothing_to_label"
  )
})

test_that("the result carries the upper-case file_key", {
  out <- apply_srtr_factors(fake_tx_ki(), file_key = "tx_ki")
  expect_equal(attr(out, "file_key"), "TX_KI")
  expect_s3_class(out$CAN_ABO, "factor")
})

test_that("an unknown file_key warns and returns the data unchanged", {
  df <- fake_tx_ki()
  expect_warning(
    out <- apply_srtr_factors(df, file_key = "NOT_A_FILE"),
    class = "sRtr_warning_unknown_file_key"
  )
  expect_identical(out, df)
  expect_snapshot(out <- apply_srtr_factors(df, file_key = "NOT_A_FILE"))
})

test_that("a file_key that cannot be worked out warns", {
  expect_warning(
    out <- apply_srtr_factors(fake_tx_ki()),
    class = "sRtr_warning_file_key_not_inferred"
  )
  expect_equal(out$CAN_ABO, c("A", "A2"))
  expect_snapshot(out <- apply_srtr_factors(fake_tx_ki()))
})

test_that("a known file_key with no matching columns does not warn", {
  df <- tibble::tibble(FAKE_COLUMN = 1)
  expect_no_warning(out <- apply_srtr_factors(df, file_key = "TX_KI"))
  expect_equal(attr(out, "file_key"), "TX_KI")
})

# ---- Codes outside the format, age bands, catch-all codes, reruns ----

test_that("ages with an age-band format stay numeric by default", {
  df <- tibble::tibble(REC_AGE_AT_TX = c(0, 1, 6, 40, 72, NA))

  out <- apply_srtr_factors(df, file_key = "TX_KI")

  expect_equal(out$REC_AGE_AT_TX, c(0, 1, 6, 40, 72, NA))
})

test_that("range_formats = 'bin' bands ages from each band's lower bound", {
  df <- tibble::tibble(REC_AGE_AT_TX = c(0, 0.5, 1, 5.9, 6, 40, 72, NA))

  out <- apply_srtr_factors(df, file_key = "TX_KI", range_formats = "bin")

  expect_equal(
    as.character(out$REC_AGE_AT_TX),
    c("<1", "<1", "1-5", "1-5", "6-11", "35-49", "65+", NA)
  )
  expect_equal(
    levels(out$REC_AGE_AT_TX),
    c("<1", "1-5", "6-11", "12-17", "18-34", "35-49", "50-64", "65+", "Unknown")
  )
})

test_that("a code outside the format is kept as its own level, with a warning", {
  df <- tibble::tibble(CAN_ABO = c("A", "FAKE_ABO", NA))

  expect_warning(
    out <- apply_srtr_factors(df, file_key = "TX_KI"),
    class = "sRtr_warning_unknown_codes"
  )
  expect_equal(as.character(out$CAN_ABO), c("A: A", "FAKE_ABO: not in format", NA))
  expect_equal(utils::tail(levels(out$CAN_ABO), 1), "FAKE_ABO: not in format")
  expect_snapshot(out <- apply_srtr_factors(df, file_key = "TX_KI"))
})

test_that("unknown_codes = 'na' drops codes outside the format, with a warning", {
  df <- tibble::tibble(CAN_ABO = c("A", "FAKE_ABO"))

  expect_warning(
    out <- apply_srtr_factors(df, file_key = "TX_KI", unknown_codes = "na"),
    class = "sRtr_warning_unknown_codes"
  )
  expect_equal(as.character(out$CAN_ABO), c("A: A", NA))
  expect_false("FAKE_ABO: not in format" %in% levels(out$CAN_ABO))
})

test_that("unknown_codes = 'error' stops on a code outside the format", {
  df <- tibble::tibble(CAN_ABO = c("A", "FAKE_ABO"))

  expect_snapshot(
    apply_srtr_factors(df, file_key = "TX_KI", unknown_codes = "error"),
    error = TRUE
  )
  expect_error(
    apply_srtr_factors(df, file_key = "TX_KI", unknown_codes = "error"),
    class = "sRtr_error_unknown_codes"
  )
})

test_that("codes outside a format with a catch-all get the catch-all label", {
  df <- tibble::tibble(CAN_RACE = c(8, 24, 16))

  expect_no_warning(out <- apply_srtr_factors(df, file_key = "TX_KI"))

  expect_equal(
    as.character(out$CAN_RACE),
    c("8: White", "Multi-Racial", "16: Black or African American")
  )
})

test_that("other = 'keep' treats codes outside a catch-all format as unknown", {
  df <- tibble::tibble(CAN_RACE = c(8, 24))

  expect_warning(
    out <- apply_srtr_factors(df, file_key = "TX_KI", other = "keep"),
    class = "sRtr_warning_unknown_codes"
  )
  expect_equal(as.character(out$CAN_RACE), c("8: White", "24: not in format"))
})

test_that("applying factors twice changes nothing", {
  df <- tibble::tibble(
    CAN_ABO = c("A", "B", "FAKE_ABO", NA),
    CAN_RACE = c(8, 24, 16, NA),
    REC_AGE_AT_TX = c(30, 40, 50, NA)
  )
  once <- suppressWarnings(apply_srtr_factors(df, file_key = "TX_KI"))

  expect_no_warning(twice <- apply_srtr_factors(once, file_key = "TX_KI"))

  expect_identical(twice, once)
})

test_that("a marked factor whose labels reuse codes is not converted again", {
  fmt_map <- tibble::tibble(
    Value = c("3", "10"),
    Label = c("1", "3")
  )
  labelled <- factor(c("1", "3"), levels = c("1", "3"))
  attr(labelled, "srtr_format") <- "FAKEFMT"

  out <- .srtr_factor_column(labelled, fmt_map, fmt = "FAKEFMT", var = "FAKE_VAR")

  expect_identical(out, labelled)
})

test_that("variable labels on a column are kept", {
  df <- tibble::tibble(CAN_ABO = c("A", "B"))
  attr(df$CAN_ABO, "label") <- "Fake label"

  out <- apply_srtr_factors(df, file_key = "TX_KI")

  expect_equal(attr(out$CAN_ABO, "label"), "Fake label")
})

test_that("a code outside the format stays distinct from a label it matches", {
  fmt_map <- tibble::tibble(Value = "FAKE_CODE", Label = "FAKE_LABEL")

  expect_warning(
    out <- .srtr_factor_column(
      c("FAKE_CODE", "FAKE_LABEL"),
      fmt_map,
      fmt = "FAKEFMT",
      var = "FAKE_VAR"
    ),
    class = "sRtr_warning_unknown_codes"
  )
  expect_equal(as.character(out), c("FAKE_LABEL", "FAKE_LABEL: not in format"))

  expect_error(
    .srtr_factor_column(
      c("FAKE_CODE", "FAKE_LABEL"),
      fmt_map,
      fmt = "FAKEFMT",
      var = "FAKE_VAR",
      unknown_codes = "error"
    ),
    class = "sRtr_error_unknown_codes"
  )
})

test_that("a raw value that looks like a kept code is still a code outside the format", {
  df <- tibble::tibble(CAN_ABO = c("FAKE_X", "FAKE_X: not in format"))

  expect_warning(
    out <- apply_srtr_factors(df, file_key = "TX_KI"),
    class = "sRtr_warning_unknown_codes"
  )
  expect_equal(
    as.character(out$CAN_ABO),
    c("FAKE_X: not in format", "FAKE_X: not in format: not in format")
  )
  expect_error(
    apply_srtr_factors(df, file_key = "TX_KI", unknown_codes = "error"),
    class = "sRtr_error_unknown_codes"
  )
  expect_error(
    apply_srtr_factors(
      tibble::tibble(CAN_ABO = factor("FAKE_X: not in format")),
      file_key = "TX_KI",
      unknown_codes = "error"
    ),
    class = "sRtr_error_unknown_codes"
  )
})

test_that("an unconverted factor of codes outside the format is handled like text", {
  df <- tibble::tibble(CAN_ABO = factor(c("A", "FAKE_ABO")))

  expect_warning(
    kept <- apply_srtr_factors(df, file_key = "TX_KI"),
    class = "sRtr_warning_unknown_codes"
  )
  expect_equal(as.character(kept$CAN_ABO), c("A: A", "FAKE_ABO: not in format"))

  expect_warning(
    dropped <- apply_srtr_factors(df, file_key = "TX_KI", unknown_codes = "na"),
    class = "sRtr_warning_unknown_codes"
  )
  expect_equal(as.character(dropped$CAN_ABO), c("A: A", NA))

  expect_error(
    apply_srtr_factors(df, file_key = "TX_KI", unknown_codes = "error"),
    class = "sRtr_error_unknown_codes"
  )
})

test_that("an unconverted factor is read as codes, labels included", {
  df <- tibble::tibble(CAN_ABO = factor(c("A", "A: A")))

  expect_warning(
    out <- apply_srtr_factors(df, file_key = "TX_KI"),
    class = "sRtr_warning_unknown_codes"
  )
  expect_equal(as.character(out$CAN_ABO), c("A: A", "A: A: not in format"))
  expect_error(
    apply_srtr_factors(df, file_key = "TX_KI", unknown_codes = "error"),
    class = "sRtr_error_unknown_codes"
  )

  race <- tibble::tibble(CAN_RACE = factor(c("8", "24")))
  out <- apply_srtr_factors(race, file_key = "TX_KI")
  expect_equal(as.character(out$CAN_RACE), c("8: White", "Multi-Racial"))
})

test_that("a column that lost its marker is read as codes again, loudly", {
  df <- data.frame(CAN_ABO = c("A", "B"))
  once <- apply_srtr_factors(df, file_key = "TX_KI")
  attr(once$CAN_ABO, "srtr_format") <- NULL

  expect_warning(
    twice <- apply_srtr_factors(once, file_key = "TX_KI"),
    class = "sRtr_warning_unknown_codes"
  )
  expect_equal(
    as.character(twice$CAN_ABO),
    c("A: A: not in format", "B: B: not in format")
  )
  expect_error(
    apply_srtr_factors(once, file_key = "TX_KI", unknown_codes = "error"),
    class = "sRtr_error_unknown_codes"
  )
})

test_that("an unmarked factor with every label as a level is still read as codes", {
  fmt_map <- tibble::tibble(Value = "FAKE_CODE", Label = "FAKE_LABEL")
  x <- factor("FAKE_RAW", levels = c("FAKE_LABEL", "FAKE_RAW"))

  expect_error(
    .srtr_factor_column(x, fmt_map, fmt = "FAKEFMT", var = "FAKE_VAR", unknown_codes = "error"),
    class = "sRtr_error_unknown_codes"
  )
  expect_warning(
    out <- .srtr_factor_column(x, fmt_map, fmt = "FAKEFMT", var = "FAKE_VAR", unknown_codes = "na"),
    class = "sRtr_warning_unknown_codes"
  )
  expect_equal(as.character(out), NA_character_)
})

test_that("kept names never merge two codes, even next to a label like a kept name", {
  fmt_map <- tibble::tibble(Value = "FAKE_CODE", Label = "FAKE_X: not in format")

  expect_warning(
    out <- .srtr_factor_column(
      c("FAKE_X", "FAKE_X: not in format", "FAKE_X"),
      fmt_map,
      fmt = "FAKEFMT",
      var = "FAKE_VAR"
    ),
    class = "sRtr_warning_unknown_codes"
  )

  expect_length(unique(as.character(out)), 2)
  expect_equal(as.character(out)[1], as.character(out)[3])
  expect_false(as.character(out)[1] %in% c(fmt_map$Label, as.character(out)[2]))
})
