# Add the Estimated Post-Transplant Survival score

Computes the raw Estimated Post-Transplant Survival (EPTS) value for
adult kidney candidates or recipients from Standard Analysis File (SAF)
columns and maps it to the EPTS score, a percentile from 0 to 100, with
an OPTN mapping table (see
[optn_mapping_tables](https://vagishhemmige.github.io/sRtr/reference/optn_mapping_tables.md)).

## Usage

``` r
add_epts(
  df,
  at = c("listing", "transplant"),
  table = "latest",
  unknown_diabetes = c("na", "no"),
  missing_dialysis_date = c("status", "zero"),
  adults_only = TRUE,
  epts_col = "EPTS",
  raw_col = "EPTS_RAW",
  return_terms = FALSE
)
```

## Arguments

- df:

  A data frame of candidates or recipients, one row each.

- at:

  Score the candidate at `"listing"` (default) or at `"transplant"`.

- table:

  Which mapping table to use: `"latest"` (default), the newest stored
  table; `"in_force"`, for each row the table OPTN was using on the date
  scored; or a table label such as `"2018"`. For `"in_force"`, each
  table's start date is OPTN's published date where one exists
  (2024-05-29 and 2025-05-21); otherwise it is June 1 of the year after
  the snapshot, the deadline in OPTN Policy 8.4.B, which is a
  convention. Rows with no stored table in force get a missing score,
  with a warning. The dates and their basis are in
  `optn_mapping_tables$effective`.

- unknown_diabetes:

  How to treat unknown diabetes status (code 998). `"na"` (default)
  gives a missing score. `"no"` counts it as no diabetes; this is a
  convention some analyses use, not part of the OPTN definition.

- missing_dialysis_date:

  How to treat a missing dialysis start date. `"status"` (default)
  counts it as 0 years when the dialysis status column says the
  candidate was not on dialysis (code 1), and otherwise gives a missing
  score. `"zero"` always counts it as 0 years, a convention.

- adults_only:

  If `TRUE` (default), candidates under 18 get a missing score: OPTN
  assigns EPTS to adults only.

- epts_col, raw_col:

  Names of the output columns for the score and the raw value.

- return_terms:

  If `TRUE`, also add a list-column `EPTS_terms` with each row's inputs.

## Value

`df` with two new columns. The score column carries an `optn_table`
attribute with the table label used for each row.

## Details

EPTS uses four factors: age, current diabetes, any prior solid organ
transplant, and years on dialysis. They are read from these columns
(labelled factors from
[`apply_srtr_factors()`](https://vagishhemmige.github.io/sRtr/reference/apply_srtr_factors.md)
also work):

|  |  |  |
|----|----|----|
| Factor | `at = "listing"` | `at = "transplant"` |
| Date scored | `CAN_LISTING_DT` | `REC_TX_DT` |
| Age | `CAN_AGE_IN_MONTHS_AT_LISTING` / 12 | `REC_AGE_IN_MONTHS_AT_TX` / 12 |
| Dialysis start | `CAN_DIAL_DT` | `REC_DIAL_DT` |
| Dialysis status | `CAN_DIAL` | `REC_DIAL_TY` |

Diabetes comes from `CAN_DIAB_TY` (1 no; 2 to 5 yes; 998 unknown), or
`CAN_DIAB` when that column is absent. A prior solid organ transplant is
any value above 0 (or `Y`) among the organ columns `*_PREV_HL`,
`*_PREV_HR`, `*_PREV_IN`, `*_PREV_KI`, `*_PREV_KP`, `*_PREV_LI`,
`*_PREV_LU` and `*_PREV_PA` that are present: `REC_PREV_*` at transplant
when any are present, otherwise `CAN_PREV_*`. It is none when every
column present is 0 (or `N`), and missing otherwise. `CAN_PREV_TX` is
used only when no organ column is present, because it may count
non-organ transplants. The dictionary gives these columns no format, so
whether they are counts or flags is read the same way.

OPTN measures age in fractional years from the date of birth. SAFs carry
age in whole months, so age here is months / 12, which can differ from
OPTN's by up to one month (a raw EPTS difference of at most 0.004).
Years on dialysis is the days from dialysis start to the date scored,
divided by 365.25, and 0 if dialysis starts later.

## References

OPTN. *A Guide to Calculating and Interpreting the Estimated
Post-Transplant Survival (EPTS) Score Used in the Kidney Allocation
System.* Updated 2026-04-07 (formula and worked examples).

## See also

Guides:

- [Which mapping table: KDPI and
  EPTS](https://vagishhemmige.github.io/sRtr/articles/adding-columns.html#which-mapping-table-kdpi-and-epts)

- [Missing and unknown
  inputs](https://vagishhemmige.github.io/sRtr/articles/adding-columns.html#missing-and-unknown-inputs)

## Examples

``` r
candidates <- data.frame(
  CAN_AGE_IN_MONTHS_AT_LISTING = c(600, 300),
  CAN_LISTING_DT = as.Date(c("2025-01-01", "2025-01-01")),
  CAN_DIAL_DT = as.Date(c("2020-01-01", NA)),
  CAN_DIAL = c(2, 1),
  CAN_DIAB_TY = c(1, 3),
  CAN_PREV_KI = c("N", "Y")
)
add_epts(candidates)
#>   CAN_AGE_IN_MONTHS_AT_LISTING CAN_LISTING_DT CAN_DIAL_DT CAN_DIAL CAN_DIAB_TY
#> 1                          600     2025-01-01  2020-01-01        2           1
#> 2                          300     2025-01-01        <NA>        1           3
#>   CAN_PREV_KI EPTS_RAW EPTS
#> 1           N 1.739512   28
#> 2           Y 1.205000   14
```
