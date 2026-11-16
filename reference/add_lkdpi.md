# Add the Living Kidney Donor Profile Index

Computes the Living Kidney Donor Profile Index (LKDPI) for living donor
kidney transplants and appends it (default column `LKDPI`). The LKDPI is
on the same scale as the deceased donor KDPI, but it is not limited to
0-100: a negative value means less risk than any deceased donor kidney
in the reference population.

## Usage

``` r
add_lkdpi(
  df,
  creatinine = "DON_KI_CREAT_PREOP",
  egfr_equation = c("ckd_epi_2009", "ckd_epi_2021"),
  a2_donor = c("incompatible", "compatible"),
  lkdpi_col = "LKDPI",
  return_terms = FALSE
)
```

## Arguments

- df:

  A data frame of living donor kidney transplants, one row each.

- creatinine:

  Name of the donor creatinine column used for eGFR. Defaults to
  `"DON_KI_CREAT_PREOP"` (pre-donation creatinine), a convention.

- egfr_equation:

  eGFR equation passed to
  [`add_donor_egfr()`](https://vagishhemmige.github.io/sRtr/reference/add_donor_egfr.md).
  `"ckd_epi_2009"` (default) is the CKD-EPI equation the paper used.
  `"ckd_epi_2021"` is the newer equation without race; the coefficients
  were not fit with it.

- a2_donor:

  Whether an A2 or A2B donor counts as ABO incompatible with a recipient
  lacking the A antigen. `"incompatible"` (default) follows the
  antigens; `"compatible"` treats A2 as lacking A, as in A2-to-B
  allocation. Both are conventions; the paper does not say.

- lkdpi_col:

  Name of the output column.

- return_terms:

  If `TRUE`, also add a list-column `LKDPI_terms` with each row's
  components.

## Value

`df` with a new column.

## Details

The inputs come from both the living donor file (`DONOR_LIVE`) and the
kidney transplant file (`TX_KI`), so join them first:

|  |  |
|----|----|
| Factor | Columns |
| Donor age | `DON_AGE` |
| Donor eGFR | computed with [`add_donor_egfr()`](https://vagishhemmige.github.io/sRtr/reference/add_donor_egfr.md) from `creatinine`, `DON_AGE`, `DON_GENDER` and race |
| Donor BMI | `DON_WGT_KG`, `DON_HGT_CM` |
| Donor African American | `DON_RACE_BLACK_AFRICAN_AMERICAN` (Y/N), or `DON_RACE` = 16 (1024 = unknown) |
| Donor cigarette use | `DON_HIST_CIGARETTE` (Y/N) |
| Donor systolic blood pressure | `DON_BP_PREOP_SYST` |
| Male donor to male recipient | `DON_GENDER`, `CAN_GENDER` |
| ABO incompatible | `DON_ABO`, `CAN_ABO` |
| Unrelated donor | `DON_RELATIONSHIP_TY` |
| HLA-B and HLA-DR mismatches | `REC_B_MM_EQUIV_TX`, `REC_DR_MM_EQUIV_TX` |
| Donor/recipient weight ratio | `DON_WGT_KG`, `REC_WGT_KG` |

The paper states its factors but not how each was read from SRTR fields.
The mapping above, and these rules, are this package's reading:

- ABO incompatible means the donor carries an A or B antigen the
  recipient lacks (A, A1 and A2 carry A; AB, A1B and A2B carry both).

- Unrelated means a non-biological relationship: codes 7 to 12, 15 and
  999 of format `LVDNRL`.

## References

Massie AB, Leanza J, Fahmy LM, et al. A risk index for living donor
kidney transplantation. *Am J Transplant* 2016;16:2077-2084.
[doi:10.1111/ajt.13709](https://doi.org/10.1111/ajt.13709) (Results,
"Calculation of the LKDPI".)

## Examples

``` r
pairs <- data.frame(
  DON_AGE = 60, DON_GENDER = "M", CAN_GENDER = "M",
  DON_HGT_CM = 180, DON_WGT_KG = 90, REC_WGT_KG = 80,
  DON_KI_CREAT_PREOP = 1.0, DON_RACE = 8, DON_HIST_CIGARETTE = "N",
  DON_BP_PREOP_SYST = 125, DON_ABO = "O", CAN_ABO = "A",
  DON_RELATIONSHIP_TY = 4, REC_B_MM_EQUIV_TX = 1, REC_DR_MM_EQUIV_TX = 1
)
add_lkdpi(pairs)
#>   DON_AGE DON_GENDER CAN_GENDER DON_HGT_CM DON_WGT_KG REC_WGT_KG
#> 1      60          M          M        180         90         80
#>   DON_KI_CREAT_PREOP DON_RACE DON_HIST_CIGARETTE DON_BP_PREOP_SYST DON_ABO
#> 1                  1        8                  N               125       O
#>   CAN_ABO DON_RELATIONSHIP_TY REC_B_MM_EQUIV_TX REC_DR_MM_EQUIV_TX    LKDPI
#> 1       A                   4                 1                  1 13.22419
```
