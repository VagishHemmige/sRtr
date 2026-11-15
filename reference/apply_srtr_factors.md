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
  other = c("sas", "keep")
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

A column that is already a factor of this format's labels, for example
from an earlier call, is left as it is, so calling the function twice
changes nothing. Attributes on each column, such as a variable label,
are kept.

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
