# Changelog

## sRtr (development version)

- sRtr now needs R 4.1.0 or later and dplyr 1.1.0 or later, and no
  longer depends on magrittr. Package code calls every function as
  `pkg::fun()`
  ([\#55](https://github.com/VagishHemmige/sRtr/issues/55)).

- The cohort-building vignette now uses the CRAN package flowchart
  instead of strobe, and is renamed “Building Cohorts with Flow
  Diagrams” ([\#69](https://github.com/VagishHemmige/sRtr/issues/69)).

- Errors, warnings and messages now come from cli, so they are formatted
  consistently, and errors name the function you called. Every condition
  signalled by sRtr itself has a class you can catch: a general one
  (`sRtr_error`, `sRtr_warning`, `sRtr_message`) and a specific one such
  as `sRtr_error_file_not_found` or `sRtr_error_missing_columns`. Errors
  that come from base R or other packages, such as an invalid choice for
  an argument, keep their own classes. sRtr now imports cli
  ([\#102](https://github.com/VagishHemmige/sRtr/issues/102),
  [\#103](https://github.com/VagishHemmige/sRtr/issues/103)).

- `formats`: four code meanings (three in `BILICOMP`, one in `DGN`)
  showed a control character where SRTR’s page has an en dash or an
  apostrophe. The dictionary page is now read as Windows-1252, the
  encoding it uses, so they show the intended character
  ([\#26](https://github.com/VagishHemmige/sRtr/issues/26)).

- Loading sRtr no longer warns when `SRTR_WD` is not set, and no longer
  sets `options(arrow.skip_nul = TRUE)` for the session
  ([\#62](https://github.com/VagishHemmige/sRtr/issues/62)).

- The bundled `dictionary` now names the original MELD exception tumors
  file `MPEXCEPT_ORIG_TUMORS`, as the SRTR data file is named, instead
  of the shortened `MPEXCEPT_ORIG_TUMO`, so loading and labeling that
  file find its dictionary entries.

- [`add_pdri()`](https://vagishhemmige.github.io/sRtr/reference/add_pdri.md)
  is now exported
  ([\#50](https://github.com/VagishHemmige/sRtr/issues/50)).

- [`add_txf_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_txf_outcomes.md)
  no longer fails unless dplyr is attached
  ([\#17](https://github.com/VagishHemmige/sRtr/issues/17)).

- [`apply_srtr_factors()`](https://vagishhemmige.github.io/sRtr/reference/apply_srtr_factors.md)
  and
  [`apply_srtr_varlabels()`](https://vagishhemmige.github.io/sRtr/reference/apply_srtr_varlabels.md)
  no longer fail when called as `sRtr::fun()` without sRtr attached
  ([\#90](https://github.com/VagishHemmige/sRtr/issues/90)).

- [`apply_srtr_factors()`](https://vagishhemmige.github.io/sRtr/reference/apply_srtr_factors.md)
  and
  [`apply_srtr_varlabels()`](https://vagishhemmige.github.io/sRtr/reference/apply_srtr_varlabels.md)
  now set a `file_key` attribute on their result, so a chain such as
  `TX_KI |> apply_srtr_factors() |> apply_srtr_varlabels()` labels both
  steps. `file_key` is matched in upper case. A key that is not in the
  bundled dictionary, or that cannot be worked out, now gives a warning
  instead of silently returning unlabeled data
  ([\#89](https://github.com/VagishHemmige/sRtr/issues/89)).

- [`apply_srtr_factors()`](https://vagishhemmige.github.io/sRtr/reference/apply_srtr_factors.md),
  and so
  [`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)
  with its default `factor_labels = TRUE`, no longer turns values into
  `NA` ([\#15](https://github.com/VagishHemmige/sRtr/issues/15)):

  - Ages with an age-band format (`REC_AGE_AT_TX`, `CAN_AGE_AT_LISTING`)
    stay numeric; before, every age that was not a band’s lower bound
    became `NA`. `range_formats = "bin"` bands them instead.
  - A value not listed in a format with a catch-all entry gets the
    catch-all label, as in SAS: race code 24 (White and Black) becomes
    “Multi-Racial”. `other = "keep"` turns this off.
  - Any other value not listed in its format is kept as its own level
    with a warning; `unknown_codes = "na"` or `"error"` choose
    otherwise.
  - Calling it again on its own result changes nothing, and attributes
    on each column, such as a variable label, are kept.

- [`calculate_geography_coverage_gain()`](https://vagishhemmige.github.io/sRtr/reference/calculate_geography_coverage_gain.md)
  now does what its arguments say
  ([\#58](https://github.com/VagishHemmige/sRtr/issues/58)):

  - `method = "centroid"` and `method = "areal"` are implemented.
    Before, every method gave intersection results. The default is
    `"areal"`.
  - `output = "wide"` returns one row with `<variable>_<measure>`
    columns.
  - `geography_id` adds a `covered_ids` attribute listing the
    geographies counted in each area.
  - All inputs are transformed to `crs` first.
  - It no longer fails unless dplyr and sf are attached
    ([\#55](https://github.com/VagishHemmige/sRtr/issues/55)).

- [`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)
  finds the folder set with
  [`set_srtr_wd()`](https://vagishhemmige.github.io/sRtr/reference/set_srtr_wd.md)
  when it first needs it, and looks again if a file is not found, so
  files added during a session are picked up. Errors now say when
  `SRTR_WD` is not set and which folder was searched
  ([\#62](https://github.com/VagishHemmige/sRtr/issues/62)).

- [`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)
  `col_select` now works as documented
  ([\#98](https://github.com/VagishHemmige/sRtr/issues/98)):

  - Tidyselect expressions such as `starts_with("REC_")` work; before,
    they failed before any file was read. Parquet files now get the
    selection too.
  - Names are matched in upper case, as in the result, and columns come
    back in the order selected.
  - `trr_id_filter` works when `TRR_ID` is not selected; it is read for
    the filter and then dropped.
  - A `"TX_KP"` subset no longer needs `TFL_LAFUDATEKI` and
    `TFL_LAFUDATEPA`. `TFL_LAFUDATE` can be selected by name, and is
    still added when both dates are selected.

- [`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)
  now compares a file’s columns with the bundled data dictionary when
  every column is read. It warns about columns the file is missing and
  names columns the dictionary does not list (once per file per
  session). The new `column_check` argument turns the warning into an
  error (`"error"`) or skips the comparison (`"none"`)
  ([\#4](https://github.com/VagishHemmige/sRtr/issues/4)).

- [`rank_individual_coverage_gains()`](https://vagishhemmige.github.io/sRtr/reference/rank_individual_coverage_gains.md)
  now defaults to `method = "areal"`, like
  [`calculate_geography_coverage_gain()`](https://vagishhemmige.github.io/sRtr/reference/calculate_geography_coverage_gain.md)
  ([\#58](https://github.com/VagishHemmige/sRtr/issues/58)).

- [`srtr_composite_death()`](https://vagishhemmige.github.io/sRtr/reference/srtr_composite_death.md)
  now requires its three death date columns to be `Date`, which is how
  [`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)
  returns SAS date columns, and errors with the names of any that are
  not. It no longer converts numbers or text to dates, so the `parse`
  argument is removed; the conversion could misread `MM/DD/YYYY` text
  and SAS day counts
  ([\#23](https://github.com/VagishHemmige/sRtr/issues/23),
  [\#59](https://github.com/VagishHemmige/sRtr/issues/59)). A missing
  column now gives a clear error instead of a failed
  [`stopifnot()`](https://rdrr.io/r/base/stopifnot.html).

- [`srtr_normalize_missing()`](https://vagishhemmige.github.io/sRtr/reference/srtr_normalize_missing.md)
  keeps the order of factor levels and removes only the replaced missing
  codes from them, so the reference level no longer depends on which
  value comes first in the data. Ordered factors and variable labels are
  kept ([\#20](https://github.com/VagishHemmige/sRtr/issues/20)).

- [`srtr_normalize_missing()`](https://vagishhemmige.github.io/sRtr/reference/srtr_normalize_missing.md)
  now recognizes the default unknown codes of 18 variables it used to
  miss. Thirteen defaults did not match their formats’ labels
  (`"998: UNKNOWN"` for `"998: Unknown"`, `"97: Unknown"` for the
  WKGRPHLA code `"998: Unknown"`), and five SRLSTT variables (CMV, EBV
  and hepatitis B results) had their labelled codes replaced by raw ones
  ([\#19](https://github.com/VagishHemmige/sRtr/issues/19)).
