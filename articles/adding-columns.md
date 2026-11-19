# Adding risk scores

sRtr adds published donor and candidate scores to a data frame as new
columns. Each function reads SRTR column names, so it works on a file
loaded with
[`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md).
The examples here use a few made-up rows, so they run on this site.

``` r

library(sRtr)
```

## The scores

| Function | Adds | For | Columns come from |
|----|----|----|----|
| [`add_kdpi()`](https://vagishhemmige.github.io/sRtr/reference/add_kdpi.md) | KDRI and KDPI | Deceased kidney donors | `DONOR_DECEASED`, or `TX_KI` |
| [`add_epts()`](https://vagishhemmige.github.io/sRtr/reference/add_epts.md) | EPTS | Adult kidney candidates or recipients | `CAND_KIPA` (at listing) or `TX_KI` (at transplant) |
| [`add_donor_egfr()`](https://vagishhemmige.github.io/sRtr/reference/add_donor_egfr.md) | Donor eGFR (CKD-EPI) | Donors | `DONOR_DECEASED`, or `DONOR_LIVE` with `creatinine = "DON_KI_CREAT_PREOP"` |
| [`add_lkdpi()`](https://vagishhemmige.github.io/sRtr/reference/add_lkdpi.md) | LKDPI | Living donor kidney transplants | `DONOR_LIVE` joined to `TX_KI` |
| [`add_pdri()`](https://vagishhemmige.github.io/sRtr/reference/add_pdri.md) | PDRI | Pancreas and kidney-pancreas transplants | `TX_PA` or `TX_KP` |
| [`add_pvr()`](https://vagishhemmige.github.io/sRtr/reference/add_pvr.md) | Pulmonary vascular resistance | Heart, lung and heart-lung candidates | `CAND_THOR` (at listing) or `TX_HR`, `TX_LU`, `TX_HL` (at transplant) |

Each function’s help page lists the exact input columns, the codes it
reads and the paper or OPTN guide that defines the score.

## Which mapping table: KDPI and EPTS

KDPI and EPTS are percentiles. The raw score (KDRI or raw EPTS) is
mapped to a percentile with a table that OPTN publishes each year, built
from the donors or candidates of a reference year. The same donor can
get a different KDPI from a different table. sRtr stores the tables in
`optn_mapping_tables`.

A made-up donor, recovered on five dates:

``` r

donor <- data.frame(
  DON_AGE = 52, DON_HGT_CM = 183, DON_WGT_KG = 81,
  DON_HIST_HYPERTEN = 2, DON_HIST_DIAB = 1, DON_CAD_DON_COD = 2,
  DON_CREAT = 1.7, DON_NON_HR_BEAT = "Y", DON_RACE = 2000,
  DON_ANTI_HCV = "N"
)
donors <- donor[rep(1, 5), ]
donors$DON_RECOV_DT <- as.Date(
  c("2010-03-01", "2015-03-01", "2023-03-01", "2025-01-15", "2025-08-01")
)
```

The `table` argument chooses the table:

- `"latest"` (the default) uses the newest stored table for every row.
- `"in_force"` uses, for each row, the table OPTN was using on the
  **donor recovery date** (`DON_RECOV_DT`), not the transplant date.
- A label such as `"2018"` uses that table for every row. The table must
  match the formula: `"2018"` needs `version = "rao2009"`.

``` r

kdpi <- add_kdpi(donors, version = "rao2009", table = "in_force")
#> Warning: No stored rao2009 KDPI table was in force on the recovery date for 3 rows; KDPI
#> set to NA.
#> ℹ Stored rao2009 tables: "2012", "2013", "2014", "2015", "2016", "2017",
#>   "2018", "2019", "2020", "2021", "2022", and "2023". See
#>   `optn_mapping_tables$effective` for the dates.
data.frame(
  recovered = kdpi$DON_RECOV_DT,
  KDPI = kdpi$KDPI,
  table = attr(kdpi$KDPI, "optn_table")
)
#>    recovered KDPI table
#> 1 2010-03-01   NA  <NA>
#> 2 2015-03-01   84  2013
#> 3 2023-03-01   79  2021
#> 4 2025-01-15   NA  <NA>
#> 5 2025-08-01   NA  <NA>
```

The rows with no KDPI are not errors in the donor’s data. In March 2010
no KDPI table was yet in force, and from 2024-10-31 OPTN used the refit
formula (`version = "refit2024"`, the default), whose tables are
separate:

``` r

refit <- add_kdpi(donors, table = "in_force")
#> Warning: No stored refit2024 KDPI table was in force on the recovery date for 4 rows;
#> KDPI set to NA.
#> ℹ Stored refit2024 tables: "2024" and "current". See
#>   `optn_mapping_tables$effective` for the dates.
data.frame(
  recovered = refit$DON_RECOV_DT,
  KDPI = refit$KDPI,
  table = attr(refit$KDPI, "optn_table")
)
#>    recovered KDPI table
#> 1 2010-03-01   NA  <NA>
#> 2 2015-03-01   NA  <NA>
#> 3 2023-03-01   NA  <NA>
#> 4 2025-01-15   79  2024
#> 5 2025-08-01   NA  <NA>
```

The last row has no KDPI either way: OPTN has not archived the table it
used from 2025-05-21. sRtr warns each time a row gets no table.

The start date of each table is in `optn_mapping_tables$effective`, with
its basis. Where OPTN published a date, that date is used. Otherwise the
start is June 1 of the following year, the deadline in OPTN policy,
which is a convention:

``` r

eff <- optn_mapping_tables$effective
eff[eff$score == "kdpi", c("label", "kdri_formula", "effective_from")]
#>          label kdri_formula effective_from
#> 13        2010      rao2009     2011-06-01
#> 14        2011      rao2009     2012-06-01
#> 15        2012      rao2009     2013-06-01
#> 16        2013      rao2009     2014-06-01
#> 17        2014      rao2009     2015-06-01
#> 18        2015      rao2009     2016-06-01
#> 19        2016      rao2009     2017-06-01
#> 20        2017      rao2009     2018-06-01
#> 21        2018      rao2009     2019-06-01
#> 22        2019      rao2009     2020-06-01
#> 23        2020      rao2009     2021-06-01
#> 24        2021      rao2009     2022-06-01
#> 25        2022      rao2009     2023-06-01
#> 26        2023      rao2009     2024-05-29
#> 27        2024    refit2024     2024-10-31
#> 28 2024-donors    refit2024     2025-05-21
#> 29     current    refit2024     2026-06-01
```

A missing KDPI from a table can have three causes:

- **The table is not stored.** OPTN has not archived the 2024-donors
  table, in force from 2025-05-21.
- **The table is stored but incomplete.** The 2010 and 2011 tables lack
  the scaling factor that turns KDRI into a percentile, so they give no
  KDPI.
- **The table lacks what one donor needs.** The 2012 and 2013 tables do
  not print the share of reference donors with hypertension or diabetes,
  so a donor with unknown history (code 998) gets no KDPI from them
  under the default `unknown_history = "optn"`.

sRtr says so each time, in a warning or a message.

[`add_epts()`](https://vagishhemmige.github.io/sRtr/reference/add_epts.md)
works the same way, on the listing date or the transplant date
(`at = "listing"` or `"transplant"`).

## Missing and unknown inputs

A missing or unknown input usually gives a missing score. Each function
documents its exceptions, and a few are options:

| Function | Input | Default | Option |
|----|----|----|----|
| [`add_kdpi()`](https://vagishhemmige.github.io/sRtr/reference/add_kdpi.md) | Unknown hypertension or diabetes history (998) | Weighted by the reference donors’ share, as in the OPTN calculator | `unknown_history = "na"` |
| [`add_kdpi()`](https://vagishhemmige.github.io/sRtr/reference/add_kdpi.md) | Unknown or pending HCV, Rao 2009 only | Counted as negative, as in the OPTN calculator | none |
| [`add_epts()`](https://vagishhemmige.github.io/sRtr/reference/add_epts.md) | Unknown diabetes (998) | Missing EPTS | `unknown_diabetes = "no"`, a convention |
| [`add_epts()`](https://vagishhemmige.github.io/sRtr/reference/add_epts.md) | Missing dialysis start date | 0 years if not on dialysis, else missing | `missing_dialysis_date = "zero"`, a convention |
| [`add_epts()`](https://vagishhemmige.github.io/sRtr/reference/add_epts.md), [`add_donor_egfr()`](https://vagishhemmige.github.io/sRtr/reference/add_donor_egfr.md) | Age under 18 | Missing | `adults_only = FALSE` |
| [`add_pdri()`](https://vagishhemmige.github.io/sRtr/reference/add_pdri.md) | Any missing input, including race | Missing PDRI. A missing BMI is first computed from height and weight. | `mean_impute = TRUE`: continuous inputs take the mean of their dplyr group (of all rows if ungrouped), and missing yes/no terms count as 0, for the calculation only |

Decide these before computing scores, and report the choice. To see how
many rows lose a score, count them:

``` r

unknown <- donor
unknown$DON_HIST_DIAB <- 998
both <- rbind(donor, unknown)
data.frame(
  diabetes = c("no", "unknown"),
  default = as.numeric(add_kdpi(both)$KDPI),
  na = as.numeric(add_kdpi(both, unknown_history = "na")$KDPI)
)
#> KDRI is missing for 1 row with a missing or unusable input.
#>   diabetes default na
#> 1       no      67 67
#> 2  unknown      73 NA
```

## Codes or labels

The functions read raw codes and the factor labels that
[`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)
applies, so a file loaded either way works. A format’s own missing code
(`"."`, labelled `"Missing"`) counts as missing. See [Missing
data](https://vagishhemmige.github.io/sRtr/articles/missing-data.md) for
what the other unknown codes mean.

## What has been checked

| Function | Checked against its source | Run on real SAFs |
|----|----|----|
| [`add_kdpi()`](https://vagishhemmige.github.io/sRtr/reference/add_kdpi.md) | KDRI for the donors in the OPTN KDPI guides (refit and Rao 2009) | Yes: KDPI range on one release’s `DONOR_DECEASED` |
| [`add_epts()`](https://vagishhemmige.github.io/sRtr/reference/add_epts.md) | Raw EPTS and the 2024 table for the candidates in the OPTN EPTS guide | Not yet |
| [`add_donor_egfr()`](https://vagishhemmige.github.io/sRtr/reference/add_donor_egfr.md) | The equations in Inker et al. 2021, Table 2 | Yes: values on one release’s `DONOR_DECEASED` |
| [`add_lkdpi()`](https://vagishhemmige.github.io/sRtr/reference/add_lkdpi.md) | The equation in Massie et al. 2016 | Not yet |
| [`add_pdri()`](https://vagishhemmige.github.io/sRtr/reference/add_pdri.md) | The formula, and rounded examples from the paper ([\#93](https://github.com/VagishHemmige/sRtr/issues/93)); two copies of the paper print different BMI coefficients | Not yet |
| [`add_pvr()`](https://vagishhemmige.github.io/sRtr/reference/add_pvr.md) | The definition | Not yet |

A check against the source shows agreement on the examples checked. A
run on real SAFs shows the function reads the real columns and codes.
Neither shows that a score matches published cohort results: that
agreement has not been established for any of these scores.

The KDPI guide prints 63% for its Rao 2009 example, but the stored 2018
table maps that donor’s KDRI to 83%. sRtr gives 83, and the test records
the difference.
