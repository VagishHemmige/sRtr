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
  graft_death_same_day = c("censor", "event"),
  rejection_after_graft_failure = c("exclude", "keep")
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

- rejection_after_graft_failure:

  Whether a rejection reported after the graft failed counts:

  - `"exclude"` (default): a graft is at risk of rejection only until it
    fails. Forms filed in the years after graft failure are not used,
    and the rejection window ends at the graft failure date
    (`TFL_GRAFT_DT`, or that graft's own date, `TFL_GRAFT_DT_KI` or
    `TFL_GRAFT_DT_PA`, for `TX_KP`); grafts without a rejection are
    censored there. These columns are then required.

  - `"keep"`: every form counts, as before.

  The follow-up code `TFL_FOL_CD` uses format `FOLCD` of the SRTR data
  dictionary (SAF releases 2203 and 2609): code 800 is the form filed at
  graft failure and codes 801 to 850 are "N year after graft failure".
  Under `"exclude"`, sRtr leaves out codes 801 to 850. These are package
  conventions, not SRTR rules: the form filed at failure (code 800) is
  kept, since it may report the rejection that led to the failure; a
  rejection reported on the day of failure counts; and a rejection
  during the transplant admission counts if it falls inside the ordinary
  window, even when the graft failed in the same admission (its date is
  only a discharge-date proxy). Censoring still ends at the failure
  date.

  Malignancy is patient-level and always uses every form. The columns
  from
  [`add_txf_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_txf_outcomes.md)
  (`FIRST_FU_REJ_DATE`, `FIRST_FU_REJ_STATUS`) describe every form
  either way.

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

First rejection (`FIRST_REJ_DATE`, and `FIRST_REJ_DATE_PA` for `TX_KP`)
counts a treated rejection (code 1 of format `ACREJEP`, raw or labelled)
during the transplant admission (`REC_ACUTE_REJ_EPISODE`, or
`REC_ACUTE_REJ_EPISODE_PA`) first, else the first follow-up form
reporting one. An admission rejection is dated at discharge, a proxy:
the transplant date plus `REC_POSTX_LOS`, else `REC_DISCHRG_DT`; a date
before the transplant is not used. `FIRST_REJ_DATE_SOURCE`
(`"admission_los"`, `"admission_discharge"`, `"admission_undated"` or
`"follow_up"`) says which rule applied (`"follow_up_undated"` is
described below). Here a missing date does not always mean no event: an
admission rejection with no usable date keeps `_BINARY = 1` with a
missing censoring date and time, with a warning, so it drops out of
time-to-event models instead of counting as rejection-free. A later
follow-up rejection stays in `FIRST_FU_REJ_DATE` (`FIRST_FU_REJ_DATE_KI`
and `FIRST_FU_REJ_DATE_PA` for `TX_KP`, with `FIRST_REJ_DATE_PA_SOURCE`
for the pancreas) and is never used in its place. A date is unusable
when it falls before the transplant; with no transplant date, the
discharge date is kept, and the elapsed time is missing.

Malignancy (`FIRST_FU_MALIG_DATE`) and rejection count only inside the
window the recipient or graft is followed for: from the transplant date
up to the earlier of the last follow-up date and death from any source
(`REC_DEATH_DT_COMPOSITE`), both inclusive, whatever `death_window` is.
Malignancy uses the patient's last follow-up (for `TX_KP`, the later of
the two graft dates); rejection uses the graft's own (`TFL_LAFUDATEKI`
or `TFL_LAFUDATEPA` for `TX_KP`). Without an event, the recipient is
censored at the end of the window. A report dated after it is not an
event, but its date stays in the date column, so
`!is.na(FIRST_FU_MALIG_DATE) & FIRST_FU_MALIG_DATE_BINARY == 0` finds
the reports left out. A report dated before the transplant is not used:
events are timed from the first report on or after the transplant date,
while `FIRST_FU_MALIG_DATE` and `FIRST_FU_REJ_DATE` keep the first
report of all, for auditing (`FIRST_REJ_DATE` is the date used). With no
last follow-up date the window's end is unknown: death is not used in
its place, and the time is missing.

A malignancy or rejection reported only on follow-up forms with no date
(status `"event"` with a missing date in
[`add_txf_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_txf_outcomes.md))
is treated like an undated admission rejection: `_BINARY = 1` with a
missing censoring date and time, with a warning, so it does not add
event-free time. For rejection, `FIRST_REJ_DATE_SOURCE` is then
`"follow_up_undated"`.

Follow-up dates are report dates (see
[`add_txf_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_txf_outcomes.md)).
A report dated on the day of death may come from the form filed at
death, so the event may have happened earlier.
`FIRST_FU_MALIG_DATE_DEATH_DAY` and `FIRST_REJ_DATE_DEATH_DAY` (and
`FIRST_REJ_DATE_PA_DEATH_DAY`) are `TRUE` when the date is the day of
death, `FALSE` when it is another day, and `NA` with no date, so you can
run a sensitivity analysis without those events. Such reports count as
events by default when follow-up covers the day of death. The status
columns from
[`add_txf_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_txf_outcomes.md)
say what the forms report, before the window is applied.
