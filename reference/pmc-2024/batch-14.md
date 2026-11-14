# 2024 PMC annotations: batch 14

Part of the [2024 catalog](../pmc-2024.md); follows the
[annotation scheme](../README.md#literature-annotations).
Only source-reading notes are stored here. Exact SAF mappings are unverified
unless explicitly tagged otherwise.

### PMC10956776

Synthetic lung donor and candidate populations · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC10956776/) ·
doi:10.1371/journal.pone.0296839 · Methods or simulation · 2015–2021 training; hypothetical 2021–2027 projection ·
MT, 2026-11-14

- **Population / unit:** Adult lung candidates and donors aged at least 12 with
  recovered lungs; site-specific counts and synthetic person profiles. [reported
  Methods]
- **Files and fields:** Registry donor/hospital and candidate/center records
  used to fit hierarchical count models and conditional trait distributions;
  exact fields unverified [reported Methods; inference].
- **Data needs:** Preserve dependencies with Bayesian networks and latent
  respiratory indices, rather than sampling columns independently. Validate site
  counts, marginal and joint distributions; distinguish synthetic generation
  from allocation/event simulation. [reported Methods/Discussion] Tags:
  `candidate-registration`, `derived-score`, `policy-era`.
- **Data pitfalls:** Training exclusions, trimming and historical site activity
  affect representativeness. Missing-data exclusion wording conflicts with table
  missingness. Forward populations are scenarios, not validated forecasts;
  synthetic status alone is not a privacy guarantee. [unclear Methods/Tables;
  inference]
- **Locators:** Complete main text read from PMC XML, including network tables.
  Article-linked code: https://github.com/ClevelandClinicQHS/COMET (not
  audited); priors and latent-index supplements not read.

### PMC10942003

Kidney DGF, ischemia and donor quality · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC10942003/) ·
doi:10.3389/ti.2024.12309 · SAF analysis · Finland 2004–2019; SRTR 2014–2019, follow-up September 2020 ·
MT, 2026-11-14

- **Population / unit:** Separate Finnish and US brain-dead donor kidney-only
  cohorts restricted to recipients on dialysis before transplant, excluding
  early nonfunction. [reported Methods]
- **Files and fields:** Donor, transplant, first-week dialysis and graft/death
  records in two independent registries; no patient-level international linkage
  [reported Methods].
- **Data needs:** DGF is first-week dialysis; primary graft survival includes
  death, with death-censored sensitivity. KDPI uses 2019 reference values;
  retain donor clustering, interactions, splines and time-splitting for
  nonproportional hazards. [reported Methods] Tags: `donor-pair`,
  `derived-score`, `follow-up-horizon`.
- **Data pitfalls:** Finland and US age thresholds differ; cohort/event totals
  conflict across narrative and tables. Clarify first-week exclusions and time
  origin before modeling future-observed DGF. The cohort omits DCD and
  preemptive recipients, limiting which donor/recipient records these
  definitions cover. [unclear Methods/Results; inference]
- **Locators:** Complete main text read from PMC XML. Supplemental hazards
  diagnostics, time-split models and original KDPI instructions not inspected.

### PMC10928501

Kidney donation rates using hospital deaths · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC10928501/) ·
doi:10.1001/jamanetworkopen.2024.1865 · External linkage · 2003–2021 ·
MT, 2026-11-14

- **Population / unit:** Aggregate kidney donors compared with potentially
  donation-compatible inpatient deaths under age 76. [reported Methods]
- **Files and fields:** SRTR donor counts combined with CDC Multiple Cause of
  Death data; compatible-cause rules from CMS, not derivable from SAF donor
  records alone [reported Methods].
- **Data needs:** Specify numerator unit and donor deduplication; stratify
  numerator/denominator consistently by year, demographics and state. Rates are
  per 1,000 potential donors, not per all deaths or waitlisted recipients.
  [reported Methods; inference] Tags: `external-linkage`, `geography`,
  `donor-pair`.
- **Data pitfalls:** Supplement is needed for exact death-code exclusions and
  numerator construction. Death certificates are imperfect; Florida state data
  are suppressed. The statement that transplanted-only numerators are unaffected
  by discard warrants caution: utilization can alter donor eligibility/counts.
  [reported Discussion; inference]
- **Locators:** Complete short main text and captions read from PMC XML.
  eMethods, CMS operational definition and cause-code list not independently
  inspected.

### PMC10919340

Cross-organ sex differences in cancer incidence · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC10919340/) ·
doi:10.1093/jnci/djad224 · External linkage · 1995–2017 ·
Screened, 2026-11-14

- **Population / unit:** Adult transplants without prior cancer in covered
  cancer-registry areas; multiple transplant episodes can occur per person.
  [reported Methods]
- **Files and fields:** Transplant Cancer Match links SRTR with 33 cancer
  registries; SEER expected rates, neighborhood deprivation and UV exposure add
  external inputs [reported Methods].
- **Data needs:** Person-time ends at failure/retransplant, death, loss or
  registry coverage end. Poisson incidence comparisons use standardized
  background rates and time-dependent covariates; Kaposi uses pre-HIV-era
  reference rates. [reported Methods] Tags: `external-linkage`,
  `repeat-transplant`, `follow-up-horizon`, `geography`.
- **Data pitfalls:** Cancer-registry diagnoses are not equivalent to SAF
  malignancy flags. Organ type proxies immunosuppression without measured dose;
  repeated episodes and coverage windows require careful handling. [reported
  Methods/Discussion; inference]
- **Locators:** Cached PMC Methods, Results and Discussion read, with missing
  intervening passages; direct page blocked. Complete main text not established:
  Screened. Cancer-site supplement and linkage specification not checked.

### PMC10895807

Liver HCC, Karnofsky and survival origins · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC10895807/) ·
doi:10.1186/s12876-024-03161-7 · SAF analysis · 2011–2017 listing ·
MT, 2026-11-14

- **Population / unit:** Adult primary-HCC liver candidates without previous LT
  and with recorded pretransplant Karnofsky status; transplanted subset for
  recurrence. [reported Methods]
- **Files and fields:** Candidate/status, tumor/exception and
  transplant/death/follow-up records; precise mappings and recurrence algorithm
  unverified [inference].
- **Data needs:** Distinguish listing-origin survival, transplant-origin
  survival, dropout and recurrence. KPS grouped 80–100, 50–70 and 10–40;
  recurrence treats death as competing event. [reported Methods] Tags:
  `candidate-registration`, `status-history`, `post-removal-death`,
  `follow-up-horizon`.
- **Data pitfalls:** Exact KPS measurement time is unclear. Donor covariates in
  listing-origin models require clarification for nontransplanted candidates and
  possible future-information selection. Dropout handling, administrative cutoff
  and referenced recurrence algorithm need verification. Functional status is
  not interchangeable with objective frailty. [unclear Methods/Results;
  inference]
- **Locators:** Complete main text read from PMC XML; Methods,
  survival/recurrence results and Limitations. Prior recurrence papers and
  supplements not inspected.

### PMC10848503

Lung COPD pulmonary vascular resistance and waitlist mortality · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC10848503/) ·
doi:10.1186/s12931-024-02674-9 · SAF analysis · May 2005–December 2022 ·
MT, 2026-11-14

- **Population / unit:** Adult COPD lung candidates with catheterization-defined
  pulmonary hypertension; excludes heart–lung listings. [reported Methods]
- **Files and fields:** Listing hemodynamics, respiratory/support measures,
  transplant and death/removal records; exact mappings and PVR derivation
  unverified [inference].
- **Data needs:** Distinguish pressure, wedge pressure, cardiac output and
  resistance units; separate guideline-derived severe PH from data-derived
  quintile thresholds. Keep baseline measurements distinct from later status
  changes. [reported Methods] Tags: `candidate-registration`, `derived-score`,
  `policy-era`, `follow-up-horizon`.
- **Data pitfalls:** LAS/CAS eras are conflated in the narrative. Every included
  candidate is classified as transplanted/dead; other removals, ongoing waiting
  and censoring need clarification. Substantial missingness and inconsistent
  boundary inequalities require checking before assigning categories. [unclear
  Methods/Results; inference]
- **Locators:** Complete main text read from PMC XML. Original PH guideline,
  allocation-era specifications and supplemental collinearity analysis not
  independently reviewed.
