# 2024 PMC annotations: batch 13

Part of the [2024 catalog](../pmc-2024.md); follows the
[annotation scheme](../README.md#literature-annotations).
Only source-reading notes are stored here. Exact SAF mappings are unverified
unless explicitly tagged otherwise.

### PMC11146644

Kidney offer bypass filters · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11146644/) ·
doi:10.34067/KID.0000000000000423 · External linkage · January 2021, April 2021 and April 2022 snapshots ·
MT, 2026-11-14

- **Population / unit:** Active adult kidney centers with recorded filter
  settings; distinct center-month and candidate-offer units. [reported Methods]
- **Files and fields:** UNOS center filter settings linked to SRTR kidney offer
  records; filter-settings availability is separate from routine SAFs [reported
  Methods; inference].
- **Data needs:** Center offer volume counts donors with logged responses;
  bypass proportion counts candidate-level declines. Openness uses January 2021
  medians for continuous filters. Reported refusal codes 883/886 require
  dictionary verification. [reported Methods] Tags: `policy-era`,
  `candidate-registration`, `external-linkage`.
- **Data pitfalls:** Do not conflate donor offers, candidate offers and filter
  settings. Consecutive-period changes have different baselines; month snapshots
  do not supply continuous filter histories. These are historical KiMAC filters,
  not automatically interchangeable with later filter products. [inference]
- **Locators:** Complete short main text and caption read from PMC XML.
  Supplemental region table and prior filter-score specification not inspected.

### PMC11118653

Heart atrial fibrillation and pharmacy linkage (preprint) · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11118653/) ·
doi:10.1101/2024.05.14.24307382 · External linkage · July 2012–July 2021 ·
Screened, 2026-11-14

- **Population / unit:** Adult heart recipients represented in both SRTR and
  Symphony Health pharmacy data. [reported Abstract Methods]
- **Files and fields:** External prescription fills linked to SRTR; AF
  classification is medication-derived rather than a verified standalone SAF
  diagnosis [reported Abstract; inference].
- **Data needs:** Distinguish pretransplant AF exposure, subsequent AF,
  predischarge stroke/dialysis and mortality horizons. Full-text drug lists,
  lookback windows, dose calculations and linkage completeness are required
  before reproducing classification. [reported Abstract; inference] Tags:
  `external-linkage`, `follow-up-horizon`.
- **Data pitfalls:** A medication proxy may capture other indications; absence
  of a fill need not mean absence of AF. Catalog entry is a preprint, not
  established peer-reviewed evidence. [inference; observed PMC record]
- **Locators:** PMC abstract and availability notice read. PMC does not archive
  full text under this preprint license; linked publisher retrieval failed.
  Screened only, no full-read claim.

### PMC11073772

Liver recovery, discard and nonuse · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11073772/) ·
doi:10.1097/TXD.0000000000001605 · SAF analysis · January 2010–December 1, 2021 ·
MT, 2026-11-14

- **Population / unit:** Deceased-donor liver opportunities classified as
  nonrecovered, recovered/discarded or transplanted. [reported Methods]
- **Files and fields:** Deceased Donor file; article names LI_DISCARD_CD_OSTXT,
  ECD_DONOR and NON_HRT_DONOR for recoding/classification, not independently
  dictionary-verified. [reported Methods]
- **Data needs:** Discard denominator is recovered livers; nonrecovery uses
  donor opportunities. DCD takes precedence over ECD. Free-text reasons refine
  coded other categories; geography uses transplant regions. [reported Methods]
  Tags: `geography`, `derived-score`.
- **Data pitfalls:** Registry donors are not all potential hospital donors.
  Reasons for nonrecovery, research allocation and discard require distinct
  handling; text classification lacks a reproducible codebook. Equal-width rate
  bins are called tertiles, and some narrative percentages conflict with tables.
  Do not infer discarded organs were transplantable. [unclear Methods/Results;
  inference]
- **Locators:** Complete main text read from PMC XML, Methods through
  Discussion. Free-text recoding rules and original donor-category definitions
  not independently checked.

### PMC11104730

Kidney early graft loss across KDPI · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11104730/) ·
doi:10.1097/TXD.0000000000001636 · SAF analysis · January 2014–September 2020; one-year horizon ·
MT, 2026-11-14

- **Population / unit:** Deceased-donor kidney recipients with complete analyzed
  predictors; repeated transplants retained. [reported Methods/Results]
- **Files and fields:** Donor KDPI/KDRI, recipient history, transplant and
  failure/death follow-up; donor identifiers preserve paired kidneys [reported
  Methods].
- **Data needs:** Early graft loss is retransplantation or return to dialysis;
  secondary outcome adds death. Continuous-treatment weighting, restricted cubic
  splines, balance/positivity assessment and donor-clustered errors are distinct
  steps. [reported Methods] Tags: `donor-pair`, `repeat-transplant`,
  `derived-score`, `follow-up-horizon`.
- **Data pitfalls:** Weighting assumes a KDPI treatment-density model;
  associations are restricted to transplanted organs. Clarify KDPI vintage, ≥95
  versus >95 matching threshold, and distinction between competing-risk curves
  and death-censored Cox estimates. Missing follow-up must not be treated as
  event-free through one year. [unclear Methods; inference]
- **Locators:** Complete main text read from PMC XML. Supplemental DAG,
  weighting diagnostics and KDRI sensitivity code not inspected.

### PMC11020014

Cross-organ immunosuppression and posttransplant diabetes · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11020014/) ·
doi:10.1097/JS9.0000000000001135 · SAF analysis · Cohort dates not specified in retrieved main text ·
MT, 2026-11-14

- **Population / unit:** Reported liver, kidney, heart, lung, heart–lung,
  intestine and very small pancreas groups; exact eligibility and
  baseline-diabetes exclusions unclear. [reported/unclear Methods]
- **Files and fields:** Medication indicators, diabetes and mortality records
  implied; no reproducible SAF field mapping supplied [inference].
- **Data needs:** Separate drug ingredient, formulation, induction versus
  maintenance, exposure timing and incident-diabetes ascertainment. Article
  reports Kaplan–Meier, Cox and logistic analyses but binary drug use without
  duration. [reported Methods/Limitations] Tags: `cross-organ-link`,
  `status-history`, `follow-up-horizon`.
- **Data pitfalls:** ADA criteria are cited without explaining their
  implementation in registry fields. Future-defined diabetes/exposure requires
  dated records rather than baseline ever/never flags. Unusual pancreas
  demographics need reconciliation with cohort eligibility. Drug indicators do
  not establish duration, combinations or treatment indication. [unclear
  Methods/Results; inference]
- **Locators:** Complete main text read from PMC XML, including tables and
  limitations. Supplemental model details and diagnostic/drug code mappings not
  checked.

### PMC11000741

Living kidney donor required weight loss · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11000741/) ·
doi:10.34067/KID.0000000000000381 · External linkage · Donations 1979–2020 in analyzed cohort ·
MT, 2026-11-14

- **Population / unit:** Consenting survey respondents who were obese at
  donation, across 53 centers; unit is donor with center-year context. [reported
  Methods]
- **Files and fields:** Survey/medical records linked to SRTR living-donor data;
  center-year transplant totals and median donor BMI derived from registry
  records [reported Methods].
- **Data needs:** Outcome is reported requirement to lose weight, not actual
  weight loss. Aggregate center metrics before donor linkage; use
  center-clustered logistic GEE and imputation sensitivity. [reported Methods]
  Tags: `living-donor`, `external-linkage`.
- **Data pitfalls:** Rejected candidates and donors who reduced BMI below
  eligibility threshold are not represented. Missing metabolic components are
  assumed absent in primary scoring; reported count range needs reconciliation
  with listed components. Recall/survivor bias and uncertain source precedence
  limit interpretation. [reported Methods/Limitations; inference]
- **Locators:** Complete main text read from PMC XML, Data Sources through
  Discussion. Survey instrument, supplemental imputation model and record
  reconciliation rules not inspected.
