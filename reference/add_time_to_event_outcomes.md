# Add appropriate time-to-event outcome variables to a data frame based on the df attributes, if the file was loaded using a load function.

Uses the helper functions to create three columns for an outcome defined
by an event date and a censor date:

- prefix_CENSOR: event date if present, otherwise censor date

- prefix_BINARY: 1 if event date present, else 0

- prefix_unit: numeric time from start_date to prefix_CENSOR in chosen
  units

## Usage

``` r
add_time_to_event_outcomes(
  df,
  death_window = c("follow_up", "ascertainment"),
  ascertainment_date = NULL
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

## Details

`REC_DEATH_DT_COMPOSITE` keeps every death date from every source. Only
the event and censoring columns (`REC_DEATH_DT_COMPOSITE_BINARY`,
`_CENSOR`, `_days`) depend on `death_window`. Counting deaths found
after last follow-up while censoring survivors at last follow-up would
overstate mortality (#18).
