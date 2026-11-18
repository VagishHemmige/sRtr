# Changelog

## sRtr (development version)

- Two new articles under “Pitfalls in SRTR data” on the package website,
  *Follow-up forms are reports, not events* and *Follow-up windows and
  death*, show subtleties in SRTR follow-up and death data that change
  results. Each shows a naive approach that trips on one, and the sRtr
  function that handles it, with code to run on your own SAFs.

- sRtr now corrects entries of SRTR’s web data dictionary that do not
  match the SAFs, each under a stable ID. The first, `SRTR-DC-001`,
  gives `REC_COD` in every TX dataset the format `COD` instead of
  `THCOD`: liver recipients’ causes of death are `COD` codes, and
  `THCOD` is a subset of `COD` with the same meanings, so `REC_COD`
  labels now say “TH:” for thoracic codes. The stored dictionary
  versions are unchanged; corrections are applied when sRtr reads them.
  [`srtr_dictionary()`](https://vagishhemmige.github.io/sRtr/reference/srtr_dictionary.md)
  and
  [`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)
  gain `view`: `"corrected"` (the default) or `"web"` for the dictionary
  as SRTR’s web page has it.
  [`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)
  records the view and the corrections applied in its `srtr_release`
  attribute, and later labelling and missing-value functions on the
  result use the same view. A correction whose entry SRTR has since
  changed is not applied, with a warning
  ([\#191](https://github.com/VagishHemmige/sRtr/issues/191)).

- [`apply_srtr_varlabels()`](https://vagishhemmige.github.io/sRtr/reference/apply_srtr_varlabels.md),
  and so
  [`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md),
  now keep the variable labels a SAS file already carries and label only
  the columns without one, without a warning. Before, any existing label
  made it warn and label nothing, which happened on every real SAF. The
  new `overwrite = TRUE` replaces the file’s labels with the
  dictionary’s.
  [`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)
  also labels the `TFL_LAFUDATE` it derives for TX_KP, which the
  dictionary does not list.

- [`srtr_normalize_missing()`](https://vagishhemmige.github.io/sRtr/reference/srtr_normalize_missing.md)
  is rebuilt on `missing_codes`. It recognises codes by what they mean
  in each variable’s own format, for raw codes and labelled columns
  alike, and a `policy` chooses which kinds become `NA`: `"analysis"`
  (the default), `"strict"` or `"tag_only"`. `actions` changes the
  policy by kind and `overrides` by variable. `reason = "changed"` adds
  a `_MISS` column recording why each value became `NA`. Also new:
  `output = "append"`, `na_level`, `extra_codes`, `cols`, `file_key` and
  `release`.

  Changes from the earlier version:

  - The `missing_vals` list and `replacement` are removed. Use
    `extra_codes` for your own codes and `na_level` for an explicit
    “Missing” level.
  - Raw codes of formatted variables are now recognised; before, most
    were recognised only after labelling.
  - 59 more variables are normalized by default, because their format
    has an unknown, not-done or pending code that the earlier list did
    not include (93 code meanings in 64 variables in all).
  - Not done and not tested still become `NA` by default;
    `actions = c(not_done = "keep")` keeps them
    ([\#28](https://github.com/VagishHemmige/sRtr/issues/28)).
  - The internal list of default missing codes (`R/sysdata.rda`) is
    gone; everything it held is in `missing_codes`, where it can be
    read.

- New
  [`srtr_missing_report()`](https://vagishhemmige.github.io/sRtr/reference/srtr_missing_report.md)
  counts, for each variable, the values that stand for missing
  information and of which kind (unknown, not done, not applicable, …),
  using `missing_codes`. It changes nothing in the data, gives the same
  counts for raw codes and labelled columns, and reports values that are
  already `NA` and values a format does not list separately.
  `detail = "code"` lists every classified code with its count, to check
  the classification against the data
  ([\#28](https://github.com/VagishHemmige/sRtr/issues/28)).

- New dataset `missing_codes`: each SRTR format code that may stand for
  missing information, classified by what it means (unknown, not
  applicable, not done, pending, cannot disclose, indeterminate, partly
  known, SAS missing, or an ordinary value). The same code number means
  different things in different formats, so the classification is by
  format and code. A second table, `variables`, lists the raw values
  (blank, `ND`, `U` and similar) of flag columns that have no format;
  these come from the list
  [`srtr_normalize_missing()`](https://vagishhemmige.github.io/sRtr/reference/srtr_normalize_missing.md)
  has used so far and are not documented in the SRTR dictionary. Nothing
  uses the dataset yet;
  [`srtr_normalize_missing()`](https://vagishhemmige.github.io/sRtr/reference/srtr_normalize_missing.md)
  is unchanged
  ([\#27](https://github.com/VagishHemmige/sRtr/issues/27)).

- New dataset `optn_mapping_tables`: the OPTN KDRI-to-KDPI (2010 onward)
  and EPTS (2014 onward) mapping tables, parsed from OPTN’s PDFs, with
  each source file’s address and sha256, and the date each table took
  effect in allocation
  ([\#171](https://github.com/VagishHemmige/sRtr/issues/171),
  [\#172](https://github.com/VagishHemmige/sRtr/issues/172)).

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

- [`add_donor_egfr()`](https://vagishhemmige.github.io/sRtr/reference/add_donor_egfr.md)
  is a new function that adds a donor’s eGFR from the CKD-EPI 2021
  equation, or the 2009 equation for comparison with older work
  ([\#173](https://github.com/VagishHemmige/sRtr/issues/173)).

- [`add_epts()`](https://vagishhemmige.github.io/sRtr/reference/add_epts.md)
  is a new function that adds the raw EPTS and the EPTS score for adult
  kidney candidates at listing or at transplant, using the mapping table
  of your choice
  ([\#172](https://github.com/VagishHemmige/sRtr/issues/172)).

- [`add_kdpi()`](https://vagishhemmige.github.io/sRtr/reference/add_kdpi.md)
  is a new function that adds KDRI and KDPI for deceased kidney donors,
  with the refit formula OPTN has used since October 2024 or the
  original Rao 2009 formula, and the mapping table of your choice
  ([\#171](https://github.com/VagishHemmige/sRtr/issues/171)).

- [`add_lkdpi()`](https://vagishhemmige.github.io/sRtr/reference/add_lkdpi.md)
  is a new function that adds the Living Kidney Donor Profile Index for
  living donor kidney transplants
  ([\#178](https://github.com/VagishHemmige/sRtr/issues/178)).

- [`add_pdri()`](https://vagishhemmige.github.io/sRtr/reference/add_pdri.md)
  is now exported
  ([\#50](https://github.com/VagishHemmige/sRtr/issues/50)).

- [`add_pdri()`](https://vagishhemmige.github.io/sRtr/reference/add_pdri.md)
  now gives a missing PDRI for a missing donor race in labelled and
  character columns, as it already did for numeric ones; before, a
  missing label counted as neither Black nor Asian. The format’s missing
  code `"."` (`"Missing"`) counts as missing too, and character race
  codes (`"16"`, `"64"`) are now recognized
  ([\#96](https://github.com/VagishHemmige/sRtr/issues/96)).

- [`add_pdri()`](https://vagishhemmige.github.io/sRtr/reference/add_pdri.md)
  now errors when a continuous input such as `DON_BMI` is not numeric,
  instead of scoring a factor by its level positions.

- [`add_pdri()`](https://vagishhemmige.github.io/sRtr/reference/add_pdri.md)
  no longer deletes the caller’s columns whose names start with a dot,
  or overwrites them with its own intermediate values, and keeps an
  output column named with a leading dot
  ([\#99](https://github.com/VagishHemmige/sRtr/issues/99)).

- [`add_pdri()`](https://vagishhemmige.github.io/sRtr/reference/add_pdri.md)
  now warns, instead of failing, when PDRI is infinite.

- [`add_pvr()`](https://vagishhemmige.github.io/sRtr/reference/add_pvr.md)
  is a new function that adds pulmonary vascular resistance from the
  catheterization values recorded at listing or at transplant
  ([\#179](https://github.com/VagishHemmige/sRtr/issues/179)).

- [`add_txf_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_txf_outcomes.md)
  no longer fails unless dplyr is attached
  ([\#17](https://github.com/VagishHemmige/sRtr/issues/17)).

- [`add_txf_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_txf_outcomes.md)
  gives a missing date, not an infinite one, when every positive
  follow-up form for a recipient is undated
  ([\#214](https://github.com/VagishHemmige/sRtr/issues/214)).

- [`add_txf_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_txf_outcomes.md)
  now says what the follow-up forms report, not only when an event was
  first reported. New `FIRST_FU_MALIG_STATUS` and `FIRST_FU_REJ_STATUS`
  columns keep an event, an untreated rejection, an explicit “no”, an
  unknown answer and no follow-up form apart; before, everything but an
  event read as no event. New `..._LAST_NEG_DATE` columns give the last
  explicitly negative form before the first report (for `TX_KP`, per
  graft), for interval-censored analyses. The help page now says that
  these dates are report dates, not onset dates. Rejections are also
  found in raw codes, not only in labelled columns
  ([\#214](https://github.com/VagishHemmige/sRtr/issues/214)).

- [`add_txf_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_txf_outcomes.md)
  attaches a `txf_report` attribute counting the merge: registrations in
  the cohort and with follow-up forms, forms read and undated, and for
  each outcome the positive forms and the registrations with a report
  and with a dated report
  ([\#216](https://github.com/VagishHemmige/sRtr/issues/216)).

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
  - Any other value not listed in its format is kept as its own level,
    named `"<code>: not in format"` so it cannot be mistaken for a
    label, with a warning; `unknown_codes = "na"` or `"error"` choose
    otherwise.
  - Calling it again on its own result changes nothing, and attributes
    on each column, such as a variable label, are kept.

- [`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md),
  [`set_srtr_wd()`](https://vagishhemmige.github.io/sRtr/reference/set_srtr_wd.md),
  [`apply_srtr_factors()`](https://vagishhemmige.github.io/sRtr/reference/apply_srtr_factors.md)
  and
  [`apply_srtr_varlabels()`](https://vagishhemmige.github.io/sRtr/reference/apply_srtr_varlabels.md)
  gain a `release` argument, so a file is labelled with the SRTR data
  dictionary of the SAF release it comes from. The release can also come
  from a folder named like `pubsaf2609`; with none, the bundled
  `dictionary` and `formats` are used as before. A release between two
  stored dictionary versions uses the entries that are the same in both,
  and decides the rest from the file’s columns (`gaps` says what to do
  when an entry changed). The release and dictionary used are recorded
  in the `srtr_release` attribute
  ([\#26](https://github.com/VagishHemmige/sRtr/issues/26)).

- [`srtr_dictionary()`](https://vagishhemmige.github.io/sRtr/reference/srtr_dictionary.md)
  returns the dictionary or format code lists for a SAF release, from
  the new `dictionary_versions` dataset of stored SRTR dictionary
  versions ([\#26](https://github.com/VagishHemmige/sRtr/issues/26)).

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

- [`get_hrsa_optn_regions()`](https://vagishhemmige.github.io/sRtr/reference/get_hrsa_optn_regions.md)
  gains `crs`. The default, `4326`, keeps the longitude/latitude result
  it already returned; `crs = 5070` keeps the NAD83 / Conus Albers
  projection of `UNOS_regions_sf`. Its documentation wrongly said it
  kept that projection.

- [`get_hrsa_optn_regions()`](https://vagishhemmige.github.io/sRtr/reference/get_hrsa_optn_regions.md)
  gains `noncontiguous`: `"exclude"` (the default) leaves out Alaska,
  Hawaii and Puerto Rico as before; `"shift"` includes them, moved below
  the contiguous states for national maps; `"include"` keeps them at
  their real locations. `UNOS_regions_sf` gains the three rows (52 in
  all). Its documentation now names the three states OPTN splits between
  regions (Virginia, Vermont, Ohio), which it assigns whole
  ([\#197](https://github.com/VagishHemmige/sRtr/issues/197)).

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

- [`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)
  now loads blank text (empty or only spaces) as `NA`. Before, a blank
  in a formatted column became a factor level such as
  `": not in format"`, and a blank in any other text column stayed as
  `""`. The new `blank_text` argument keeps blanks with `"keep"`.

- [`rank_individual_coverage_gains()`](https://vagishhemmige.github.io/sRtr/reference/rank_individual_coverage_gains.md)
  now defaults to `method = "areal"`, like
  [`calculate_geography_coverage_gain()`](https://vagishhemmige.github.io/sRtr/reference/calculate_geography_coverage_gain.md)
  ([\#58](https://github.com/VagishHemmige/sRtr/issues/58)).

- New
  [`shift_noncontiguous()`](https://vagishhemmige.github.io/sRtr/reference/shift_noncontiguous.md)
  moves Alaska, Hawaii and Puerto Rico below the contiguous states for
  national maps, offline, so points and polygons in those areas land
  together.

- [`srtr_composite_death()`](https://vagishhemmige.github.io/sRtr/reference/srtr_composite_death.md)
  gains `conflict_days`, a tolerance for the conflict flag:
  `{out}_conflict` is `TRUE` only when the earliest and latest source
  dates are more than `conflict_days` apart. The default, 0, keeps the
  old flag. The new `add_spread_days = TRUE` adds `{out}_spread_days`,
  the days between them (`NA` with fewer than two sources), so you can
  compare thresholds
  ([\#210](https://github.com/VagishHemmige/sRtr/issues/210)).

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
