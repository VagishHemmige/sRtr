# sRtr (development version)

* sRtr now needs R 4.1.0 or later and dplyr 1.1.0 or later, and no longer
  depends on magrittr. Package code calls every function as `pkg::fun()`
  (#55).

* The cohort-building vignette now uses the CRAN package flowchart instead of
  strobe, and is renamed "Building Cohorts with Flow Diagrams" (#69).

* Errors, warnings and messages now come from cli, so they are formatted
  consistently, and errors name the function you called. Every condition has
  a class you can catch: a general one (`sRtr_error`, `sRtr_warning`,
  `sRtr_message`) and a specific one such as `sRtr_error_file_not_found` or
  `sRtr_error_missing_columns`. sRtr now imports cli (#102).

* Loading sRtr no longer warns when `SRTR_WD` is not set, and no longer sets
  `options(arrow.skip_nul = TRUE)` for the session (#62).

* `add_pdri()` is now exported (#50).

* `add_txf_outcomes()` no longer fails unless dplyr is attached (#17).

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

* `rank_individual_coverage_gains()` now defaults to `method = "areal"`,
  like `calculate_geography_coverage_gain()` (#58).

* `srtr_composite_death()` now requires its three death date columns to be
  `Date`, which is how `load_srtr_file()` returns SAS date columns, and errors
  with the names of any that are not. It no longer converts numbers or text to
  dates, so the `parse` argument is removed; the conversion could misread
  `MM/DD/YYYY` text and SAS day counts (#23, #59). A missing column now gives a
  clear error instead of a failed `stopifnot()`.
