# Apply SRTR variable labels to a data frame

Adds human-readable variable labels to an SRTR dataset using the SRTR
data dictionary.

## Usage

``` r
apply_srtr_varlabels(df, file_key = NULL, verbose = FALSE)
```

## Arguments

- df:

  A data frame loaded from an SRTR SAF file.

- file_key:

  Optional. The dataset name (e.g., "CAND_KIPA", "TX_KI"). If the file
  was loaded via the `load_srtr_file` function, this argument should be
  unnecessary.

- verbose:

  Logical. If TRUE, print each variable being labeled.

## Value

A data frame with variable labels applied.

## Details

If `file_key` is not explicitly provided, the function will first check
for a `file_key` attribute on the data frame. If not found, it will
attempt to infer it from the object name.

## Examples

``` r
if (FALSE) { # \dontrun{
# Explicit file_key
df <- read_sas("TX_KI.sas7bdat")
df <- apply_srtr_varlabels(df, file_key = "TX_KI", verbose = TRUE)

# Implicit file_key from attribute (if loaded via load_srtr_file)
df <- load_srtr_file("TX_KI")
df <- apply_srtr_varlabels(df)

# Fallback to object name inference
TX_KI <- read_sas("TX_KI.sas7bdat")
TX_KI <- apply_srtr_varlabels(TX_KI)
} # }
```
