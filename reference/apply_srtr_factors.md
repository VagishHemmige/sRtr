# Apply SRTR factor labels to a data frame

Converts coded variables in an SRTR dataset into human-readable factors
using the SRTR data dictionary and associated format tables.

## Usage

``` r
apply_srtr_factors(df, file_key = NULL, verbose = FALSE)
```

## Arguments

- df:

  A data frame loaded from an SRTR SAF file.

- file_key:

  Optional. The dataset name (e.g., "CAND_KIPA", "TX_KI"). If not
  provided, the function will use a `file_key` attribute or object name.

- verbose:

  Logical. If TRUE, print each variable being labeled.

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
