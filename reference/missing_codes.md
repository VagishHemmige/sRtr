# Missing-value codes in the SRTR formats, by type

SRTR formats record missing information in several ways, and the same
code number means different things in different formats: code `4` is
"Unknown" in one format, "N/A" in another and "Not tested" in a third.
Many flag columns have no format at all, so the dictionary does not say
which of their values mean missing. This dataset classifies both kinds
of code, so that each can be handled by what it means.

## Format

A list of two tibbles.

`formats` has one row per classified format code:

- Format, Code, Meaning:

  The format code, as in
  [dictionary_versions](https://vagishhemmige.github.io/sRtr/reference/dictionary_versions.md).
  A classification applies only to this exact meaning.

- missing_type:

  The type, one of those listed in Details.

- collapses_to:

  For `"partial"` codes, the part of the answer that is known. Empty
  otherwise.

- note:

  Why the code was classified this way, where that is not plain from its
  meaning.

`variables` has one row per variable and raw value, for values that no
format of the variable lists. Most are one-character flag columns with
no format:

- Variable:

  The variable name, in whichever file it appears.

- Code:

  The raw value, as text. A blank is the empty string. A blank or text
  value listed for a variable the dictionary types as numeric cannot
  occur as stored; such rows are kept from the hand list, and their
  `note` says so.

- missing_type:

  The type, as above. Never `"none"` or `"partial"`.

- source:

  Where the row comes from. `"hand list"` rows were carried over from
  the hand-written list that
  [`srtr_normalize_missing()`](https://vagishhemmige.github.io/sRtr/reference/srtr_normalize_missing.md)
  used before this dataset existed. The SRTR dictionary does not
  document these values, and they have not yet been checked against SAF
  data.

- note:

  Anything else worth knowing about the row.

## Source

`formats`: meanings from the SRTR SAF data dictionary pages stored in
[dictionary_versions](https://vagishhemmige.github.io/sRtr/reference/dictionary_versions.md),
classified by hand in `data-raw/missing-codes/format_codes.csv`.
`variables`: `data-raw/missing-codes/variable_codes.csv`, which is not
taken from the dictionary.

## Details

The classification describes what a code means. It does not say what an
analysis should do with it.

A code is listed when its meaning matches a broad screen (words such as
"unknown", "not done", "N/A" or "pending"), when it is the SAS missing
value `.`, or when it is a format's catch-all. Each listed code was then
classified by hand from its meaning in the SRTR data dictionary. A code
the screen picked up that turned out to be an ordinary value is kept,
with type `"none"`, so that it is known to have been looked at. Codes
that are not listed did not match the screen.

The types are sRtr's own grouping of the dictionary's meanings, not an
SRTR classification:

- `"unknown"`: the information is not known.

- `"not_applicable"`: the question does not apply to this person.

- `"not_done"`: the test or assessment was not done.

- `"pending"`: a result was awaited.

- `"cannot_disclose"`: the result is withheld.

- `"indeterminate"`: the test was done and gave no clear result.

- `"partial"`: part of the answer is known, such as "Yes, duration
  unknown". `collapses_to` names the part that is known.

- `"sas_missing"`: the SAS missing value. For numbers that is `.`, which
  a format labels "Missing"; for text it is a blank.

- `"none"`: an ordinary value.

## See also

Guides:

- [What the codes
  mean](https://vagishhemmige.github.io/sRtr/articles/missing-data.html#what-the-codes-mean)
