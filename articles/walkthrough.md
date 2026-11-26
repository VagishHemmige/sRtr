# A worked example: from SAFs to survival curves

This article takes one analysis from start to finish: load a transplant
file, choose a cohort and record every exclusion, add death and graft
failure outcomes, check them, draw Kaplan-Meier curves and fit a Cox
model. Each step uses the sRtr function that handles it and links the
guide that explains it in depth.

The data are made up: 80 kidney transplants and their yearly follow-up
forms, written as `.sas7bdat` files in a temporary folder so that every
line runs on this site exactly as it would on your SAFs. The code that
makes them is [at the end](#the-made-up-files). Every number below comes
from those made-up files and says nothing about real transplants.

## Point sRtr at your SAFs

Tell sRtr where your SAF folder is, once per session. Keep that folder
where your data use agreement and security plan say, outside any project
folder tracked by git ([Data protection and
security](https://vagishhemmige.github.io/sRtr/articles/data-protection.md)).

``` r

library(sRtr)
library(dplyr)

set_srtr_wd("path/to/your/SAFs")
```

On this page, sRtr reads the made-up folder instead. Nothing else in the
code changes.

## Load the transplant file

[`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)
reads a file by its name in the data dictionary, here `TX_KI` for kidney
transplants. A real `TX_KI` file has several hundred columns, so name
the ones you need with `col_select`: loading is much faster, and you
write down what the analysis uses.

``` r

tx <- load_srtr_file(
  "TX_KI",
  col_select = c(
    TRR_ID, PERS_ID, REC_TX_DT, REC_AGE_AT_TX, DON_TY, REC_TX_ORG_TY,
    CAN_PREV_TX, REC_POSTX_LOS, REC_DISCHRG_DT, REC_ACUTE_REJ_EPISODE,
    PERS_OPTN_DEATH_DT, PERS_SSA_DEATH_DT, TFL_DEATH_DT, TFL_GRAFT_DT,
    TFL_LAFUDATE, TFL_ENDTXFU, PERS_RETX
  )
)
```

The last eight columns are the ones
[`add_time_to_event_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_time_to_event_outcomes.md)
needs later: transplant admission, death from each source, graft
failure, last follow-up, the end of death ascertainment (`TFL_ENDTXFU`)
and retransplant. Coded columns arrive as factors labelled from the
dictionary, and dates as dates:

``` r

levels(droplevels(tx$REC_TX_ORG_TY))
#> [1] "KI: Kidney"          "KI LI: Kidney-Liver"
class(tx$REC_TX_DT)
#> [1] "Date"
```

[Getting
started](https://vagishhemmige.github.io/sRtr/articles/getting-started.md)
covers loading in more detail, and [Releases, the data dictionary and
warnings](https://vagishhemmige.github.io/sRtr/articles/releases-and-warnings.md)
explains the warnings you may see on your own files.

## Count people and transplants

A transplant file has one row per transplant registration (`TRR_ID`),
not one per person (`PERS_ID`). Someone transplanted twice has two rows.
Say which you are counting.

``` r

tx |>
  summarise(
    registrations = n_distinct(TRR_ID),
    people = n_distinct(PERS_ID)
  )
#> # A tibble: 1 × 2
#>   registrations people
#>           <int>  <int>
#> 1            80     78
```

Two made-up people have a second transplant here. [Files, keys and
joins](https://vagishhemmige.github.io/sRtr/articles/files-and-keys.md)
lists the identifier for each unit and shows how to check a join before
trusting it.

## Choose the cohort, and record every exclusion

This example uses one teaching cohort for both models: each recipient’s
first transplant, of a kidney alone. It is close to, but not the same
as, the cohorts of SRTR’s program-specific reports ([SRTR Technical
Methods](#ref-psr), section C):

- their kidney patient survival analyses need a first *kidney*
  transplant, so an earlier transplant of another organ does not exclude
  anyone. Check that the prior-transplant column counts kidney
  transplants before using it to match them;
- their graft survival analyses keep repeat transplants of the same
  organ.

A real analysis builds the cohort each outcome needs.

In the code below, each step keeps a count, and a criterion whose value
is missing gets its own step, so a reader can tell exclusion from
missing data ([Building
cohorts](https://vagishhemmige.github.io/sRtr/articles/building-cohort-with-flowchart.md)
draws these steps as a flow diagram).

``` r

prev_known <- filter(tx, !is.na(CAN_PREV_TX))
first_tx <- filter(prev_known, CAN_PREV_TX == 0)
organ_known <- filter(first_tx, !is.na(REC_TX_ORG_TY))
cohort <- filter(organ_known, REC_TX_ORG_TY == "KI: Kidney")

tibble(
  step = c(
    "All kidney transplant registrations", "Previous transplants known",
    "First transplant", "Organ type known", "Kidney alone"
  ),
  registrations = c(
    nrow(tx), nrow(prev_known), nrow(first_tx), nrow(organ_known), nrow(cohort)
  ),
  excluded = c(NA, -diff(registrations))
)
#> # A tibble: 5 × 3
#>   step                                registrations excluded
#>   <chr>                                       <int>    <int>
#> 1 All kidney transplant registrations            80       NA
#> 2 Previous transplants known                     80        0
#> 3 First transplant                               78        2
#> 4 Organ type known                               78        0
#> 5 Kidney alone                                   77        1
```

`CAN_PREV_TX` and `REC_TX_ORG_TY` are this example’s way of writing the
criteria. On your release, check what each column records in the data
dictionary
([`srtr_dictionary()`](https://vagishhemmige.github.io/sRtr/reference/srtr_dictionary.md))
before you rely on it: for instance, whether `CAN_PREV_TX` counts
earlier transplants of every organ or of the kidney only.

## Add the outcomes

[`add_time_to_event_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_time_to_event_outcomes.md)
adds, for each registration, an event indicator (`_BINARY`), the date
follow-up ended (`_CENSOR`) and the time from transplant in days
(`_days`) for death, two graft failure outcomes, first malignancy and
first rejection. It reads the matching follow-up file, here `TXF_KI`,
for the cohort’s registrations only.

``` r

out <- add_time_to_event_outcomes(cohort)
```

Its defaults follow the methods of SRTR’s program-specific reports:

- **Death** (`REC_DEATH_DT_COMPOSITE`) comes from any source (OPTN,
  Social Security, transplant follow-up), and follow-up ends at
  `TFL_ENDTXFU`, the last date to which SRTR ascertains deaths. A
  recipient with no death in any source is assumed alive to that date.
- **All-cause graft failure** (`GRAFT_FAIL_ALL_CAUSE_DT`) counts graft
  failure, retransplant or death, whichever comes first, up to the
  graft’s last follow-up date. `_SOURCE` says which ended the graft.
- **Death-censored graft failure** (`TFL_GRAFT_DT`) counts only graft
  failure, and treats death with a working graft as the end of
  follow-up.

These defaults are provisional and are being evaluated
([\#300](https://github.com/VagishHemmige/sRtr/issues/300)). Each has an
argument if your question needs another rule; [Follow-up windows and
death](https://vagishhemmige.github.io/sRtr/articles/follow-up-windows.md)
explains them.

## Check the outcomes before modelling

Look at the outcomes as counts before fitting anything. What ended each
graft?

``` r

out |>
  count(GRAFT_FAIL_ALL_CAUSE_DT_BINARY, GRAFT_FAIL_ALL_CAUSE_DT_SOURCE)
#> # A tibble: 4 × 3
#>   GRAFT_FAIL_ALL_CAUSE_DT_BINARY GRAFT_FAIL_ALL_CAUSE_DT_SOURCE     n
#>                            <int> <chr>                          <int>
#> 1                              0 death                              4
#> 2                              0 NA                                43
#> 3                              1 death                             17
#> 4                              1 graft_failure                     13
```

A row with a date in `GRAFT_FAIL_ALL_CAUSE_DT` and `_BINARY` of 0 had
its first event after the graft’s last follow-up, so it is not counted.
Any missing time drops out of the models below; count them:

``` r

out |>
  summarise(
    death_time_missing = sum(is.na(REC_DEATH_DT_COMPOSITE_days)),
    graft_time_missing = sum(is.na(GRAFT_FAIL_ALL_CAUSE_DT_days))
  )
#> # A tibble: 1 × 2
#>   death_time_missing graft_time_missing
#>                <int>              <int>
#> 1                  0                  0
```

The death window matters. Some made-up deaths are known only from Social
Security records, after the recipient’s last follow-up form. The default
counts them; ending follow-up at the last form instead
(`death_window = "follow_up"`) does not:

``` r

follow_up <- add_time_to_event_outcomes(cohort, death_window = "follow_up")
c(
  deaths_to_TFL_ENDTXFU = sum(out$REC_DEATH_DT_COMPOSITE_BINARY, na.rm = TRUE),
  deaths_to_last_form = sum(follow_up$REC_DEATH_DT_COMPOSITE_BINARY, na.rm = TRUE)
)
#> deaths_to_TFL_ENDTXFU   deaths_to_last_form 
#>                    23                    19
```

The follow-up forms read are summarized in the `txf_report` attribute:

``` r

report <- attr(out, "txf_report")
report[c("follow_up_file", "registrations", "registrations_with_forms", "forms")]
#> $follow_up_file
#> [1] "TXF_KI"
#> 
#> $registrations
#> [1] 77
#> 
#> $registrations_with_forms
#> [1] 64
#> 
#> $forms
#> [1] 311
```

On your own files, every count you share outside your secure environment
must follow your agreement: aggregate counts only, with small counts
masked ([Share counts
only](https://vagishhemmige.github.io/sRtr/articles/checking-your-safs.html#share-counts-only)).

## Kaplan-Meier curves

The survival package fits the models. Convert days to years for the
plot.

``` r

library(survival)

out <- out |>
  mutate(
    death_years = REC_DEATH_DT_COMPOSITE_days / 365.25,
    graft_years = GRAFT_FAIL_ALL_CAUSE_DT_days / 365.25,
    donor = factor(DON_TY, levels = c("C", "L"), labels = c("Deceased", "Living"))
  )

km <- survfit(Surv(death_years, REC_DEATH_DT_COMPOSITE_BINARY) ~ donor, data = out)

plot(
  km,
  lty = c(1, 2),
  xlab = "Years after transplant",
  ylab = "Patient survival",
  main = "Made-up data"
)
legend("bottomleft", legend = c("Deceased donor", "Living donor"), lty = c(1, 2), bty = "n")
```

![Kaplan-Meier curves of patient survival over about nine years after a
made-up kidney transplant, one for deceased-donor and one for
living-donor recipients. Both curves start at 1 and step down as deaths
occur; the living-donor curve stays higher. Made-up
data.](walkthrough_files/figure-html/km-1.png)

Survival at one, three and five years, with the number still at risk:

``` r

summary(km, times = c(1, 3, 5))
#> Call: survfit(formula = Surv(death_years, REC_DEATH_DT_COMPOSITE_BINARY) ~ 
#>     donor, data = out)
#> 
#>                 donor=Deceased 
#>  time n.risk n.event survival std.err lower 95% CI upper 95% CI
#>     1     45       5    0.900  0.0424        0.821        0.987
#>     3     38       7    0.760  0.0604        0.650        0.888
#>     5     29       4    0.675  0.0669        0.556        0.820
#> 
#>                 donor=Living 
#>  time n.risk n.event survival std.err lower 95% CI upper 95% CI
#>     1     27       0    1.000  0.0000        1.000        1.000
#>     3     24       3    0.889  0.0605        0.778        1.000
#>     5     20       1    0.848  0.0699        0.722        0.997
```

## A Cox model

All-cause graft failure by donor type, adjusted for age at transplant,
in the same teaching cohort (first transplants only; SRTR’s graft
survival analyses would also include repeat kidney transplants):

``` r

cox <- coxph(
  Surv(graft_years, GRAFT_FAIL_ALL_CAUSE_DT_BINARY) ~ donor + REC_AGE_AT_TX,
  data = out
)
summary(cox)$conf.int
#>               exp(coef) exp(-coef) lower .95 upper .95
#> donorLiving   0.7214388  1.3861190 0.3290273  1.581857
#> REC_AGE_AT_TX 1.0400259  0.9615146 1.0138421  1.066886
```

With 80 made-up transplants the estimates are imprecise and mean
nothing. On real data, check proportional hazards
([`cox.zph()`](https://rdrr.io/pkg/survival/man/cox.zph.html)) and think
about competing risks before you interpret a graft failure model
([Follow-up windows and
death](https://vagishhemmige.github.io/sRtr/articles/follow-up-windows.md)).

## Describing the methods

A methods section should let a reader rebuild the cohort and the
outcomes. For the analysis above it would say, at least:

- the SAF release and file (`TX_KI`), and the cohort criteria with the
  number excluded at each step;
- the unit of analysis: transplant registrations, not people;
- that deaths came from OPTN, Social Security and transplant follow-up
  records, and that follow-up for death ended at SRTR’s cohort date
  (`TFL_ENDTXFU`), with recipients not reported dead assumed alive;
- that graft failure was all-cause (graft failure, retransplant or
  death), censored at the last follow-up date, as in SRTR’s
  program-specific reports ([SRTR Technical Methods](#ref-psr));
- the sRtr version used (`packageVersion("sRtr")`).

## On your own files

Replace the made-up folder with your own by calling
[`set_srtr_wd()`](https://vagishhemmige.github.io/sRtr/reference/set_srtr_wd.md);
the rest of the code is the same. Then:

- run the checks in [Checking sRtr on your own
  SAFs](https://vagishhemmige.github.io/sRtr/articles/checking-your-safs.md)
  once for your release;
- read the warnings: a column that is missing, or a code the dictionary
  does not list, changes what a step does;
- for kidney-pancreas (`TX_KP`), each graft has its own outcome columns
  (`_KI` and `_PA`).

## The made-up files

The code that wrote the two made-up files used above. Every value is
invented; the column names come from the data dictionary.

``` r

library(dplyr)

safs <- file.path(tempdir(), "made-up-safs")
dir.create(safs, showWarnings = FALSE)
set.seed(2026)
n <- 80
tx_date <- as.Date("2014-01-01") + sample(0:1825, n, replace = TRUE)
end_date <- as.Date("2022-12-31")
older <- sample(c(FALSE, TRUE), n, replace = TRUE)
living <- runif(n) < 0.3

# Death, graft failure and loss to follow-up at made-up rates.
death <- tx_date + round(365.25 * rexp(n, 0.04 * ifelse(older, 2.2, 1) * ifelse(living, 0.6, 1)))
graft <- tx_date + round(365.25 * rexp(n, 0.05))
lost <- tx_date + round(365.25 * rexp(n, 0.04))
last_fu <- pmin(death, lost, end_date)
reported <- death <= last_fu
ssa_only <- death > last_fu & death <= end_date

made_up_tx <- tibble(
  TRR_ID = 900000 + seq_len(n),
  PERS_ID = 800000 + c(seq_len(n - 2), 1, 2),
  REC_TX_DT = tx_date,
  REC_AGE_AT_TX = ifelse(older, sample(60:75, n, TRUE), sample(20:59, n, TRUE)),
  DON_TY = ifelse(living, "L", "C"),
  REC_TX_ORG_TY = c(rep("KI", n - 3), "KI LI", "KI", "KI"),
  CAN_PREV_TX = c(rep(0, n - 2), 1, 1),
  REC_POSTX_LOS = sample(3:10, n, replace = TRUE),
  REC_DISCHRG_DT = tx_date + 7,
  REC_ACUTE_REJ_EPISODE = sample(c(1, 3), n, replace = TRUE, prob = c(0.1, 0.9)),
  PERS_OPTN_DEATH_DT = if_else(reported, death, as.Date(NA_character_)),
  PERS_SSA_DEATH_DT = if_else(ssa_only, death, as.Date(NA_character_)),
  TFL_DEATH_DT = if_else(reported, death, as.Date(NA_character_)),
  TFL_GRAFT_DT = if_else(graft <= last_fu, graft, as.Date(NA_character_)),
  TFL_LAFUDATE = last_fu,
  TFL_ENDTXFU = end_date,
  PERS_RETX = as.Date(NA)
)

# One follow-up form a year until last follow-up.
made_up_forms <- bind_rows(lapply(seq_len(n), function(i) {
  years <- seq_len(floor(as.numeric(last_fu[i] - tx_date[i]) / 365.25))
  if (length(years) == 0) {
    return(NULL)
  }
  tibble(
    TRR_ID = made_up_tx$TRR_ID[i],
    TRR_FOL_ID = made_up_tx$TRR_ID[i] * 100 + years,
    ORG_TY = "KI",
    TFL_PX_STAT_DT = tx_date[i] + round(365.25 * years),
    TFL_FOL_CD = 10 * years,
    TFL_MALIG = sample(c("N", "Y"), length(years), TRUE, c(0.95, 0.05)),
    TFL_ACUTE_REJ_EPISODE = sample(c(3, 1), length(years), TRUE, c(0.93, 0.07))
  )
}))

haven::write_sas(made_up_tx, file.path(safs, "TX_KI.sas7bdat"))
haven::write_sas(made_up_forms, file.path(safs, "TXF_KI.sas7bdat"))

# Point sRtr at the made-up folder for this page only; restored at the end.
old_wd <- Sys.getenv("SRTR_WD", unset = NA)
Sys.setenv(SRTR_WD = safs)
```

## References

Scientific Registry of Transplant Recipients. Technical methods for the
program-specific reports.
<https://srtr.hrsa.gov/transplant-professionals/program-specific-report/technical-methods-for-the-program-specific-reports/>
(accessed 20 November 2026).
