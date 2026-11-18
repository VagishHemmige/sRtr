# Follow-up forms are reports, not events

SRTR follow-up files (`TXF_KI`, `TXF_LI`, and so on) hold one row per
follow-up form. It is tempting to read them as a clinical record: find
the first form that says “yes”, take its date, and call that the event.
That reading is wrong in several ways, and each one quietly changes an
analysis. This article walks through them with code you can run on your
own standard analysis files (SAFs). The companion article, [Follow-up
windows and
death](https://vagishhemmige.github.io/sRtr/articles/follow-up-windows.md),
covers what happens around the end of follow-up and death.

The code here is not run on this website, because it needs real SAFs.
You can run it yourself: each section shows a naive version first, then
the sRtr function that handles the problem. When you share what you
find, share counts only, and mask any count under 11, as the SRTR data
use agreement requires. The helpers below do that: `mask()` for a table
of a column, `mask_n()` for counts you have already computed. Every
chunk here prints counts only, never rows; keep it that way when you
adapt the code. Masking each number is not enough on its own: if you
share a total next to masked parts, or two counts that differ by a few,
a reader can subtract to recover a count under 11. Summaries such as
quartiles can also describe a handful of people; look at them yourself,
and share them only when the group behind them is large.

``` r

library(sRtr)
library(dplyr)

set_srtr_wd("path/to/your/SAFs")

tx <- load_srtr_file("TX_LI")
txf <- load_srtr_file(
  "TXF_LI",
  col_select = c(
    "TRR_ID", "ORG_TY", "TFL_PX_STAT_DT", "TFL_FOL_CD",
    "TFL_MALIG", "TFL_ACUTE_REJ_EPISODE"
  )
)

# Counts safe to share: any count from 1 to 10 shows as "<11".
mask_n <- function(n) {
  noquote(ifelse(n > 0 & n < 11, "<11", format(n, big.mark = ",")))
}
# The same for a frequency table of a column.
mask <- function(x) mask_n(table(x, useNA = "ifany"))
```

The examples use liver files and malignancy and acute rejection, the two
outcomes
[`add_txf_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_txf_outcomes.md)
derives. The same issues apply to the other organs.

## A form date is not an onset date

Each follow-up form covers a period, often a year, and its date
(`TFL_PX_STAT_DT`, the patient status date) is when the status was
recorded. A form that first says “yes, malignancy” after one that said
“no” tells you the *recorded* status changed between those two dates.

That interval bounds when the malignancy began only if the forms are
complete and timely: if each form records what was known at the time,
and a malignancy is recorded on the first form after it is found. A
malignancy recognized late, or present but not recorded on an earlier
form, can have begun before the interval. Read the interval as bounding
the change in recorded status, and treat it as bounding onset only as an
assumption you state. The figure below shows three made-up recipients.

![Timeline of follow-up forms for three made-up recipients, in years
since transplant. Recipient A has forms saying no at years 1 and 2 and
yes at year 3; the recorded status changed somewhere in the shaded
interval between years 2 and 3. Recipient B has a form saying no at year
1, an unknown answer at year 2 and yes at year 3; the recorded status
changed somewhere between years 1 and 3. Recipient C has forms saying
unknown at years 1 and 2, so nothing is known about malignancy. The
interval bounds onset only if the forms are complete and
timely.](follow-up-forms_files/figure-html/timeline-1.png)

**The naive approach** takes the first “yes”:

``` r

naive <- txf |>
  filter(TFL_MALIG == "Y") |>
  summarise(malig_date = min(TFL_PX_STAT_DT), .by = TRR_ID)
```

This gives the date of the first *report*, which comes after the change
in status, by up to the gap between forms. It also has a technical trap:
[`min()`](https://rdrr.io/r/base/Extremes.html) returns `NA` for a
recipient whose positive forms include an undated one, and with
`na.rm = TRUE` it returns `Inf`, with a warning, when all of them are
undated.

**With sRtr**,
[`add_txf_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_txf_outcomes.md)
gives the first report date and the other end of the interval: the last
form that explicitly said “no” before it.

``` r

tx <- add_txf_outcomes(tx)

gap <- as.numeric(tx$FIRST_FU_MALIG_DATE - tx$FIRST_FU_MALIG_LAST_NEG_DATE)
mask_n(sum(!is.na(gap)))

# For your own inspection; share only if the count above is large.
gap_quartiles <- quantile(gap, c(0.25, 0.5, 0.75), na.rm = TRUE)
```

On real files the median gap is close to a year, because forms are
mostly annual. An analysis that treats the report date as the event date
is right-censored data with a built-in delay; the two dates together
support interval-censored or discrete-time models instead, under the
assumption above.

## A missing date does not mean “no event”

**The naive approach** joins the first dates back to the cohort and
calls everyone without one event-free:

``` r

naive_cohort <- tx |>
  left_join(naive, by = "TRR_ID") |>
  mutate(malignancy = !is.na(malig_date))
```

That merges four quite different groups into “no malignancy”:

- recipients whose forms said “no”;
- recipients whose forms said only “unknown” or were left blank;
- recipients with no follow-up form at all;
- recipients with a “yes” form that has no date.

**With sRtr**, the status column keeps them apart:

``` r

mask(tx$FIRST_FU_MALIG_STATUS)
```

`"event"` means at least one form reports a malignancy, dated or not;
`"no event"` means none does and at least one says “no”; `"unknown"`
means there are forms but none says “yes” or “no”; `"no follow-up"`
means there is no form. On real liver files, “unknown” and “no
follow-up” are each large groups, not rounding errors. Whether to
exclude them, treat them as censored at transplant, or model them is an
analysis decision, and it should be made on purpose.

## “Rejection” has more than one meaning

The rejection question (`TFL_ACUTE_REJ_EPISODE`, format `ACREJEPF`) has
four answers: 1, at least one episode treated with an anti-rejection
agent; 2, rejection, none treated; 3, no; 998, unknown.

**The naive approach** matches the label text:

``` r

naive_rej <- txf |>
  filter(
    TFL_ACUTE_REJ_EPISODE ==
      "1: Yes, at least one episode treated with anti-rejection agent"
  )
mask_n(nrow(naive_rej))
```

This finds nothing if the file was loaded with raw codes
(`factor_labels = FALSE`), and nothing if SRTR rewords the label in a
later release. And it treats an untreated rejection (code 2) the same as
“no”.

**With sRtr**, rejection is matched by code, so raw and labelled files
give the same answer, and an untreated rejection gets its own status:

``` r

mask(tx$FIRST_FU_REJ_STATUS)
```

The derived endpoint is *treated* acute rejection. An untreated
rejection is evidence that rejection happened, so it is never used as a
negative form when bounding the interval in
`FIRST_FU_REJ_LAST_NEG_DATE`.

## Rejection during the transplant admission is not on the follow-up forms

Rejection before discharge is recorded on the transplant record
(`REC_ACUTE_REJ_EPISODE` in `TX_LI`), not on a follow-up form, and it
has no date of its own.

**The naive approach** uses only the follow-up file, and so misses early
rejection, or counts it late, at the first follow-up form.

**With sRtr**,
[`add_time_to_event_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_time_to_event_outcomes.md)
(see the note in [Follow-up windows and
death](https://vagishhemmige.github.io/sRtr/articles/follow-up-windows.md))
uses the admission rejection first. It dates it at discharge, a proxy:
the transplant date plus the length of stay (`REC_POSTX_LOS`), else the
discharge date (`REC_DISCHRG_DT`). `FIRST_REJ_DATE_SOURCE` records which
rule applied:

``` r

out <- sRtr:::add_time_to_event_outcomes(tx)
mask(out$FIRST_REJ_DATE_SOURCE)
```

When neither date is usable, the rejection still counts: its status is 1
and its time is missing, so it drops out of a survival model rather than
adding rejection-free time. The same rule covers a rejection or
malignancy reported only on undated follow-up forms. Each case gives a
warning with the count.

## Forms can be dated before the transplant

A follow-up form describes the period after transplant, so a form dated
before it is a data error. Check how many you have:

``` r

tx_date <- tx$REC_TX_DT[match(txf$TRR_ID, tx$TRR_ID)]
mask_n(sum(txf$TFL_PX_STAT_DT < tx_date, na.rm = TRUE))
```

In liver files they are rare, but a single one can matter: with the
naive approach, a pre-transplant “yes” becomes an event at time zero, or
a negative time. sRtr times events from the first report on or after the
transplant date; the date columns from
[`add_txf_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_txf_outcomes.md)
keep the first report of all, so you can find these cases.

## Count registrations, and say so

Each row of a transplant file is a transplant registration (`TRR_ID`),
not a person. A person transplanted twice has two rows, and two sets of
follow-up forms.

``` r

mask_n(c(registrations = n_distinct(tx$TRR_ID), people = n_distinct(tx$PERS_ID)))
```

[`add_txf_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_txf_outcomes.md)
attaches a report of the merge, in registrations, ready for a methods
section: how many registrations have any follow-up form, how many forms
were read and how many were undated, and for each outcome the positive
forms, the registrations with a report, and the registrations whose
report is dated.

``` r

report <- attr(tx, "txf_report")
mask_n(unlist(report[setdiff(names(report), c("follow_up_file", "outcomes"))]))
report$outcomes |>
  mutate(across(where(is.numeric), mask_n))
```

The report describes the cohort at the time of the merge; filter first,
then call
[`add_txf_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_txf_outcomes.md),
if you want it to describe your analysis cohort.

## Checklist

- Treat follow-up dates as report dates. The last negative form and the
  first report bound a change in recorded status; say so if you treat
  them as bounding onset.
- Read the status column before treating a missing date as no event.
- Decide what “unknown” and “no follow-up” mean for your question.
- Match codes, not label text, and decide whether untreated rejection
  counts.
- Include rejection during the transplant admission.
- Look for forms dated before the transplant.
- Report counts in registrations, and mask counts under 11 when you
  share them.
