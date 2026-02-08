# Normalize Missing Value Representations in SRTR Data

Replaces common non-standard representations of missing values (e.g.,
-1, 999, "Unknown") with either `NA` or a user-specified string (e.g.,
`"Missing"`). This includes both explicit missing codes (provided via
`missing_vals`) and, if `replacement` is not `NA`, any existing `NA`
values in the specified columns.

## Usage

``` r
srtr_normalize_missing(
  df,
  missing_vals = NULL,
  replacement = NA,
  verbose = FALSE
)
```

## Arguments

- df:

  A data frame from an SRTR SAF file.

- missing_vals:

  An optional named list. The `srtr_normalize_missing()` function
  defaults to an internal list of variables to normalize and values to
  convert to the specified replacement value. Each name corresponds to a
  column in `df`, and each element is a vector of values to treat as
  missing in that column. Any values matched will be replaced by
  `replacement`. Columns not present in `df` are silently skipped.

- replacement:

  The value to use in place of the missing representations. Defaults to
  `NA`. If a string is provided (e.g., `"Missing"`), both missing codes
  and `NA` values will be replaced. If the column is a factor and
  `replacement` is not `NA`, the replacement will be added as a new
  factor level.

- verbose:

  Logical. If `TRUE`, the function prints a message for each column it
  modifies, including skipped columns that are not found in `df`.

## Value

A modified version of `df`, with all specified missing values (and
possibly `NA`s) replaced by `replacement`.

## Details

This function is helpful for harmonizing SRTR datasets, which may use
multiple codes to represent missingness (e.g., -1 for numeric fields,
"U" or "Unknown" for character or factor fields).

## Examples

``` r
if (FALSE) { # \dontrun{
df <- load_srtr_file("TX_LI")

# Use default SRTR-wide missing definitions
srtr_normalize_missing(df)

# Explicitly define missing values and convert all missing to "Missing"
missing_vals <- list(
  REC_HIV_STAT = c("U", ""),
  REC_HCV_STAT = c("U", ""),
)
srtr_normalize_missing(df, missing_vals, replacement = "Missing")
} # }
```
