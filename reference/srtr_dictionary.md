# SRTR data dictionary for a SAF release

Returns the SRTR data dictionary, or its format code lists, as they were
for a SAF release. sRtr stores each version of SRTR's public dictionary
page it has seen (see
[dictionary_versions](https://vagishhemmige.github.io/sRtr/reference/dictionary_versions.md));
a release between two stored versions uses the entries that are the same
in both.

## Usage

``` r
srtr_dictionary(
  release = NULL,
  table = c("dictionary", "formats"),
  gaps = c("warn", "error", "nearest"),
  view = c("corrected", "web")
)
```

## Arguments

- release:

  The SAF release, as year and month (`"2609"` for September 2026). If
  `NULL` (the default), the bundled
  [dictionary](https://vagishhemmige.github.io/sRtr/reference/dictionary.md)
  or
  [formats](https://vagishhemmige.github.io/sRtr/reference/formats.md).

- table:

  `"dictionary"` (the default) for variables, or `"formats"` for format
  code lists.

- gaps:

  For a release between two stored versions, what to do about a variable
  or format code whose definition changed between them: `"warn"` (the
  default) uses the earlier version with a warning, `"nearest"` does so
  silently, and `"error"` stops. Variables seen in only one of the two
  versions are left out, since whether they existed at that release
  cannot be known without the file;
  [`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)
  decides them from the file's columns. Format codes seen in only one
  are kept.

- view:

  `"corrected"` (the default) applies sRtr's corrections to SRTR's web
  dictionary; `"web"` returns the dictionary as SRTR's web page has it.
  The corrections are listed in the Corrections section below. They
  change only the dictionary table, never the format code lists.

## Value

A tibble with the columns of
[dictionary](https://vagishhemmige.github.io/sRtr/reference/dictionary.md)
or [formats](https://vagishhemmige.github.io/sRtr/reference/formats.md).
Its attributes `snapshot` (the stored version used, or `NA`) and `basis`
(`"observed"`, `"interpolated"`, `"nearest snapshot"` or `"default"`)
say where it came from. A release before the first or after the last
stored version uses that version, with a warning. Attribute `view` is
the view used and `corrections` the IDs of the corrections applied.

## Corrections

sRtr corrects a few entries of SRTR's web dictionary that do not match
the SAFs, each under a stable ID:

- `SRTR-DC-001`: `REC_COD` in every TX dataset uses the format `COD`,
  not `THCOD`. The thoracic format `THCOD` is a subset of `COD` with the
  same meanings (`COD` prefixes their labels with "TH:"), and liver
  recipients' causes of death are `COD` codes that `THCOD` lacks. This
  was checked on a real TX_LI file only; for other organs it is a
  generalization.

A correction is applied only when SRTR's entry still has the value sRtr
expects; if SRTR has changed it, sRtr keeps SRTR's value and warns.
Codes that appear in data but are in no format are not corrected: their
meaning is not documented.

## See also

Guides:

- [Releases](https://vagishhemmige.github.io/sRtr/articles/releases-and-warnings.html#releases)

- [Corrections to SRTR's
  dictionary](https://vagishhemmige.github.io/sRtr/articles/releases-and-warnings.html#corrections-to-srtrs-dictionary)

[`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)
and
[`set_srtr_wd()`](https://vagishhemmige.github.io/sRtr/reference/set_srtr_wd.md),
which take a `release`.

## Examples

``` r
current <- srtr_dictionary("2609")
attr(current, "snapshot")
#> [1] "2609-1"
head(srtr_dictionary("2609", table = "formats"))
#> # A tibble: 6 × 3
#>   Format   Code  Meaning                                                     
#>   <chr>    <chr> <chr>                                                       
#> 1 ABNLBRNC 1     1: No Bronchoscopy                                          
#> 2 ABNLBRNC 2     2: Bronchoscopy Results normal                              
#> 3 ABNLBRNC 3     3: Bronchoscopy Results, Abnormal-purulent secretions       
#> 4 ABNLBRNC 4     4: Bronchoscopy Results, Abnormal-aspiration of foreign body
#> 5 ABNLBRNC 5     5: Bronchoscopy Results, Abnormal-blood                     
#> 6 ABNLBRNC 6     6: Bronchoscopy Results, Abnormal-anatomy/other lesion      
```
