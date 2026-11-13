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
  column_check = c("warn", "error", "none"),
  ...
)
```

## Arguments

- file_key:

  Character. Canonical dataset key (e.g., "TX_LI", "CAND_KIPA").

- trr_id_filter:

  Optional vector of `TRR_ID` values. If not `NULL`, only rows whose
  `TRR_ID` is in this vector are kept.

- factor_labels:

  Logical. Whether to apply factor labels. Default = TRUE.

- var_labels:

  Logical. Whether to apply variable labels. Default = TRUE.

- col_select:

  Optional. Columns to keep, as a character vector or a tidyselect
  expression such as `starts_with("REC_")`. Names are matched in upper
  case, as in the result, whatever their case in the file. Columns come
  back in the order selected. Columns needed only for `trr_id_filter`
  are read and then dropped. For `"TX_KP"`, `TFL_LAFUDATE` (derived on
  loading) can be selected like any other column; it is derived when
  `col_select` is `NULL`, includes it, or includes both `TFL_LAFUDATEKI`
  and `TFL_LAFUDATEPA`. Renaming (`c(new = OLD)`) is not supported;
  rename after loading.

- column_check:

  What to do when the file's columns differ from the columns the bundled
  data dictionary
  ([dictionary](https://vagishhemmige.github.io/sRtr/reference/dictionary.md))
  lists for `file_key`. `"warn"` (the default) warns about columns the
  file is missing; `"error"` makes that an error; `"none"` skips the
  comparison. Either way, columns the dictionary does not list are named
  in a message, once per file key per session, and loaded as they are.
  The comparison runs only when every column is read
  (`col_select = NULL`) and only for file keys the dictionary lists. A
  file from a different SAF release than the dictionary can differ in
  its columns.

- ...:

  Additional arguments passed to the file reader
  ([`haven::read_sas()`](https://haven.tidyverse.org/reference/read_sas.html)
  or
  [`arrow::read_parquet()`](https://arrow.apache.org/docs/r/reference/read_parquet.html)),
  e.g. `encoding` for `read_sas()`.

## Value

A tibble with the loaded file contents, optionally labeled. The tibble
includes attributes `source_path` and `file_key`.

## Details

Files are looked up in the folder set with
[`set_srtr_wd()`](https://vagishhemmige.github.io/sRtr/reference/set_srtr_wd.md)
(the `SRTR_WD` environment variable). The folder is scanned the first
time a file is loaded, and again if a file is not found, so files added
during the session are picked up.

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
