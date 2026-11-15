test_that("the parser reads variables and their attributes", {
  skip_if_not_installed("xml2")
  path <- local_dictionary_page(
    data = list(TX_KI = fake_vars(
      c("REC_FAKE_A", "REC_FAKE_B"),
      Type = c("char", "num"),
      Length = c("2", "8"),
      FormatID = c("FAKEFMT", "")
    )),
    formats = list(FAKEFMT = fake_codes(c("1", "2")))
  )

  page <- .srtr_parse_dictionary_page(path)

  expect_equal(page$release, "9901")
  expect_equal(
    page$dictionary,
    tibble::tibble(
      Dataset = "TX_KI",
      Variable = c("REC_FAKE_A", "REC_FAKE_B"),
      Type = c("char", "num"),
      Length = c("2", "8"),
      FormatID = c("FAKEFMT", ""),
      Label = c("Label of REC_FAKE_A", "Label of REC_FAKE_B")
    )
  )
})

test_that("the parser takes the dataset from 'Data File:' when the id is cut short", {
  skip_if_not_installed("xml2")
  path <- local_dictionary_page(
    data = list(FAKE_FILE_TRUNC = fake_vars("FAKE_VAR")),
    formats = list(FAKEFMT = fake_codes("1")),
    data_file = c(FAKE_FILE_TRUNC = "FAKE_FILE_TRUNCATED")
  )

  page <- .srtr_parse_dictionary_page(path)

  expect_equal(page$dictionary$Dataset, "FAKE_FILE_TRUNCATED")
})

test_that("the parser reads format codes", {
  skip_if_not_installed("xml2")
  path <- local_dictionary_page(
    data = list(TX_KI = fake_vars("REC_FAKE_A", FormatID = "FAKEFMT")),
    formats = list(FAKEFMT = fake_codes(c("1", "U"), c("1: Yes", "U: Unknown")))
  )

  page <- .srtr_parse_dictionary_page(path)

  expect_equal(
    page$formats,
    tibble::tibble(
      Format = "FAKEFMT",
      Code = c("1", "U"),
      Meaning = c("1: Yes", "U: Unknown")
    )
  )
  expect_equal(nrow(page$problems), 0)
})

test_that("the parser errors when the title has no release", {
  skip_if_not_installed("xml2")
  path <- local_dictionary_page(
    data = list(TX_KI = fake_vars("REC_FAKE_A")),
    title = "Some other page"
  )

  expect_snapshot(
    .srtr_parse_dictionary_page(path),
    error = TRUE,
    transform = \(x) gsub(path, "<page>", x, fixed = TRUE)
  )
  expect_error(
    .srtr_parse_dictionary_page(path),
    class = "sRtr_error_dictionary_page_invalid"
  )
})

test_that("the parser errors when the page has no dataset sections", {
  skip_if_not_installed("xml2")
  path <- local_dictionary_page(formats = list(FAKEFMT = fake_codes("1")))

  expect_snapshot(
    .srtr_parse_dictionary_page(path),
    error = TRUE,
    transform = \(x) gsub(path, "<page>", x, fixed = TRUE)
  )
  expect_error(
    .srtr_parse_dictionary_page(path),
    class = "sRtr_error_dictionary_page_invalid"
  )
})

test_that("the parser reports duplicate entries and undefined formats", {
  skip_if_not_installed("xml2")
  path <- local_dictionary_page(
    data = list(TX_KI = fake_vars(
      c("REC_FAKE_A", "REC_FAKE_A", "REC_FAKE_B", "REC_FAKE_DT"),
      FormatID = c("FAKEFMT", "FAKEFMT", "NOSUCHFMT", "MMDDYY")
    )),
    formats = list(FAKEFMT = fake_codes(c("1", "1")))
  )

  page <- .srtr_parse_dictionary_page(path)

  expect_equal(
    page$problems,
    tibble::tibble(
      problem = c("duplicate_entry", "duplicate_entry", "undefined_format"),
      table = c("dictionary", "formats", "dictionary"),
      key = c("TX_KI REC_FAKE_A", "FAKEFMT 1", "TX_KI REC_FAKE_B"),
      detail = c("2 rows", "2 rows", "NOSUCHFMT")
    )
  )
})

test_that("snapshot ids sort by release, then revision", {
  expect_equal(
    .srtr_sort_snapshots(c("2609-1", "2203-2", "2203-1", "9901-10", "9901-2")),
    c("2203-1", "2203-2", "2609-1", "9901-2", "9901-10")
  )
  expect_error(
    .srtr_sort_snapshots(c("2203-1", "2203")),
    class = "sRtr_error_invalid_snapshot_id"
  )
})

test_that("an entry identical in two snapshots is one run", {
  snaps <- list(
    "2203-1" = fake_snapshot("REC_FAKE_A", "A"),
    "2609-1" = fake_snapshot("REC_FAKE_A", "A")
  )

  runs <- .srtr_runs_build(snaps, key = c("Dataset", "Variable"))

  expect_equal(runs$first, "2203-1")
  expect_equal(runs$last, "2609-1")
})

test_that("a value that changes and changes back gives three runs", {
  snaps <- list(
    "2203-1" = fake_snapshot("REC_FAKE_A", "A"),
    "2306-1" = fake_snapshot("REC_FAKE_A", "B"),
    "2609-1" = fake_snapshot("REC_FAKE_A", "A")
  )

  runs <- .srtr_runs_build(snaps, key = c("Dataset", "Variable"))

  expect_equal(runs$Label, c("A", "B", "A"))
  expect_equal(runs$first, c("2203-1", "2306-1", "2609-1"))
  expect_equal(runs$last, c("2203-1", "2306-1", "2609-1"))
})

test_that("an entry missing from a snapshot ends its run", {
  snaps <- list(
    "2203-1" = fake_snapshot(c("REC_FAKE_A", "REC_FAKE_B"), c("A", "B")),
    "2306-1" = fake_snapshot("REC_FAKE_B", "B"),
    "2609-1" = fake_snapshot(c("REC_FAKE_A", "REC_FAKE_B"), c("A", "B"))
  )

  runs <- .srtr_runs_build(snaps, key = c("Dataset", "Variable"))

  expect_equal(runs$Variable, c("REC_FAKE_A", "REC_FAKE_A", "REC_FAKE_B"))
  expect_equal(runs$first, c("2203-1", "2609-1", "2203-1"))
  expect_equal(runs$last, c("2203-1", "2609-1", "2609-1"))
})

test_that("each snapshot can be recovered from the runs", {
  snaps <- list(
    "2203-1" = fake_snapshot(c("REC_FAKE_A", "REC_FAKE_B"), c("A", "B")),
    "2306-1" = fake_snapshot(c("REC_FAKE_B", "REC_FAKE_C"), c("B2", "C")),
    "2609-1" = fake_snapshot(c("REC_FAKE_A", "REC_FAKE_B"), c("A", "B"))
  )
  runs <- .srtr_runs_build(snaps, key = c("Dataset", "Variable"))

  for (id in names(snaps)) {
    expect_equal(.srtr_runs_at(runs, names(snaps), id), snaps[[id]])
  }
  expect_error(
    .srtr_runs_at(runs, names(snaps), "2406-1"),
    class = "sRtr_error_snapshot_not_found"
  )
})

test_that("adding a snapshot between two others splits a run", {
  key <- c("Dataset", "Variable")
  runs <- .srtr_runs_build(
    list(
      "2203-1" = fake_snapshot("REC_FAKE_A", "A"),
      "2609-1" = fake_snapshot("REC_FAKE_A", "A")
    ),
    key = key
  )

  added <- .srtr_runs_add(
    runs,
    order = c("2203-1", "2609-1"),
    snapshot = fake_snapshot("REC_FAKE_A", "B"),
    id = "2406-1",
    key = key
  )

  expect_equal(added$order, c("2203-1", "2406-1", "2609-1"))
  expect_equal(added$runs$Label, c("A", "B", "A"))
  expect_equal(added$runs$first, c("2203-1", "2406-1", "2609-1"))
})

test_that("adding a snapshot id that is already stored is an error", {
  key <- c("Dataset", "Variable")
  runs <- .srtr_runs_build(
    list("2203-1" = fake_snapshot("REC_FAKE_A", "A")),
    key = key
  )

  expect_error(
    .srtr_runs_add(runs, "2203-1", fake_snapshot("REC_FAKE_A", "A"), "2203-1", key),
    class = "sRtr_error_snapshot_exists"
  )
})

test_that("a page with no declared charset is read as Windows-1252", {
  skip_if_not_installed("xml2")
  html <- fake_dictionary_page(
    data = list(TX_KI = fake_vars("REC_FAKE_A", FormatID = "FAKEFMT")),
    formats = list(FAKEFMT = fake_codes(c("1", "2"), c("1: Grade 1 DASH x", "2: FAKE QUOTE S")))
  )
  bytes <- charToRaw(html)
  bytes <- .fake_replace_bytes(bytes, "DASH", as.raw(0x96))
  bytes <- .fake_replace_bytes(bytes, "QUOTE", as.raw(0x92))
  path <- withr::local_tempfile(fileext = ".html")
  writeBin(bytes, path)

  page <- .srtr_parse_dictionary_page(path)

  expect_equal(page$encoding, "windows-1252")
  expect_equal(
    page$formats$Meaning,
    c("1: Grade 1 – x", "2: FAKE ’ S")
  )
})

test_that("a page that declares its charset is read in that charset", {
  skip_if_not_installed("xml2")
  html <- fake_dictionary_page(
    data = list(TX_KI = fake_vars("REC_FAKE_A", FormatID = "FAKEFMT")),
    formats = list(FAKEFMT = fake_codes("1", "1: Grade 1 – x"))
  )
  html <- sub("<head>", '<head><meta charset="utf-8">', html, fixed = TRUE)
  path <- withr::local_tempfile(fileext = ".html")
  writeBin(charToRaw(enc2utf8(html)), path)

  page <- .srtr_parse_dictionary_page(path)

  expect_equal(page$encoding, "utf-8")
  expect_equal(page$formats$Meaning, "1: Grade 1 – x")
})

test_that("the parser reports text with control characters", {
  skip_if_not_installed("xml2")
  path <- local_dictionary_page(
    data = list(TX_KI = fake_vars("REC_FAKE_A", FormatID = "FAKEFMT")),
    formats = list(FAKEFMT = fake_codes(c("1", "2"), c("1: Fine", "2: Bad &#150; dash")))
  )

  page <- .srtr_parse_dictionary_page(path)

  expect_equal(
    page$problems,
    tibble::tibble(
      problem = "control_character",
      table = "formats",
      key = "FAKEFMT 2",
      detail = "Meaning"
    )
  )
})
