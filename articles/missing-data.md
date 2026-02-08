# Missing data

## Harmonizing missing data

SRTR data often uses non-standard codes to represent missingness — such
as `""`,`"U"`, `"ND"`, or `"C: Cannot Disclose"` — which can vary by
variable. The
[`srtr_normalize_missing()`](https://vagishhemmige.github.io/sRtr/reference/srtr_normalize_missing.md)
function helps harmonize these values by converting them to `NA` or a
user-specified label like `"Missing"`.

``` r
tx_li <- load_srtr_file("TX_LI", var_labels = TRUE, factor_labels = TRUE)

# Replace common SRTR missing codes (e.g., "U", "", "ND") with NA
tx_li <- srtr_normalize_missing(tx_li)

# Replace missing codes and NAs with an explicit label
tx_li <- srtr_normalize_missing(tx_li, replacement = "Missing")
```

Internally, this uses a built-in dictionary of variable-specific missing
codes drawn from the SRTR documentation and known conventions. You can
also pass a custom list of codes using the `missing_vals` argument.

``` r

# Load the data
tx_li <- load_srtr_file("TX_LI", var_labels = TRUE, factor_labels = TRUE)

# Define custom missing codes for specific variables
custom_missing_vals <- list(
  REC_HIV_STAT = c("U", ""),              # "Unknown" or blank
  REC_HCV_STAT = c("ND: Not Done", "U"),  # Custom-labeled values
  REC_CMVD = c(-1, 999),                  # Numeric codes
  DON_RACE = c("99", "Unknown")           # Other arbitrary codes
)

# Apply normalization, replacing with NA
tx_li_clean <- srtr_normalize_missing(tx_li, missing_vals = custom_missing_vals)

# Or, replace all with an explicit label
tx_li_labeled <- srtr_normalize_missing(tx_li, missing_vals = custom_missing_vals, replacement = "Missing")
```
