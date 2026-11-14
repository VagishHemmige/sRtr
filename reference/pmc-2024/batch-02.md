# 2024 PMC annotations: batch 02

Part of the [2024 catalog](../pmc-2024.md); follows the
[annotation scheme](../README.md#literature-annotations).
Only source-reading notes are stored here. Exact SAF mappings are unverified
unless explicitly tagged otherwise.

### PMC12981238

Liver HCC downstaging and access · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC12981238/) ·
doi:10.1097/LVT.0000000000000532 · External linkage · listings June 2013–December 2021; follow-up March 1, 2023 ·
MT, 2026-11-14

- **Population / unit:** Adults >18 with HCC exceptions; relistings, status 1,
  missing ZIP/center excluded. Unit: candidate. [reported Methods]
- **Files and fields:** Candidate/exception and removal records with initial
  tumor burden, residential ZIP and center [inference]; ADI, RUCA and Google
  Maps travel times [external; reported Methods]. Exact SAF mappings unverified.
- **Data needs:** Separate Milan, UNOS-downstaging and allcomer burden at
  presentation; combine the latter two only for modeled comparisons.
  Death/too-sick removal competes with transplant; retain center MMaT and
  listing year. [reported Methods] Tags: `candidate-registration`, `geography`,
  `external-linkage`, `derived-score`.
- **Data pitfalls:** The cohort starts after successful waitlisting and cannot
  measure earlier referral losses; individual social factors are sparse.
  [reported Discussion] Initial tumor burden is not interchangeable with
  post-treatment eligibility [inference].
- **Locators:** Methods; Results; Discussion. Complete main text read from PMC
  XML; tables/captions and supplements not separately appraised.

### PMC13215463

Liver HCC exceptions and allocation eras · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC13215463/) ·
doi:10.1111/ctr.15365 · SAF analysis · exception approvals May 2017–March 2021; pre-policy follow-up censored at policy change ·
MT, 2026-11-14

- **Population / unit:** Adults with HCC exceptions; excludes prior LT, status
  1A, living-donor recipients, multiple-center listings and other exceptions.
  Unit: candidate. [reported §2.1]
- **Files and fields:** Candidate, exception approval, removal and transplant
  records; laboratory versus allocation MELD, race/ethnicity and region; exact
  mappings unverified [inference].
- **Data needs:** Time origin is earliest HCC exception approval, not listing;
  retain candidates who later lose exceptions. Compare MMaT-3 eras at May 19,
  2019, and acuity-circle eras at February 4, 2020; censor earlier cohorts at
  each policy boundary. Transplant and death/too-sick removal compete. [reported
  §§2.1–2.5] Tags: `candidate-registration`, `policy-era`, `geography`,
  `follow-up-horizon`.
- **Data pitfalls:** Main text describes payment at transplant and dialysis just
  before transplant among candidate covariates [reported §2.4]; their
  availability/timing for nonrecipients needs clarification [unclear §2.4].
  Tumor detail is incomplete; the pandemic overlaps acuity-circle
  implementation. [reported §4]
- **Locators:** Methods §§2.1–2.5; Results; Discussion. Complete main text read
  from PMC XML; supplements and tables/captions not separately appraised.

### PMC13618735

Living liver donors and relationship strata · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC13618735/) ·
doi:10.1111/ctr.15468 · SAF analysis · donations 2012–2022; March 2023 release ·
MT, 2026-11-14

- **Population / unit:** Living liver donors, stratified by relationship,
  race/ethnicity and age. Unit: donor, aggregated into temporal counts.
  [reported Methods]
- **Files and fields:** Living-donor demographic and relationship records; exact
  filenames and relationship-code mappings unverified [inference].
- **Data needs:** Separate biologically related from unrelated donors, retaining
  relationship subtypes; age split <40 versus ≥40. Negative-binomial count
  models estimate change per three years within strata. [reported Methods;
  Results] Tags: `living-donor`, `follow-up-horizon`.
- **Data pitfalls:** Counts concern completed donors, not everyone evaluated;
  excluded donor candidates are absent. [reported Discussion] Methods groups
  White/others together, while results shorten the label to White [reported
  Methods; Results]; retain the original race grouping when reconstructing
  counts [inference]. Count trends do not supply population-based donation rates
  [inference].
- **Locators:** Methods (Data Source and Study Population; Outcomes; Change in
  Number of Donors); Results; Discussion. Complete main text read from PMC XML;
  tables/captions and supplement not separately appraised.

### PMC11925671

Lung offer sequence and center volume · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11925671/) ·
doi:10.1016/j.healun.2024.11.012 · SAF analysis · transplants 2015–2021; administrative follow-up cutoff unreported ·
MT, 2026-11-14

- **Population / unit:** Lung transplant recipients grouped by accepted donor
  sequence number; unit: transplant with center grouping. [reported Methods]
- **Files and fields:** Accepted-offer sequence linked to donor, recipient,
  center and posttransplant outcomes; exact mappings unverified [inference].
- **Data needs:** Retain sequence at acceptance and annual center volume;
  compare survival through five years and separate early complications.
  Center-volume subgroups assess high-sequence recipients. [reported Methods]
  Tags: `follow-up-horizon`.
- **Data pitfalls:** Low sequence is described as <20 and also 0–20;
  center-volume labels similarly leave 30 ambiguous [unclear Methods; Results].
  Do not silently assign boundary records [inference]. Serial improvement in
  donor physiology and several detailed donor-risk measures cannot be captured.
  [reported Discussion] Sequence is candidate position, not the number of
  distinct declining centers [reported Introduction].
- **Locators:** Methods; Results; Discussion. Complete main text read from PMC
  XML; tables/captions and supplement not separately appraised.

### PMC11862262

Kidney nonuse and allocation delays · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11862262/) ·
doi:10.1097/TP.0000000000005178 · External linkage · regression March 2019–January 2023; curated match runs March 2020–December 2021 ·
MT, 2026-11-14

- **Population / unit:** Recovered deceased-donor kidneys, including nonused
  organs; two kidneys may share a donor. [reported §§2.3–2.4]
- **Files and fields:** SRTR plus specially curated OPTN match-run data;
  notification/response/cross-clamp timestamps and center sequence. [reported
  §§2.1–2.4] Standard-SAF availability requires verification [inference].
- **Data needs:** Progression time uses the maximum prior response timestamp
  because responses can be out of sequence. Separate candidate and center
  counts. Cold time at last notification differs from transplant CIT and is zero
  before cross-clamp; GEE clusters kidneys by donor. [reported §§2.3–2.4] Tags:
  `donor-pair`, `policy-era`, `follow-up-horizon`.
- **Data pitfalls:** Moving-average displays use a different period and are not
  regression inputs; missing/extreme notification times cause exclusions.
  [reported §§2.2–2.4] Transplanted-only data omit the nonuse denominator
  [inference].
- **Locators:** Methods §§2.1–2.4; Results; Discussion. Complete main text read
  from PMC XML; tables/captions and supplementary decomposition details not
  separately appraised.

### PMC12126925

Liver HCC survival and graft failure · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC12126925/) ·
doi:10.1016/j.jceh.2024.102489 · SAF analysis · 2001–2023 cohorts; start/end dates vary across sections ·
Screened, 2026-11-14

- **Population / unit:** Adult liver recipients with MELD 6–40;
  multiorgan/retransplants and missing outcomes excluded. Unit: recipient.
  [reported Study Designs]
- **Files and fields:** Transplant/follow-up, primary diagnosis, Milan
  eligibility and graft-failure cause records; exact mappings unverified
  [inference].
- **Data needs:** Separate patient and graft survival, transplantation eras and
  Milan eligibility. Graft failure is described through regrafting or a recorded
  death cause; no recorded death is treated as alive through May 2023. [reported
  Outcome Definitions] Tags: `death-source`, `follow-up-horizon`.
- **Data pitfalls:** No death date does not establish continued observation
  [inference]. Calendar bounds differ between abstract and Methods; precise
  failure/censor construction requires clarification. [unclear Abstract; Study
  Designs; Outcome Definitions]
- **Locators:** Retrieved Methods, Results and Discussion passages via PMC
  search cache. Direct PMC retrieval returned a browser check; complete
  main-text coverage not established. Remains Screened; tables/captions and
  supplements not appraised.
