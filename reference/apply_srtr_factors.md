# Apply SRTR factor labels to a data frame

Converts coded variables in an SRTR dataset into human-readable factors
using the SRTR data dictionary and associated format tables.

## Usage

``` r
apply_srtr_factors(
  df,
  file_key = NULL,
  verbose = FALSE,
  range_formats = c("keep", "bin"),
  unknown_codes = c("keep", "na", "error"),
  other = c("sas", "keep"),
  release = NULL
)
```

## Arguments

- df:

  A data frame loaded from an SRTR SAF file.

- file_key:

  Optional. The dataset name (e.g., "CAND_KIPA", "TX_KI"). If not
  provided, the function will use a `file_key` attribute or object name.

- verbose:

  Logical. If TRUE, print each variable being labeled.

- range_formats:

  What to do with numeric variables whose format is a set of bands
  rather than a code list: the age formats `AGE8A`, `AGE8C` and `AGE9A`,
  used by `REC_AGE_AT_TX` and `CAN_AGE_AT_LISTING`. `"keep"` (the
  default) leaves the numbers as they are. `"bin"` turns them into a
  factor of bands. The page lists only each band's lower bound, so
  `"bin"` treats each listed code as the start of a band that runs to
  the next one; this reading is a convention, not stated by SRTR.

- unknown_codes:

  What to do with a value that is not a code in the variable's format
  (and is not covered by a catch-all entry, see `other`). `"keep"` (the
  default) keeps it as an extra level named by the raw code followed by
  `": not in format"`, so it cannot be mistaken for a label; `"na"`
  turns it into `NA`. Both warn (class `sRtr_warning_unknown_codes`).
  `"error"` stops (class `sRtr_error_unknown_codes`).

- other:

  What to do with a format's catch-all entry (`**OTHER**`, as in `RACE`,
  where it means "Multi-Racial"). `"sas"` (the default) gives every
  value not otherwise listed the catch-all label, as a SAS format does.
  `"keep"` ignores the catch-all, so those values are handled by
  `unknown_codes`.

- release:

  Optional. The SAF release `df` comes from, as year and month
  (`"2609"`), to use that release's dictionary and formats (see
  [`srtr_dictionary()`](https://vagishhemmige.github.io/sRtr/reference/srtr_dictionary.md)).
  If `NULL` (the default), the release recorded by
  [`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)
  is used, or the bundled
  [dictionary](https://vagishhemmige.github.io/sRtr/reference/dictionary.md)
  and
  [formats](https://vagishhemmige.github.io/sRtr/reference/formats.md)
  if there is none.

## Value

A data frame with factor levels applied to coded variables, and a
`file_key` attribute holding the dataset key in upper case, so the key
carries through a chain of calls. If no usable key is found, `df` is
returned unchanged with a warning.

## Details

If `file_key` is not explicitly provided, the function will first check
for a `file_key` attribute on the data frame (e.g., from
[`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)).
If not found, it will attempt to infer it from the object name.

The key is matched in upper case. A key that is not a dataset in the
bundled
[dictionary](https://vagishhemmige.github.io/sRtr/reference/dictionary.md),
or a key that cannot be worked out (no attribute and no object name, as
when `df` is an expression), gives a warning. A known key whose columns
are not in `df` is not a problem: nothing is changed.

Values are read as codes. A value that is not a code in the format is
outside it, even if it reads like one of the format's labels.

A column converted by an earlier call carries an `srtr_format` attribute
and is left as it is, so calling the function twice changes nothing.
dplyr and tibble operations keep the attribute; base R subsetting such
as `df[rows, ]` on a data frame drops it, and the column is then read as
codes again, with every value reported as outside the format (also when
the format has a catch-all: for a factor input, values given the
catch-all label are reported too; raw codes get it silently, as in SAS).
Convert again from the raw codes, or keep working with dplyr. Attributes
on each column, such as a variable label, are kept.

When codes that are not in the format are kept, the column also carries
an `srtr_kept_codes` attribute: a named vector giving, for each such
level, the original code.
[`srtr_missing_report()`](https://vagishhemmige.github.io/sRtr/reference/srtr_missing_report.md)
uses it to recognise those codes after labelling.

## Examples

``` r
if (FALSE) { # \dontrun{
# Explicit file_key
df <- read_sas("TX_KI.sas7bdat")
df <- apply_srtr_factors(df, file_key = "TX_KI", verbose = TRUE)

# Implicit file_key from attribute (if loaded via load_srtr_file)
df <- load_srtr_file("TX_KI")
df <- apply_srtr_factors(df)

# Fallback to object name inference
TX_KI <- read_sas("TX_KI.sas7bdat")
TX_KI <- apply_srtr_factors(TX_KI)
} # }
```
