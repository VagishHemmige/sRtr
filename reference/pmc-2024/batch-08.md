# 2024 PMC annotations: batch 08

Part of the [2024 catalog](../pmc-2024.md); follows the
[annotation scheme](../README.md#literature-annotations).
Only source-reading notes are stored here. Exact SAF mappings are unverified
unless explicitly tagged otherwise.

### PMC11935373

Lung laterality in paired single transplants · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11935373/) ·
doi:10.1016/j.jhlto.2024.100148 · SAF analysis · May 2005–December 2021; September 2022 release; five-year horizon ·
MT, 2026-11-14

- **Population / unit:** Adult single-lung recipients where both donor lungs
  went to eligible recipients; excludes multiorgan transplantation. Unit:
  recipient within donor pair. [reported Methods]
- **Files and fields:** Donor identifier/laterality, transplant and longitudinal
  thoracic follow-up. Article names TFL_ENDTXFU and TFL_LAFUDATE as censoring
  inputs; dictionary mapping unverified [reported Methods].
- **Data needs:** Graft failure includes death; survival models cluster by
  donor. Subgroup analyses retain pairs only when both recipients meet subgroup
  criteria. Separate first-year complications from five-year survival. [reported
  Methods] Mortality uses TFL_ENDTXFU; graft failure uses TFL_ENDTXFU and
  TFL_LAFUDATE [reported Methods]. Tags: `donor-pair`, `repeat-transplant`,
  `follow-up-horizon`.
- **Data pitfalls:** BOS/bronchial-stricture collection stopped around 2020;
  missing follow-up may reflect death, unavailable forms or loss. Exact
  combination of censoring dates needs clarification. Early-death counts differ
  between narrative and table. [reported Table 3; unclear Methods/Results]
- **Locators:** Methods; Results; Discussion and embedded tables. Complete main
  text read from PMC XML; supplements and rendered figures not inspected.

### PMC11003724

Kidney HLA-DQ qualitative mismatch · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11003724/) ·
doi:10.1111/tan.15455 · SAF analysis · SRTR mate kidneys 2010–2021; separate institutional cohorts ·
MT, 2026-11-14

- **Population / unit:** Adult first deceased-donor kidney recipients with both
  kidneys transplanted; excludes other-organ recipients and follow-up under 31
  days. Separate laboratory cohorts assess antibodies. [reported SRTR Registry
  study]
- **Files and fields:** SRTR donor-pair/HLA and graft follow-up; high-resolution
  typing and dnDSA/biopsy data come from external cohorts [reported Methods;
  Results].
- **Data needs:** Death-censored graft-loss Cox models use clustered standard
  errors. Keep allele-level observations distinct from patients, and
  low-resolution evolutionary-group comparisons distinct from molecular mismatch
  predictions. [reported Statistics; Results] Tags: `donor-pair`,
  `follow-up-horizon`.
- **Data pitfalls:** SRTR lacks dnDSA and granular ABMR; low-resolution typing
  cannot test all heterodimer hypotheses. Wording about required molecular
  typing conflicts with acknowledged resolution. Follow-up exclusion conditions
  on early survival. [reported Discussion; unclear Methods; inference]
- **Locators:** Complete main text read from PMC XML, including laboratory and
  SRTR methods. Supplementary registry models, software and HLA mapping details
  not independently checked.

### PMC10947888

Living kidney donor eGFR recovery · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC10947888/) ·
doi:10.1097/XCS.0000000000000970 · SAF analysis · donations 1999–2021; measurements through 24 months ·
MT, 2026-11-14

- **Population / unit:** Adult living kidney donors with pre/post creatinine;
  baseline eGFR below 60 excluded, and postoperative recovery above 99.4%
  removed. [reported Study population]
- **Files and fields:** Living donor baseline and follow-up creatinine, dates,
  BMI and blood pressure; exact mappings unverified [inference].
- **Data needs:** 2021 race-free CKD-EPI estimates at baseline/6/12/24 months;
  recovery is a percentage of personal baseline. Event is first observed
  crossing of 60%/75%; censor at last measurement. [reported Methods] Tags:
  `living-donor`, `derived-score`, `follow-up-horizon`.
- **Data pitfalls:** Observed visit crossing is not exact biological recovery
  time. Missing follow-up and excluded high recovery affect selection; model
  covariate missingness further reduces sample. Strict versus inclusive
  threshold wording differs. [inference; reported Methods/Results] Equation
  coefficients not verified [unclear implementation].
- **Locators:** Methods; Results; Discussion. Complete main text read from PMC
  XML; supplements and eGFR implementation not inspected.

### PMC11910811

Lung opioid exposure and outcomes · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11910811/) ·
doi:10.1016/j.atssr.2024.09.010 · External linkage · 2011–2021 transplants; cutoff October 31, 2022 ·
MT, 2026-11-14

- **Population / unit:** Adult lung-only recipients with linked Symphony
  pharmacy data, covering 74% of recipients. Unit: recipient with longitudinal
  prescription windows. [reported Patients and Methods]
- **Files and fields:** SRTR linked to outpatient pharmaceutical claims;
  dose/fill histories are external [reported Data Source; Opioid Use].
- **Data needs:** Separate six-month pretransplant exposure and posttransplant
  windows; standardize morphine equivalents, distinguish >48-hour ventilation
  from mortality, and preserve propensity/weighting estimands. [reported
  Methods] Tags: `external-linkage`, `follow-up-horizon`.
- **Data pitfalls:** Prescription fills do not establish consumption; inpatient
  opioids and prescribing indications unavailable. Missing pharmacy coverage can
  select patients. Dose-window denominator and weighting/censoring
  implementation require verification. [reported Limitations; inference; unclear
  Statistical Analysis]
- **Locators:** Patients and Methods; Results; Comment. Complete main text read
  from PMC XML, including embedded tables; dose conversion rules and supplements
  not inspected.

### PMC11910802

Lung ECMO bridge to retransplantation · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11910802/) ·
doi:10.1016/j.atssr.2024.09.018 · SAF analysis · May 2005–December 2022; eras split at 2018 ·
MT, 2026-11-14

- **Population / unit:** Adult lung retransplant recipients, excluding
  multiorgan recipients; ECMO subgroup compared by prior/current surgical
  configuration. [reported Study Cohort]
- **Files and fields:** Linked prior/current transplants, laterality, ECMO at
  retransplant, interval and mortality follow-up; exact mappings unverified
  [inference].
- **Data needs:** Distinguish contralateral native-lung transplant from
  ipsilateral allograft replacement and bilateral sequences. Compare one-year
  survival logistic models with overall Cox survival and era-limited follow-up.
  [reported Methods; Figure 2] Tags: `repeat-transplant`, `follow-up-horizon`,
  `policy-era`.
- **Data pitfalls:** Thirty-day boundary wording leaves equality unclear.
  Follow-up completeness for one-year logistic outcomes and administrative
  cutoff are unspecified. Detailed ECMO configuration, ambulation and illness
  severity unavailable. [unclear Methods; reported Comment]
- **Locators:** Patients and Methods; Results; Comment. Complete main text read
  from PMC XML with embedded tables; supplemental analyses and rejection-field
  mapping not independently checked.

### PMC11935449

Lung donor–recipient interactions and prediction · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11935449/) ·
doi:10.1016/j.jhlto.2024.100122 · SAF analysis · February 2015–February 2020; posttransplant follow-up ·
MT, 2026-11-14

- **Population / unit:** Adult primary bilateral lung recipients; model
  comparisons restricted to complete CAS-factor records. [reported Methods;
  Model comparison]
- **Files and fields:** Linked donor/recipient characteristics, serology, size,
  diagnosis and survival records; exact SAF mappings and mismatch definitions
  unverified [inference].
- **Data needs:** Compare donor-interaction Cox/random-forest models with the
  CAS posttransplant model using ten-fold time-dependent AUC, calibration and
  Brier scores. Separate prediction from causal effect estimation. [reported
  Methods; Discussion] Tags: `derived-score`, `follow-up-horizon`.
- **Data pitfalls:** Cardiac-index missingness drives exclusions. Derived-risk
  reconstruction needs the complete predictor set and interaction definitions.
  Some narrative directions differ from table HRs. Serologic mismatch must not
  be assumed to mean only D+/R−. [reported Results/Limitations; inference;
  unclear Table 3]
- **Locators:** Methods; Results; Discussion and embedded tables read from PMC
  XML. Complete main text read; supplemental model specification and code not
  appraised.
