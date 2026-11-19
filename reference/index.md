# Package index

## Load files

Point sRtr at your SAFs and load them. Start with [Getting
started](https://vagishhemmige.github.io/sRtr/articles/getting-started.md);
joining files is in [Files, keys and
joins](https://vagishhemmige.github.io/sRtr/articles/files-and-keys.md).

- [`set_srtr_wd()`](https://vagishhemmige.github.io/sRtr/reference/set_srtr_wd.md)
  : Set the SRTR working directory
- [`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)
  : Load an SRTR file and optionally apply labels

## Labels and the data dictionary

Factor and variable labels, and the SRTR dictionary they come from. See
[Releases, the data dictionary and
warnings](https://vagishhemmige.github.io/sRtr/articles/releases-and-warnings.md).

- [`apply_srtr_factors()`](https://vagishhemmige.github.io/sRtr/reference/apply_srtr_factors.md)
  : Apply SRTR factor labels to a data frame
- [`apply_srtr_varlabels()`](https://vagishhemmige.github.io/sRtr/reference/apply_srtr_varlabels.md)
  : Apply SRTR variable labels to a data frame
- [`srtr_dictionary()`](https://vagishhemmige.github.io/sRtr/reference/srtr_dictionary.md)
  : SRTR data dictionary for a SAF release
- [`dictionary`](https://vagishhemmige.github.io/sRtr/reference/dictionary.md)
  : SRTR Variable Dictionary
- [`dictionary_versions`](https://vagishhemmige.github.io/sRtr/reference/dictionary_versions.md)
  : Stored versions of the SRTR data dictionary
- [`formats`](https://vagishhemmige.github.io/sRtr/reference/formats.md)
  : SRTR Format Lookup Table

## Missing data

Count and normalize SRTR’s missing-value codes. See [Missing
data](https://vagishhemmige.github.io/sRtr/articles/missing-data.md).

- [`srtr_missing_report()`](https://vagishhemmige.github.io/sRtr/reference/srtr_missing_report.md)
  : Count the missing-value codes in SRTR data
- [`srtr_normalize_missing()`](https://vagishhemmige.github.io/sRtr/reference/srtr_normalize_missing.md)
  : Normalize missing-value codes in SRTR data
- [`missing_codes`](https://vagishhemmige.github.io/sRtr/reference/missing_codes.md)
  : Missing-value codes in the SRTR formats, by type

## Risk scores

Add published donor and candidate scores. See [Adding risk
scores](https://vagishhemmige.github.io/sRtr/articles/adding-columns.md).

- [`add_kdpi()`](https://vagishhemmige.github.io/sRtr/reference/add_kdpi.md)
  : Add the Kidney Donor Risk Index and Kidney Donor Profile Index
- [`add_epts()`](https://vagishhemmige.github.io/sRtr/reference/add_epts.md)
  : Add the Estimated Post-Transplant Survival score
- [`add_donor_egfr()`](https://vagishhemmige.github.io/sRtr/reference/add_donor_egfr.md)
  : Add a donor's estimated glomerular filtration rate
- [`add_lkdpi()`](https://vagishhemmige.github.io/sRtr/reference/add_lkdpi.md)
  : Add the Living Kidney Donor Profile Index
- [`add_pdri()`](https://vagishhemmige.github.io/sRtr/reference/add_pdri.md)
  : Add Pancreas Donor Risk Index (PDRI)
- [`add_pvr()`](https://vagishhemmige.github.io/sRtr/reference/add_pvr.md)
  : Add pulmonary vascular resistance
- [`optn_mapping_tables`](https://vagishhemmige.github.io/sRtr/reference/optn_mapping_tables.md)
  : OPTN KDPI and EPTS mapping tables

## Outcomes

Death, graft failure, rejection and malignancy, and the time to each.
See [Rejection and malignancy on follow-up
forms](https://vagishhemmige.github.io/sRtr/articles/follow-up-forms.md)
and [Death, graft failure, and
censoring](https://vagishhemmige.github.io/sRtr/articles/follow-up-windows.md).

- [`srtr_composite_death()`](https://vagishhemmige.github.io/sRtr/reference/srtr_composite_death.md)
  : Composite death date (OPTN \> SSA \> TFL)
- [`add_txf_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_txf_outcomes.md)
  : Add time-to-event follow-up outcomes to a transplant cohort
- [`add_time_to_event_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_time_to_event_outcomes.md)
  : Add appropriate time-to-event outcome variables to a data frame
  based on the df attributes, if the file was loaded using a load
  function.
- [`srtr_time_to_event()`](https://vagishhemmige.github.io/sRtr/reference/srtr_time_to_event.md)
  : Helper function to add a time-to-event outcome from a date function

## Geography

Transplant centers, OPTN regions, OPO service areas and coverage. See
[Mapping](https://vagishhemmige.github.io/sRtr/articles/mapping.md) and
[Coverage
gain](https://vagishhemmige.github.io/sRtr/articles/geographic-coverage-gain.md).

- [`get_hrsa_transplant_centers()`](https://vagishhemmige.github.io/sRtr/reference/get_hrsa_transplant_centers.md)
  : Download HRSA Organ Procurement & Transplantation Center Locations
- [`get_hrsa_optn_regions()`](https://vagishhemmige.github.io/sRtr/reference/get_hrsa_optn_regions.md)
  : Get OPTN/UNOS Region Boundaries
- [`get_hrsa_opo_service_areas()`](https://vagishhemmige.github.io/sRtr/reference/get_hrsa_opo_service_areas.md)
  : Download HRSA OPO Service Area Boundaries
- [`shift_noncontiguous()`](https://vagishhemmige.github.io/sRtr/reference/shift_noncontiguous.md)
  : Move Alaska, Hawaii and Puerto Rico below the contiguous United
  States
- [`transplant_centers_sf`](https://vagishhemmige.github.io/sRtr/reference/transplant_centers_sf.md)
  : U.S. Transplant Centers (sf), EPSG:5070
- [`UNOS_regions_sf`](https://vagishhemmige.github.io/sRtr/reference/UNOS_regions_sf.md)
  : UNOS Regions by State (sf), EPSG:5070
- [`calculate_geography_coverage_gain()`](https://vagishhemmige.github.io/sRtr/reference/calculate_geography_coverage_gain.md)
  : Calculate net geographic coverage gain from adding new coverage
  areas to an existing coverage base
- [`rank_individual_coverage_gains()`](https://vagishhemmige.github.io/sRtr/reference/rank_individual_coverage_gains.md)
  : Rank individual candidate areas by marginal coverage gain
