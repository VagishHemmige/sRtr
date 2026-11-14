# Repositories reviewed

All reviewed on 2026-11-01 unless noted. "Commit" is the commit read; later
changes are not covered. Code inspection does not establish data provenance or
certify an entire repository as free of patient-level data. Do not open data or
outputs without established safe provenance; public availability is insufficient.

## heatherjcohen/SRTR

- **URL:** https://github.com/heatherjcohen/SRTR
- **Commit:** `59939bd`
- **What it is:** two Python notebooks using the **public** program-specific
  report (PSR) Excel files (`csrs_final_tables_*`), not SAFs. One builds a
  Sankey diagram of heart waitlist flow from Table B1; the other fits a
  straight line through one center's transplant rate ratio across releases.
- **Useful:**
  - PSR tables expose center code `CTR_CD`; validate the matching identifier
    and release when linking other public center metadata.
  - Hard-coded table of PSR release dates and cohort end dates (1 month,
    1 year, 3 years). Take dates from SRTR's release notes, not this table.
  - Sheet names and columns change between PSR releases.
- **Pitfalls:** forecasting from five overlapping release cohorts ignores
  published uncertainty.

## NicholasLinderWood/Status1A_Life_Expectancy

- **URL:** https://github.com/NicholasLinderWood/Status1A_Life_Expectancy
- **Commit:** `e0b9fa3`
- **What it is:** Python code for Wood et al., "Life expectancy without a
  transplant of status 1A liver transplant candidates", *AJT* 2021,
  doi:10.1111/ajt.16830. Uses `cand_liin`, `stathist_liin`, `statjust_li1`
  (Stata exports).
- **Useful:**
  - Builds start–stop intervals from status history (A file: transplant as
    event; B file: waitlist death as event) and a hand-written IPCW
    estimator, because transplant is informative censoring.
  - Edge cases: status rows created after allocation (begin = end =
    transplant date); off-by-one day when transplant follows the last row;
    administrative censoring.
  - MELD, MELD-Na, MELD 3.0 (with/without albumin), MELD-GRAIL-Na; decoding
    of match MELD from `CANHX_OPTN_LAB_MELD` (author unsure of the field).
  - Waitlist death = removal codes 8, 13, 5, excluding suicide.
  - Bootstraps by candidate, not interval.
- **Pitfalls:** age computed with `/365/25` (typo for `/365.25`);
  `x == np.nan` never true, so carry-forward never happens; MELD-GRAIL-Na
  rescaled by sample min/max; matching on padded Stata labels; MELD 3.0
  without the dialysis rule; misses removal codes 21 and 23 (deaths).

## bcollins92078/SRTS_liver_center

- **URL:** https://github.com/bcollins92078/SRTS_liver_center
- **Commit:** `84db599`
- **What it is:** Python notebooks extracting tables from PSR **PDFs** with
  Camelot for 116 adult liver programs, then correlating offer acceptance
  with an improvised "success" metric. `liver_centers.csv` is public
  center-level data.
- **Useful:**
  - Table row positions moved between releases; parse by row label.
  - PSR waitlist tables mix adult and pediatric listings.
  - Region assigned from the state prefix of the center code, which fails
    for the split states (Vermont, Virginia).

## rmahfouz/srtr-kidney-waitlist-calculator

- **URL:** https://github.com/rmahfouz/srtr-kidney-waitlist-calculator
- **Commit:** `2152427cd49072f3598bd6da9a0f896b78f83949`
- **Rechecked:** 2026-11-14, [src/outcomes.py](https://github.com/rmahfouz/srtr-kidney-waitlist-calculator/blob/2152427cd49072f3598bd6da9a0f896b78f83949/src/outcomes.py), source inspection only; other file assessments below remain dated 2026-11-01.
- **What it is:** Python competing-risks waitlist model on `CAND_KIPA`
  (deceased-donor transplant vs death or too sick), time to equivalent risk
  (TiTER), Cox and random survival forest models, Streamlit app. The 2026-11-14
  follow-up inspected only the outcome script; no data/outputs were accessed.
- **Useful:**
  - `src/outcomes.py`: collect every candidate event from removal code and
    transplant record, take the earliest, keep an `event_type` label.
  - Death from four sources: `CAN_DEATH_DT`, `PERS_OPTN_DEATH_DT`,
    `PERS_RESTRICT_DEATH_DT`, `PERS_SSA_DEATH_DT`.
  - Reported: about 183,000 adult kidney-only listings 2015–2019; at 5 years
    41% deceased-donor transplant, 18% died or too sick, 41% censored.
    C-index 0.57 for transplant vs 0.64 for death.
- **Pitfalls:**
  - Removal code 14 treated as deceased-donor transplant; it is "Transplant
    at another center (multi-listed)". Misses 18, 19 (deceased-donor), 21,
    23 (deaths).
  - The earliest-event selection includes dated other removals; an earlier
    dated removal takes precedence over a later death.
  - Living-donor transplant is censored; whether it should compete depends
    on the target estimand.
  - Follow-up cut-off from the data's maximum listing date, not the release.
  - Functional status mapped wrongly (codes 4 and 5 don't exist; Lansky
    4000-series ignored); two conflicting diagnosis code lists.

## TramAnhDoLe/data_clean_up

- **URL:** https://github.com/TramAnhDoLe/data_clean_up
- **Commit:** `9512077`
- **What it is:** cleaning of a local hospital dataset plus one notebook
  linking `TX_LI`, `TXF_LI` and follow-up immunosuppression on `TRR_ID`.
- **Useful:** picks one follow-up per time window by day ranges; the
  follow-up code (`TFL_FOL_CD`) already encodes the period.
- **Pitfalls:** `ffill()` without grouping copies one recipient's values
  into the next recipient's missing cells.

## lgragert/srtr-impute-pubsaf2306

- **Reviewed:** 2026-11-14, script only; not executed.
- **Source:** [construct_outcomes_vars_9loc.py](https://github.com/lgragert/srtr-impute-pubsaf2306/blob/7a1a8747b8b753f07cba83ba1de072fadc954b83/construct_outcomes_vars_9loc.py), commit `7a1a8747b8b753f07cba83ba1de072fadc954b83`.
- **Scope:** kidney HLA analysis, pubsaf2306, transplants from 2005.
- **Useful comparison:** explicit retransplant component and fixed censor date.
  It uses TFL_DEATH_DT only; the graft-years <= 1 disjunction can classify
  censored first-year follow-up as failure. Do not adopt it as a validated endpoint.
- **Access limit:** the README example's provenance is unresolved. No example
  values are reproduced here; associated data and outputs were not accessed.

## Found, not yet reviewed

Found on 2026-11-02 by GitHub code search for SAF column and file names
(`REC_TX_DT`, `CAN_LISTING_DT`, `TFL_DEATH_DT`, `PERS_OPTN_DEATH_DT`,
`CAN_REM_CD`, `REC_CTR_CD`, `tx_ki.sas7bdat`, `cand_kipa`). Not read yet and
**not** cleared for data access. Move an entry into a full section above once reviewed.

### R / R Markdown

- https://github.com/dyjohnson/opo_survival — data prep for kidney, liver,
  heart and lung from `TX_*` and `CAND_*`; death and censoring logic.
- https://github.com/dyjohnson/opo_survival_analysis — survival-benefit
  analyses by organ (2022).
- https://github.com/dyjohnson/heart_transplant_exceptions — heart exception
  requests; Cox models.
- https://github.com/dyjohnson/psr_heart — heart program-specific outcomes.
- https://github.com/08wparker/KDPI_decision_curve_analysis — KDPI decision
  curve analysis.
- https://github.com/08wparker/mixed_effects_survival_benefit_heart_tx —
  mixed-effects survival benefit, heart.
- https://github.com/08wparker/new_heart_allocation_policy — 2018 heart
  allocation policy.
- https://github.com/Healthcare-Allocation-Lab/survival_benefit_kidney —
  kidney survival benefit.
- https://github.com/kevinz1194/Kidney-Transplant-Disparities — candidate and
  recipient prep; `KDPI_for_EPTS.Rmd`.
- https://github.com/kevinz1194/Heart-Continuous-Score — 6-week waitlist
  death.
- https://github.com/danieljaechulahn/LVAD — LVAD candidates.
- https://github.com/danieljaechulahn/Adult-Nonstandardized-MELD-Exceptions —
  MELD exceptions; `NLRBCensoring.R`.
- https://github.com/mollywhite19/US-CRS-2.0 — heart candidate risk score.
- https://github.com/juliagegeran/geo_var_heart_tx_list — geographic
  variation in heart listing.
- https://github.com/ochristensen628/Kidney-Transplant-and-Place-Based-Disadvantage
  — kidney access and area deprivation.
- https://github.com/the-markup/investigation-organs — journalism project;
  R cleaning script and Python notebooks.
- https://github.com/bowang-lab/Transplant_Time_Series — liver data prep.
- https://github.com/petergraffy/environment_transplant_survival —
  environmental exposures and waitlist survival.
- https://github.com/ronirg/liver-rsf-waitlist-mortality — random survival
  forest, liver waitlist mortality.
- https://github.com/rziemba/SRTR_transplant_trends — kidney transplant time
  series.

### Reference implementations to cross-check derived variables

- https://github.com/CU-Anschutz-DOS-CORP/sas-macros — `ukdcdrisk.sas`, a SAS
  donor risk macro.
- https://github.com/akhan390/KDRI — KDRI re-estimated without race.
- https://github.com/akhan390/decision-curve-analysis-kdri — decision curves
  for KDRI.
- https://github.com/pairs-jh/beta — Stata `.do` files defining patient
  survival, graft survival and transplant date.

### Python, Julia, Stata

- https://github.com/adi2809/A-Data-Driven-Approach-towards-Improving-Deceased-Donor-Kidney-Utilization
  — links match-run data to SAFs.
- https://github.com/uclamii/liver_allocation_simulation — liver allocation
  simulation.
- https://github.com/jojal5/KidneyAllocation.jl — kidney allocation
  simulation (Julia).
- https://github.com/Anivader/LDLT_survival_benefit_ML_tool — living-donor
  liver survival benefit.
- https://github.com/criticalml-uw/DeepMASH — deep learning, MASH liver.
- https://github.com/Afarzindar/deep-survival — deep survival models.
- https://github.com/ceharvs/transplant2mongo — loads OPTN STAR files into
  MongoDB.
- https://github.com/rjcc/ic_v_ex — STAR data, Stata.
