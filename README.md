
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sRtr

<!-- badges: start -->

[![R-CMD-check](https://github.com/VagishHemmige/sRtr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/VagishHemmige/sRtr/actions/workflows/R-CMD-check.yaml)
![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
<!-- badges: end -->

The **sRtr** package provides tools to load, label, and work with the
Scientific Registry of Transplant Recipients (SRTR) Standard Analysis
Files (SAFs) in R. It supports automatic variable labeling and factor
conversion using the official SRTR data dictionary.

## Installation

You can install the development version of **sRtr** from
[GitHub](https://github.com/VagishHemmige/sRtr) with:

``` r
# install.packages("devtools")
devtools::install_github("VagishHemmige/sRtr")
```

## Setup

Before using `load_srtr_file()`, you must initialize the file registry
using your local file paths:

``` r
library(sRtr)

# Example: point to a folder of .sas7bdat or .parquet files for the session only
set_srtr_wd("path/to/srtr/files")

# Or set permanently:
set_srtr_wd("path/to/srtr/files", permanent = TRUE)
```

## Example

The primary function is `load_srtr_file()`, which loads and (optionally)
labels SRTR files:

``` r
# Load the TX_LI file with factor and variable labels
tx_li <- load_srtr_file("TX_LI", factor_labels = TRUE, var_labels = TRUE)

# View factor labels
str(tx_li$DON_RACE)  # Example factor column

# View variable label
labelled::var_label(tx_li$DON_RACE)
```

You can also use the labeling functions independently:

``` r
df <- haven::read_sas("TX_KI.sas7bdat")

df <- apply_srtr_factors(df, file_key = "TX_KI")
df <- apply_srtr_varlabels(df, file_key = "TX_KI")
```

If the name of the data frame corresponds to the name of the underlying
file, then the `file_key` argument can be omitted:

``` r
TX_KI <- haven::read_sas("TX_KI.sas7bdat")

TX_KI_labelled <- TX_KI |>
  apply_srtr_factors()
```

## Missing values

SRTR variables record missing information in many ways, and the codes
differ from variable to variable: code `4` is “Unknown” in one format,
“N/A” in another and “Not tested” in a third. sRtr recognises each code
by what it means in its own variable, for raw codes and labelled columns
alike.

``` r
tx_ki <- load_srtr_file("TX_KI")

# Count the unknown, not-done, pending and other codes in each variable
srtr_missing_report(tx_ki)

# Turn them into NA, in a new data frame
tx_ki_clean <- srtr_normalize_missing(tx_ki)
```

Which kinds of missing value should become `NA` depends on the analysis,
so it is a choice. The default policy, `"analysis"`, removes unknown,
not done, pending, withheld and blank values, and keeps “not
applicable”, “indeterminate” and partly known answers.
`policy = "strict"` removes those too, and `actions` or `overrides`
change the rule for one kind of value or one variable:

``` r
# From the original data: keep "not done" as a value, and record why
# each value became NA
tx_ki_clean <- srtr_normalize_missing(
  tx_ki,
  actions = c(not_done = "keep"),
  reason = "changed"
)
```

The `missing_codes` dataset lists every code and its type. See the
[Missing data
article](https://vagishhemmige.github.io/sRtr/articles/missing-data.html)
for the full walk-through.

See [Function
Reference](https://vagishhemmige.github.io/sRtr/reference/index.html)
for full documentation.

Much more, including help files, vignettes, etc. will be coming soon!
