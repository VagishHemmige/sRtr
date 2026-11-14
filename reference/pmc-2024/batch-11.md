# 2024 PMC annotations: batch 11

Part of the [2024 catalog](../pmc-2024.md); follows the
[annotation scheme](../README.md#literature-annotations).
Only source-reading notes are stored here. Exact SAF mappings are unverified
unless explicitly tagged otherwise.

### PMC11317850

Oklahoma kidney transplantation and Medicaid expansion · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11317850/) ·
doi:10.5500/wjt.v14.i3.92981 · SAF analysis · Before versus after July 2021; full cohort bounds unclear ·
MT, 2026-11-14

- **Population / unit:** Adult kidney-only recipients associated with Oklahoma;
  repeat transplants included. Geographic inclusion rule needs clarification.
  [reported/unclear Methods]
- **Files and fields:** Recipient insurance, citizenship, functional status,
  donor/transplant and one-year follow-up; supplemental CDC demographics
  [reported Methods].
- **Data needs:** Separate insurance at transplant from policy-era exposure and
  distinguish registration, transplant and follow-up Karnofsky measurements. DGF
  is dialysis in the first week; waiting time includes inactivity. [reported
  Methods/Table 1] Tags: `policy-era`, `follow-up-horizon`, `geography`.
- **Data pitfalls:** Karnofsky grouping is not a validated frailty phenotype.
  Public-insurance definition omits explicit Medicare handling; cohort bounds,
  graft-failure definition and some table denominators are unclear. A
  before/after recipient sample cannot alone measure population access or
  isolate policy effects. [unclear Methods/Tables; inference]
- **Locators:** Complete main text read from PMC XML, Methods through
  Conclusion; original insurance codes and CDC supplement not checked.

### PMC11427033

Older kidney recipients, induction and viral mismatch · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11427033/) ·
doi:10.1097/TXD.0000000000001698 · SAF analysis · 2005–2022 ·
MT, 2026-11-14

- **Population / unit:** Primary kidney recipients aged at least 55, receiving
  one specified induction agent and tacrolimus/mycophenolate at discharge;
  excludes ABO-incompatible/positive-crossmatch transplants. [reported Methods]
- **Files and fields:** Induction/discharge medications, donor–recipient CMV/EBV
  serology and longitudinal graft/death/rejection records; mappings unverified
  [inference].
- **Data needs:** Separate mortality, death with function, death-censored
  failure and death-inclusive failure; use center random effects and era
  adjustment. Rejection includes biopsy-proven or treated episodes. [reported
  Methods/Table 2] Tags: `death-source`, `policy-era`, `follow-up-horizon`.
- **Data pitfalls:** Death-before-failure definition needs missing/tied-date
  handling. Methods gives KAS250 as 2012 while Table 1 uses 2021: resolve
  against policy source. Discharge treatment does not establish later exposure;
  causes of death/failure are incomplete and infection episodes are not directly
  characterized. [unclear Methods; reported Limitations]
- **Locators:** Complete main text read from PMC XML; outcome definitions,
  Tables 1–5 and Limitations. Drug-code mappings not checked.

### PMC11378686

Kidney preservation, DGF and hospital stay · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11378686/) ·
doi:10.12659/AOT.944338 · SAF analysis · January 2010–September 2, 2020 ·
MT, 2026-11-14

- **Population / unit:** Single deceased-donor kidney transplants; excludes
  multiorgan, dual/en-bloc kidneys and missing preservation/DGF. [reported
  Methods]
- **Files and fields:** Donor, preservation-at-receipt, transplant ischemia time
  and admission/discharge records; mappings unverified [inference].
- **Data needs:** Machine perfusion means received on pump; kidneys received on
  ice and pumped later remain cold-storage classified. DGF is first-week
  dialysis; stay is discharge minus admission. KDPI uses the 2022 mapping table.
  [reported Methods] Tags: `derived-score`, `donor-pair`.
- **Data pitfalls:** Later pumping is unrecorded, dialysis thresholds vary by
  center, and DGF does not identify injury severity or dialysis duration.
  Hospital stay begins at admission, not necessarily transplant. Confounded
  preservation comparisons and inconsistent ischemia-hour summaries do not
  establish a causal safe-delay threshold or cost savings. [reported Discussion;
  inference]
- **Locators:** Complete main text read from PMC XML; Methods, Results,
  Discussion and Conclusions. Detailed cost data and KDPI mapping not
  independently checked.

### PMC10966323

Kidney donor sex, age and registry harmonization · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC10966323/) ·
doi:10.1093/ndt/gfad181 · SAF analysis · SRTR 1988–2018; follow-up June 2019 ·
Screened, 2026-11-14

- **Population / unit:** First deceased-donor kidney-only recipients of all
  ages, combined analytically with ANZDATA/CTS cohorts. [reported Methods]
- **Files and fields:** Independent registry datasets, not a patient-level
  linkage; CTS excludes overlapping countries to avoid duplication [reported
  publisher Methods].
- **Data needs:** Harmonize disease, PRA and race categories, use
  cohort-specific Cox models and random-effects meta-analysis, and retain
  donor-age/recipient-sex interactions. Figure 1 conditions on graft function
  beyond 90 days. [reported Methods/caption] Tags: `follow-up-horizon`,
  `derived-score`.
- **Data pitfalls:** Covariate availability differs across registries;
  death-censored loss is dialysis/retransplant, not death-inclusive failure.
  Clarify landmark entry and harmonization before reuse. [reported Methods;
  inference]
- **Locators:** Cached PMC/publisher Methods, selected Results, Discussion and
  caption read; direct PMC blocked. Continuity of complete main text not
  established: Screened. Supplements not read.

### PMC11342767

Living kidney donor GFR indexing · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11342767/) ·
doi:10.1016/j.xkme.2024.100866 · SAF analysis · 2000–2019; cutoff March 2, 2023 ·
MT, 2026-11-14

- **Population / unit:** Adult living-donor kidney transplants with valid donor
  creatinine and donor/recipient height and weight. [reported Methods]
- **Files and fields:** Living-donor laboratory/anthropometric data, recipient
  size and graft/death follow-up; mappings unverified [inference].
- **Data needs:** Apply explicit plausibility exclusions, DuBois BSA and 2021
  CKD-EPI. Distinguish donor-indexed eGFR, deindexed absolute GFR and
  recipient-reindexed GFR; compare Cox discrimination and death-competing
  Fine–Gray models. [reported Methods] Tags: `living-donor`, `derived-score`,
  `follow-up-horizon`.
- **Data pitfalls:** Results swap units for indexed/deindexed estimates; retain
  dimensional checks rather than copying labels. Donor-selection restriction
  limits inference for extreme size mismatch. Exact failure coding and original
  formula implementation remain unverified. [unclear Results; reported
  Discussion; inference]
- **Locators:** Complete short main text and caption read from PMC XML. Original
  GFR/BSA formula references not independently read.

### PMC11327446

Pediatric kidney transplant seasonality · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11327446/) ·
doi:10.1016/j.xkme.2024.100864 · SAF analysis · 2001–2022 ·
MT, 2026-11-14

- **Population / unit:** Kidney-only recipients aged 0–65, grouped as preschool,
  school-age 6–17 and adult 18–65. [reported Methods]
- **Files and fields:** Transplant dates, age, donor type, pretransplant
  dialysis and sociodemographic variables; exact mappings unverified
  [inference].
- **Data needs:** Compare weekly counts in weeks 23–32 versus other weeks,
  separately for living/deceased donors and dialysis status. Specify week
  numbering, denominator years and boundary-week handling before implementation.
  [reported Methods; inference] Tags: `living-donor`, `follow-up-horizon`.
- **Data pitfalls:** Age-based school eligibility and a uniform summer period
  are proxies; actual enrollment, school calendars and scheduling preferences
  are unavailable. Descriptive transplant counts are not rates among eligible
  candidates. Reported subgroup weekly counts need reconciliation with overall
  deceased-donor counts. [reported Discussion; inference]
- **Locators:** Complete short main text and captions read from PMC XML.
  Supplemental Methods and Tables S1–S3 not read; week/calendar algorithm
  unverified.
