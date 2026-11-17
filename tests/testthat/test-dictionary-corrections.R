test_that("REC_COD uses the COD format by default, THCOD with view = \"web\"", {
  corrected <- srtr_dictionary("2609")
  web <- srtr_dictionary("2609", view = "web")

  rec_cod <- \(d) unique(d$FormatID[d$Variable == "REC_COD"])
  expect_equal(rec_cod(corrected), "COD")
  expect_equal(rec_cod(web), "THCOD")
  expect_equal(attr(corrected, "view"), "corrected")
  expect_equal(attr(corrected, "corrections"), "SRTR-DC-001")
  expect_equal(attr(web, "view"), "web")
  expect_equal(attr(web, "corrections"), character())
})

test_that("the correction covers REC_COD in every TX dataset", {
  corrected <- srtr_dictionary("2609")

  rec_cod <- corrected[corrected$Variable == "REC_COD", ]
  expect_setequal(
    rec_cod$Dataset,
    c("TX_HL", "TX_HR", "TX_IN", "TX_KI", "TX_KP", "TX_LI", "TX_LU", "TX_PA")
  )
  expect_equal(unique(rec_cod$FormatID), "COD")
})

test_that("only the corrected entries differ from the web dictionary", {
  for (release in list(NULL, "2203", "2609")) {
    corrected <- srtr_dictionary(release)
    web <- srtr_dictionary(release, view = "web")

    changed <- corrected$FormatID != web$FormatID
    expect_equal(unique(corrected$Variable[changed]), "REC_COD")
    expect_equal(corrected[!changed, ], web[!changed, ], ignore_attr = TRUE)
    expect_equal(
      srtr_dictionary(release, table = "formats"),
      srtr_dictionary(release, table = "formats", view = "web"),
      ignore_attr = TRUE
    )
  }
})

test_that("every correction still matches the latest stored dictionary", {
  # Fails when SRTR changes an entry a correction expects, so the correction
  # can be reviewed or retired.
  latest <- srtr_dictionary("2609", view = "web")
  corrections <- .srtr_dictionary_corrections

  for (i in seq_len(nrow(corrections))) {
    row <- corrections[i, ]
    entry <- latest[latest$Dataset == row$Dataset & latest$Variable == row$Variable, ]
    expect_equal(entry[[row$field]], row$from, info = row$id)
  }
})

test_that("a correction whose target format is missing is not applied", {
  corrections <- .srtr_dictionary_corrections
  corrections$to <- "NOT_A_FORMAT"
  tables <- .srtr_dictionary_for("2609", view = "web")

  expect_warning(
    out <- .srtr_apply_corrections(tables, "corrected", corrections),
    class = "sRtr_warning_dictionary_correction_conflict"
  )
  expect_equal(unique(out$dictionary$FormatID[out$dictionary$Variable == "REC_COD"]), "THCOD")
  expect_equal(out$corrections, character())
})

test_that("an entry that no longer has the expected value is left alone, with a warning", {
  corrections <- .srtr_dictionary_corrections
  corrections$from <- "SOMETHING_ELSE"
  tables <- .srtr_dictionary_for("2609", view = "web")

  expect_snapshot(
    out <- .srtr_apply_corrections(tables, "corrected", corrections)
  )
  expect_warning(
    .srtr_apply_corrections(tables, "corrected", corrections),
    class = "sRtr_warning_dictionary_correction_conflict"
  )
  expect_equal(unique(out$dictionary$FormatID[out$dictionary$Variable == "REC_COD"]), "THCOD")
})

test_that("an entry SRTR has already fixed is left alone, quietly", {
  corrections <- .srtr_dictionary_corrections
  corrections$from <- "OLD"
  tables <- .srtr_dictionary_for("2609", view = "web")
  fixed <- tables
  fixed$dictionary$FormatID[fixed$dictionary$Variable == "REC_COD"] <- "COD"

  expect_no_warning(out <- .srtr_apply_corrections(fixed, "corrected", corrections))
  expect_equal(out$dictionary, fixed$dictionary)
  expect_equal(out$corrections, character())
})

test_that("switching views does not reuse the other view's cached tables", {
  local_srtr_folder(character())
  df <- tibble::tibble(REC_COD = 4600)

  first <- .srtr_tables_for(df, "2303", "TX_LI", gaps = "nearest", view = "corrected")
  web <- .srtr_tables_for(df, "2303", "TX_LI", gaps = "nearest", view = "web")
  again <- .srtr_tables_for(df, "2303", "TX_LI", gaps = "nearest", view = "corrected")

  rec_cod <- \(t) unique(t$dictionary$FormatID[t$dictionary$Dataset == "TX_LI" & t$dictionary$Variable == "REC_COD"])
  expect_equal(rec_cod(first), "COD")
  expect_equal(rec_cod(web), "THCOD")
  expect_equal(rec_cod(again), "COD")
})

test_that("load_srtr_file() labels REC_COD with COD and records the view", {
  local_sas_file(fake_tx_cause_of_death(), "TX_LI")

  expect_no_warning(
    out <- load_srtr_file("TX_LI", var_labels = FALSE, column_check = "none", release = "2609")
  )

  expect_equal(as.character(out$REC_COD[1]), "4600: LI:GRAFT FAILURE:PRIMARY")
  expect_equal(attr(out$REC_COD, "srtr_format"), "COD")
  expect_equal(attr(out, "srtr_release")$view, "corrected")
  expect_equal(attr(out, "srtr_release")$corrections, "SRTR-DC-001")
})

test_that("load_srtr_file(view = \"web\") keeps THCOD and its warning", {
  local_sas_file(fake_tx_cause_of_death(), "TX_LI")

  expect_warning(
    out <- load_srtr_file(
      "TX_LI",
      var_labels = FALSE, column_check = "none", release = "2609", view = "web"
    ),
    class = "sRtr_warning_unknown_codes"
  )

  expect_equal(attr(out$REC_COD, "srtr_format"), "THCOD")
  expect_equal(as.character(out$REC_COD[2]), "2000: GRAFT FAILURE: PRIMARY FAILURE")
  expect_equal(attr(out, "srtr_release")$view, "web")
  expect_equal(attr(out, "srtr_release")$corrections, character())
})

test_that("labelling later follows the view recorded at loading", {
  local_sas_file(fake_tx_cause_of_death(), "TX_LI")
  raw_corrected <- load_srtr_file(
    "TX_LI", factor_labels = FALSE, var_labels = FALSE,
    column_check = "none", release = "2609"
  )
  raw_web <- load_srtr_file(
    "TX_LI", factor_labels = FALSE, var_labels = FALSE,
    column_check = "none", release = "2609", view = "web"
  )

  corrected <- apply_srtr_factors(raw_corrected)
  web <- suppressWarnings(apply_srtr_factors(raw_web))

  expect_equal(attr(corrected$REC_COD, "srtr_format"), "COD")
  expect_equal(attr(web$REC_COD, "srtr_format"), "THCOD")
})

test_that("codes keep their values and order under the corrected format", {
  local_sas_file(fake_tx_cause_of_death(), "TX_LI")

  out <- load_srtr_file("TX_LI", var_labels = FALSE, column_check = "none", release = "2609")

  codes <- as.integer(sub(":.*", "", as.character(out$REC_COD)))
  expect_equal(codes, fake_tx_cause_of_death()$REC_COD)
  level_codes <- as.integer(sub(":.*", "", levels(out$REC_COD)))
  expect_equal(level_codes, sort(level_codes))
})

test_that("the missing-value report agrees on raw and labelled REC_COD", {
  local_sas_file(fake_tx_cause_of_death(), "TX_LI")
  raw <- load_srtr_file(
    "TX_LI", factor_labels = FALSE, var_labels = FALSE,
    column_check = "none", release = "2609"
  )
  labelled <- apply_srtr_factors(raw)

  report_raw <- srtr_missing_report(raw, cols = "REC_COD", detail = "code")
  report_labelled <- srtr_missing_report(labelled, cols = "REC_COD", detail = "code")

  unknown <- \(r) r$n[r$missing_type == "unknown" & r$code %in% "998"]
  expect_equal(unknown(report_raw), 1L)
  expect_equal(unknown(report_labelled), 1L)
})

test_that("a column labelled under the web view keeps its own format", {
  local_sas_file(fake_tx_cause_of_death(), "TX_LI")
  web <- suppressWarnings(load_srtr_file(
    "TX_LI", var_labels = FALSE, column_check = "none",
    release = "2609", view = "web"
  ))
  attr(web, "srtr_release")$view <- "corrected"

  report <- srtr_missing_report(web, cols = "REC_COD")

  expect_equal(unique(report$format), "THCOD")
})
