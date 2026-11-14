# 2024 PMC annotations: batch 06

Part of the [2024 catalog](../pmc-2024.md); follows the
[annotation scheme](../README.md#literature-annotations).
Only source-reading notes are stored here. Exact SAF mappings are unverified
unless explicitly tagged otherwise.

### PMC11377801

Kidney living-donor biological relationships · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11377801/) ·
doi:10.1681/ASN.0000000000000424 · SAF analysis · 1988–2022 ·
MT, 2026-11-14

- **Population / unit:** Biologically related living kidney donors, stratified
  by race/ethnicity and eras before versus after 2005. Unit: donor. [reported
  Methods]
- **Files and fields:** Living donor relationship, donation date, race/ethnicity
  and recipient age; exact mappings unverified [inference].
- **Data needs:** Separate annual counts from proportions of all living
  donations; Poisson trends use five-year increments, with joinpoint support and
  sensitivity excluding pediatric recipients. [reported Methods; Results] Tags:
  `living-donor`, `policy-era`.
- **Data pitfalls:** White/other combines several racial groups. Missing race is
  excluded. Counts do not estimate population donation rates; evaluated but
  ineligible donors are absent from the registry used. [reported Methods;
  Discussion]
- **Locators:** Methods; Results; Discussion; inline Figure 1 caption. Complete
  main text read from PMC XML; underlying figure data not independently checked.

### PMC11537496

Liver exceptions under MMaT/250 · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11537496/) ·
doi:10.1097/TP.0000000000004957 · SAF analysis · first activation February 4, 2020–February 3, 2022; cutoff February 4, 2022 ·
MT, 2026-11-14

- **Population / unit:** First-time active adult liver registrations; each
  registration analyzed separately. Status 1, mixed exception categories and HAT
  exceptions excluded. [reported Study Population]
- **Files and fields:** Candidate/status histories, exception
  applications/approval, allocation and laboratory MELD, removal and mortality
  records; exact mappings unverified [inference].
- **Data needs:** Exception cohorts enter at approval, including the subsequent
  six-month HCC delay; non-exception cohort enters at activation. DDLT competes
  with death/deterioration/medical-unsuitability removal; other removal censors
  regression. [reported Waitlist outcomes; mortality/dropout] Tags:
  `candidate-registration`, `status-history`, `death-source`, `policy-era`.
- **Data pitfalls:** Cumulative-incidence descriptions and regression censoring
  differ. MELD strata and stated observation duration also differ across
  sections; check intended estimand before copying. [unclear Methods; Results;
  Limitations] Multiple registrations are not unique patients [reported Study
  Population].
- **Locators:** Methods; Results; Discussion. Complete main text read from PMC
  XML; tables/captions and supplemental models not independently appraised.

### PMC11216888

Pediatric liver healthcare utilization · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11216888/) ·
doi:10.1002/jpn3.12234 · External linkage · 2004–2022; cutoff May 31, 2022 ·
MT, 2026-11-14

- **Population / unit:** Recipients aged at most 21 at transplant, matched to
  PHIS admissions; excludes initial-hospitalization deaths. Units: patient,
  encounter and posttransplant year. [reported Methods]
- **Files and fields:** SRTR linked to PHIS by hospital, transplant
  hospitalization dates, age and sex; PHIS supplies utilization and ZIP-based
  2010 Census income [reported Data Sources; Merging; Exposure].
- **Data needs:** Recurrent hospitalizations/biopsies with death as potentially
  informative terminal event; censor at age 22 or administrative end. Annual
  bed-days use a two-part count model. [reported Statistical Analysis] Tags:
  `external-linkage`, `geography`, `follow-up-horizon`.
- **Data pitfalls:** Unmatched patients differ geographically and by age;
  non-PHIS admissions are missed. Biopsy is not confirmed rejection.
  Neighborhood income is not individual income. [reported Discussion] Verify
  zero-inflated versus hurdle implementation before reuse [inference from model
  description].
- **Locators:** Methods; Results; Discussion. Complete main text read from PMC
  XML; supplemental merge algorithm, ICD codes and model code not inspected.

### PMC11168827

Kidney sensitization and allocation priority · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11168827/) ·
doi:10.2215/CJN.0000000000000449 · SAF analysis · January 2016–September 2023; cutoff September 30, 2023 ·
Screened, 2026-11-14

- **Population / unit:** Adult kidney candidates at their first listing during
  the study period. [reported Methods]
- **Files and fields:** Candidate baseline cPRA, prior transplant, dialysis
  duration, blood group, transplant/removal and death records; exact mappings
  unverified [inference].
- **Data needs:** Use listing cPRA rather than updated cPRA; distinguish
  living/deceased donor incidence. Cox splines use five percentile-spaced knots;
  policy strata use listing date relative to March 15, 2021. [reported Methods]
  Tags: `candidate-registration`, `repeat-transplant`, `policy-era`,
  `living-donor`.
- **Data pitfalls:** Baseline sensitization can change. Rounded broad cPRA
  groups conceal highly sensitized subgroups; post-policy follow-up is shorter.
  High-sensitization threshold wording differs between Methods and tables.
  [reported Discussion; unclear Methods/Table 2]
- **Locators:** PMC cached Methods, Results and Discussion passages read;
  continuity of complete main text not established, so Screened. Tables and
  supplements not comprehensively inspected.

### PMC11232925

Kidney neighborhood deprivation and preemptive transplantation · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11232925/) ·
doi:10.1111/ctr.15382 · External linkage · 2006–2021; cutoff December 31, 2021 ·
MT, 2026-11-14

- **Population / unit:** First-time adult kidney candidates, including
  non-listed living-donor recipients. Unit: candidate. [reported Study
  Population]
- **Files and fields:** SRTR linked by residential ZIP/year to
  population-weighted tract NDI/ACS aggregates [reported NDI]. Exact SAF
  mappings unverified [inference].
- **Data needs:** Preserve NDI construction and constituent standardized
  variables; compare cause-specific hazards with Fine–Gray sensitivity analyses,
  and race/era interactions. [reported Statistical Analysis] Tags:
  `external-linkage`, `geography`, `living-donor`, `candidate-registration`.
- **Data pitfalls:** Non-listed recipients lack an obvious listing time origin.
  DDKT censoring in the preemptive analysis and definition of preemptive
  eligibility need clarification. Kaplan–Meier complements differ from
  competing-risk incidence. [unclear Statistical Analysis; inference] ZIP
  measures cannot establish individual deprivation [reported Discussion].
- **Locators:** Methods; Results; Discussion. Complete main text read from PMC
  XML; supplementary missing-data details and NDI implementation not inspected.

### PMC11090717

DCD heart procurement NRP versus DPP · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11090717/) ·
doi:10.1016/j.healun.2024.02.1456 · SAF analysis · 2019–2021 transplants; March 2023 release; one-year outcomes ·
MT, 2026-11-14

- **Population / unit:** Adult heart-only DCD recipients with eligible status
  and complete required variables. Unit: transplant; matched analyses pair
  recipients. [reported Methods]
- **Files and fields:** Donor death/cross-clamp/withdrawal timestamps, recipient
  characteristics, centers and OPTN-verified death/follow-up records; exact
  mappings unverified [inference].
- **Data needs:** Procurement is inferred from death-to-cross-clamp duration:
  over 30 minutes NRP, otherwise DPP. Compare 365-day RMST and
  matched-pair-stratified Cox models. [reported Methods] Tags: `death-source`,
  `follow-up-horizon`, `geography`.
- **Data pitfalls:** This is a proxy classification, not a recorded procurement
  method. Withdrawal-to-death time does not measure warm ischemic injury.
  Same-hospital pairs receive zero transport distance, including donor
  co-location. Center confounding remains. [reported Limitations]
- **Locators:** Methods; Results; Discussion. Complete main text read from PMC
  XML; supplementary matching models and linked reproducibility code not
  inspected.
