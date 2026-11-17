# Count the missing-value codes in SRTR data

Reports, for each variable, how many values stand for missing
information and of which kind: unknown, not done, not applicable and so
on. Nothing in the data is changed. Use it to see what is there before
deciding how to handle it.

## Usage

``` r
srtr_missing_report(
  df,
  cols = NULL,
  file_key = NULL,
  detail = c("type", "code"),
  release = NULL,
  extra_codes = NULL
)
```

## Arguments

- df:

  A data frame from an SRTR SAF file.

- cols:

  Names of the columns to report. `NULL` (the default) reports every
  column that
  [missing_codes](https://vagishhemmige.github.io/sRtr/reference/missing_codes.md)
  covers.

- file_key:

  The dataset `df` comes from, such as `"TX_KI"`. `NULL` uses the
  `file_key` attribute that
  [`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)
  sets. If there is none, variables are looked up by name alone, and a
  variable whose format differs between datasets is skipped, with a
  message.

- detail:

  `"type"` (the default) gives one row per variable and kind of missing
  value found. `"code"` gives one row per classified code, including
  codes that do not occur (`n` is 0), which shows whether the codes in
  [missing_codes](https://vagishhemmige.github.io/sRtr/reference/missing_codes.md)
  match the data.

- release:

  The SAF release, as in
  [`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md).
  `NULL` uses the release recorded on `df`, or else the bundled
  dictionary.

- extra_codes:

  Your own codes, for values that
  [missing_codes](https://vagishhemmige.github.io/sRtr/reference/missing_codes.md)
  does not cover: a named list with one element per column, each a named
  character vector giving the type of each value, such as
  `list(MY_VAR = c("9" = "unknown"))`. These win over
  [missing_codes](https://vagishhemmige.github.io/sRtr/reference/missing_codes.md),
  and apply alike to raw codes and to labelled columns. If two codes of
  a format share one label, both must be given the same type.

## Value

A tibble with one row per variable and kind of missing value:

- variable:

  The column name.

- format:

  The variable's SRTR format, or `NA` if it has none.

- missing_type:

  A type from
  [missing_codes](https://vagishhemmige.github.io/sRtr/reference/missing_codes.md),
  or `"not_in_format"` for a value the variable's format does not list,
  or `"na"` for a value that is already `NA`.

- n:

  The number of rows.

- percent:

  `n` as a percentage of all rows of `df`.

With `detail = "code"`, `code` and `meaning` columns identify each code;
they are `NA` in the `"not_in_format"` and `"na"` rows. Partly known
codes (type `"partial"`) are reported too, although they are not wholly
missing.

## Details

Codes are recognised from
[missing_codes](https://vagishhemmige.github.io/sRtr/reference/missing_codes.md),
by what they mean in the variable's own format: the same code number can
be "Unknown" in one format and an ordinary value in another. Raw codes
and labelled columns (from
[`apply_srtr_factors()`](https://vagishhemmige.github.io/sRtr/reference/apply_srtr_factors.md))
give the same counts. Flag columns that have no format are recognised
from the `variables` table of
[missing_codes](https://vagishhemmige.github.io/sRtr/reference/missing_codes.md),
which is not taken from the SRTR dictionary.

The report holds counts, and the codes and meanings that
[missing_codes](https://vagishhemmige.github.io/sRtr/reference/missing_codes.md)
lists. It never holds a value taken from the data: values a format does
not list are counted together and not shown. Counts from SRTR data can
still be small cells; treat them as you would any other table made from
the data.

## See also

[missing_codes](https://vagishhemmige.github.io/sRtr/reference/missing_codes.md),
[`srtr_normalize_missing()`](https://vagishhemmige.github.io/sRtr/reference/srtr_normalize_missing.md)

## Examples

``` r
# Made-up rows using TX_KI column names
df <- data.frame(
  DON_ANTI_CMV = c("P", "N", "U", "ND", NA),
  DON_HIST_DIAB = c(1, 5, 998, 998, 2)
)
srtr_missing_report(df, file_key = "TX_KI")
#> # A tibble: 5 × 5
#>   variable      format  missing_type     n percent
#>   <chr>         <chr>   <chr>        <int>   <dbl>
#> 1 DON_ANTI_CMV  SRLSTT  unknown          1      20
#> 2 DON_ANTI_CMV  SRLSTT  not_done         1      20
#> 3 DON_ANTI_CMV  SRLSTT  na               1      20
#> 4 DON_HIST_DIAB HSTDBDR unknown          2      40
#> 5 DON_HIST_DIAB HSTDBDR partial          1      20
srtr_missing_report(df, file_key = "TX_KI", detail = "code")
#> # A tibble: 8 × 7
#>   variable      format  code  meaning                 missing_type     n percent
#>   <chr>         <chr>   <chr> <chr>                   <chr>        <int>   <dbl>
#> 1 DON_ANTI_CMV  SRLSTT  U     U: Unknown              unknown          1      20
#> 2 DON_ANTI_CMV  SRLSTT  ND    ND: Not Done            not_done         1      20
#> 3 DON_ANTI_CMV  SRLSTT  PD    PD: Pending             pending          0       0
#> 4 DON_ANTI_CMV  SRLSTT  C     C: Cannot Disclose      cannot_disc…     0       0
#> 5 DON_ANTI_CMV  SRLSTT  I     I: Indeterminate        indetermina…     0       0
#> 6 DON_ANTI_CMV  SRLSTT  NA    NA                      na               1      20
#> 7 DON_HIST_DIAB HSTDBDR 998   998: UNKNOWN            unknown          2      40
#> 8 DON_HIST_DIAB HSTDBDR 5     5: YES, DURATION UNKNO… partial          1      20
```
