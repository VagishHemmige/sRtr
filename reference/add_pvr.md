# Add pulmonary vascular resistance

Computes pulmonary vascular resistance (PVR) from right heart
catheterization values recorded at listing or at transplant for heart,
lung and heart-lung candidates, and appends it (default column `PVR`):
PVR = (mean pulmonary artery pressure - pulmonary capillary wedge
pressure) / cardiac output.

## Usage

``` r
add_pvr(
  df,
  at = c("listing", "transplant"),
  units = c("wood", "dyn"),
  pvr_col = "PVR"
)
```

## Arguments

- df:

  A data frame of candidates or recipients, one row each.

- at:

  Use the values recorded at `"listing"` (default) or at `"transplant"`.

- units:

  `"wood"` (default) for Wood units (mmHg min/L), or `"dyn"` for dyn s
  cm\\^{-5}\\, Wood units times 80. The exact conversion from the unit
  definitions is 79.99; 80 is the conventional factor.

- pvr_col:

  Name of the output column.

## Value

`df` with a new column.

## Details

Input columns, in mmHg and L/min:

|                |                     |                |                      |
|----------------|---------------------|----------------|----------------------|
| `at`           | Mean PA pressure    | Wedge pressure | Cardiac output       |
| `"listing"`    | `CAN_PULM_ART_MEAN` | `CAN_PCW_MEAN` | `CAN_CARDIAC_OUTPUT` |
| `"transplant"` | `REC_PULM_ART_MEAN` | `REC_PCW_MEAN` | `REC_CARDIAC_OUTPUT` |

A cardiac output of zero or less gives a missing PVR. The SAFs also
record whether each reading was taken on inotropes or vasodilators (the
`*_MEDS` columns); this function does not use them, so filter on them
first if that matters.

## References

Humbert M, Kovacs G, Hoeper MM, et al. 2022 ESC/ERS Guidelines for the
diagnosis and treatment of pulmonary hypertension. *Eur Heart J*
2022;43:3618-3731.
[doi:10.1093/eurheartj/ehac237](https://doi.org/10.1093/eurheartj/ehac237)
(Section 5.1.12.1 and Table 11.)

## Examples

``` r
candidates <- data.frame(
  CAN_PULM_ART_MEAN = c(40, 25),
  CAN_PCW_MEAN = c(20, 15),
  CAN_CARDIAC_OUTPUT = c(4, 5)
)
add_pvr(candidates)
#>   CAN_PULM_ART_MEAN CAN_PCW_MEAN CAN_CARDIAC_OUTPUT PVR
#> 1                40           20                  4   5
#> 2                25           15                  5   2
```
