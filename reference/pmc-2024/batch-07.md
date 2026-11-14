# 2024 PMC annotations: batch 07

Part of the [2024 catalog](../pmc-2024.md); follows the
[annotation scheme](../README.md#literature-annotations).
Only source-reading notes are stored here. Exact SAF mappings are unverified
unless explicitly tagged otherwise.

### PMC11530307

Cross-organ sebaceous tumor multi-omics · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11530307/) ·
doi:10.1158/1078-0432.CCR-24-1327 · Case-finding or local source · tumors diagnosed 1999–2021 ·
MT, 2026-11-14

- **Population / unit:** Institutional sebaceous tumor specimens, enriched with
  transplant-recipient cases from Transplant Cancer Match. Unit: tumor/specimen,
  not a national recipient cohort. [reported Sample Acquisition]
- **Files and fields:** TCM links SRTR and cancer registries for case-finding;
  pathology review and sequencing are external laboratory sources [reported
  Methods].
- **Data needs:** Keep specimen, patient and transplant identities distinct;
  preserve histology adjudication and separate availability of
  genome/transcriptome assays. [inference from Methods; Results] Tags:
  `external-linkage`.
- **Data pitfalls:** Molecular signatures and histology are not SAF outcomes
  [not in SAFs]. Enriched specimen selection cannot estimate population cancer
  incidence. Some transplant cases came from institutions rather than TCM.
  [reported Sample Acquisition; inference]
- **Locators:** Sample Acquisition and Approvals; sequencing methods; Results;
  Discussion. Complete main text read from PMC XML; supplemental specimen
  tables, raw data and analysis repositories not inspected.

### PMC12070216

Liver donor age and ACLF severity · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC12070216/) ·
doi:10.5009/gnl230143 · SAF analysis · 2007–2017; follow-up March 1, 2019 ·
MT, 2026-11-14

- **Population / unit:** Adult liver recipients, including ACLF0; excludes
  prior/multiorgan transplant, status 1a, HCC and waiting time over 28 days.
  [reported Study design]
- **Files and fields:** Listing/transplant laboratory values, encephalopathy,
  dialysis, ventilation/vasopressor proxies, donor age and graft/death
  follow-up; exact mappings unverified [inference].
- **Data needs:** Distinguish ACLF at listing from transplantation; separate
  donor-age groups and donor–recipient age combinations. Graft endpoint includes
  failure/retransplantation. [reported Study design] ACLF is assessed at listing
  and transplant: bilirubin ≥12 mg/dL, encephalopathy grade 3–4, INR ≥2.5, and
  creatinine ≥2 mg/dL or dialysis define specified failures; creatinine 1.5–1.9
  defines dysfunction. Vasopressors and ventilation proxy circulatory and
  respiratory failure. Donor-age groups are ≤17, 18–59 and ≥60 [reported Study
  design]. Tags: `derived-score`, `follow-up-horizon`.
- **Data pitfalls:** Ventilation and vasopressors are imperfect organ-failure
  proxies. Death handling in graft survival is unspecified. Membership of the
  weighted analysis cohort needs clarification. Living donors are a small
  minority. [reported Limitations; unclear Study design; Discussion]
- **Locators:** Materials and Methods; Results; Discussion. Complete main text
  read from PMC XML; supplemental weighting and ACLF details not independently
  verified.

### PMC11136601

Cross-organ PHS criteria and organ non-use · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11136601/) ·
doi:10.1097/TP.0000000000004929 · SAF analysis · May 2019–December 2022; policy boundary March 1, 2021 ·
MT, 2026-11-14

- **Population / unit:** Adult deceased donors with at least one
  kidney/liver/heart/lung recovered; excludes HIV/HBV/HCV-positive donors. Units
  differ by organ. [reported §§2.2–2.4] Kidney donors missing serum creatinine
  are excluded [reported §2.4].
- **Files and fields:** Donor infection-risk classification, testing,
  recovery/disposition and recipient/match information; exact mappings
  unverified [inference].
- **Data needs:** Separate recovered-but-unused from overall non-utilization.
  Kidneys are separate observations; a liver or lung donor counts as utilized if
  any part/lung is transplanted. Model policy interaction and secular trend;
  assess donor correlation. [reported §2.4] Kidney models retain individual KDRI
  component factors rather than the composite index [reported §2.4]. Tags:
  `donor-pair`, `cross-organ-link`, `policy-era`.
- **Data pitfalls:** PHS classification itself changes across eras; do not treat
  it as stable biological risk. Denominators exclude potential donors with no
  recovered organ. Policy and COVID changes overlap. [reported Methods;
  Discussion]
- **Locators:** Methods; Results; Discussion. Complete main text read from PMC
  XML; policy table, supplemental models and exact infection-test exclusions not
  independently checked.

### PMC11144558

Cross-organ melanoma before transplantation · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11144558/) ·
doi:10.1016/j.ajt.2024.02.013 · External linkage · TCM coverage 1990–2019; follow-up bounded by registry coverage ·
MT, 2026-11-14

- **Population / unit:** First-transplant non-Hispanic White recipients with
  pretransplant melanoma and at least one year of prior cancer-registry
  coverage. [reported Methods]
- **Files and fields:** SRTR–cancer-registry linkage; death-certificate cause
  from vital statistics/NDI; external SEER8 comparison rates [reported Methods].
  The linkage covers 28 cancer registries and 61% of US recipients in 1990–2019
  [reported Methods].
- **Data needs:** Separate de novo invasive melanoma from melanoma death; use
  sex/age/calendar-specific expected rates for SIR/SMR. Posttransplant melanoma
  enters mortality models as time-dependent exposure. [reported Methods]
  Follow-up also ends at SRTR loss to follow-up [reported Methods]. Tags:
  `external-linkage`, `death-source`, `follow-up-horizon`.
- **Data pitfalls:** Cancer registries do not record recurrence; melanoma
  mortality is only a surrogate. Detailed AJCC stage/Breslow depth unavailable.
  Immunosuppression information is tied to transplant-era practices rather than
  a complete longitudinal dosing history. [reported Discussion; Results]
- **Locators:** Methods; Results; Discussion. Complete main text read from PMC
  XML; cancer-code mappings, tables and supplements not independently checked.

### PMC11149039

Kidney preemptive transplantation and declined offers · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11149039/) ·
doi:10.1681/ASN.0000000000000317 · SAF analysis · 2010–2022 ·
MT, 2026-11-14

- **Population / unit:** Transplanted deceased-donor kidneys with match runs,
  including pediatric and repeat recipients; excludes multiorgan and bypass
  offers. [reported main text]
- **Files and fields:** Match runs linked to candidate and recipient
  dialysis-start information; exact mappings unverified [inference].
- **Data needs:** Preemptive status requires no dialysis-start date in either
  registration source. Group recipients by zero, 1–99 or at least 100 prior
  declined offers. Special allocation categories can overlap. [reported main
  text; Table 1] Tags: `candidate-registration`, `repeat-transplant`,
  `policy-era`.
- **Data pitfalls:** Absence of a dialysis date is the operational definition,
  not confirmation of no dialysis. Transplant-recipient waiting times do not
  represent all waitlisted candidates. Detailed match-run selection and
  definitions remain in unread supplement. [inference; reported Table 1;
  Supplemental Material]
- **Locators:** Complete short main text and Table 1 note read from PMC search
  cache. MT only: supplemental detailed methods and figures not inspected.

### PMC11935462

Lung hypersensitivity pneumonitis and pulmonary hypertension · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11935462/) ·
doi:10.1016/j.jhlto.2024.100157 · SAF analysis · adult listings 2000–2022; follow-up cutoff unspecified ·
MT, 2026-11-14

- **Population / unit:** Adult lung candidates with primary hypersensitivity
  pneumonitis; hemodynamic availability determines analytic subgroups. [reported
  Subjects; Results]
- **Files and fields:** Candidate diagnosis, mPAP/PVR/wedge pressure, lung
  function, walk distance, oxygen requirement and waitlist outcomes; exact
  mappings unverified [inference].
- **Data needs:** Compare combined PH classifications with separate
  pressure/resistance thresholds and adjusted Cox models. Preserve units and
  strict versus inclusive boundaries. [reported Statistical analysis] Tags:
  `candidate-registration`, `derived-score`, `follow-up-horizon`.
- **Data pitfalls:** Threshold wording, PH counts and some units conflict across
  sections. Timing of measurements and transplant/removal censoring are not
  specified. PH treatment and disease subtype unavailable. [unclear
  Methods/Results/Discussion; reported Limitations] Do not copy classifications
  without reconciliation [inference].
- **Locators:** Methods; Results; Discussion, including embedded table text.
  Complete main text read from PMC XML; rendered figures and exact SAF codes not
  independently appraised.
