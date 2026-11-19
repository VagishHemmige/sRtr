# Checking sRtr on your own SAFs

sRtr’s automatic tests run on made-up data, because SRTR files cannot be
shared. Real files differ from release to release: columns come and go,
codes appear that no format lists, and identifiers that should match
sometimes do not. Before you rely on sRtr for an analysis, run the
checks below on your own standard analysis files (SAFs). Checks 1 to 4
take a few minutes in your usual R session. Check 5, the package’s own
live tests, needs a copy of the source code and is worth running once
per release. Together they tell you whether sRtr behaves on your release
as it does on the releases it has been checked against. The checks cover
the three kinds of data quality in a common framework: whether values
conform to the documented formats, whether they are complete, and
whether they are plausible ([Kahn et al. 2016](#ref-kahn)).

The code is not run on this website, because it needs real SAFs. It uses
liver files; change the file keys for other organs.

## Share counts only

The SRTR data use agreement does not allow sharing patient-level data.
Everything below prints counts, never rows. Keep it that way if you
change the code, so you can share the results, for example in a GitHub
issue. The other sRtr articles that run on real files follow the same
rules and link here.

- **Mask any count from 1 to 10.** The helpers in the setup chunk print
  such a count as `<11`: `mask_n()` for counts you have computed,
  `mask()` for a frequency table of a column of categories, such as a
  status. Never use `mask()` on an identifier or a date: the table’s
  labels are the values themselves, so masking the counts hides nothing.
- **Do not share a total beside masked parts.** If a table of a column
  shows every cell but one, together with the total, a reader recovers
  the masked cell by subtraction. Share the table or the total, not
  both, or check that no single masked cell can be worked out.
- **Do not share two counts that differ by a little.** “1,204
  registrations and 1,198 people” reveals 6. Print the difference
  instead, masked, or as a check that should be 0.
- **Summaries can describe a few people.** A median or quartile of a
  small group is close to individual values. Look at such summaries
  yourself, and share them only when the group behind them is large.
- **Keep raw output on your computer.** Test failures and warning
  messages can include exact counts and values from your files. Rewrite
  what they say in your own words, as in the example at the end of this
  article.

The first three rules follow the CMS cell size suppression policy: no
count from 1 to 10, and none that can be worked out from other reported
numbers ([CMS 2020](#ref-cms)). The last two are sRtr’s own practice.

``` r

library(sRtr)
library(dplyr)

wd <- "path/to/your/SAFs"
set_srtr_wd(wd, release = "2303") # your release, named by year and month

mask_n <- function(n) {
  noquote(ifelse(n > 0 & n < 11, "<11", format(n, big.mark = ",")))
}
# For a column of categories only, never identifiers or dates.
mask <- function(x) mask_n(table(x, useNA = "ifany"))
```

## 1. Load with the warnings counted, not hidden

Loading a real file can give several warnings. Every sRtr warning has a
class, so you can collect each kind instead of hiding them all with
[`suppressWarnings()`](https://rdrr.io/r/base/warning.html):

``` r

seen <- list()
collect <- function(expr) {
  withCallingHandlers(
    expr,
    sRtr_warning = function(w) {
      kind <- class(w)[1]
      seen[[kind]] <<- c(seen[[kind]], conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )
}

tx <- collect(load_srtr_file("TX_LI"))
txf <- collect(load_srtr_file("TXF_LI"))

mask_n(lengths(seen))
```

The kinds you are most likely to see:

- `sRtr_warning_missing_columns` or `sRtr_warning_extra_columns`: the
  file does not have the columns the dictionary lists for this release.
  A long list usually means the release is wrong (check
  `set_srtr_wd(release =)`); a short one may be a real difference worth
  reporting.
- `sRtr_warning_unknown_codes`: values no format lists. sRtr keeps them
  as their own level, named `<code>: not in format`, and says which
  variable they are in. Some are known gaps in SRTR’s dictionary; a new
  one is worth reporting.
- `sRtr_warning_dictionary_gap`: your release falls between the
  dictionary versions sRtr stores, and an entry differs between them.

To silence one kind in later code while keeping the others visible,
muffle only that class, such as `sRtr_warning_unknown_codes`.

Read the messages in `seen` yourself, but do not share them as they are:
some include exact row counts and the codes found.

## 2. Check the keys

Joins between SAF files rely on identifiers. These should hold, and
anything else is worth knowing before you join:

``` r

mask_n(c(
  registrations = n_distinct(tx$TRR_ID, na.rm = TRUE),
  rows_beyond_one_per_registration =
    sum(!is.na(tx$TRR_ID)) - n_distinct(tx$TRR_ID, na.rm = TRUE),
  missing_trr_id = sum(is.na(tx$TRR_ID)),
  follow_up_registrations_not_in_tx =
    n_distinct(txf$TRR_ID[!is.na(txf$TRR_ID) & !txf$TRR_ID %in% tx$TRR_ID])
))

# Each registration belongs to one person. Check that first; only then is
# "registrations minus people" a count of repeat registrations.
ids <- tx |>
  filter(!is.na(TRR_ID), !is.na(PERS_ID)) |>
  distinct(TRR_ID, PERS_ID)
one_person_per_registration <- !anyDuplicated(ids$TRR_ID)
one_person_per_registration
if (one_person_per_registration) {
  mask_n(c(repeat_registrations = nrow(ids) - n_distinct(ids$PERS_ID)))
}
```

- `rows_beyond_one_per_registration` should be 0: each row of a
  transplant file is one registration.
- `missing_trr_id` should be 0.
- `one_person_per_registration` should be `TRUE`. If it is not, that is
  worth reporting, and the next count is skipped.
- `repeat_registrations` counts registrations after a person’s first
  one: people transplanted more than once have several registrations. It
  is not the number of people with a repeat transplant, nor all their
  registrations.
- `follow_up_registrations_not_in_tx` should be 0: every follow-up form
  belongs to a registration in the transplant file.

Each difference is printed on its own, masked, rather than as two totals
(see [Share counts only](#share-counts-only)).

For donors, a deceased donor file covers only deceased donors, so some
transplant `DONOR_ID`s will not be in it:

``` r

donors <- collect(load_srtr_file("DONOR_DECEASED", col_select = "DONOR_ID"))
mask_n(c(
  donors_not_in_deceased_donors = n_distinct(
    tx$DONOR_ID[!is.na(tx$DONOR_ID) & !tx$DONOR_ID %in% donors$DONOR_ID]
  )
))
```

This counts distinct donors. One donor can give organs to several
recipients, so it can be smaller than the number of transplants
concerned.

## 3. Check labels

``` r

unlabelled <- vapply(tx, \(x) is.null(attr(x, "label")), logical(1))
mask_n(c(columns = ncol(tx), without_a_label = sum(unlabelled)))
```

Almost every column should have a label, either the one stored in the
SAS file or one from the dictionary.

## 4. Check that derived outcomes add up

Derived variables should be consistent with each other. These checks use
the follow-up outcomes; the reasons behind them are in [Follow-up forms
are reports, not
events](https://vagishhemmige.github.io/sRtr/articles/follow-up-forms.md)
and [Follow-up windows and
death](https://vagishhemmige.github.io/sRtr/articles/follow-up-windows.md).

``` r

tx <- add_txf_outcomes(tx)

# The status columns cover every registration once. Look at these tables
# yourself; shared beside the registration total, a table with a single
# masked cell gives that cell away.
mask(tx$FIRST_FU_MALIG_STATUS)
mask(tx$FIRST_FU_REJ_STATUS)

# The last negative form always comes before the first report.
gap <- tx$FIRST_FU_MALIG_DATE - tx$FIRST_FU_MALIG_LAST_NEG_DATE
mask_n(c(gaps = sum(!is.na(gap)), not_positive = sum(gap <= 0, na.rm = TRUE)))
```

`not_positive` should be 0. The merge report attached by
[`add_txf_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_txf_outcomes.md)
should agree with the status columns: registrations with forms plus
those with no follow-up make up all registrations. The report counts
distinct registrations, so count those on the other side too, and print
only whether they agree:

``` r

report <- attr(tx, "txf_report")
no_follow_up <- n_distinct(
  tx$TRR_ID[!is.na(tx$TRR_ID) & tx$FIRST_FU_MALIG_STATUS == "no follow-up"]
)
report$registrations == report$registrations_with_forms + no_follow_up
```

This should be `TRUE`.

The time-to-event outcomes come from
[`add_time_to_event_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_time_to_event_outcomes.md),
which is not yet exported, so it is called with `sRtr:::`:

``` r

out <- collect(sRtr:::add_time_to_event_outcomes(tx))

# The date a counted event is timed at is the _CENSOR column, not
# FIRST_FU_MALIG_DATE, which keeps the first report of all for auditing.
counted <- out$FIRST_FU_MALIG_DATE_BINARY %in% 1L
event <- out$FIRST_FU_MALIG_DATE_CENSOR
lafu <- out$TFL_LAFUDATE
death <- out$REC_DEATH_DT_COMPOSITE
# The window ends at last follow-up, or at death if that is earlier. With
# no last follow-up date, the end is unknown: death is not used instead.
end <- if_else(!is.na(death) & death < lafu, death, lafu)
dated <- counted & !is.na(event)

mask_n(c(
  before_transplant = sum(dated & event < out$REC_TX_DT, na.rm = TRUE),
  after_window_end = sum(dated & event > end, na.rm = TRUE),
  with_no_last_follow_up = sum(dated & is.na(lafu)),
  counted_but_undated = sum(counted & is.na(event))
))
```

The first three should be 0. `counted_but_undated` is the events
reported only on undated forms: they count, with an unknown time.

## 5. Run the package’s live tests

sRtr’s test suite includes live tests that run only on real files. They
check, among other things, that columns load with the right types, that
codes match the dictionary, and that derived outcomes are consistent.
The tests are not installed with the package, so you need a copy of the
source that matches the version you have installed:

``` r

# The commit your installed copy was built from, if installed from GitHub:
packageDescription("sRtr")$RemoteSha
```

Clone the repository and check out that commit. In a terminal:

    git clone https://github.com/VagishHemmige/sRtr
    git -C sRtr checkout <commit>

Then start a fresh R session, so the tests run against the version you
checked out, run the setup chunk at the top of this article again (it
sets `wd` and the masking helpers), and run the tests:

``` r

Sys.setenv(
  SRTR_LIVE_TESTS = "true",
  SRTR_WD = wd,
  SRTR_RELEASE = "2303"
)
testthat::test_local(
  "path/to/the/sRtr/clone",
  reporter = "summary",
  stop_on_failure = FALSE
)
```

Each live test names the files it needs and skips when your folder does
not have them, so you can run the whole suite with whatever files you
have. To run one area, add `filter`, such as
`filter = "add_txf_outcomes"`. A failure means sRtr does something on
your release that it has not been checked for. Please report it (see
below). The test output itself stays on your computer: a failure message
can print values from your files.

## 6. Report what you find

If a live test fails, a check above gives an unexpected answer, or a
warning lists something new, please open an issue at
<https://github.com/VagishHemmige/sRtr/issues>. Write it from the pieces
below, not by pasting output: test output and warning messages can
include exact counts and values from your files.

- the SAF release, and which files you used;
- `packageDescription("sRtr")$RemoteSha` and your R version;
- the name of the failing test, or the warning’s class (such as
  `sRtr_warning_unknown_codes`);
- the file key and column name;
- a masked count from `mask_n()`, if a count helps.

For example: “Release 2303, `TX_LI`. `sRtr_warning_unknown_codes` for
`REC_COD`: \<11 rows with codes not in the format.” Never attach SAF
files, rows from them, or unmasked counts.

## References

Centers for Medicare & Medicaid Services. CMS cell size suppression
policy. 2020.
<https://www.hhs.gov/guidance/document/cms-cell-suppression-policy>

Kahn MG, Callahan TJ, Barnard J, et al. A harmonized data quality
assessment terminology and framework for the secondary use of electronic
health record data. *EGEMS (Wash DC)*. 2016;4(1):1244.
[doi:10.13063/2327-9214.1244](https://doi.org/10.13063/2327-9214.1244)
