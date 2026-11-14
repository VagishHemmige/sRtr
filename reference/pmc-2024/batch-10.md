# 2024 PMC annotations: batch 10

Part of the [2024 catalog](../pmc-2024.md); follows the
[annotation scheme](../README.md#literature-annotations).
Only source-reading notes are stored here. Exact SAF mappings are unverified
unless explicitly tagged otherwise.

### PMC10857737

Pediatric kidney paired donation · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC10857737/) ·
doi:10.1111/petr.14657 · External linkage · February 2008–December 2021; follow-up June 2022 ·
MT, 2026-11-14

- **Population / unit:** Recipients younger than 18 at kidney transplantation;
  excludes multiorgan transplants. [reported Methods]
- **Files and fields:** SRTR transplant/follow-up linked to National Kidney
  Registry; encrypted identifiers checked against transplant date, blood group
  and sex [reported Methods].
- **Data needs:** KPD combines reported relationship codes 9/11/12 with NKR
  confirmation; these codes are not dictionary-verified here. Death-censored
  failure includes maintenance dialysis, relisting or retransplantation.
  Multiple imputation, stabilized/truncated weighting and center-stratified Cox
  models require separate preparation steps. [reported Methods] Tags:
  `external-linkage`, `living-donor`, `death-source`.
- **Data pitfalls:** Nondirected donation alone does not establish KPD. Listing
  age differs from transplant age. Results/Discussion disagree on KPD counts and
  DGF significance; resolve before reusing counts. [inference; unclear
  Results/Discussion]
- **Locators:** Complete main text read from PMC XML: Methods, Results,
  Discussion. Supplement, exact relationship codes and score formulas not
  checked.

### PMC11699630

Heart CHARM waitlist prediction · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11699630/) ·
doi:10.1016/j.jacadv.2024.101449 · SAF analysis · 2017–September 2, 2023 ·
MT, 2026-11-14

- **Population / unit:** Adult single-organ heart candidates with sufficient
  laboratory data; random training/test split. [reported Methods]
- **Files and fields:** Candidate characteristics, support devices, laboratory
  measurements and removal/death history; exact file/field mapping unverified
  [inference].
- **Data needs:** Preserve BNP versus NT-proBNP distinction, laboratory
  transformations and separate ECMO/life-support indicators. Endpoint combines
  death with too-ill removal; prediction horizons range from 90 days to two
  years. [reported Methods] Tags: `candidate-registration`, `status-history`,
  `derived-score`, `follow-up-horizon`.
- **Data pitfalls:** Extensive missing laboratories and discontinued collection
  restrict representativeness. Binary-horizon handling of incomplete follow-up
  and transplantation is insufficiently clear. Internal holdout performance is
  not external validation; coefficients, log bases and inverse-link
  transformation require verification before implementation. [reported
  Limitations; unclear Methods; inference]
- **Locators:** Complete main text read from PMC XML, including model equations
  and Discussion; supplemental calculations and code not checked.

### PMC11661731

Liver donor cardiac arrest and resuscitation · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11661731/) ·
doi:10.1097/AS9.0000000000000522 · SAF analysis · 2003–2022 ·
MT, 2026-11-14

- **Population / unit:** Adult recipients of donation-after-brain-death livers,
  compared by donor cardiac arrest and resuscitation duration. [reported
  Methods]
- **Files and fields:** Donor arrest/CPR duration, recipient/transplant and
  graft/death follow-up; exact mappings unverified [inference].
- **Data needs:** Cardiac arrest time is total CPR time between first medical
  contact and procurement, not DCD warm ischemia. Early failure uses a 90-day
  horizon; overall failure includes death. [reported Methods] Tags:
  `follow-up-horizon`, `derived-score`.
- **Data pitfalls:** Failure-date wording includes relisting/death and needs
  reconciliation with recorded graft failure. Matching-score construction
  appears to use early-failure predictors; clarify propensity versus prognostic
  scoring. The ROC-derived 30-minute boundary and conflicting matched-outcome
  statements need checking. Selected transplanted donors cannot establish
  protective preconditioning causally. [unclear Methods/Results; inference]
- **Locators:** Complete main text read from PMC XML: Methods, Results,
  Discussion. DRI original specification, supplements and matching code not
  checked.

### PMC11606542

HOPE kidney safety and noninferiority · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11606542/) ·
doi:10.1056/NEJMoa2403733 · External linkage · 2018–September 2021 enrollment; one to four years follow-up ·
MT, 2026-11-14

- **Population / unit:** Prospective multicenter HIV-positive kidney recipients
  receiving HIV-positive or HIV-negative donor organs. [reported Methods]
- **Files and fields:** Clinical study data linked to SRTR for completeness;
  viral load, genotyping, opportunistic-infection adjudication and detailed
  safety events require external study records [reported Methods; not in SAFs].
- **Data needs:** Confirm donor HIV status after false-positive allocation
  tests. Protocol graft failure includes prolonged renal replacement,
  nephrectomy or retransplant; composite safety additionally includes death,
  serious events and HIV/infectious outcomes. [reported Methods] Tags:
  `external-linkage`, `follow-up-horizon`.
- **Data pitfalls:** Study-specific noninferiority margin and composite endpoint
  are not general safety defaults or evidence of equivalence for each component.
  Distinguish protocol graft failure from death-inclusive graft survival.
  Registry-only replication cannot reproduce adjudicated outcomes. [inference]
- **Locators:** Complete main text read from PMC XML; Methods, Results,
  Discussion. Linked protocol/supplement and adjudication specifications not
  fully inspected.

### PMC11581662

Cross-organ CMV serostatus and deprivation · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11581662/) ·
doi:10.1001/jamanetworkopen.2024.37878 · External linkage · 2008–May 2022 ·
MT, 2026-11-14

- **Population / unit:** First adult transplant recipients across organs;
  excludes repeat transplantation, missing serology and multiple-donor organ
  combinations. [reported Methods]
- **Files and fields:** SRTR linked to 2017 Social Deprivation Index using
  ZIP/ZCTA crosswalks and 2013 county rurality [reported Methods].
- **Data needs:** Separate baseline recipient seropositivity from posttransplant
  CMV infection. Preserve organ-combination categories, geography vintage and
  interactions; imputation applies to covariates. [reported Methods] Tags:
  `cross-organ-link`, `repeat-transplant`, `external-linkage`, `geography`.
- **Data pitfalls:** Reported logit models and prevalence-ratio terminology need
  reconciliation before translating effects. Missing-ZIP exclusion wording
  appears inconsistent with reported availability. Area deprivation is
  ecological and a fixed vintage may poorly describe earlier residence. [unclear
  Methods; inference]
- **Locators:** Complete main text read from PMC XML: Methods, Results and
  Discussion. Supplementary geographic crosswalks and effect-estimation code not
  inspected.

### PMC11576004

Liver risk-score comparison · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11576004/) ·
doi:10.1097/TXD.0000000000001724 · SAF analysis · 2002–2021 ·
MT, 2026-11-14

- **Population / unit:** Adult first whole-liver recipients with exclusions for
  multivisceral transplantation, ABO incompatibility and selected malignancies.
  [reported Methods]
- **Files and fields:** Recipient/transplant, donor and mortality follow-up for
  LTRS, P-SOFT, SOFT, BAR, D-MELD and ORPS; exact mappings unverified
  [inference].
- **Data needs:** Separate preoperative recipient-only predictors from
  donor/ischemia inputs available later. Compare horizon-specific
  discrimination, calibration and risk categories; mortality observation censors
  at retransplantation. [reported Methods] Tags: `derived-score`,
  `repeat-transplant`, `follow-up-horizon`.
- **Data pitfalls:** Minimum one-year-follow-up eligibility needs clarification
  to exclude survivor selection. Original score coefficients, MELD bounds and
  dialysis rules require source verification. Similar performance or
  nonsignificant differences do not establish formal noninferiority; risk labels
  are study-specific. [unclear Methods; inference]
- **Locators:** Complete main text read from PMC XML: Methods through
  Conclusions. Original score publications and calibration supplements not
  checked.
