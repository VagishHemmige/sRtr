# 2024 PMC annotations: batch 05

Part of the [2024 catalog](../pmc-2024.md); follows the
[annotation scheme](../README.md#literature-annotations).
Only source-reading notes are stored here. Exact SAF mappings are unverified
unless explicitly tagged otherwise.

### PMC11424273

Kidney en bloc versus single-graft survival · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11424273/) ·
doi:10.1097/TP.0000000000005058 · SAF analysis · December 2020–December 2021 and historical 2010–2012 cohorts ·
MT, 2026-11-14

- **Population / unit:** Deceased-donor kidney-alone transplants; en bloc grafts
  grouped by donor weight versus single kidneys by allocation sequence. Unit:
  transplant graft, not individual kidney. [reported §2]
- **Files and fields:** Transplant procedure, donor weight/KDPI inputs,
  recipient EPTS inputs and graft/death follow-up; exact mappings unverified
  [inference].
- **Data needs:** Death with functioning graft counts as failure. Split hazards
  at 90 days, compare one-year restricted mean survival and historical ten-year
  outcomes; account for center and recipient matching. [reported §§2.2–2.3]
  Tags: `derived-score`, `follow-up-horizon`, `death-source`, `policy-era`.
- **Data pitfalls:** Missing diabetes/hypertension were treated as absent
  [reported §2.1]. Weight groups are sometimes described as age groups in
  narrative headings [unclear §§3–4]; do not substitute age for the weight
  exposure [inference]. Historical long-term outcomes are not post-policy
  follow-up [reported Limitations].
- **Locators:** Methods; Results; Discussion. Complete main text read from PMC
  XML; tables/captions, supplement and linked analysis code not inspected.

### PMC11490384

Heart/lung HCV-offer preferences by center · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11490384/) ·
doi:10.1016/j.jss.2024.07.043 · SAF analysis · active listings 2015–March 8, 2023; September 2023 release ·
MT, 2026-11-14

- **Population / unit:** Adult heart and lung candidates; organ-specific
  analyses and center-level summaries. [reported Study population]
- **Files and fields:** Acceptance-criteria, active waitlist, donor/recipient
  HCV and center/OPO records; exact mappings unverified [inference].
- **Data needs:** Separate candidate willingness from actual HCV-positive
  transplantation and center experience. Annual trends omit partial 2023;
  contemporary center models use 2021–2023 with earlier experience and random
  center intercepts. [reported Methods] Tags: `candidate-registration`,
  `cross-organ-link`, `policy-era`, `geography`.
- **Data pitfalls:** Candidate HCV serostatus unavailable; willingness combines
  antibody-positive and viremic offers. [reported Study population; Discussion]
  Criteria are ascertained from a later release, and historical
  preference-change handling is unstated [unclear Study population].
  Prior-experience windows differ between Methods and Results [unclear
  Center-level willingness; Factors independently associated].
- **Locators:** Patients and Methods; Results; Discussion. Complete main text
  read from PMC XML; tables/captions not separately appraised.

### PMC11620729

Heart donor acceptance prediction · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11620729/) ·
doi:10.1161/CIRCHEARTFAILURE.123.011360 · SAF analysis · DHS February 2015–May 2020; SRTR February 2005–May 2020 ·
MT, 2026-11-14

- **Population / unit:** Potential donors aged 18–65 with recorded LVEF; DCD and
  prior myocardial infarction excluded. Separate DHS training/validation and
  national SRTR cohorts. [reported Cohort definitions]
- **Files and fields:** SRTR donor/acceptance records versus a more detailed
  prospective DHS cohort [reported Data sources]. Lactate, NT-proBNP and LV
  hypertrophy unavailable in national cohort [reported Variables].
- **Data needs:** Use measurements at donor-management start; exclude coronary
  angiography from prediction because it may be obtained later. Preserve
  separate inference/prediction covariate sets, imputation and temporal
  validation. [reported Methods] Tags: `derived-score`, `policy-era`.
- **Data pitfalls:** The model predicts acceptance practices, not recipient
  survival or organ suitability. National trend analysis is not external
  validation of the DHS model; important DHS predictors are absent from SRTR.
  [reported Methods; Discussion]
- **Locators:** Methods; Results; Discussion. Complete main text read from PMC
  XML; tables/captions and supplement not separately appraised. Web calculator
  not inspected.

### PMC11350102

Pediatric kidney waitlisting and activation · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11350102/) ·
doi:10.1542/peds.2024-065934 · SAF analysis · waitlist additions 2015–2019; follow-up cutoff unverified ·
Screened, 2026-11-14

- **Population / unit:** Candidates aged 3–17 at listing, plus adults whose
  dialysis began before age 18. Unit: candidate. [reported Methods Parts 1–2]
- **Files and fields:** Candidate registration, dialysis onset,
  activation/status and transplant/removal records; exact mappings unverified
  [inference].
- **Data needs:** Distinguish listing before dialysis from preemptive
  transplantation. Compare time from listing and first activation; transplant
  includes living/deceased donors, with death/removal competing. [reported
  Statistical Analysis Parts 1–2] Tags: `candidate-registration`,
  `status-history`, `living-donor`.
- **Data pitfalls:** Missing PRA is assumed below the high-PRA threshold.
  Specific removal exclusions are in the unread supplement. [reported Methods]
  Age at dialysis initiation and age at listing must be calculated separately
  [inference].
- **Locators:** Abstract and main Methods/selected Results from PMC search
  cache; direct retrieval returned a browser check. Complete main text not
  established; remains Screened. Supplemental exclusions and tables not
  appraised.

### PMC11375524

Liver HCC exception, sex and size · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11375524/) ·
doi:10.1001/jamasurg.2024.3498 · SAF analysis · adult listings January 2010–March 2023; cutoff unverified ·
Screened, 2026-11-14

- **Population / unit:** Adult liver candidates receiving HCC exceptions. Unit:
  candidate. [reported Abstract; Study Population]
- **Files and fields:** Candidate/exception, body-size, transplant and removal
  records; exact mappings unverified [inference].
- **Data needs:** Distinguish exception-based allocation from laboratory MELD
  and retain size alongside sex. Outcomes are deceased-donor transplantation and
  death/health-deterioration removal, analyzed with competing risks. [reported
  Abstract] Tags: `candidate-registration`, `derived-score`,
  `follow-up-horizon`.
- **Data pitfalls:** The retrieved abstract does not specify size
  transformations, exception time origin, missing-data handling or exact
  censoring; these remain unverified [unclear Abstract]. Do not equate a sex
  comparison with a size-matched analysis [inference].
- **Locators:** PMC abstract and opening Methods passages from search cache;
  direct retrieval returned a browser check. Full Methods/Results/Discussion,
  tables and supplements not read; Screened only.

### PMC11421570

Kidney longevity matching and EPTS · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11421570/) ·
doi:10.1053/j.ajkd.2024.02.017 · SAF analysis · listings 2015–2020; follow-up February 2023; five-year posttransplant horizon ·
MT, 2026-11-14

- **Population / unit:** Adult kidney candidates; multiple registrations
  collapsed into unique candidates. Unit: candidate, then longevity-matched
  recipient. [reported Methods; Results]
- **Files and fields:** Candidate EPTS components, donor KDPI, status/removal,
  graft and death records; exact mappings unverified [inference].
- **Data needs:** Raw EPTS is mapped using the 2023 reference table. Distinguish
  initial priority from loss of priority; higher-KDPI transplant, death and
  delisting compete with low-KDPI transplant; living donation censors. [reported
  Methods] Tags: `candidate-registration`, `derived-score`, `living-donor`,
  `death-source`, `follow-up-horizon`.
- **Data pitfalls:** Unknown diabetes is treated as absent. OPTN-verified deaths
  may undercount mortality. [reported EPTS calculation; Limitations] The
  last-inactive-status censoring rule and registration-collapse details need
  clarification before reuse [unclear Statistical Analysis; Results].
- **Locators:** Methods; Results; Discussion. Complete main text read from PMC
  XML; percentile-table contents, equations, tables/captions, supplements and
  linked code not independently appraised.
