# Made-up format codes and classifications for testing the missing-code
# checks without the stored dictionary.
fake_format_codes <- function(Format, Code, Meaning) {
  tibble::tibble(Format = Format, Code = Code, Meaning = Meaning)
}

fake_missing_codes <- function(
  Format,
  Code,
  Meaning,
  missing_type,
  collapses_to = "",
  note = ""
) {
  tibble::tibble(
    Format = Format,
    Code = Code,
    Meaning = Meaning,
    missing_type = missing_type,
    collapses_to = collapses_to,
    note = note
  )
}
