# 2024 PMC annotations: batch 01

Part of the [2024 catalog](../pmc-2024.md); follows the
[annotation scheme](../README.md#literature-annotations).

### PMC10865158

Heart candidate risk prediction · doi:10.1001/jama.2023.27029 · SAF analysis ·
listing 2019–2022; follow-up through March 2023 · MT, 2026-11-14

- **Population / unit:** adult heart candidates, including multiorgan listings;
  distinguish people from registrations and repeated 14-day intervals.
  [reported Methods; Figure 1 caption]
- **Files and fields:** candidate registration and status justification files;
  clinical trajectories and OPTN/SSA-verified deaths. Exact SAF keys unverified.
  [reported Methods]
- **Data needs:** predict six-week mortality from successive intervals; retain
  prior/current support, laboratory history and post-removal deaths. Cluster
  repeated observations by candidate; split training/test sets by center.
  [reported Methods] Tags: `candidate-registration`, `status-history`,
  `post-removal-death`, `death-source`, `derived-score`.
- **Data pitfalls:** carrying observations forward and imputing normal values
  affect trajectories [reported Methods; Limitations]. Device classification
  was corrected: temporary percutaneous devices had been misclassified as
  durable LVADs; coefficients and supplementary material changed [reported
  correction]. Verify the corrected specification before reconstructing the
  score [inference].
- **Locators:** Methods; Results; Discussion/Limitations;
  [coding-error correction](https://pmc.ncbi.nlm.nih.gov/articles/PMC12413661/)
  (read in full). Main text read; tables/captions not comprehensively appraised;
  supplements unread, including interval construction and imputation details.

### PMC11867891

Older lung recipients, single versus bilateral · doi:10.1016/j.chest.2024.08.044 ·
SAF analysis · transplants January 2005–June 2022; follow-up cutoff not stated
in main text · MT, 2026-11-14

- **Population / unit:** recipients aged at least 65; multiorgan and duplicate
  patient records excluded. Unit: recipient; matched single/bilateral pairs.
  [reported Methods]
- **Files and fields:** thoracic transplant/follow-up records, donor covariates,
  procedure laterality, hospitalization outcomes and survival; exact file/field
  mappings unverified [inference].
- **Data needs:** propensity matching uses recipient and donor characteristics;
  retain matched-pair membership. Separate 72-hour support, predischarge
  complications, treated rejection within one year, and survival through five
  years. [reported Methods; Results] Tags: `follow-up-horizon`.
- **Data pitfalls:** missing observations drive exclusions; several support and
  rejection measures have substantial missingness, and cause of death is
  incomplete [reported Methods; Discussion]. Missing outcomes cannot be treated
  as absent [inference]. The duplicate-record rule is not specified [unclear
  Methods]. Rejection subtype/severity and detailed functional outcomes are
  unavailable [reported Discussion].
- **Locators:** Methods (Study Population; Statistical Analysis); Results;
  Discussion. Main text read; tables, figure captions and supplements not
  comprehensively appraised.

### PMC11150328

Liver opportunity equity and geography · doi:10.1097/TP.0000000000004888 ·
External linkage · pre-allocation-change 2013–2019 and post-change 2020–2021;
SRTR releases June 2021/March 2023 · MT, 2026-11-14

- **Population / unit:** adult first primary liver listings; recipient analysis
  excludes multiorgan transplants except liver–kidney. Index-building and
  outcome cohorts use different exclusions. Units: ZIP area and person.
  [reported Methods]
- **Files and fields:** candidate, transplant and follow-up families with
  residence and center geography; exact mappings unverified [inference].
  ACS/AHRQ neighborhood measures require external data [external; reported Methods].
- **Data needs:** crosswalk ZIP to ZCTA; construct the opportunity index from
  neighborhood variables. Waitlist death/deterioration competes with transplant;
  posttransplant follow-up ends at death, retransplant or last follow-up, with
  era-specific administrative cutoffs. [reported Methods] Tags: `geography`,
  `external-linkage`, `policy-era`, `derived-score`, `candidate-registration`.
- **Data pitfalls:** unmatched/nonresidential ZIPs and missing index/center data
  cause exclusions; neighborhood measures are ecological [reported Methods;
  Discussion]. Preserve the release, era and geographic denominator when
  comparing cohorts [inference].
- **Locators:** Materials and Methods; Results; Discussion. Main text read;
  tables, figure captions and supplements not comprehensively appraised.

### PMC11149032

Kidney high-KDPI consent · doi:10.1681/ASN.0000000000000318 · SAF analysis ·
listed January 2015–May 30, 2022; cutoff May 31, 2022 · MT, 2026-11-14

- **Population / unit:** adult kidney candidates in their first eligible
  waitlist period; never-activated candidates excluded. Unit: candidate.
  [reported Methods]
- **Files and fields:** candidate/status records, consent, removal events,
  transplant donor KDPI and center identifiers; exact mappings unverified
  [inference].
- **Data needs:** baseline consent and time origin use listing if active,
  activation otherwise. Distinguish deceased/living-donor transplant, death
  and other removal: cumulative-incidence and cause-specific analyses handle
  competing events differently. Center summaries require at least 30 listings.
  [reported Methods; Results] Tags: `candidate-registration`, `status-history`,
  `living-donor`, `follow-up-horizon`.
- **Data pitfalls:** consent can change after baseline but those changes were
  not modeled; transfer/multiple-listing exclusions limit representation.
  Posttransplant graft survival was not evaluated. [reported Discussion]
  Do not interpret baseline consent as a time-varying acceptance history
  [inference].
- **Locators:** Methods; Results; Discussion. Main text read; tables and figure
  captions not comprehensively appraised; no supplemental appraisal.

### PMC11630524

Cancer registry linkage across organs · doi:10.1093/jnci/djae159 · External
linkage · 1996–2019, bounded by registry coverage · MT, 2026-11-14

- **Population / unit:** solid-organ recipients in Transplant Cancer Match,
  compared with a separate HIV/cancer linkage. Unit: person-time and first
  invasive cancer. [reported Methods]
- **Files and fields:** SRTR linked with 34 cancer registries; cancer site and
  histology use ICD-O-3 classification [reported Methods]. Cancer-registry
  outcomes and reference incidence rates require external access [external].
- **Data needs:** entry is the later of transplant and coverage start; exit is
  first cancer, coverage end or death. Expected counts use demographic/calendar
  strata; heart/lung versus other-organ comparisons use Poisson models.
  [reported Methods] Tags: `external-linkage`, `follow-up-horizon`, `death-source`.
- **Data pitfalls:** organ type is a proxy for immunosuppression, not measured
  treatment intensity; registry covariates leave important exposures unmeasured
  [reported Discussion]. SAF malignancy flags alone cannot reproduce the
  linked histology-specific outcome classification [inference]. Epidemiologic
  patterns do not establish a tumor's viral cause [reported Discussion].
- **Locators:** Methods; Results; Discussion; Data availability. Main text read;
  tables/captions not comprehensively appraised; supplementary classification
  details unread.

### PMC11261589

COMET lung allocation simulation · doi:10.1016/j.healun.2024.04.063 · Methods
or simulation · training inputs 2015–2021; historical validation 2018–2019 ·
MT, 2026-11-14

- **Population / unit:** adult lung candidates and donors, simulated with
  hospital/center agents in daily cycles. [reported Methods]
- **Files and fields:** donor, candidate/status, offer, transplant/follow-up and
  geographic inputs; exact SAF mappings and offer-data availability require
  verification [inference].
- **Data needs:** separate population generation, compatibility screening,
  allocation, acceptance and survival modules. Retain center and offer-order
  information, hospital–center distances, and LAS/CAS policy versions.
  Waitlist-survival validation uses a 365-day horizon; posttransplant validation
  ends March 12, 2020. [reported Methods] Tags: `status-history`, `policy-era`,
  `geography`, `follow-up-horizon`.
- **Data pitfalls:** generated populations and simulated outcomes differ from
  observed records; fitted modules depend on historical inputs and
  recalibration [reported Methods; Discussion]. Lung-specific assumptions
  should not become other organs' defaults [inference].
- **Locators:** Methods; Results; Discussion. Main text read; tables, figure
  captions and supplements not comprehensively appraised.
  [Code linked by the article](https://github.com/ClevelandClinicQHS/COMET)
  has not been inspected.
