# Add appropriate time-to-event outcome variables to a data frame based on the df attributes, if the file was loaded using a load function.

Uses the helper functions to create three columns for an outcome defined
by an event date and a censor date:

- `{prefix}_CENSOR`: event date if present, otherwise censor date

- `{prefix}_BINARY`: 1 if event date present, else 0

- `{prefix}_{unit}`: numeric time from start_date to `{prefix}_CENSOR`
  in chosen units

## Usage

``` r
add_time_to_event_outcomes(
  df,
  death_window = c("follow_up", "ascertainment"),
  ascertainment_date = NULL,
  graft_death_same_day = c("censor", "event")
)
```

## Arguments

- df:

  A transplant data frame from
  [`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md).
  Its `file_key` attribute decides which follow-up file and outcome
  columns are used.

- death_window:

  Which deaths count as events, and where recipients without one are
  censored:

  - `"follow_up"` (default): deaths on or before the recipient's last
    follow-up date count; everyone else is censored at last follow-up.

  - `"ascertainment"`: the SRTR program-specific report method for
    patient survival. Deaths from any source on or before
    `ascertainment_date` count; everyone else is assumed alive and
    censored at that date.

- ascertainment_date:

  One date up to which deaths are ascertained in your SAF release, from
  its release notes. Required when `death_window = "ascertainment"`.

- graft_death_same_day:

  How to treat a graft failure dated on the day the recipient died:

  - `"censor"` (default): as death with a functioning graft. The graft
    is censored at death, not counted as failed.

  - `"event"`: as a graft failure.

  The default is a package assumption, not an SRTR rule: the data
  dictionary does not say whether the graft failure date is filled in
  with the death date when a recipient dies with a functioning graft. A
  real failure and death can also fall on the same day. Run both
  settings to see how much your results depend on it.

## Details

`REC_DEATH_DT_COMPOSITE` keeps every death date from every source. Only
the event and censoring columns (`REC_DEATH_DT_COMPOSITE_BINARY`,
`_CENSOR`, `_days`) depend on `death_window`. Counting deaths found
after last follow-up while censoring survivors at last follow-up would
overstate mortality (#18).

Graft failure (`TFL_GRAFT_DT`, or `TFL_GRAFT_DT_KI` and
`TFL_GRAFT_DT_PA` for `TX_KP`) is death-censored, whatever
`death_window` is: a graft failure dated after the recipient's death
from any source (`REC_DEATH_DT_COMPOSITE`) is not counted, and a graft
without a failure is censored at the earlier of its last follow-up date
and death. Death with a functioning graft is a censoring time, not a
graft failure. A graft failure dated after the last follow-up date but
before death is still counted, at its own date.
