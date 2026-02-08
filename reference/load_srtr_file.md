# Load an SRTR file and optionally apply labels

Loads a file from the SRTR dataset registry and optionally applies:

- Factor labels using the `formats` dataset

- Variable labels using the `dictionary` dataset

## Usage

``` r
load_srtr_file(
  file_key,
  trr_id_filter = NULL,
  factor_labels = TRUE,
  var_labels = TRUE,
  col_select = NULL,
  ...
)
```

## Arguments

- file_key:

  Character. Canonical dataset key (e.g., "TX_LI", "CAND_KIPA").

- trr_id_filter:

  Optional vector of TRR_IDs to keep.. If not NULL, will filter by
  \`TRR_ID' vector passed to this option.

- factor_labels:

  Logical. Whether to apply factor labels. Default = TRUE.

- var_labels:

  Logical. Whether to apply variable labels. Default = FALSE.

- col_select:

  Optional. Tidyselect expression or character vector for selecting
  columns.

- ...:

  Additional arguments passed to the file reader (e.g., `as_factor` for
  `read_sas()`).

## Value

A tibble with the loaded file contents, optionally labeled. The tibble
includes attributes `source_path` and `file_key`.

## Details

All variable names are standardized to uppercase after loading. The
returned tibble includes two attributes:

- `source_path`: the full path to the file on disk

- `file_key`: the canonical dataset key used to load it

## Examples

``` r
if (FALSE) { # \dontrun{
df <- load_srtr_file("TX_LI", factor_labels = TRUE, var_labels = TRUE)
} # }
```
