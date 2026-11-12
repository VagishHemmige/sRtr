# Package index

## File Loading

- [`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)
  : Load an SRTR file and optionally apply labels
- [`set_srtr_wd()`](https://vagishhemmige.github.io/sRtr/reference/set_srtr_wd.md)
  : Set the SRTR working directory

## Variable and Factor Labeling

- [`apply_srtr_varlabels()`](https://vagishhemmige.github.io/sRtr/reference/apply_srtr_varlabels.md)
  : Apply SRTR variable labels to a data frame
- [`apply_srtr_factors()`](https://vagishhemmige.github.io/sRtr/reference/apply_srtr_factors.md)
  : Apply SRTR factor labels to a data frame

## Risk and Score Calculators

- [`add_pdri()`](https://vagishhemmige.github.io/sRtr/reference/add_pdri.md)
  : Add Pancreas Donor Risk Index (PDRI)

## Missing data

- [`srtr_normalize_missing()`](https://vagishhemmige.github.io/sRtr/reference/srtr_normalize_missing.md)
  : Normalize Missing Value Representations in SRTR Data

## Time-to-event & composite dates

Helpers for composing event dates and simple TTE calculations

- [`srtr_composite_death()`](https://vagishhemmige.github.io/sRtr/reference/srtr_composite_death.md)
  : Composite death date (OPTN \> SSA \> TFL)
- [`add_txf_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_txf_outcomes.md)
  : Add time-to-event (TTE) follow-up outcomes to a transplant cohort
- [`add_tte_outcomes()`](https://vagishhemmige.github.io/sRtr/reference/add_tte_outcomes.md)
  : Add appropriate TTE outcome variables to a data frame based on the
  df attributes, if the file was loaded using a load function.
- [`srtr_time_to_event()`](https://vagishhemmige.github.io/sRtr/reference/srtr_time_to_event.md)
  : Helper function to add a time-to-event outcome from a date function

## Mapping transplant geography

- [`get_hrsa_transplant_centers()`](https://vagishhemmige.github.io/sRtr/reference/get_hrsa_transplant_centers.md)
  : Download HRSA Organ Procurement & Transplantation Center Locations
- [`get_hrsa_optn_regions()`](https://vagishhemmige.github.io/sRtr/reference/get_hrsa_optn_regions.md)
  : Get OPTN/UNOS Region Boundaries
- [`get_hrsa_opo_service_areas()`](https://vagishhemmige.github.io/sRtr/reference/get_hrsa_opo_service_areas.md)
  : Download HRSA OPO Service Area Boundaries
- [`calculate_geography_coverage_gain()`](https://vagishhemmige.github.io/sRtr/reference/calculate_geography_coverage_gain.md)
  : Calculate net geographic coverage gain from adding new coverage
  areas to an existing coverage base
- [`rank_individual_coverage_gains()`](https://vagishhemmige.github.io/sRtr/reference/rank_individual_coverage_gains.md)
  : Rank individual candidate areas by marginal coverage gain

## Spatial datasets

- [`transplant_centers_sf`](https://vagishhemmige.github.io/sRtr/reference/transplant_centers_sf.md)
  : U.S. Transplant Centers (sf), EPSG:5070
- [`UNOS_regions_sf`](https://vagishhemmige.github.io/sRtr/reference/UNOS_regions_sf.md)
  : UNOS Regions by State (sf), EPSG:5070

## Package data

- [`formats`](https://vagishhemmige.github.io/sRtr/reference/formats.md)
  : SRTR Format Lookup Table
- [`dictionary`](https://vagishhemmige.github.io/sRtr/reference/dictionary.md)
  : SRTR Variable Dictionary
