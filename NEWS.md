# sRtr (development version)

* New `srtr_missing_report()` counts, for each variable, the values that
  stand for missing information and of which kind (unknown, not done, not
  applicable, ...), using `missing_codes`. It changes nothing in the data,
  gives the same counts for raw codes and labelled columns, and reports
  values that are already `NA` and values a format does not list separately.
  `detail = "code"` lists every classified code with its count, to check
  the classification against the data (#28).

* New dataset `missing_codes`: each SRTR format code that may stand for
  missing information, classified by what it means (unknown, not applicable,
  not done, pending, cannot disclose, indeterminate, partly known, SAS
  missing, or an ordinary value). The same code number means different
  things in different formats, so the classification is by format and code.
  A second table, `variables`, lists the raw values (blank, `ND`, `U` and
  similar) of flag columns that have no format; these come from the list
  `srtr_normalize_missing()` has used so far and are not documented in the
  SRTR dictionary. Nothing uses the dataset yet; `srtr_normalize_missing()`
  is unchanged (#27).

* New dataset `optn_mapping_tables`: the OPTN KDRI-to-KDPI (2010 onward) and
  EPTS (2014 onward) mapping tables, parsed from OPTN's PDFs, with each
  source file's address and sha256, and the date each table took effect in
  allocation (#171, #172).

* sRtr now needs R 4.1.0 or later and dplyr 1.1.0 or later, and no longer
  depends on magrittr. Package code calls every function as `pkg::fun()`
  (#55).

* The cohort-building vignette now uses the CRAN package flowchart instead of
  strobe, and is renamed "Building Cohorts with Flow Diagrams" (#69).

* Errors, warnings and messages now come from cli, so they are formatted
  consistently, and errors name the function you called. Every condition
  signalled by sRtr itself has a class you can catch: a general one
  (`sRtr_error`, `sRtr_warning`, `sRtr_message`) and a specific one such as
  `sRtr_error_file_not_found` or `sRtr_error_missing_columns`. Errors that come
  from base R or other packages, such as an invalid choice for an argument,
  keep their own classes. sRtr now imports cli (#102, #103).

* `formats`: four code meanings (three in `BILICOMP`, one in `DGN`) showed a
  control character where SRTR's page has an en dash or an apostrophe. The
  dictionary page is now read as Windows-1252, the encoding it uses, so they
  show the intended character (#26).

* Loading sRtr no longer warns when `SRTR_WD` is not set, and no longer sets
  `options(arrow.skip_nul = TRUE)` for the session (#62).

* The bundled `dictionary` now names the original MELD exception tumors file
  `MPEXCEPT_ORIG_TUMORS`, as the SRTR data file is named, instead of the
  shortened `MPEXCEPT_ORIG_TUMO`, so loading and labeling that file find its
  dictionary entries.

* `add_donor_egfr()` is a new function that adds a donor's eGFR from the
  CKD-EPI 2021 equation, or the 2009 equation for comparison with older work
  (#173).

* `add_epts()` is a new function that adds the raw EPTS and the EPTS score
  for adult kidney candidates at listing or at transplant, using the mapping
  table of your choice (#172).

* `add_kdpi()` is a new function that adds KDRI and KDPI for deceased kidney
  donors, with the refit formula OPTN has used since October 2024 or the
  original Rao 2009 formula, and the mapping table of your choice (#171).

* `add_lkdpi()` is a new function that adds the Living Kidney Donor Profile
  Index for living donor kidney transplants (#178).

* `add_pdri()` is now exported (#50).

* `add_pvr()` is a new function that adds pulmonary vascular resistance from
  the catheterization values recorded at listing or at transplant (#179).

* `add_txf_outcomes()` no longer fails unless dplyr is attached (#17).

* `apply_srtr_factors()` and `apply_srtr_varlabels()` no longer fail when
  called as `sRtr::fun()` without sRtr attached (#90).

* `apply_srtr_factors()` and `apply_srtr_varlabels()` now set a `file_key`
  attribute on their result, so a chain such as
  `TX_KI |> apply_srtr_factors() |> apply_srtr_varlabels()` labels both
  steps. `file_key` is matched in upper case. A key that is not in the bundled
  dictionary, or that cannot be worked out, now gives a warning instead of
  silently returning unlabeled data (#89).

* `apply_srtr_factors()`, and so `load_srtr_file()` with its default
  `factor_labels = TRUE`, no longer turns values into `NA` (#15):
  - Ages with an age-band format (`REC_AGE_AT_TX`, `CAN_AGE_AT_LISTING`) stay
    numeric; before, every age that was not a band's lower bound became `NA`.
    `range_formats = "bin"` bands them instead.
  - A value not listed in a format with a catch-all entry gets the catch-all
    label, as in SAS: race code 24 (White and Black) becomes "Multi-Racial".
    `other = "keep"` turns this off.
  - Any other value not listed in its format is kept as its own level, named
    `"<code>: not in format"` so it cannot be mistaken for a label, with a
    warning; `unknown_codes = "na"` or `"error"` choose otherwise.
  - Calling it again on its own result changes nothing, and attributes on
    each column, such as a variable label, are kept.

* `load_srtr_file()`, `set_srtr_wd()`, `apply_srtr_factors()` and
  `apply_srtr_varlabels()` gain a `release` argument, so a file is labelled
  with the SRTR data dictionary of the SAF release it comes from. The release
  can also come from a folder named like `pubsaf2609`; with none, the bundled
  `dictionary` and `formats` are used as before. A release between two stored
  dictionary versions uses the entries that are the same in both, and decides
  the rest from the file's columns (`gaps` says what to do when an entry
  changed). The release and dictionary used are recorded in the
  `srtr_release` attribute (#26).

* `srtr_dictionary()` returns the dictionary or format code lists for a SAF
  release, from the new `dictionary_versions` dataset of stored SRTR
  dictionary versions (#26).

* `calculate_geography_coverage_gain()` now does what its arguments say
  (#58):
  * `method = "centroid"` and `method = "areal"` are implemented. Before,
    every method gave intersection results. The default is `"areal"`.
  * `output = "wide"` returns one row with `<variable>_<measure>` columns.
  * `geography_id` adds a `covered_ids` attribute listing the geographies
    counted in each area.
  * All inputs are transformed to `crs` first.
  * It no longer fails unless dplyr and sf are attached (#55).

* `load_srtr_file()` finds the folder set with `set_srtr_wd()` when it first
  needs it, and looks again if a file is not found, so files added during a
  session are picked up. Errors now say when `SRTR_WD` is not set and which
  folder was searched (#62).

* `load_srtr_file()` `col_select` now works as documented (#98):
  * Tidyselect expressions such as `starts_with("REC_")` work; before, they
    failed before any file was read. Parquet files now get the selection too.
  * Names are matched in upper case, as in the result, and columns come back
    in the order selected.
  * `trr_id_filter` works when `TRR_ID` is not selected; it is read for the
    filter and then dropped.
  * A `"TX_KP"` subset no longer needs `TFL_LAFUDATEKI` and `TFL_LAFUDATEPA`.
    `TFL_LAFUDATE` can be selected by name, and is still added when both
    dates are selected.

* `load_srtr_file()` now compares a file's columns with the bundled data
  dictionary when every column is read. It warns about columns the file is
  missing and names columns the dictionary does not list (once per file per
  session). The new `column_check` argument turns the warning into an error
  (`"error"`) or skips the comparison (`"none"`) (#4).

* `rank_individual_coverage_gains()` now defaults to `method = "areal"`,
  like `calculate_geography_coverage_gain()` (#58).

* `srtr_composite_death()` now requires its three death date columns to be
  `Date`, which is how `load_srtr_file()` returns SAS date columns, and errors
  with the names of any that are not. It no longer converts numbers or text to
  dates, so the `parse` argument is removed; the conversion could misread
  `MM/DD/YYYY` text and SAS day counts (#23, #59). A missing column now gives a
  clear error instead of a failed `stopifnot()`.

* `srtr_normalize_missing()` keeps the order of factor levels and removes only
  the replaced missing codes from them, so the reference level no longer
  depends on which value comes first in the data. Ordered factors and variable
  labels are kept (#20).

* `srtr_normalize_missing()` now recognizes the default unknown codes of 18
  variables it used to miss. Thirteen defaults did not match their formats'
  labels (`"998: UNKNOWN"` for `"998: Unknown"`, `"97: Unknown"` for the
  WKGRPHLA code `"998: Unknown"`), and five SRLSTT variables (CMV, EBV and
  hepatitis B results) had their labelled codes replaced by raw ones (#19).
