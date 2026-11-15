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
  gaps = c("warn", "error", "nearest")
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

## Value

A tibble with the columns of
[dictionary](https://vagishhemmige.github.io/sRtr/reference/dictionary.md)
or [formats](https://vagishhemmige.github.io/sRtr/reference/formats.md).
Its attributes `snapshot` (the stored version used, or `NA`) and `basis`
(`"observed"`, `"interpolated"`, `"nearest snapshot"` or `"default"`)
say where it came from. A release before the first or after the last
stored version uses that version, with a warning.

## See also

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
