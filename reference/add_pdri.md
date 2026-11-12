# Add Pancreas Donor Risk Index (PDRI)

Computes PDRI and appends it to `df` (default column name: "PDRI"). If
`df` is grouped (dplyr), optional mean-imputation is performed within
groups. Original columns are never modified.

## Usage

``` r
add_pdri(
  df,
  variant = NULL,
  mean_impute = FALSE,
  pdri_col = "PDRI",
  verbose = FALSE,
  return_terms = FALSE
)
```

## Arguments

- df:

  A data frame (may be a dplyr grouped data frame).

- variant:

  NULL (default; auto-detect), or "PA" (pancreas-alone), or "KP"
  (kidney-pancreas).

- mean_impute:

  Logical. If TRUE, mean-impute missing numeric inputs within the
  current group (or overall if ungrouped) for the calculation only. For
  indicator terms, NA is treated as 0 only when `mean_impute = TRUE`;
  otherwise NA propagates to PDRI.

- pdri_col:

  Name of the output column. Default "PDRI".

- verbose:

  If TRUE, print inference and sanity messages.

- return_terms:

  Logical. If TRUE, also attaches a list-column `PDRI_terms` with
  per-row linear predictor contributions (for QA/testing).

## Value

`df` with a new `pdri_col` column; grouping is preserved.

## Details

Required base columns: DON_GENDER, DON_AGE_IN_MONTHS, DON_CREAT,
DON_RACE, DON_HGT_CM, DON_COD_DON_STROKE, REC_PA_PRESERV_TM,
DON_NON_HR_BEAT If `DON_BMI` is missing, it is computed from
`DON_WGT_KG` and `DON_HGT_CM`. PA additionally uses `REC_PREV_KI` for an
interaction term; if absent, the interaction is skipped (equivalent to
KP behavior).

## Examples

``` r
# Two made-up donors
donors <- data.frame(
  DON_GENDER = c("F", "M"),
  DON_AGE_IN_MONTHS = c(300, 540),
  DON_CREAT = c(0.9, 2.8),
  DON_RACE = c(8L, 16L),
  DON_BMI = c(24, 31),
  DON_HGT_CM = c(165, 180),
  DON_COD_DON_STROKE = c(0L, 1L),
  REC_PA_PRESERV_TM = c(10, 14),
  DON_NON_HR_BEAT = c("N", "Y")
)
add_pdri(donors, variant = "KP")
#>   DON_GENDER DON_AGE_IN_MONTHS DON_CREAT DON_RACE DON_BMI DON_HGT_CM
#> 1          F               300       0.9        8      24        165
#> 2          M               540       2.8       16      31        180
#>   DON_COD_DON_STROKE REC_PA_PRESERV_TM DON_NON_HR_BEAT      PDRI
#> 1                  0                10               N 0.8210823
#> 2                  1                14               Y 4.9551202

if (FALSE) { # \dontrun{
# Default: auto-detect PA vs KP
kp |>
  dplyr::group_by(REC_TX_YEAR) |>
  add_pdri(mean_impute = TRUE)

# Force PA
pa |> add_pdri(variant = "PA")

# Inspect term breakdown (QA)
# tmp <- kp |> dplyr::slice(1:3)
# res <- add_pdri(tmp, return_terms = TRUE)
# res$PDRI_terms[[1]]  # additive components for the first row
} # }
```
