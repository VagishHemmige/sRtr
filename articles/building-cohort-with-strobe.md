# Building Cohorts with STROBE Diagrams

## Introduction

The STROBE (Strengthening the Reporting of Observational Studies in
Epidemiology) statement provides guidelines for reporting observational
studies. A key component is the flow diagram that shows how the study
population was selected. We encourage use of the companion `strobe`
package, which provides tools to create STROBE-compliant flow diagrams
while building your cohort.

This vignette demonstrates how to use the `strobe` functions via the
standalone `strobe` package to:

1.  Initialize a cohort with inclusion criteria  
2.  Apply sequential filters with exclusion tracking  
3.  Generate and customize STROBE flow diagrams  
4.  Review the complete filtering log

For more details, visit the [`strobe` package
website](https://vagishhemmige.github.io/strobe/).

### Installation

You can install the development version of the `sRtr` package from
GitHub using [`devtools`](https://cran.r-project.org/package=devtools)
or [`pak`](https://pak.r-lib.org/):

``` r
# Install devtools if needed
install.packages("devtools")

# Install sRtr (and strobe, a suggested package)
devtools::install_github("VagishHemmige/sRtr", dependencies = TRUE)
```

## Getting Started

``` r
library(sRtr)
library(dplyr)
library(strobe)
```

## Basic STROBE Workflow

The STROBE workflow in `strobe` follows these steps:

1.  **Initialize** the cohort with
    [`strobe_initialize()`](https://rdrr.io/pkg/strobe/man/strobe_initialize.html)  
2.  **Filter** sequentially with
    [`strobe_filter()`](https://rdrr.io/pkg/strobe/man/strobe_filter.html)  
3.  **Plot** the diagram with
    [`plot_strobe_diagram()`](https://rdrr.io/pkg/strobe/man/plot_strobe_diagram.html)  
4.  **Review** the log with
    [`get_strobe_log()`](https://rdrr.io/pkg/strobe/man/get_strobe_log.html)

### Example: Kidney Transplant Cohort

Let’s build a cohort of kidney transplant recipients with specific
criteria:

``` r
TX_KI %>%
  strobe::strobe_initialize(inclusion_label = "All kidney transplants") %>%
  strobe::strobe_filter(
    condition = "DON_AGE > 18",
    inclusion_label = "Donor over 18 years old",
    exclusion_reason = "Excluded: Donor age ≤ 18"
  ) %>%
  strobe::strobe_filter(
    condition = "DON_ABO == 'B'",
    inclusion_label = "Donor blood type B",
    exclusion_reason = "Excluded: Donor blood type is not B"
  ) %>%
  strobe::strobe_filter(
    condition = "REC_AGE >= 18 & REC_AGE <= 65",
    inclusion_label = "Recipient age 18-65",
    exclusion_reason = "Excluded: Recipient age outside 18-65 range"
  )
```

### Reviewing the Filtering Log

``` r
# View the complete filtering log
strobe::get_strobe_log()
```

The log shows: - Each filtering step - Number of records
included/excluded at each step - Cumulative counts - Exclusion reasons

## Creating STROBE Diagrams

``` r
strobe::plot_strobe_diagram(
  incl_width_min = 3,
  incl_height = 1,
  excl_width_min = 2.5,
  excl_height = 1,
  lock_width_min = TRUE,
  lock_height = TRUE,
  incl_fontsize = 16,
  excl_fontsize = 14

)
```

For more details, see the separate documentation of the `strobe`
package.
