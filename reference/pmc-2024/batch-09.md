# 2024 PMC annotations: batch 09

Part of the [2024 catalog](../pmc-2024.md); follows the
[annotation scheme](../README.md#literature-annotations).
Only source-reading notes are stored here. Exact SAF mappings are unverified
unless explicitly tagged otherwise.

### PMC11935327

Heart and heart–kidney mechanical support · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11935327/) ·
doi:10.1016/j.jhlto.2024.100071 · SAF analysis · 2015–2021; policy boundary October 18, 2018 ·
MT, 2026-11-14

- **Population / unit:** Adult heart-only and combined heart–kidney recipients,
  stratified by allocation era and temporary/durable mechanical support.
  [reported Methods]
- **Files and fields:** Thoracic transplant/support, kidney co-transplant
  indicators, rejection/dialysis and death follow-up; exact mappings unverified
  [inference].
- **Data needs:** Preserve organ-combination definition and era-specific status
  categories. Distinguish temporary devices from durable LVADs and model
  posttransplant survival separately from recorded complications. [reported
  Methods] Tags: `cross-organ-link`, `policy-era`, `follow-up-horizon`.
- **Data pitfalls:** Methods, Results and table captions disagree on
  June/December cohort end and six-month/one-year endpoints. Rejection
  missingness is substantial; device/dialysis duration and rejection type are
  unavailable. [unclear Methods/Table 3; reported Limitations] Resolve before
  translating outcome definitions [inference].
- **Locators:** Materials and methods; Results; Discussion and embedded tables.
  Complete main text read from PMC XML; supplements and exact device codes not
  checked.

### PMC11910819

Lung LAM and sirolimus timing · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11910819/) ·
doi:10.1016/j.atssr.2024.07.011 · External linkage · January 2005–May 2021; cutoff May 30, 2021 ·
MT, 2026-11-14

- **Population / unit:** Adult first lung-only recipients; LAM versus other
  diagnoses, then LAM recipients with documented sirolimus prescriptions.
  [reported Methods]
- **Files and fields:** SRTR linked to Symphony pharmacy claims for prescription
  dates; mortality supplemented by death-file linkage [reported Data Source].
- **Data needs:** Separate diagnostic-cohort survival from drug-user subgroup
  survival. Pretransplant initiation includes recipients treated both before and
  after transplant; post-only users initiate later. [reported Subgroup Analysis]
  Tags: `external-linkage`, `death-source`, `follow-up-horizon`.
- **Data pitfalls:** Post-only classification uses future prescriptions,
  creating potential immortal time if survival begins at transplant without
  delayed entry/time-varying exposure. Claims capture is incomplete and fills do
  not prove adherence. [inference from Methods; reported Limitations]
- **Locators:** Methods; Results; Comment. Complete main text read from PMC XML;
  supplements and prescription linkage algorithm not inspected.

### PMC11935422

Lung AAT augmentation after transplantation · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11935422/) ·
doi:10.1016/j.jhlto.2024.100201 · External linkage · 2011–2021; pharmacy data through 2021 ·
MT, 2026-11-14

- **Population / unit:** Adult AAT-deficiency lung recipients with pharmacy
  data; excludes perioperative/early deaths. Post-treatment comparison uses
  continuers/new starters versus discontinuers. [reported Methods]
- **Files and fields:** SRTR linked to external prescription fills; article
  reports diagnosis code 1606, not independently codebook-verified [reported
  Study population].
- **Data needs:** All-cause graft failure combines death, failure and
  retransplantation. Delayed entry is three months posttransplant or first
  posttransplant prescription, whichever later for treated recipients. [reported
  Outcomes] Tags: `external-linkage`, `follow-up-horizon`, `death-source`.
- **Data pitfalls:** Early-death exclusion uses discharge-based wording while
  entry uses transplant-based wording. One prescription assumes indefinite
  treatment. Age-binned mean survival estimation does not specify handling of
  censored times; bilirubin is an imperfect disease proxy. [unclear Methods;
  reported Limitations]
- **Locators:** Methods; Results; Discussion and embedded tables. Complete main
  text read from PMC XML; supplement, medication definitions and estimation code
  not inspected.

### PMC10877505

Kidney residential and center segregation · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC10877505/) ·
doi:10.1001/jamainternmed.2023.8184 · External linkage · 1995–2021; maximum three years from listing ·
Screened, 2026-11-14

- **Population / unit:** First-time adult Black/White kidney candidates,
  including non-listed living-donor recipients; complete-case primary analysis.
  [reported Methods]
- **Files and fields:** SRTR linked by residential and center ZIP to ACS
  five-year estimates; Theil H neighborhood segregation [reported Methods].
- **Data needs:** Assign non-listed recipients one day of waiting; distinguish
  residential versus center thresholds and compare cause-specific,
  competing-risk and center-frailty analyses. [reported Access; Sensitivity
  Analysis] Tags: `external-linkage`, `geography`, `living-donor`,
  `candidate-registration`.
- **Data pitfalls:** Preemptive transplant is listed as a separate competing
  endpoint, requiring mutually exclusive outcome clarification. ZIP/ZCTA
  measures are ecological; historical ACS alignment and full score construction
  need checking. [unclear Methods; reported Limitations]
- **Locators:** PMC cached Methods, selected Results and Limitations; direct
  retrieval blocked by browser check. Complete main text not established:
  Screened. Supplementary score formula not read.

### PMC11359088

Living kidney donor perioperative mortality · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11359088/) ·
doi:10.1001/jama.2024.14527 · SAF analysis · 1993–2022; 90-day endpoint ·
MT, 2026-11-14

- **Population / unit:** Living kidney donors stratified across three ten-year
  eras. Unit: donation/donor. [reported Methods]
- **Files and fields:** Donor records and deaths from program follow-up, Limited
  Access Death Master File and verified CMS/HRSA sharing [reported Methods].
  Availability of all death sources in a routine extract needs verification
  [inference].
- **Data needs:** Exact binomial intervals and Fisher tests for rare events;
  restrict procedure/BMI analyses to 1999 onward and hypertension to 2004 onward
  when capture was reliable. [reported Methods] Tags: `living-donor`,
  `death-source`, `follow-up-horizon`, `policy-era`.
- **Data pitfalls:** Ninety-day death is all-cause, not necessarily
  donation-attributable. Few events preclude adjusted modeling; follow-up
  requirements changed over time. [inference; reported Methods/Discussion] Table
  age-category denominators merit reconciliation before reuse [unclear Table].
- **Locators:** Complete short main text, table and caption read from PMC search
  cache; source death linkage and supplemental data-sharing statement not
  inspected.

### PMC11793170

Kidney out-of-sequence allocation · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11793170/) ·
doi:10.34067/KID.0000000640 · SAF analysis · 2018–2023; KAS250 boundary March 2021 ·
MT, 2026-11-14

- **Population / unit:** Transplanted deceased-donor kidneys excluding
  Hawaii/Puerto Rico procurement or transplant sites. Unit: kidney, with
  OPO/center summaries. [reported Methods]
- **Files and fields:** Match runs linked to donor and recipient data; article
  reports prior-offer codes 861/862/863 for OOS, not independently
  codebook-verified [reported Methods].
- **Data needs:** Identify OOS codes before acceptance; compare interrupted
  trends by KDPI, using all transplanted kidneys as denominator. Preserve
  paired-kidney and OPO/center aggregation distinctions. [reported Methods;
  Figure 1] Tags: `donor-pair`, `policy-era`, `geography`.
- **Data pitfalls:** Missing process timestamps and unsuccessful OOS attempts
  among unused kidneys prevent efficiency estimates. Travel/access and
  neighborhood measures require additional derivation/source checking. Unused
  organs and unsuccessful attempts would be needed to study nonuse. [reported
  Discussion; inference]
- **Locators:** Methods; Results; Discussion and embedded table. Complete main
  text read from PMC XML; supplemental geography derivations and code
  definitions not independently checked.
