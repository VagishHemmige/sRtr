# Add the Kidney Donor Risk Index and Kidney Donor Profile Index

Computes the donor-only Kidney Donor Risk Index (KDRI) and the Kidney
Donor Profile Index (KDPI) for deceased kidney donors from Standard
Analysis File (SAF) columns, and appends three columns: the unscaled
KDRI (`KDRI_RAO`), the KDRI scaled to the median donor of the reference
year (`KDRI`), and the KDPI, a percentile from 0 to 100.

## Usage

``` r
add_kdpi(
  df,
  version = c("refit2024", "rao2009"),
  table = "latest",
  unknown_history = c("optn", "na"),
  kdri_rao_col = "KDRI_RAO",
  kdri_col = "KDRI",
  kdpi_col = "KDPI",
  return_terms = FALSE
)
```

## Arguments

- df:

  A data frame of deceased donors or transplants, one row each.

- version:

  KDRI formula: `"refit2024"` (default) or `"rao2009"`.

- table:

  Which mapping table to use: `"latest"` (default), the newest stored
  table for `version`; `"in_force"`, for each row the table OPTN was
  using on `DON_RECOV_DT`; or a table label such as `"2018"` (see
  [optn_mapping_tables](https://vagishhemmige.github.io/sRtr/reference/optn_mapping_tables.md)).
  For `"in_force"`, each table's start date is OPTN's published date
  where one exists (2024-05-29, the refit on 2024-10-31, and
  2025-05-21); otherwise it is June 1 of the year after the reference
  year, the deadline OPTN Policy 8.4.B sets, which is a convention. Rao
  2009 tables end on 2024-10-31 and refit tables start then. Rows with
  no stored table in force, such as refit KDPI from 2025-05-21, when
  OPTN used a table it has not archived, get a missing KDPI, with a
  warning. The dates and their basis are in
  `optn_mapping_tables$effective`.

- unknown_history:

  How to treat unknown hypertension or diabetes history (code 998).
  `"optn"` (default) follows the OPTN calculator: the term is weighted
  by the share of reference donors with that history, printed on the
  mapping table. The 2012 and 2013 tables do not print these shares, so
  with them unknown history gives a missing KDRI. `"na"` always gives a
  missing KDRI.

- kdri_rao_col, kdri_col, kdpi_col:

  Names of the output columns.

- return_terms:

  If `TRUE`, also add a list-column `KDRI_terms` with each row's linear
  predictor components.

## Value

`df` with three new columns. The KDPI column carries attributes
`optn_table` (the table label used for each row) and `kdri_formula`.

## Details

Two formulas are available. `"refit2024"` is the formula OPTN has used
since 2024-10-31, refit without donor race or hepatitis C. `"rao2009"`
is the original 10-factor donor-only formula, used by OPTN before then.
The KDPI comes from an OPTN mapping table (see
[optn_mapping_tables](https://vagishhemmige.github.io/sRtr/reference/optn_mapping_tables.md));
only tables built with the chosen formula are used.

Input columns (codes as in the SRTR data dictionary; labelled factors
from
[`apply_srtr_factors()`](https://vagishhemmige.github.io/sRtr/reference/apply_srtr_factors.md)
also work):

- `DON_AGE` (years), `DON_HGT_CM`, `DON_WGT_KG`, `DON_CREAT` (mg/dL);

- `DON_HIST_HYPERTEN`, `DON_HIST_DIAB`: 1 no, 2 to 5 yes, 998 unknown;

- `DON_CAD_DON_COD` (2 = cerebrovascular/stroke; 1, 3, 4, 999 = other;
  998 = unknown), or `DON_COD_DON_STROKE` (1 = yes, 0 = no) when
  `DON_CAD_DON_COD` is absent;

- `DON_NON_HR_BEAT` (Y = donation after circulatory death);

- for `"rao2009"` only: `DON_RACE_BLACK_AFRICAN_AMERICAN` (Y/N), or
  `DON_RACE` (16 = Black or African American; 1024 = unknown) when that
  column is absent; and at least one of `DON_ANTI_HCV`, `DON_HCV_NAT` (P
  = positive) and `DON_HCV_STAT` (1 = positive);

- for `table = "in_force"`: `DON_RECOV_DT`.

As in the OPTN calculator, creatinine above 8 mg/dL counts as 8, and for
`"rao2009"` an unknown, pending or not-done HCV result counts as
negative. Any other missing or unknown input, including an unknown cause
of death or race and a creatinine that is not a positive number, gives a
missing KDRI and KDPI. A multiracial donor (a `DON_RACE` code that is a
sum of single codes) is not counted as Black by the `DON_RACE` fallback.

## References

Rao PS, Schaubel DE, Guidinger MK, et al. A comprehensive risk
quantification score for deceased donor kidneys: the kidney donor risk
index. *Transplantation* 2009;88:231-236.
[doi:10.1097/TP.0b013e3181ac620b](https://doi.org/10.1097/TP.0b013e3181ac620b)

OPTN. *A Guide to Calculating and Interpreting the Kidney Donor Profile
Index (KDPI).* Updated 2020-03-23 (Table 1, Rao 2009 coefficients) and
2026-04-23 (Table 1, refit coefficients).

## Examples

``` r
donors <- data.frame(
  DON_AGE = c(52, 30),
  DON_HGT_CM = c(183, 165),
  DON_WGT_KG = c(81, 70),
  DON_HIST_HYPERTEN = c(2, 1),
  DON_HIST_DIAB = c(1, 1),
  DON_CAD_DON_COD = c(2, 3),
  DON_CREAT = c(1.7, 0.9),
  DON_NON_HR_BEAT = c("Y", "N")
)
add_kdpi(donors)
#>   DON_AGE DON_HGT_CM DON_WGT_KG DON_HIST_HYPERTEN DON_HIST_DIAB DON_CAD_DON_COD
#> 1      52        183         81                 2             1               2
#> 2      30        165         70                 1             1               3
#>   DON_CREAT DON_NON_HR_BEAT  KDRI_RAO      KDRI KDPI
#> 1       1.7               Y 1.7123557 1.1749559   67
#> 2       0.9               N 0.9813462 0.6733639   13
```
