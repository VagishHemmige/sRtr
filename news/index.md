# Changelog

## sRtr (development version)

- sRtr now needs R 4.1.0 or later and dplyr 1.1.0 or later, and no
  longer depends on magrittr. Package code calls every function as
  `pkg::fun()`
  ([\#55](https://github.com/VagishHemmige/sRtr/issues/55)).

- [`add_txf_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_txf_outcomes.md)
  no longer fails unless dplyr is attached
  ([\#17](https://github.com/VagishHemmige/sRtr/issues/17)).

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

- [`rank_individual_coverage_gains()`](https://vagishhemmige.github.io/sRtr/reference/rank_individual_coverage_gains.md)
  now defaults to `method = "areal"`, like
  [`calculate_geography_coverage_gain()`](https://vagishhemmige.github.io/sRtr/reference/calculate_geography_coverage_gain.md)
  ([\#58](https://github.com/VagishHemmige/sRtr/issues/58)).
