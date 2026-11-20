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
  keep_source = TRUE,
  add_conflict_flag = TRUE,
  prefer_earliest = FALSE,
  conflict_days = 0,
  add_spread_days = FALSE
)
```

## Arguments

- df:

  A data frame.

- optn, ssa, tfl:

  Character column names for OPTN, SSA, and TFL death dates. Each must
  be a `Date` column.

- out:

  Name of the output composite column to create.

- keep_source:

  If TRUE, add `{out}_source` with the chosen source label.

- add_conflict_flag:

  If TRUE, add `{out}_conflict`: `TRUE` when the earliest and latest
  non-missing source dates are more than `conflict_days` apart, `FALSE`
  otherwise, including when fewer than two sources have a date.

- prefer_earliest:

  If TRUE, ignore precedence and choose the earliest date.

- conflict_days:

  How many calendar days apart the earliest and latest source dates may
  be before `{out}_conflict` is `TRUE`; only a spread strictly greater
  than it is flagged. The default, 0, flags any difference. A larger
  value is your choice of what counts as recording noise: a difference
  of a day can still change the order of death and another event. It
  changes only the flag, never the composite date or its source.

- add_spread_days:

  If TRUE, add `{out}_spread_days`: the calendar days between the
  earliest and latest non-missing source dates, 0 when two or more
  sources agree, and `NA` when fewer than two have a date. A column
  given for two sources counts once. Use it to compare thresholds
  without running this function again.

## Value

`df` with added composite column (and optional source, conflict and
spread columns).

## Details

The three columns must be stored as `Date`, which is how
[`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)
returns SAS date columns. You can also keep a "which source won"
indicator and a conflict flag when multiple sources disagree.

## How the sources compare in real data

In the 2303 liver transplant file (TX_LI):

- Among recipients with both dates, `TFL_DEATH_DT` matched the OPTN date
  on the same day in over 99%. Deaths recorded only in `TFL_DEATH_DT`
  were very rare (19 of about 87,000 recipients with any death date).

- Among recipients with both dates, the SSA date matched OPTN on the
  same day in about 82% and within a week in about 94%; differences ran
  in both directions.

- SSA recorded far fewer deaths than OPTN in recent years (under a
  quarter as many from 2015 on), consistent with the 2011 change to the
  SSA Death Master File. So for recent deaths a missing SSA date is weak
  evidence against a death reported to OPTN.

- Conflicts between sources were more frequent among earlier
  transplants.

- `prefer_earliest = TRUE` changed the date for under 5% of recipients
  with a death date, mostly by a week or less.

Other releases and organs may differ.

## See also

Guides:

- [Which death
  date?](https://vagishhemmige.github.io/sRtr/articles/follow-up-windows.html#which-death-date)

- [Deaths found after follow-up
  ends](https://vagishhemmige.github.io/sRtr/articles/follow-up-windows.html#deaths-found-after-follow-up-ends)

## Examples

``` r
if (FALSE) { # \dontrun{
df <- srtr_composite_death(df)
} # }
```
