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
