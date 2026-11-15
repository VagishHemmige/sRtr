# Versioned SRTR data dictionaries: parsing and storage (#26)
#
# SRTR publishes only the current SAF data dictionary, as one HTML page
# (https://www.srtr.org/docs/datadictionary.html). sRtr keeps every page it has
# seen as a "snapshot", identified as "<release>-<revision>": "2609-1" is the
# first copy seen of release 2609, and "2609-2" would be a later, revised
# page with the same release number.
#
# Entries are stored as runs rather than as one full copy per snapshot. A run
# is one entry (a variable in a dataset, or a code in a format) with the same
# attributes in an unbroken sequence of snapshots, recorded by its first and
# last snapshot. An entry that is absent from a snapshot, or whose attributes
# differ, ends its run there, so a value that changes and changes back (A, B,
# A) is three runs, never one run covering B.
#
# The runs describe only the snapshots seen. Treating an entry as unchanged in
# releases that fall between the first and last snapshot of its run is an
# assumption made by the code that reads the runs, not by this storage.
#
# Nothing here writes files. The scripts in data-raw/ write the stored tables.

# Format IDs that are SAS formats rather than SRTR code lists, so the page
# has no table for them.
.srtr_sas_formats <- c("MMDDYY", "DATE", "TIME", "DATETIME")

# Parse one saved copy of the SRTR SAF data dictionary page.
#
# Returns a list:
#   * release: the release number from the page title, e.g. "2609";
#   * title: the page title;
#   * encoding: the character encoding the page was read in;
#   * dictionary: Dataset, Variable, Type, Length, FormatID, Label;
#   * formats: Format, Code, Meaning;
#   * problems: problem, table, key, detail. One row per duplicate entry
#     ("duplicate_entry"), per variable whose format ID has no table on the
#     page ("undefined_format"), per table row with the wrong number of
#     cells ("malformed_row"), and per entry whose text has control
#     characters, a sign the page was read in the wrong encoding
#     ("control_character"). Problems are reported, not fixed.
#
# Errors when the page has no release in its title or has no dataset or
# format sections, since it is then not a dictionary page this parser knows.
.srtr_parse_dictionary_page <- function(path, call = rlang::caller_env()) {
  rlang::check_installed("xml2", "to read an SRTR data dictionary page.")

  encoding <- .srtr_page_encoding(path)
  html <- xml2::read_html(path, encoding = encoding)
  title <- xml2::xml_text(xml2::xml_find_first(html, "//title"), trim = TRUE)
  release <- stringr::str_match(
    title,
    "^SRTR\\s+(\\d{4})\\s+Public SAFs Data Dictionary$"
  )[, 2]
  if (is.na(release)) {
    srtr_abort(
      c(
        "This page's title does not give an SRTR dictionary release:",
        " " = "{.file {path}}",
        "i" = "Expected a title like {.val SRTR 2609 Public SAFs Data Dictionary}; found {.val {title}}."
      ),
      class = "dictionary_page_invalid",
      call = call
    )
  }

  data_divs <- xml2::xml_find_all(html, "//div[starts-with(@id, 'data_')]")
  fmt_divs <- xml2::xml_find_all(html, "//div[starts-with(@id, 'fmt_')]")
  if (length(data_divs) == 0 || length(fmt_divs) == 0) {
    srtr_abort(
      c(
        "This page has no dataset or no format sections:",
        " " = "{.file {path}}",
        "i" = "Found {length(data_divs)} dataset section{?s} and {length(fmt_divs)} format section{?s}."
      ),
      class = "dictionary_page_invalid",
      call = call
    )
  }

  dict_parts <- lapply(data_divs, .srtr_parse_data_div)
  fmt_parts <- lapply(fmt_divs, .srtr_parse_fmt_div)
  dictionary <- dplyr::bind_rows(lapply(dict_parts, `[[`, "rows"))
  formats <- dplyr::bind_rows(lapply(fmt_parts, `[[`, "rows"))
  malformed <- dplyr::bind_rows(
    lapply(dict_parts, `[[`, "malformed"),
    lapply(fmt_parts, `[[`, "malformed")
  )

  list(
    release = release,
    title = title,
    encoding = encoding,
    dictionary = dictionary,
    formats = formats,
    problems = .srtr_dictionary_problems(dictionary, formats, malformed)
  )
}

# The encoding to read a saved dictionary page in.
#
# The SRTR page declares no charset (neither in the page nor, as served on
# 2026-11-15, in its Content-Type) and contains Windows-1252 bytes such as
# 0x96 (en dash) and 0x92 (apostrophe). Read as Latin-1, those become C1
# control characters. Following the WHATWG encoding rules, a page with a byte
# order mark or a declared charset is read as declared, with Latin-1 and ASCII
# labels read as Windows-1252, and an undeclared page as Windows-1252.
.srtr_page_encoding <- function(path) {
  head <- readBin(path, "raw", n = 4096)
  if (length(head) >= 3 && identical(head[1:3], as.raw(c(0xef, 0xbb, 0xbf)))) {
    return("utf-8")
  }
  # A charset declaration is ASCII, so the other bytes can be dropped.
  text <- rawToChar(head[head > as.raw(0) & head < as.raw(0x80)])
  declared <- stringr::str_match(
    tolower(text),
    "<meta[^>]*charset\\s*=\\s*[\"']?([a-z0-9_.:-]+)"
  )[, 2]
  if (is.na(declared) || declared %in% c("iso-8859-1", "latin1", "us-ascii", "ascii")) {
    return("windows-1252")
  }
  declared
}

# The cells of every body row of the section's table.dataTable.
.srtr_table_cells <- function(div) {
  rows <- xml2::xml_find_all(
    div,
    paste0(
      ".//table[contains(concat(' ', normalize-space(@class), ' '), ' dataTable ')]",
      "//tr[td]"
    )
  )
  lapply(rows, function(row) {
    xml2::xml_text(xml2::xml_find_all(row, "./td"), trim = TRUE)
  })
}

.srtr_parse_data_div <- function(div) {
  id <- xml2::xml_attr(div, "id")
  dataset <- sub("^data_[^_]+_", "", id)
  # The section id can be cut short (MPEXCEPT_ORIG_TUMO for the
  # MPEXCEPT_ORIG_TUMORS file), so the "Data File:" name wins when present.
  section_title <- xml2::xml_text(
    xml2::xml_find_all(div, ".//td[contains(@class, 'sectionTitle')]")
  )
  data_file <- stringr::str_match(
    section_title,
    "^\\s*Data File:\\s*([A-Za-z0-9_]+)\\s*$"
  )[, 2]
  data_file <- data_file[!is.na(data_file)][1]
  if (!is.na(data_file)) {
    dataset <- data_file
  }

  cells <- .srtr_table_cells(div)
  ok <- lengths(cells) == 5
  rows <- tibble::tibble(
    Dataset = rep(dataset, sum(ok)),
    Variable = vapply(cells[ok], `[`, character(1), 1),
    Type = vapply(cells[ok], `[`, character(1), 2),
    Length = vapply(cells[ok], `[`, character(1), 3),
    FormatID = sub("^\\$", "", vapply(cells[ok], `[`, character(1), 4)),
    Label = vapply(cells[ok], `[`, character(1), 5)
  )
  list(rows = rows, malformed = .srtr_malformed(cells, ok, "dictionary", dataset))
}

.srtr_parse_fmt_div <- function(div) {
  format <- sub("^fmt_", "", xml2::xml_attr(div, "id"))
  cells <- .srtr_table_cells(div)
  ok <- lengths(cells) == 2
  rows <- tibble::tibble(
    Format = rep(format, sum(ok)),
    Code = vapply(cells[ok], `[`, character(1), 1),
    Meaning = vapply(cells[ok], `[`, character(1), 2)
  )
  list(rows = rows, malformed = .srtr_malformed(cells, ok, "formats", format))
}

.srtr_malformed <- function(cells, ok, table, section) {
  tibble::tibble(
    problem = rep("malformed_row", sum(!ok)),
    table = rep(table, sum(!ok)),
    key = rep(section, sum(!ok)),
    detail = paste(lengths(cells[!ok]), "cells")
  )
}

.srtr_dictionary_problems <- function(dictionary, formats, malformed) {
  dup <- function(data, key, table) {
    data |>
      dplyr::count(dplyr::across(dplyr::all_of(key)), name = "n") |>
      dplyr::filter(.data$n > 1) |>
      dplyr::transmute(
        problem = "duplicate_entry",
        table = table,
        key = paste(.data[[key[1]]], .data[[key[2]]]),
        detail = paste(.data$n, "rows")
      )
  }
  undefined <- dictionary |>
    dplyr::filter(
      nzchar(.data$FormatID),
      !.data$FormatID %in% formats$Format,
      !.data$FormatID %in% .srtr_sas_formats
    ) |>
    dplyr::transmute(
      problem = "undefined_format",
      table = "dictionary",
      key = paste(.data$Dataset, .data$Variable),
      detail = .data$FormatID
    )

  control <- function(data, key, text, table) {
    bad <- grepl("[\u0001-\u0008\u000b\u000c\u000e-\u001f\u007f-\u009f]", data[[text]])
    tibble::tibble(
      problem = rep("control_character", sum(bad)),
      table = rep(table, sum(bad)),
      key = paste(data[[key[1]]][bad], data[[key[2]]][bad]),
      detail = rep(text, sum(bad))
    )
  }

  dplyr::bind_rows(
    tibble::tibble(
      problem = character(),
      table = character(),
      key = character(),
      detail = character()
    ),
    dup(dictionary, c("Dataset", "Variable"), "dictionary"),
    dup(formats, c("Format", "Code"), "formats"),
    undefined,
    control(dictionary, c("Dataset", "Variable"), "Label", "dictionary"),
    control(formats, c("Format", "Code"), "Meaning", "formats"),
    malformed
  )
}

# Sort snapshot ids ("<release>-<revision>") by release, then revision.
.srtr_sort_snapshots <- function(ids, call = rlang::caller_env()) {
  parts <- stringr::str_match(ids, "^(\\d{4})-([1-9]\\d*)$")
  bad <- ids[is.na(parts[, 1])]
  if (length(bad) > 0) {
    srtr_abort(
      c(
        "Snapshot ids must look like {.val 2609-1} (release, then revision).",
        "x" = "Not valid: {.val {bad}}."
      ),
      class = "invalid_snapshot_id",
      call = call
    )
  }
  ids[order(as.integer(parts[, 2]), as.integer(parts[, 3]))]
}

# Build runs from snapshot tables.
#
# `snapshots`: a named list of data frames, one per snapshot, named by
#   snapshot id. Each has the `key` columns plus attribute columns (all the
#   same columns). Order does not matter; ids are sorted.
# Returns one row per run: the key and attribute columns, then `first` and
# `last`, sorted by key and then by first snapshot.
.srtr_runs_build <- function(snapshots, key) {
  order <- .srtr_sort_snapshots(names(snapshots))
  long <- dplyr::bind_rows(snapshots[order], .id = "snapshot")
  value_cols <- setdiff(names(long), "snapshot")
  attr_cols <- setdiff(value_cols, key)
  position <- match(long$snapshot, order)

  long |>
    dplyr::mutate(.pos = position) |>
    dplyr::arrange(dplyr::across(dplyr::all_of(key)), .data$.pos) |>
    dplyr::group_by(dplyr::across(dplyr::all_of(key))) |>
    dplyr::mutate(
      .changed = .srtr_row_changed(dplyr::pick(dplyr::all_of(attr_cols))),
      .run = cumsum(.data$.changed | .data$.pos != dplyr::lag(.data$.pos, default = -1L) + 1L)
    ) |>
    dplyr::group_by(dplyr::across(dplyr::all_of(c(key, ".run")))) |>
    dplyr::summarise(
      dplyr::across(dplyr::all_of(attr_cols), dplyr::first),
      first = order[min(.data$.pos)],
      last = order[max(.data$.pos)],
      .first_pos = min(.data$.pos),
      .groups = "drop"
    ) |>
    dplyr::arrange(dplyr::across(dplyr::all_of(key)), .data$.first_pos) |>
    dplyr::select(dplyr::all_of(value_cols), "first", "last")
}

# TRUE where a row's values differ from the row before (first row TRUE).
.srtr_row_changed <- function(values) {
  n <- nrow(values)
  if (n == 0) {
    return(logical())
  }
  if (n == 1) {
    return(TRUE)
  }
  same <- Reduce(
    `&`,
    lapply(values, function(col) {
      prev <- col[-n]
      cur <- col[-1]
      (is.na(prev) & is.na(cur)) | (!is.na(prev) & !is.na(cur) & prev == cur)
    })
  )
  c(TRUE, !same)
}

# The table as it was in one observed snapshot.
.srtr_runs_at <- function(runs, order, id, call = rlang::caller_env()) {
  order <- .srtr_sort_snapshots(order)
  pos <- match(id, order)
  if (is.na(pos)) {
    srtr_abort(
      c(
        "Snapshot {.val {id}} is not among the stored snapshots.",
        "i" = "Stored: {.val {order}}."
      ),
      class = "snapshot_not_found",
      call = call
    )
  }
  first <- match(runs$first, order)
  last <- match(runs$last, order)
  runs[first <= pos & last >= pos, setdiff(names(runs), c("first", "last"))]
}

# Add one snapshot to stored runs. Returns list(runs, order).
.srtr_runs_add <- function(runs, order, snapshot, id, key,
                           call = rlang::caller_env()) {
  if (id %in% order) {
    srtr_abort(
      c(
        "Snapshot {.val {id}} is already stored.",
        "i" = "A revised page for the same release needs the next revision number."
      ),
      class = "snapshot_exists",
      call = call
    )
  }
  order <- .srtr_sort_snapshots(order)
  snapshots <- stats::setNames(
    lapply(order, function(x) .srtr_runs_at(runs, order, x)),
    order
  )
  snapshots[[id]] <- tibble::as_tibble(snapshot)
  list(
    runs = .srtr_runs_build(snapshots, key),
    order = .srtr_sort_snapshots(names(snapshots))
  )
}
