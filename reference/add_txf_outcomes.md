# Add time-to-event (TTE) follow-up outcomes to a transplant cohort

Uses the cohort's `file_key` attribute (as set by your SRTR load
helpers) to locate and load the corresponding follow-up table, then
derives:

## Usage

``` r
add_txf_outcomes(df)
```

## Arguments

- df:

  A data frame representing a transplant cohort (one row per recipient
  or transplant). Must include a `TRR_ID` column and have an attribute
  `file_key` (a string) indicating the originating SRTR table key (e.g.,
  `"KI_txf"`). The companion follow-up key is inferred as the same
  prefix with `"F"` inserted after the first two characters (e.g.,
  `"KI_Ftxf"`).

## Value

The input `df` with additional columns:

- FIRST_FU_MALIG_DATE:

  Date of first follow-up malignancy (per TRR).

- FIRST_FU_REJ_DATE_ORG:

  Date of first acute rejection per organ (wide columns by organ code).

Existing columns/attributes of `df` are preserved.

## Details

- `FIRST_FU_MALIG_DATE` — first follow-up malignancy date per `TRR_ID`

- `FIRST_FU_REJ_DATE_{ORG}` — first acute rejection date per organ code
  (e.g., `FIRST_FU_REJ_DATE_KI`, `FIRST_FU_REJ_DATE_PA`)

The function limits the follow-up load to the cohort's `TRR_ID`s for
efficiency, and merges the derived dates back into `df`.

This helper:

1.  Infers the follow-up table key from `attr(df, "file_key")`.

2.  Loads the follow-up subset for the cohort's `TRR_ID`s via
    [`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md).

3.  Normalizes organ to a two-letter code (`ORG_TYPE` := first two
    characters of `ORG_TY`), selects core follow-up fields, and orders
    by `TRR_ID` and `TFL_PX_STAT_DT`.

4.  Computes the earliest malignancy date per `TRR_ID` where
    `TFL_MALIG == "Y"`.

5.  Computes the earliest acute rejection date per (`TRR_ID`,
    `ORG_TYPE`) where `TFL_ACUTE_REJ_EPISODE` indicates at least one
    treated episode, and pivots to wide organ-specific columns.

6.  Left-joins both results back to `df`.

**Assumptions/requirements**

- The follow-up table contains: `TRR_ID`, `ORG_TY`, `TFL_PX_STAT_DT`,
  `TFL_MALIG`, and `TFL_ACUTE_REJ_EPISODE`.

- `TFL_PX_STAT_DT` should be a `Date`; if stored as `YYYYMMDD`, convert
  upstream (e.g., `as.Date(as.character(x), "%Y%m%d")`).

- Rejection is identified by the labeled value
  `"1: Yes, at least one episode treated with anti-rejection agent"`.
  Adjust the filter if your coding differs.

**Notes**

- Combined organ codes (e.g., `"HL"`) are not split; they will produce a
  column `FIRST_FU_REJ_DATE_HL`. If you prefer to split into heart/lung,
  duplicate those rows before pivoting.

- This function only derives event *dates*. To build full TTE variables
  (censor date, indicator, elapsed time), pass these dates to your
  [`srtr_time_to_event()`](https://vagishhemmige.github.io/sRtr/reference/srtr_time_to_event.md)
  helper along with transplant and last-follow-up dates.

## See also

[`srtr_time_to_event`](https://vagishhemmige.github.io/sRtr/reference/srtr_time_to_event.md),
[`load_srtr_file`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# df loaded earlier, e.g., df <- load_srtr_file("KI_txf")
attr(df, "file_key")
#> "KI_txf"

df2 <- add_txf_outcomes(df)
names(df2)
# ... includes FIRST_FU_MALIG_DATE, FIRST_FU_REJ_DATE_KI, etc.

# Then compute time-to-event from transplant date:
df2 <- srtr_time_to_event(
  df2,
  event_date  = FIRST_FU_MALIG_DATE,
  start_date  = REC_TX_DT,
  censor_date = TFL_LAFUDATEKI,
  prefix      = "REC_MALIG"
)
} # }
```
