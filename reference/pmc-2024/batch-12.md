# 2024 PMC annotations: batch 12

Part of the [2024 catalog](../pmc-2024.md); follows the
[annotation scheme](../README.md#literature-annotations).
Only source-reading notes are stored here. Exact SAF mappings are unverified
unless explicitly tagged otherwise.

### PMC11332371

Liver counterfactual prediction validation · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11332371/) ·
doi:10.1097/EDE.0000000000001713 · Methods or simulation · Liver example: January 2014–April 2019 listing ·
MT, 2026-11-14

- **Population / unit:** Liver candidates represented by transplant-origin and
  repeated waitlist-landmark records; outcome is death/health-related removal.
  [reported Application]
- **Files and fields:** Candidate/status histories, longitudinal biomarkers,
  transplant/removal/death dates; validation additionally needs confounders
  beyond prediction inputs [reported Methods].
- **Data needs:** Artificially censor deviations from transplant/no-transplant
  strategies and estimate censoring weights in validation data. Evaluate
  counterfactual calibration, discrimination and Brier scores under
  exchangeability, positivity, consistency and model assumptions. [reported
  Methods] Tags: `candidate-registration`, `status-history`,
  `follow-up-horizon`.
- **Data pitfalls:** Observed strategy-followers alone give selected validation
  subsets. Verify person-level development/validation separation for repeated
  landmarks and combined censoring assumptions. Equation 2 was corrected July
  2024; use corrected source and inspect code before reuse. [reported
  Discussion/correction; inference]
- **Locators:** Complete main text read from PMC XML. Supplemental setup not
  read; article-linked R simulation code:
  https://github.com/survival-lumc/Validation_Under_Interventions (not audited).

### PMC11275659

Heart, liver and lung offer acceptance inequities · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11275659/) ·
doi:10.1101/2024.07.14.24310395 · External linkage · 2010–2020 offers ·
MT, 2026-11-14

- **Population / unit:** Offer-level heart/liver/lung cohorts; survival analysis
  pairs accepter with immediately higher-ranked decliner for the same organ.
  [reported Methods]
- **Files and fields:** PTR offer files joined to SAF donor/candidate data and
  offer-time allocation scores; external Census income and CDC vulnerability
  linked geographically [reported Methods].
- **Data needs:** Accepted offers plus refusals for reported codes 830/831;
  cluster logistic errors by candidate and donor, distinguish center/year fixed
  effects, and retain pair structure for survival/RMST. [reported Methods] Tags:
  `candidate-registration`, `status-history`, `external-linkage`, `geography`.
- **Data pitfalls:** Refusal codes can be catch-all categories; codes not
  independently verified. Random offer splits can share donors/candidates across
  sets. Later-transplanted-only sensitivity selects recipients using a future
  event. [reported Limitations; inference]
- **Locators:** Complete main text read from PMC XML; Data/cohort, Statistical
  Analysis, Results and Discussion. Supplemental mappings, censoring rules and
  full covariate list not checked.

### PMC11265282

Liver TIPS and longitudinal HCC burden · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11265282/) ·
doi:10.3389/ti.2024.12781 · SAF analysis · February 2002–June 2022 ·
MT, 2026-11-14

- **Population / unit:** HCC liver candidates with versus without TIPS before
  listing, then a matched cohort and transplanted subset. [reported Methods]
- **Files and fields:** Article explicitly names CAN_TIPSS and MPEXCEPT;
  longitudinal tumor size/count/AFP, treatment, transplant and mortality. Names
  reported, not codebook-verified. [reported Methods]
- **Data needs:** Sum spherical lesion volumes; distinguish monthly volume/AFP
  changes from annual tumor-count changes. Separate listing-origin survival
  censored at transplant, transplant-origin mortality and recurrence competing
  risks. [reported Methods] Tags: `status-history`, `derived-score`,
  `follow-up-horizon`.
- **Data pitfalls:** Reported sodium/creatinine units and MELD implementation
  wording require authoritative verification. Cohort counts differ across
  sections; matching includes outcome completeness and potentially later
  treatment. Recurrence algorithm is delegated to prior papers, not specified
  here. TIPS date relative to HCC is unavailable. [unclear Methods/Results;
  reported Discussion]
- **Locators:** Complete main text read from PMC XML. Original recurrence
  algorithm, MELD specification and matching code not inspected.

### PMC11252006

Liver serum and endothelial permeability experiment · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11252006/) ·
doi:10.3389/fmed.2024.1412891 · Case-finding or local source · May 2021–May 2023 ·
MT, 2026-11-14

- **Population / unit:** Single-center consenting adult liver/SLK recipients
  with prospectively collected intraoperative serum; experimental units include
  patient, sampling time, cell donor and replicate well. [reported Methods]
- **Files and fields:** Local Transplant Outcomes in Anesthesia Database
  combines EHR, SRTR and prospective anesthesia records; serum assays and
  impedance traces are external [reported Clinical data extraction].
- **Data needs:** Preserve specimen timing relative to reperfusion, normalize
  resistance within well, compare assay AUC with healthy-serum control, and
  distinguish technical replicates from independent patients. [reported Methods]
  Tags: `external-linkage`, `cross-organ-link`.
- **Data pitfalls:** Rich intraoperative measurements, cytokines and endothelial
  responses are not routine SAF variables. Early graft dysfunction/AKI
  definitions require local timed laboratories. Small selected cohort and
  incomplete specimen collection limit outcome inference; this is not a national
  SRTR cohort. [reported Limitations; inference]
- **Locators:** Complete main text read from PMC XML, especially sections
  2.4–2.6. Protocols.io procedure, supplements and local database schema not
  inspected.

### PMC11177818

Kidney zero-antigen mismatch and race · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11177818/) ·
doi:10.1097/TXD.0000000000001653 · SAF analysis · 2007–2016; at least three years potential follow-up ·
MT, 2026-11-14

- **Population / unit:** Adult deceased-donor single-organ kidney transplants,
  with White/non-White and Black-only comparisons. [reported Methods]
- **Files and fields:** HLA A/B/DR mismatch, cPRA, induction, socioeconomic
  covariates and graft/death follow-up including death-file information
  [reported Methods].
- **Data needs:** Distinguish zero ABDR mismatch from complete immunologic
  compatibility. Five covariate imputations plus five censor-time imputations
  create 25 datasets; Weibull modeling uses competing-death imputation. KDRI
  normalized to 2021. [reported Analysis] Tags: `derived-score`, `death-source`,
  `follow-up-horizon`.
- **Data pitfalls:** Death-censored endpoint language and reported
  subdistribution hazards require careful reconciliation with the imputation
  estimator, not substitution of ordinary Cox censoring. Acute rejection was
  deliberately excluded for poor sensitivity. Broad race/insurance categories
  and inconsistent missingness percentages need explicit reconstruction.
  [reported Methods/Limitations; inference]
- **Locators:** Complete main text read from PMC XML. Competing-risk
  methodological references, supplement and original score mapping not checked.

### PMC11152206

Living versus deceased donor liver matching · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11152206/) ·
doi:10.1093/bjsopen/zrae058 · SAF analysis · 2002–2020; cutoff December 31, 2021 ·
MT, 2026-11-14

- **Population / unit:** Adult first liver recipients, excluding multivisceral,
  ABO-incompatible and selected non-HCC malignant indications; matching within
  biochemical MELD strata. [reported Methods]
- **Files and fields:** Recipient/donor/transplant data plus later relisting,
  retransplant and mortality; exact linkage mappings unverified [inference].
- **Data needs:** Graft loss includes relisting/retransplant and optionally
  death. MELD excludes exception points; matching targets up to ten controls
  without replacement, with subsequent adjustment and ischemia-time sensitivity.
  [reported Methods] Tags: `living-donor`, `repeat-transplant`, `derived-score`,
  `follow-up-horizon`.
- **Data pitfalls:** Posttransplant survival addresses a different question than
  listing-origin benefit. Relisting is not interchangeable with recorded
  graft-failure date. Table counts/percentages and MELD/ischemia boundary
  wording are inconsistent across sections and merit checking. [reported
  Results/Discussion; inference]
- **Locators:** Complete main text read from PMC XML. Supplemental matching
  diagnostics and precise biochemical MELD implementation not inspected.
