# SRTR Variable Dictionary

A lookup table of variable metadata extracted from the Scientific
Registry of Transplant Recipients (SRTR) data dictionary. This dataset
describes the variable name, type, length, label, and associated format
for each variable in each dataset.

## Usage

``` r
dictionary
```

## Format

A data frame with 6 columns:

- Dataset:

  The abbreviated SRTR dataset name (e.g., `kp_diab`, `txfu`)

- Variable:

  The name of the variable as it appears in the data

- Type:

  The storage type (e.g., `character`, `numeric`)

- Length:

  The declared length or field width

- FormatID:

  The format group name (used to match with `formats` for coded values)

- Label:

  The descriptive label for the variable

## Source

Extracted from SRTR data dictionary HTML snapshot
(`data-raw/dataDictionary.html`).
