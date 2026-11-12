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

* `rank_individual_coverage_gains()` now defaults to `method = "areal"`,
  like `calculate_geography_coverage_gain()` (#58).
