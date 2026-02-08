# Composite death date (OPTN \> SSA \> TFL)

Builds a composite death date column using precedence across the typical
SRTR sources: OPTN (PERS_OPTN_DEATH_DT), SSA (PERS_SSA_DEATH_DT), then
TFL (TFL_DEATH_DT). By default it respects this precedence using
[`dplyr::coalesce()`](https://dplyr.tidyverse.org/reference/coalesce.html).
Optionally, set `prefer_earliest = TRUE` to pick the earliest
non-missing date instead.

## Usage

``` r
srtr_composite_death(
  df,
  optn = "PERS_OPTN_DEATH_DT",
  ssa = "PERS_SSA_DEATH_DT",
  tfl = "TFL_DEATH_DT",
  out = "REC_DEATH_DT_COMPOSITE",
  parse = TRUE,
  keep_source = TRUE,
  add_conflict_flag = TRUE,
  prefer_earliest = FALSE
)
```

## Arguments

- df:

  A data frame.

- optn, ssa, tfl:

  Character column names for OPTN, SSA, and TFL death dates.

- out:

  Name of the output composite column to create.

- parse:

  If TRUE, parse the three inputs with `.srtr_as_date()`.

- keep_source:

  If TRUE, add `{out}_source` with the chosen source label.

- add_conflict_flag:

  If TRUE, add `{out}_conflict` when sources disagree.

- prefer_earliest:

  If TRUE, ignore precedence and choose the earliest date.

## Value

`df` with added composite column (and optional source/conflict columns).

## Details

Columns are parsed with `.srtr_as_date()` to accept YYYYMMDD
integers/strings. You can also keep a "which source won" indicator and a
conflict flag when multiple sources disagree.

## Examples

``` r
if (FALSE) { # \dontrun{
df <- srtr_composite_death(df)
} # }
```
