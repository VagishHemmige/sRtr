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
  The study counts 91 filters and analyzes 192 centers after excluding 38
  pediatric centers, 38 with no deceased-donor transplants in 2021/2022 and 10
  with no filter settings; bypasses for reasons outside the center's control are
  dropped. [reported main text]
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
  PTR offer/refusal codes are outside this bundled dictionary's coverage; verify 883/886 against the offer-data documentation, not ordinary SAF formats. Absence from that dictionary alone does not prove the data are unavailable. [dictionary: sRtr::dictionary at 8e73993, checked by Claude; not independently verified here]

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
  The paper's LI_DISCARD_CD_OSTXT, ECD_DONOR and NON_HRT_DONOR are absent from the bundled snapshot. It instead contains per-organ DONOR_DISPOSITION fields DON_ORG, DON_DISPOSITION, DON_DISCARD_CD and DON_REASON_CD; DON_NON_HR_BEAT is the DCD flag, and no ready ECD flag is present. These are not automatically interchangeable with the paper's release. [dictionary: sRtr::dictionary at 8e73993, checked by Claude; not independently verified here]

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
  n = 89,290 analyzed; retransplants are 12.4%; complete-case analysis with 2.1%
  missing. [reported Data; Table 1; Statistical Analysis]
- **Files and fields:** Donor KDPI/KDRI, recipient history, transplant and
  failure/death follow-up; donor identifiers preserve paired kidneys [reported
  Methods].
- **Data needs:** Early graft loss is retransplantation or return to dialysis;
  secondary outcome adds death. Continuous-treatment weighting, restricted cubic
  splines, balance/positivity assessment and donor-clustered errors are distinct
  steps. [reported Methods] Tags: `donor-pair`, `repeat-transplant`,
  `derived-score`, `follow-up-horizon`.
  The described KDPI includes donor race for this 2014–2020 cohort; loss to follow-up censors as alive with a functioning graft at center reporting. [reported Variables and Predictors; Statistical Analysis; source checked by Claude, 2026-11-14]

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
  Group sizes: LT 87,763; KT 214,935; IT 2,047; PA 68; HT 37,962; LU 23,904; HL
  535. Table 1 gives the PA group mean age 2.4 years and mean weight 11.6 kg, so
  pediatric recipients appear to be included. [reported Results; Table 1;
  inference]
- **Files and fields:** Medication indicators, diabetes and mortality records
  implied; no reproducible SAF field mapping supplied [inference].
  Brand and generic drug names are listed in Definition of terms, providing the source for medication-class mapping. [reported Definition of terms; source checked by Claude, 2026-11-14]

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
doi:10.34067/KID.0000000000000381 · External linkage · Donations 1976–2020 in Data Sources versus 1979–2020 in Study Population (unresolved) in analyzed cohort ·
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
  The outcome is a yes to any of three survey questions (asked to lose weight
  before approval, after approval, or required to have weight-loss surgery).
  Metabolic thresholds: glucose >100 mg/dL or HbA1c >5.6; BP ≥130/80;
  triglycerides >150; HDL <40 (men) or <50 (women). [reported Outcomes and
  Exposures]
- **Data pitfalls:** Rejected candidates and donors who reduced BMI below
  eligibility threshold are not represented. Missing metabolic components are
  assumed absent in primary scoring; reported count range needs reconciliation
  with listed components. Recall/survivor bias and uncertain source precedence
  limit interpretation. [reported Methods/Limitations; inference]
  The donation period conflicts between Data Sources (September 1976–May 2020) and Study Population (1979–2020). [unclear Data Sources; Study Population; source checked by Claude, 2026-11-14]

- **Locators:** Complete main text read from PMC XML, Data Sources through
  Discussion. Survey instrument, supplemental imputation model and record
  reconciliation rules not inspected.
