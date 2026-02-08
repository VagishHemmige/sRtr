# SRTR Format Lookup Table

Lookup table used to convert coded values in SRTR datasets to
human-readable factor labels.

## Usage

``` r
formats
```

## Format

A data frame with 3 columns:

- Format:

  The name of the format group (e.g., ABO, CMV)

- Code:

  The coded value (as a string or numeric)

- Meaning:

  The human-readable label for that code

## Source

Derived from official SRTR format tables
