# Add death, graft failure, rejection and malignancy outcomes

**\[experimental\]** Adds an event date, an event indicator, a censoring
date and a time for each post-transplant outcome: patient death,
all-cause and death-censored graft failure, malignancy and acute
rejection. The follow-up forms are read from the matching follow-up file
(`TX_KI` to `TXF_KI`, and so on) with
[`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md),
for the cohort's `TRR_ID`s only. Defaults follow the SRTR
program-specific report methods where SRTR gives a rule; the arguments
switch to other common choices.

## Usage

``` r
add_time_to_event_outcomes(
  df,
  death_window = c("ascertainment", "follow_up"),
  ascertainment_date = "TFL_ENDTXFU",
  graft_death_same_day = c("censor", "event"),
  rejection_after_graft_failure = c("exclude", "keep"),
  retransplant = c("graft_failure", "ignore")
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

  - `"ascertainment"` (default): the SRTR program-specific report method
    for patient survival. Deaths from any source on or before
    `ascertainment_date` count; everyone else is assumed alive and
    censored at that date, even if their last follow-up form is earlier.

  - `"follow_up"`: deaths on or before the recipient's last follow-up
    date count; everyone else is censored at last follow-up.

  sRtr's defaults follow SRTR's published definitions where SRTR gives
  one; other practice is available as an option.

- ascertainment_date:

  Where death ascertainment ends, used when
  `death_window = "ascertainment"`. Either the name of a date column
  with one date per recipient, or one date for everyone (a `Date` or
  text such as `"2023-06-30"`). The default, `"TFL_ENDTXFU"`, is the
  column SRTR describes as the last possible follow-up date for each
  transplant, with a built-in lag of 3 months. A recipient whose date is
  missing gets no death event and a missing time, with a warning.

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

- retransplant:

  Whether a retransplant ends the graft in the all-cause graft failure
  outcome (`GRAFT_FAIL_ALL_CAUSE_DT`):

  - `"graft_failure"` (default): the retransplant date (`PERS_RETX`, or
    `PERS_RETXKI` and `PERS_RETXPA` for `TX_KP`) counts as graft
    failure, as in the SRTR program-specific reports. It never counts
    for lung and heart-lung (`TX_LU`, `TX_HL`), which SRTR also leaves
    it out for.

  - `"ignore"`: retransplant is not used.

  The death-censored graft failure columns (`TFL_GRAFT_DT_*`) do not use
  retransplant either way.

## Value

`df` with these columns added. For each outcome, `_CENSOR` is the event
date if the event counts, else the censoring date; `_BINARY` is `1` for
a counted event, else `0`; `_days` is the time from `REC_TX_DT` to
`_CENSOR` (see
[`srtr_time_to_event()`](https://vagishhemmige.github.io/sRtr/reference/srtr_time_to_event.md)).

- Death: `REC_DEATH_DT_COMPOSITE` with `_source` and `_conflict` (see
  [`srtr_composite_death()`](https://vagishhemmige.github.io/sRtr/reference/srtr_composite_death.md)),
  then `_CENSOR`, `_BINARY`, `_days`.

- All-cause graft failure: `GRAFT_FAIL_ALL_CAUSE_DT`, `_SOURCE`,
  `_CENSOR`, `_BINARY`, `_days`.

- Death-censored graft failure: `TFL_GRAFT_DT_CENSOR`, `_BINARY`,
  `_days`.

- Malignancy: `FIRST_FU_MALIG_DATE`, `FIRST_FU_MALIG_STATUS`,
  `FIRST_FU_MALIG_LAST_NEG_DATE` (see
  [`add_txf_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_txf_outcomes.md)),
  then `FIRST_FU_MALIG_DATE_CENSOR`, `_BINARY`, `_days` and
  `_DEATH_DAY`.

- Rejection: `FIRST_FU_REJ_DATE`, `FIRST_FU_REJ_STATUS`,
  `FIRST_FU_REJ_LAST_NEG_DATE`, `FIRST_REJ_DATE` (the date used) and
  `FIRST_REJ_DATE_SOURCE`, then `FIRST_REJ_DATE_CENSOR`, `_BINARY`,
  `_days` and `_DEATH_DAY`.

For `TX_KP`, graft columns come once per graft with `_KI` and `_PA`
(`GRAFT_FAIL_ALL_CAUSE_DT_KI`, `TFL_GRAFT_DT_PA_CENSOR`,
`FIRST_FU_REJ_DATE_KI`, ...); kidney rejection keeps the name
`FIRST_REJ_DATE`, and pancreas rejection is `FIRST_REJ_DATE_PA`. The
`txf_report` attribute from
[`add_txf_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_txf_outcomes.md)
is kept.

## Details

It accepts all eight transplant files (`TX_KI`, `TX_LI`, `TX_PA`,
`TX_KP`, `TX_HR`, `TX_LU`, `TX_HL` and `TX_IN`), whose columns the SRTR
data dictionary lists. So far only `TX_LI` has been checked on a real
release; check the others on your own files (see the *Checking sRtr on
your own SAFs* guide).

`REC_DEATH_DT_COMPOSITE` keeps every death date from every source. Only
the event and censoring columns (`REC_DEATH_DT_COMPOSITE_BINARY`,
`_CENSOR`, `_days`) depend on `death_window`. Counting deaths found
after last follow-up while censoring survivors at last follow-up would
overstate mortality (#18).

Two graft failure outcomes are added. **All-cause graft failure**
(`GRAFT_FAIL_ALL_CAUSE_DT`, or `GRAFT_FAIL_ALL_CAUSE_DT_KI` and
`GRAFT_FAIL_ALL_CAUSE_DT_PA` for `TX_KP`) follows the SRTR
program-specific reports: the graft fails at the first of its graft
failure date, retransplant (see `retransplant`) and death from any
source (`REC_DEATH_DT_COMPOSITE`). The graft is censored at its last
follow-up date, and an event after that date is not counted. Heart
grafts (`TX_HR`) follow SRTR's heart rule instead: only death and
retransplant count, the graft failure date is not used, and follow-up is
not censored at the last follow-up date but ends where death
ascertainment ends (see `death_window`). The date column holds the first
event even when it is not counted, and `_SOURCE` says which it was
(`"graft_failure"`, `"retransplant"` or `"death"`; on the same day, in
that order).

As in the SRTR reports, a graft is censored on the day of transplant,
with no event, when any of its graft failure, retransplant or death
dates falls before the transplant date (`_SOURCE` is then
`"before_transplant"`, and a later event is not used in its place), or
when its last follow-up date is missing or before the transplant date.
Its time is then the one-day offset that
[`srtr_time_to_event()`](https://vagishhemmige.github.io/sRtr/reference/srtr_time_to_event.md)
adds.

**Death-censored graft failure** (`TFL_GRAFT_DT`, or `TFL_GRAFT_DT_KI`
and `TFL_GRAFT_DT_PA` for `TX_KP`) is not an SRTR report definition, and
does not depend on `death_window`: a graft failure dated after the
recipient's death from any source (`REC_DEATH_DT_COMPOSITE`) is not
counted, and a graft without a failure is censored at the earlier of its
last follow-up date and death. Death with a functioning graft is a
censoring time, not a graft failure. A graft failure dated after the
last follow-up date but before death is still counted, at its own date.

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

## References

Scientific Registry of Transplant Recipients. Technical Methods for the
Program-Specific Reports, section C, patient survival and graft
survival.
<https://srtr.hrsa.gov/transplant-professionals/program-specific-report/technical-methods-for-the-program-specific-reports/>

Kim SJ, Snyder JJ. OPTN/SRTR registry analysis: the devil is in the
details. Slides, American Transplant Congress; 2012. Slide 25
(`TFL_ENDTXFU`).
<https://www.srtr.org/media/1106/atc2012_snyder_kim.pdf>

## See also

Guides:

- [Events count only while someone is
  watching](https://vagishhemmige.github.io/sRtr/articles/follow-up-windows.html#events-count-only-while-someone-is-watching)

- [Whose
  follow-up?](https://vagishhemmige.github.io/sRtr/articles/follow-up-windows.html#whose-follow-up)

- [Graft failure and death on the same
  day](https://vagishhemmige.github.io/sRtr/articles/follow-up-windows.html#graft-failure-and-death-on-the-same-day)

- [Rejection after the graft has
  failed](https://vagishhemmige.github.io/sRtr/articles/follow-up-windows.html#rejection-after-the-graft-has-failed)

## Examples

``` r
if (FALSE) { # \dontrun{
tx <- load_srtr_file("TX_LI")
tx <- add_time_to_event_outcomes(tx)
table(tx$GRAFT_FAIL_ALL_CAUSE_DT_SOURCE, tx$GRAFT_FAIL_ALL_CAUSE_DT_BINARY)

# Censor deaths at the last follow-up form instead
tx <- add_time_to_event_outcomes(load_srtr_file("TX_LI"), death_window = "follow_up")
} # }
```
