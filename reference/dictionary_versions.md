# Stored versions of the SRTR data dictionary

Every version of SRTR's public SAF data dictionary page that sRtr has
stored, kept as runs: each variable or format code appears once for each
unbroken sequence of stored versions in which it was the same. Use
[`srtr_dictionary()`](https://vagishhemmige.github.io/sRtr/reference/srtr_dictionary.md)
to get the dictionary for a release; this dataset is what it reads.

## Format

A list of three tibbles:

- releases:

  One row per stored snapshot: `snapshot`, `release`, `revision`,
  `title`, `sha256`, `encoding`, `last_modified`, `retrieved` and
  `source`.

- dictionary:

  Variables: `Dataset`, `Variable`, `Type`, `Length`, `FormatID`,
  `Label`, and `first` and `last`, the first and last snapshots of the
  run.

- formats:

  Format codes: `Format`, `Code`, `Meaning`, `Position` (the code's
  place within its format), `first` and `last`.

## Source

SRTR SAF data dictionary pages, stored in
`data-raw/dictionary-versions/`.

## Details

Versions are added by a monthly check of
<https://www.srtr.org/docs/datadictionary.html>. A snapshot is named by
the release and a revision number (`"2609-1"`), since SRTR can revise a
page without changing its release.
