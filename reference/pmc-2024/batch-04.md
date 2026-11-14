# 2024 PMC annotations: batch 04

Part of the [2024 catalog](../pmc-2024.md); follows the
[annotation scheme](../README.md#literature-annotations).
Only source-reading notes are stored here. Exact SAF mappings are unverified
unless explicitly tagged otherwise.

### PMC11807259

Heart HCV-offer willingness · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11807259/) ·
doi:10.1016/j.jtcvs.2024.06.025 · SAF analysis · waitlist October 2018–February 2022 in Methods; cutoff August 31, 2023 ·
MT, 2026-11-14

- **Population / unit:** Adult heart-only candidates grouped by willingness to
  consider HCV-positive offers. Unit: candidate, linked through transplant for
  overall mortality. [reported Study population; Overall mortality]
- **Files and fields:** Candidate acceptance preferences, support devices,
  removal, transplant and death records; donor antibody/NAT results. Exact
  mappings unverified [inference].
- **Data needs:** HCV-positive combines antibody-positive and NAT-positive
  donors. Waitlist death/deterioration competes with transplant; a separate
  mortality analysis continues after transplant. [reported Definition of donor
  HCV status; Waitlist survival; Overall mortality] Tags:
  `candidate-registration`, `death-source`, `follow-up-horizon`.
- **Data pitfalls:** Willingness does not distinguish viremic from antibody-only
  offers or isolate patient from center preference. [reported Discussion] Timing
  of preference changes is not specified [unclear Study population]. Results and
  Discussion reverse the willing/not-willing percentage; use source denominators
  rather than the narrative summary [unclear Results; Discussion].
- **Locators:** Methods; Results; Discussion. Complete main text read from PMC
  XML; tables/captions not separately appraised.

### PMC11631678

Liver targeted-sharing simulation · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11631678/) ·
doi:10.1097/TP.0000000000005184 · Methods or simulation · optimization 2013–2017; simulation inputs 2011–2016; March 2018 release ·
MT, 2026-11-14

- **Population / unit:** Incident candidates reaching MELD/PELD ≥15 and
  transplanted donor livers for optimization; a separate LSAM population for
  simulation. Units: donor hospital, aggregated center demand and simulated
  candidate. [reported Methods]
- **Files and fields:** SRTR donor/candidate geography and LSAM input files;
  exact SAF mappings unverified [inference].
- **Data needs:** Separate supply/demand optimization from outcome simulation;
  aggregate nearby centers into demand nodes and retain donor-hospital distances
  in nautical miles. Run repeated allocation scenarios with acceptance and
  counterfactual waitlist histories. [reported Methods; Discussion] Tags:
  `geography`, `policy-era`, `derived-score`, `candidate-registration`.
- **Data pitfalls:** Optimization excludes prevalent high-MELD candidates and
  counts transplanted livers as supply. Simulation retains outdated HCC
  exception rules and historical cohorts; recent policy scenarios do not make
  input data contemporary. [reported Methods; Discussion]
- **Locators:** Methods; Results; Discussion. Complete main text read from PMC
  XML; equations, tables/captions and external LSAM implementation not
  independently validated.

### PMC11840864

Lung compatible supply and allocation scoring · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11840864/) ·
doi:10.1016/j.healun.2024.09.022 · Methods or simulation · adult donors/candidates February 2015–September 2021; simulated two-year horizons ·
MT, 2026-11-14

- **Population / unit:** Adult lung candidates and recovered donors;
  research-only recoveries excluded. Unit: candidate-specific donor supply and
  simulated candidate. [reported Methods]
- **Files and fields:** Candidate diagnosis, ABO, height and donor
  recovery/geography records; exact SAF mappings unverified [inference].
- **Data needs:** Calculate distance-adjusted compatible donors per observed day
  within ±1 year of listing; compatibility depends on diagnosis/procedure.
  Compare original, ABO-modified and supply-adjusted CAS over the same simulated
  cohorts. [reported Methods] Tags: `geography`, `derived-score`, `policy-era`,
  `follow-up-horizon`.
- **Data pitfalls:** cPRA is omitted because of extensive nonrandom missingness.
  Compatibility ranges and distance weights are assumptions requiring the
  supplement; future donor availability is part of retrospective supply
  estimation. [reported Methods; Limitations] Do not treat that retrospective
  exposure as information available at listing [inference].
- **Locators:** Methods; Results; Discussion/Limitations. Complete main text
  read from PMC XML; supplemental compatibility/model details and
  tables/captions not separately appraised.

### PMC11835194

Pediatric kidney neighborhood deprivation · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11835194/) ·
doi:10.2215/CJN.0000000592 · External linkage · transplants January 2010–May 2022; cutoff not verified ·
Screened, 2026-11-14

- **Population / unit:** Kidney recipients younger than 18 at listing, not
  necessarily at transplant. Unit: recipient. [reported Abstract]
- **Files and fields:** Recipient, listing, donor-type, dialysis and graft
  follow-up records plus Material Community Deprivation Index geography
  [inference]. Exact linkage source/version and SAF mappings unverified.
- **Data needs:** Keep age-at-listing eligibility separate from transplant age;
  distinguish preemptive and living-donor transplantation and graft loss.
  [reported Abstract] Tags: `geography`, `external-linkage`, `living-donor`,
  `candidate-registration`.
- **Data pitfalls:** The retrieved figure caption calls graft loss
  death-censored, but its exact event/censor implementation is not available
  [unclear Figure 2 caption]. Neighborhood deprivation must not be assumed to
  measure individual household resources [inference].
- **Locators:** PubMed abstract and Figure 2 caption (PMID 39480491); PMC
  returned a browser check and no full body was available in the saved XML. Full
  methods, tables and supplements remain unread; Screened only.

### PMC11426084

Heart malignancy and subsequent mortality · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11426084/) ·
doi:10.1016/j.ijcard.2024.132455 · SAF analysis · first transplants October 1987–June 2020; entry at day 365 ·
MT, 2026-11-14

- **Population / unit:** Adult first heart-only recipients surviving cancer-free
  through the first year with known survival/follow-up. Unit: recipient with
  time-varying cancer exposure. [reported Study population; Exposures]
- **Files and fields:** Transplant, malignancy follow-up and mortality records;
  exact mappings unverified [inference].
- **Data needs:** Use delayed entry at one year; classify first cancer subtype,
  accrue prediagnosis time as unexposed, and follow to death/loss/administrative
  end. Mortality models stratify by center and allow time-varying associations.
  [reported Statistical Analysis] Tags: `death-source`, `follow-up-horizon`,
  `policy-era`.
- **Data pitfalls:** Cancer ascertainment depends on clinical reporting and
  lacks stage/histopathology. The mortality outcome is all-cause, not
  cancer-specific. [reported Discussion] Results describe first-year incidence
  despite excluding first-year cancers; reconcile plotted time with delayed
  entry before reproducing it [unclear Exposures; Results].
- **Locators:** Materials and Methods; Results; Discussion. Complete main text
  read from PMC XML; tables/captions and supplements not separately appraised.

### PMC11573248

Kidney offer-notification batches · [PMC article](https://pmc.ncbi.nlm.nih.gov/articles/PMC11573248/) ·
doi:10.1111/ctr.70024 · External linkage · match runs December 2017–January 2023; OPO performance report uses 2021 data ·
MT, 2026-11-14

- **Population / unit:** Match runs with at least one kidney recovered; host-OPO
  final run chosen when repeated. Units: notification, candidate, distinct
  center and OPO. [reported Methods]
- **Files and fields:** SAFs, Potential Transplant Recipient file and
  supplemental notification timestamps; external OPO performance report.
  [reported Data source; Analysis] Exact join keys unverified [inference].
- **Data needs:** Exclude bypasses from notified counts and placement ranks;
  distinguish first/second kidney and candidate/center ranks. Placement-rank
  calculations require both kidneys accepted. Preserve KAS250 geography and OPO
  merger history. [reported Methods] Tags: `donor-pair`, `geography`,
  `policy-era`, `external-linkage`.
- **Data pitfalls:** A sequence number equals placement rank only without
  bypasses. Initial notifications do not describe the whole allocation timeline;
  standard match-run files alone lack the added timestamp information. [reported
  Methods; Discussion]
- **Locators:** Methods; Results; Discussion. Complete main text read from PMC
  XML; tables/captions and supplement not separately appraised. Reported
  bypass-code definitions were not independently dictionary-checked.
