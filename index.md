# sRtr

![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

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

Before using
[`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md),
you must initialize the file registry using your local file paths:

``` r
library(sRtr)

# Example: point to a folder of .sas7bdat or .parquet files for the session only
set_srtr_wd("path/to/srtr/files")

# Or set permanently:
set_srtr_wd("path/to/srtr/files", permanent = TRUE)
```

## Example

The primary function is
[`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md),
which loads and (optionally) labels SRTR files:

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
df <- read_sas("TX_KI.sas7bdat")

df <- apply_srtr_factors(df, filekey="TX_KI")
df <- apply_srtr_varlabels(df, filekey="TX_KI")
```

If the name of the data frame corresponds to the name of the underlying
file, then the filekey option can be omitted:

``` r
TX_KI <- read_sas("TX_KI.sas7bdat")

TX_KI_labelled <-TX_KI%>% 
  apply_srtr_factors()
```

See [Function
Reference](https://vagishhemmige.github.io/sRtr/reference/index.html)
for full documentation.

Much more, including help files, vignettes, etc. will be coming soon!
