# Add time-to-event follow-up outcomes to a transplant cohort

Uses the cohort's `file_key` attribute (as set by
[`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md))
to load the matching follow-up file (`TX_KI` to `TXF_KI`, and so on),
limited to the cohort's `TRR_ID`s and to the columns used here, and adds
what the follow-up forms say about malignancy and acute rejection.

## Usage

``` r
add_txf_outcomes(df)
```

## Arguments

- df:

  A transplant data frame from
  [`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md),
  with a `TRR_ID` column and a `file_key` attribute.

## Value

`df` with these columns added. For `TX_KP`, each rejection column comes
once per graft, with the suffix `_KI` or `_PA` (`FIRST_FU_REJ_DATE_KI`,
`FIRST_FU_REJ_STATUS_PA`, ...); malignancy is patient-level and uses the
forms for both grafts.

- `FIRST_FU_MALIG_DATE`:

  Date of the first form reporting a malignancy (`TFL_MALIG` `"Y"`).

- `FIRST_FU_MALIG_STATUS`:

  What the forms say: `"event"` (at least one form reports a
  malignancy), `"no event"` (none does, and at least one says `"N"`),
  `"unknown"` (forms exist, but none says `"Y"` or `"N"`), or
  `"no follow-up"` (no form).

- `FIRST_FU_MALIG_LAST_NEG_DATE`:

  Date of the last form saying `"N"`, strictly before
  `FIRST_FU_MALIG_DATE`; with no report, the last such form at all.

- `FIRST_FU_REJ_DATE`:

  Date of the first form reporting a treated acute rejection
  (`TFL_ACUTE_REJ_EPISODE` code 1 of format `ACREJEPF`, raw or
  labelled).

- `FIRST_FU_REJ_STATUS`:

  `"event"` (a treated rejection), `"untreated"` (no treated rejection,
  but at least one untreated, code 2), `"no event"` (at least one form
  says no rejection, code 3), `"unknown"` (only code 998 or no answer),
  or `"no follow-up"`.

- `FIRST_FU_REJ_LAST_NEG_DATE`:

  Date of the last form saying no rejection (code 3), strictly before
  `FIRST_FU_REJ_DATE`; with no report, the last such form at all. An
  untreated rejection is evidence of rejection, so it is not a negative
  form.

## Details

**The dates are report dates.** A follow-up form covers a period, and
its date (`TFL_PX_STAT_DT`, the patient status date) is when the status
was recorded, not when the malignancy or rejection began. The event
happened at some time after the last negative form and on or before the
first report, so `..._LAST_NEG_DATE` and the report date bound it for
interval-censored or discrete-time models. Whether that interval bounds
clinical onset depends on what each form asked.

**Evidence and timing are kept apart.** A status of `"event"` with a
missing date means a form reports the event but no positive form is
dated; `..._LAST_NEG_DATE` is then missing too, since the bound is
unknown. A missing date alone does not mean no event: read the status
column.

Forms for every period count here, whenever they are dated.
[`add_time_to_event_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_time_to_event_outcomes.md)
counts a report as an event only inside the follow-up window.

Combined organ codes in `TXF_KP` (`ORG_TY` other than `KI` or `PA`)
cannot be assigned to one graft, and give a warning.

## See also

[`add_time_to_event_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_time_to_event_outcomes.md),
[`srtr_time_to_event()`](https://vagishhemmige.github.io/sRtr/reference/srtr_time_to_event.md),
[`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)

## Examples

``` r
if (FALSE) { # \dontrun{
tx <- load_srtr_file("TX_KI")
tx <- add_txf_outcomes(tx)
table(tx$FIRST_FU_REJ_STATUS)
} # }
```
