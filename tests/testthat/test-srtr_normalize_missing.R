# Made-up rows built from real dictionary column names of TX_KI:
#   DON_ANTI_CMV  character, format SRLSTT
#   DON_HIST_DIAB numeric, format HSTDBDR
#   CAN_MALIG     character flag with no format (variables table)
#   CAN_PRIMARY_PAY numeric, format PRMSRCPY... not used here
fake_tx_ki_values <- function() {
  tibble::tibble(
    FAKE_ID = 1:8,
    DON_ANTI_CMV = c("P", "N", "U", "I", "ND", "PD", "C", NA),
    DON_HIST_DIAB = c(1, 2, 5, 998, 998, NA, 1, 3),
    CAN_MALIG = c("Y", "N", "", "U", "u", "ND", "Y", NA)
  )
}

test_that("the default policy turns unknown-type codes into NA", {
  out <- srtr_normalize_missing(fake_tx_ki_values(), file_key = "TX_KI")

  expect_equal(out$DON_ANTI_CMV, c("P", "N", NA, "I", NA, NA, NA, NA))
  expect_equal(out$DON_HIST_DIAB, c(1, 2, 5, NA, NA, NA, 1, 3))
  expect_equal(out$CAN_MALIG, c("Y", "N", NA, NA, NA, NA, "Y", NA))
  expect_equal(out$FAKE_ID, 1:8)
})

test_that("no columns are added by default", {
  df <- fake_tx_ki_values()

  out <- srtr_normalize_missing(df, file_key = "TX_KI")

  expect_named(out, names(df))
})

test_that("reason = 'changed' says why a value became NA, and only that", {
  out <- srtr_normalize_missing(
    fake_tx_ki_values(),
    reason = "changed",
    file_key = "TX_KI"
  )

  expect_equal(
    out$DON_ANTI_CMV_MISS,
    c(NA, NA, "unknown", NA, "not_done", "pending", "cannot_disclose", NA)
  )
  expect_equal(
    out$DON_HIST_DIAB_MISS,
    c(NA, NA, NA, "unknown", "unknown", NA, NA, NA)
  )
})

test_that("a variable with nothing to change gets no reason column", {
  df <- tibble::tibble(DON_ANTI_CMV = c("P", "N", "I", NA))

  out <- srtr_normalize_missing(df, reason = "changed", file_key = "TX_KI")

  expect_identical(out, df)
})

test_that("raw codes and labelled columns are normalized alike", {
  raw <- fake_tx_ki_values()
  labelled <- suppressWarnings(apply_srtr_factors(raw, file_key = "TX_KI"))

  from_raw <- srtr_normalize_missing(raw, reason = "changed", file_key = "TX_KI")
  from_labelled <- srtr_normalize_missing(labelled, reason = "changed")

  expect_equal(is.na(from_labelled$DON_ANTI_CMV), is.na(from_raw$DON_ANTI_CMV))
  expect_equal(is.na(from_labelled$DON_HIST_DIAB), is.na(from_raw$DON_HIST_DIAB))
  expect_equal(from_labelled$DON_ANTI_CMV_MISS, from_raw$DON_ANTI_CMV_MISS)
  expect_equal(from_labelled$DON_HIST_DIAB_MISS, from_raw$DON_HIST_DIAB_MISS)
})

test_that("a factor loses the levels that became NA and keeps its order", {
  labelled <- suppressWarnings(
    apply_srtr_factors(fake_tx_ki_values(), file_key = "TX_KI")
  )
  attr(labelled$DON_ANTI_CMV, "label") <- "Fake label"

  out <- srtr_normalize_missing(labelled)

  expect_equal(
    levels(out$DON_ANTI_CMV),
    c("I: Indeterminate", "N: Negative", "P: Positive")
  )
  expect_equal(attr(out$DON_ANTI_CMV, "label"), "Fake label")
  expect_equal(attr(out$DON_ANTI_CMV, "srtr_format"), "SRLSTT")
  expect_equal(
    levels(out$DON_HIST_DIAB),
    setdiff(levels(labelled$DON_HIST_DIAB), "998: UNKNOWN")
  )
})

test_that("policy 'strict' leaves only substantive values", {
  out <- srtr_normalize_missing(
    fake_tx_ki_values(),
    policy = "strict",
    reason = "changed",
    file_key = "TX_KI"
  )

  expect_equal(out$DON_ANTI_CMV, c("P", "N", NA, NA, NA, NA, NA, NA))
  expect_equal(out$DON_HIST_DIAB, c(1, 2, NA, NA, NA, NA, 1, 3))
  expect_equal(out$DON_ANTI_CMV_MISS[4], "indeterminate")
  expect_equal(out$DON_HIST_DIAB_MISS[3], "partial")
})

test_that("policy 'tag_only' changes no value and tags every recognised code", {
  df <- fake_tx_ki_values()

  out <- srtr_normalize_missing(df, policy = "tag_only", file_key = "TX_KI")

  expect_identical(out[names(df)], df)
  expect_equal(
    out$DON_ANTI_CMV_MISS,
    c(
      NA, NA, "unknown", "indeterminate", "not_done", "pending",
      "cannot_disclose", NA
    )
  )
  expect_equal(out$DON_HIST_DIAB_MISS[3], "partial")
})

test_that("actions override the policy for one type", {
  out <- srtr_normalize_missing(
    fake_tx_ki_values(),
    actions = c(not_done = "keep", indeterminate = "na"),
    file_key = "TX_KI"
  )

  expect_equal(out$DON_ANTI_CMV, c("P", "N", NA, NA, "ND", NA, NA, NA))
  expect_equal(out$CAN_MALIG, c("Y", "N", NA, NA, NA, "ND", "Y", NA))
})

test_that("overrides change the rule for one variable only", {
  out <- srtr_normalize_missing(
    fake_tx_ki_values(),
    overrides = list(DON_ANTI_CMV = c(not_done = "keep")),
    file_key = "TX_KI"
  )

  expect_equal(out$DON_ANTI_CMV[5], "ND")
  expect_true(is.na(out$CAN_MALIG[6]))
})

test_that("reason = 'all' tags recognised codes that were kept", {
  out <- srtr_normalize_missing(
    fake_tx_ki_values(),
    reason = "all",
    file_key = "TX_KI"
  )

  expect_equal(out$DON_ANTI_CMV[4], "I")
  expect_equal(out$DON_ANTI_CMV_MISS[4], "indeterminate")
})

test_that("output = 'append' keeps the original columns", {
  df <- fake_tx_ki_values()

  out <- srtr_normalize_missing(df, output = "append", file_key = "TX_KI")

  expect_identical(out[names(df)], df)
  expect_equal(out$DON_ANTI_CMV_NORM, c("P", "N", NA, "I", NA, NA, NA, NA))
  expect_false("DON_ANTI_CMV_MISS" %in% names(out))
})

test_that("cols limits the variables that are normalized", {
  out <- srtr_normalize_missing(
    fake_tx_ki_values(),
    cols = "CAN_MALIG",
    file_key = "TX_KI"
  )

  expect_equal(out$DON_ANTI_CMV, fake_tx_ki_values()$DON_ANTI_CMV)
  expect_true(is.na(out$CAN_MALIG[4]))
})

test_that("na_level makes missing an explicit last level or value", {
  labelled <- suppressWarnings(
    apply_srtr_factors(fake_tx_ki_values(), file_key = "TX_KI")
  )

  out <- srtr_normalize_missing(labelled, na_level = "Missing")
  raw <- srtr_normalize_missing(
    fake_tx_ki_values(),
    na_level = "Missing",
    file_key = "TX_KI"
  )

  expect_equal(
    levels(out$DON_ANTI_CMV),
    c("I: Indeterminate", "N: Negative", "P: Positive", "Missing")
  )
  expect_equal(as.character(out$DON_ANTI_CMV[c(3, 8)]), c("Missing", "Missing"))
  expect_equal(raw$CAN_MALIG[c(3, 8)], c("Missing", "Missing"))
  expect_equal(raw$DON_HIST_DIAB, c(1, 2, 5, NA, NA, NA, 1, 3))
})

test_that("extra_codes adds the caller's own codes", {
  df <- tibble::tibble(FAKE_SCORE = c("1", "ZZ", "2"), DON_ANTI_CMV = "P")

  out <- srtr_normalize_missing(
    df,
    extra_codes = list(FAKE_SCORE = c(ZZ = "unknown")),
    reason = "changed",
    file_key = "TX_KI"
  )

  expect_equal(out$FAKE_SCORE, c("1", NA, "2"))
  expect_equal(out$FAKE_SCORE_MISS, c(NA, "unknown", NA))
})

test_that("normalizing twice changes nothing more", {
  once <- srtr_normalize_missing(fake_tx_ki_values(), file_key = "TX_KI")

  expect_identical(srtr_normalize_missing(once, file_key = "TX_KI"), once)
})

test_that("values a format does not list are left alone", {
  df <- tibble::tibble(DON_ANTI_CMV = c("P", "ZQ", "U"))

  out <- srtr_normalize_missing(df, file_key = "TX_KI")

  expect_equal(out$DON_ANTI_CMV, c("P", "ZQ", NA))
})

test_that("the data frame's attributes are kept", {
  df <- fake_tx_ki_values()
  attr(df, "file_key") <- "TX_KI"
  attr(df, "source_path") <- "fake/path"

  out <- srtr_normalize_missing(df)

  expect_equal(attr(out, "file_key"), "TX_KI")
  expect_equal(attr(out, "source_path"), "fake/path")
  expect_s3_class(out, "tbl_df")
})

test_that("an existing reason or output column is not overwritten", {
  df <- fake_tx_ki_values()
  df$DON_ANTI_CMV_MISS <- "mine"

  expect_error(
    srtr_normalize_missing(df, reason = "changed", file_key = "TX_KI"),
    class = "sRtr_error_column_exists"
  )
})

test_that("invalid actions, overrides and extra codes are errors", {
  df <- fake_tx_ki_values()

  expect_error(
    srtr_normalize_missing(df, actions = c(unknown = "drop"), file_key = "TX_KI"),
    class = "sRtr_error_invalid_actions"
  )
  expect_error(
    srtr_normalize_missing(df, actions = c(maybe = "na"), file_key = "TX_KI"),
    class = "sRtr_error_invalid_actions"
  )
  expect_error(
    srtr_normalize_missing(
      df,
      overrides = list(NOT_THERE = c(unknown = "keep")),
      file_key = "TX_KI"
    ),
    class = "sRtr_error_columns_not_found"
  )
  expect_error(
    srtr_normalize_missing(
      df,
      extra_codes = list(CAN_MALIG = c(Q = "whatever")),
      file_key = "TX_KI"
    ),
    class = "sRtr_error_invalid_extra_codes"
  )
})

test_that("the old missing_vals list is refused with a pointer", {
  expect_error(
    srtr_normalize_missing(fake_tx_ki_values(), list(CAN_MALIG = "U")),
    class = "sRtr_error_missing_vals_removed"
  )
})

test_that("verbose reports how many values changed", {
  expect_message(
    srtr_normalize_missing(
      fake_tx_ki_values(),
      file_key = "TX_KI",
      verbose = TRUE
    ),
    class = "sRtr_message_missing_normalized"
  )
})

test_that("labelling does not change what becomes NA for unlisted codes", {
  # DON_EBV_IGG has format SRLSTT in DONOR_DECEASED, which lists neither a
  # blank nor "u"; the variables table classifies both.
  raw <- tibble::tibble(DON_EBV_IGG = c("P", "", "u", "ZQ", "U", NA))
  labelled <- suppressWarnings(
    apply_srtr_factors(raw, file_key = "DONOR_DECEASED")
  )

  from_raw <- srtr_normalize_missing(raw, file_key = "DONOR_DECEASED")
  from_labelled <- srtr_normalize_missing(labelled)

  expect_equal(is.na(from_raw$DON_EBV_IGG), c(FALSE, TRUE, TRUE, FALSE, TRUE, TRUE))
  expect_equal(is.na(from_labelled$DON_EBV_IGG), is.na(from_raw$DON_EBV_IGG))
  expect_equal(
    levels(from_labelled$DON_EBV_IGG),
    c("I: Indeterminate", "N: Negative", "P: Positive", "ZQ: not in format")
  )
  expect_equal(
    attr(from_labelled$DON_EBV_IGG, "srtr_kept_codes"),
    c("ZQ: not in format" = "ZQ")
  )
})

test_that("extra_codes override a format's own code, raw or labelled", {
  # SRLSTT lists I as "I: Indeterminate"; here the caller calls it unknown.
  raw <- tibble::tibble(DON_ANTI_CMV = c("I", "P", "U"))
  labelled <- apply_srtr_factors(raw, file_key = "TX_KI")
  extra <- list(DON_ANTI_CMV = c(I = "unknown"))

  from_raw <- srtr_normalize_missing(
    raw,
    extra_codes = extra,
    reason = "changed",
    file_key = "TX_KI"
  )
  from_labelled <- srtr_normalize_missing(
    labelled,
    extra_codes = extra,
    reason = "changed"
  )

  expect_equal(is.na(from_raw$DON_ANTI_CMV), c(TRUE, FALSE, TRUE))
  expect_equal(is.na(from_labelled$DON_ANTI_CMV), c(TRUE, FALSE, TRUE))
  expect_equal(from_raw$DON_ANTI_CMV_MISS, c("unknown", NA, "unknown"))
  expect_equal(from_labelled$DON_ANTI_CMV_MISS, from_raw$DON_ANTI_CMV_MISS)
  expect_false("I: Indeterminate" %in% levels(from_labelled$DON_ANTI_CMV))
  for (detail in c("type", "code")) {
    expect_equal(
      srtr_missing_report(labelled, extra_codes = extra, detail = detail),
      srtr_missing_report(
        raw,
        extra_codes = extra,
        file_key = "TX_KI",
        detail = detail
      )
    )
  }
})

test_that("extra_codes can also name a label as it appears in a labelled column", {
  labelled <- apply_srtr_factors(
    tibble::tibble(DON_ANTI_CMV = c("I", "P")),
    file_key = "TX_KI"
  )

  out <- srtr_normalize_missing(
    labelled,
    extra_codes = list(DON_ANTI_CMV = c("I: Indeterminate" = "unknown"))
  )

  expect_equal(is.na(out$DON_ANTI_CMV), c(TRUE, FALSE))
})

test_that("an extra code whose label another code shares must cover both", {
  format_rows <- tibble::tibble(
    Code = c("1", "2", "3"),
    Meaning = c("Group A", "Group A", "Group B"),
    missing_type = NA_character_
  )
  one <- data.frame(Code = "1", missing_type = "unknown")
  both <- data.frame(Code = c("1", "2"), missing_type = "unknown")
  mixed <- data.frame(Code = c("1", "2"), missing_type = c("unknown", "pending"))
  alone <- data.frame(Code = "3", missing_type = "unknown")

  expect_error(
    .srtr_missing_check_extra(one, format_rows, "FAKE_VAR"),
    class = "sRtr_error_ambiguous_extra_codes"
  )
  expect_error(
    .srtr_missing_check_extra(mixed, format_rows, "FAKE_VAR"),
    class = "sRtr_error_ambiguous_extra_codes"
  )
  expect_no_error(.srtr_missing_check_extra(both, format_rows, "FAKE_VAR"))
  expect_no_error(.srtr_missing_check_extra(alone, format_rows, "FAKE_VAR"))
  found <- .srtr_missing_match(
    c("Group A", "Group B"),
    format_rows,
    NULL,
    "FAKEFMT",
    extra_rows = both,
    labelled = TRUE
  )
  expect_equal(found$type, c("unknown", NA))
})

test_that("live: normalizing TX_LI leaves no 998 Unknown REC_FUNCTN_STAT level", {
  skip_if_no_srtr_file("TX_LI")
  tx <- load_live("TX_LI", col_select = c("TRR_ID", "REC_FUNCTN_STAT"))

  out <- srtr_normalize_missing(tx, file_key = "TX_LI", release = srtr_live_release())

  expect_equal(grep("^998:", levels(out$REC_FUNCTN_STAT), value = TRUE), character())
})
