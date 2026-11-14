# 2024 PMC annotations: batch 03

Part of the [2024 catalog](../pmc-2024.md); follows the
[annotation scheme](../README.md#literature-annotations).
Only source-reading notes are stored here. Exact SAF mappings are unverified
unless explicitly tagged otherwise.

### PMC11880352

Living kidney HLA-DQ heterodimer mismatch · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11880352/) ·
doi:10.1097/TP.0000000000005198 · External linkage · transplants 2010–March 2022; cutoff July 31, 2023 ·
MT, 2026-11-14

- **Population / unit:** Adult primary living-donor kidney recipients from 11
  centers. Unit: donor–recipient pair, with repeated rejection observations.
  [reported Study Population; Rejection]
- **Files and fields:** Center high-resolution HLA typing and NMDP haplotype
  frequencies linked with SRTR outcomes [external; reported Methods]. Exact SAF
  mappings unverified [inference].
- **Data needs:** Construct cis DQαβ heterodimers, not trans combinations or DQB
  antigen counts alone. All-cause graft failure includes death/retransplant;
  death-censored failure censors death. Rejection combines episode, biopsy,
  treatment and failure indicators; repeated records require person clustering.
  [reported HLA Typing and Mismatch; Graft failure; Rejection] Tags:
  `external-linkage`, `living-donor`, `death-source`, `follow-up-horizon`.
- **Data pitfalls:** Rejection reports do not consistently distinguish cellular
  from antibody-mediated rejection; de novo donor-specific antibodies are
  unavailable in SRTR. [reported Discussion] Untreated rejection and missing
  treatment are distinct from no rejection [inference].
- **Locators:** Methods; Results; Discussion. Complete main text read from PMC
  XML; tables/captions and supplements not separately appraised.

### PMC12875400

Lung donor rehabilitation and LUNDON score · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC12875400/) ·
doi:10.1016/j.jtcvs.2024.08.047 · External linkage · donors January 2014–June 2020; one-year recipient survival ·
MT, 2026-11-14

- **Population / unit:** Adult brain-dead donors at three OPOs, including
  unrecovered lungs; unit: donor with initial/final assessments. [reported
  Methods]
- **Files and fields:** SRTR/UNOS plus OPO serial oxygenation, radiology and
  bronchoscopy information [external; reported Methods]. Exact SAF mappings
  unverified [inference].
- **Data needs:** Compute initial/final acceptability scores; outcome is at
  least one lung recovered with transplant intent, not necessarily transplanted.
  Preserve OPO and care setting for recalibration; link transplanted lungs to
  recipient survival. [reported Methods; Results] Tags: `external-linkage`,
  `derived-score`, `follow-up-horizon`.
- **Data pitfalls:** National data lack the full dynamic measurements. Even this
  enhanced dataset lacks exact time between scores; length of stay includes
  terminal admission and donor management. Creatinine and bloodstream infection
  remain single summaries; DCD excluded. [reported Discussion] Do not treat
  score change as a time-standardized rate [inference].
- **Locators:** Methods; Results; Discussion. Complete main text read from PMC
  XML; original derivation coefficients and supplement not appraised, nor
  tables/captions comprehensively.

### PMC11972892

Kidney EHR representativeness and mortality · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11972892/) ·
doi:10.1016/j.ajt.2024.11.008 · SAF analysis · transplants 2014–2022; cutoff December 31, 2022; January 2024 release ·
MT, 2026-11-14

- **Population / unit:** Adult kidney recipients in separate Cosmos and SRTR
  cohorts; no individual cross-database linkage. Unit: transplant/recipient;
  center participation strata. [reported Methods; Discussion]
- **Files and fields:** SRTR transplant and mortality records compared with
  Cosmos Phoenix-derived tables and a public participation list [reported
  Methods]. Exact SAF mappings unverified [inference].
- **Data needs:** Use earliest SRTR death across sources; Cosmos additionally
  censors at last encounter. Preserve the mortality-release lag and center
  participation date. Cosmos dates are person-specifically shifted, preserving
  within-person intervals. [reported Mortality Ascertainment; Statistical
  Analysis] Tags: `death-source`, `follow-up-horizon`, `geography`.
- **Data pitfalls:** Population agreement is not individual outcome validation.
  Race/ethnicity mappings differ; first listed Cosmos race is not necessarily
  primary. Outside-network care/deaths can be absent, and multiorgan
  identification is incomplete. [reported Discussion] Do not infer a
  patient-level linkage from this comparison [inference].
- **Locators:** Methods; Results; Discussion. Complete main text read from PMC
  XML; tables/captions and supplements not separately appraised.

### PMC12094899

Older heart candidates: outcomes from listing · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC12094899/) ·
doi:10.1016/j.healun.2024.11.038 · SAF analysis · listing October 18, 2018–March 1, 2021; follow-up March 2, 2023 ·
MT, 2026-11-14

- **Population / unit:** Candidates ≥65 potentially suitable for durable LVAD;
  excludes existing durable support, retransplants, multiorgan listings and
  specified contraindications. Unit: candidate across listing/transplant
  transitions. [reported Methods]
- **Files and fields:** Candidate/status, removal, transplant and mortality
  records linked across phases; exact mappings unverified [inference].
- **Data needs:** Start at listing and continue through transplant. The
  unfavorable composite includes death, too-ill removal and death within six
  months after removal; other removals censor. Assess a two-year horizon and
  initial status. [reported Methods] Tags: `candidate-registration`,
  `post-removal-death`, `death-source`, `follow-up-horizon`.
- **Data pitfalls:** Freedom from the composite is not pure survival because
  too-ill removal is an event [inference]. Exact reconciliation of the six-month
  removal window with the two-year listing horizon is unstated [unclear
  Methods]. LVAD eligibility lacks unmeasured frailty/social information.
  [reported Discussion]
- **Locators:** Methods; Results; Discussion. Complete main text read from PMC
  XML; tables/captions not separately appraised.

### PMC11930355

Kidney circle allocation and center waiting time · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11930355/) ·
doi:10.1053/j.ajkd.2024.07.014 · SAF analysis · listings March 2017–March 2024; KAS250 boundary March 15, 2021 ·
MT, 2026-11-14

- **Population / unit:** Adult first, single-organ kidney candidates at
  continuously active centers; multiple listings excluded. Unit: candidate with
  time-split follow-up and center grouping. [reported Study Population]
- **Files and fields:** Candidate/removal/transplant records plus January 2021
  SRTR program-specific waiting-time reports [reported Methods]. Exact SAF
  mappings unverified [inference].
- **Data needs:** Policy exposure changes during waiting rather than being fixed
  at listing. Cause-specific transplant hazards censor death, living donation
  and other removals; retain quarterly calendar trend and center interactions.
  [reported Analytical Approach; Statistical Analysis] Tags:
  `candidate-registration`, `policy-era`, `living-donor`, `geography`.
- **Data pitfalls:** Historical center waiting time includes living and deceased
  transplantation, while the outcome is deceased transplantation alone.
  [reported Statistical Analysis; Discussion] Preserve that denominator
  distinction; a post-policy transplant must not classify all preceding waiting
  time as exposed [inference].
- **Locators:** Methods; Results; Discussion. Complete main text read from PMC
  XML; tables/captions and supplements not separately appraised.

### PMC11842210

Colorectal cancer cure models before transplantation · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11842210/) ·
doi:10.1016/j.ajt.2024.08.018 · External linkage · SEER diagnoses 2004–2015; TCM diagnoses 1976–2017 and transplants 1991–2019 ·
MT, 2026-11-14

- **Population / unit:** Adults 20–79 with first colorectal cancer; separate
  model-development and subsequently transplanted cohorts. Unit: person with
  cancer/transplant time origins. [reported Methods]
- **Files and fields:** SEER and SRTR-linked cancer registries supply subsite,
  stage, initial treatment and death-certificate causes [external; reported
  Methods]. Exact SAF mappings unverified [inference].
- **Data needs:** Fit cancer-specific cure models with noncancer deaths
  censored; update five-year cancer-specific survival conditional on surviving
  to evaluation/transplant. Keep staging system and registry-specific death
  coding. [reported Statistical analyses] Tags: `external-linkage`,
  `death-source`, `follow-up-horizon`, `derived-score`.
- **Data pitfalls:** Cancer-specific survival is not recurrence-free or
  all-cause survival [inference]. AJCC6 stage is frequently missing in older
  transplanted cases; treatment is yes versus no/unknown. Diagnosis-to-treatment
  completion is assumed six months for guideline comparisons. [reported Methods;
  Discussion]
- **Locators:** Methods; Results; Discussion. Complete main text read from PMC
  XML; supplements with model specification and tables/captions not separately
  appraised.
