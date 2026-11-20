# External code references

Legacy entries below were reviewed on 2026-11-01 unless noted. "Commit" is the commit read; later
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
- **Rechecked 2026-11-20** (same commit, lines [74-137](https://github.com/lgragert/srtr-impute-pubsaf2306/blob/7a1a8747b8b753f07cba83ba1de072fadc954b83/construct_outcomes_vars_9loc.py#L74-L137)):
  - The script is a port of a SAS program: the SAS statements are kept as
    comments, and one credits 2006 guidance on which death date to use.
  - Follow-up ends at the earliest of `TFL_ENDTXFU`, `PERS_RETX`, death and the
    fixed censor date. A comment says `TFL_LAFUDATE` is left out on purpose,
    because outside death sources (ESRD and SSDMF) extend follow-up past the
    last form. This is the clearest public example of `TFL_ENDTXFU` used as the
    end of ascertainment.
  - `PERS_RETX` counts as graft failure, and it also ends patient follow-up,
    so death after a retransplant is not counted for the first graft's
    registration.
  - No license file: cite, do not copy.
- **Access limit:** the README example's provenance is unresolved. No example
  values are reproduced here; associated data and outputs were not accessed.

## Focused source annotations — 2026-11-14

The 32 previously unreviewed links were screened at the commits below, with
selected source inspected for 31 and README/tree inspection only for the empty
trends repository. Two paper-linked repositories are added at the end. These are
bounded code-reading notes, not full repository audits or endorsed definitions.
Only the linked line ranges were inspected; code outside them remains unchecked.
Nothing was executed. Data files, rendered notebooks, saved outputs and model
artifacts were not opened. One source contains an identifier of unverified
provenance and is flagged below for sanitized follow-up.

File and field names below are observed in source, not dictionary-verified.
Operational rules describe that implementation; cautions identify consequences
or unanswered questions. Paper/code concordance and current clinical policy
were not independently established. The six legacy entries above retain their
original review dates and scope. Dependencies named are observed imports or
calls, not a complete environment specification.

### dyjohnson/opo_survival

- **Source / scope:** [data_set_prep_srtr_kidney2.Rmd, lines 1–200](https://github.com/dyjohnson/opo_survival/blob/3cc7651bb51797eb5d0365cc29b7924e65089f29/data_set_prep_srtr_kidney2.Rmd#L1-L200); commit `3cc7651bb51797eb5d0365cc29b7924e65089f29`. Targeted source inspection only.
- **Context:** Kidney candidate trajectories; R/haven, tidyverse, survival.
- **Data and operational rules:** Loads CAND_KIPA, STATHIST_KIPA, TX_KI, DONOR_DECEASED and INSTITUTION for 2018-11-01–2025-04-30; joins transplant follow-up by PX_ID.
- **What to learn:** Candidate-to-recipient linkage and explicit death/follow-up precedence are useful comparison points.
- **Pitfalls / limits:** The event flag includes TFL_LASTATUS D or R, but the selected death date prefers OPTN then SSA. Event flag and date must be reconciled; repeated transplant rows can multiply registrations. Only the kidney preparation excerpt was inspected, not other organs or interval/model code.

### dyjohnson/opo_survival_analysis

- **Source / scope:** [data_prep.Rmd, lines 1–200](https://github.com/dyjohnson/opo_survival_analysis/blob/4f0362aa46633c27191b0991fe66093bbcea8925/data_prep.Rmd#L1-L200); commit `4f0362aa46633c27191b0991fe66093bbcea8925`. Targeted source inspection only.
- **Context:** Cross-organ cohort construction; R/haven, MatchIt.
- **Data and operational rules:** Reads three candidate families, four TX families, INSTITUTION and HIST_OPO_TXC plus an external OPO-tier CSV. Separates person-level multi-organ listing with PERS_ID from registration-level transplant joins with PX_ID.
- **What to learn:** First transplant per registration and second same-organ transplant per person illustrate why identifier choice matters. The header describes matched cohort exports and reproducible per-cohort seeds.
- **Pitfalls / limits:** The center–OPO lookup selects the latest qualifying service record rather than matching every observation date. Multi-organ flags use all loaded listings; contemporaneous versus ever-listed eligibility needs explicit interpretation. Matching implementation and outcomes beyond the excerpt remain unchecked.

### dyjohnson/heart_transplant_exceptions

- **Source / scope:** [data_prep.Rmd, lines 1–200](https://github.com/dyjohnson/heart_transplant_exceptions/blob/b95b2a980eb1c297e1d9e90921c33acd5c1d1702/data_prep.Rmd#L1-L200); commit `b95b2a980eb1c297e1d9e90921c33acd5c1d1702`. Targeted source inspection only.
- **Context:** Heart exception requests; R/tidyverse and lubridate.
- **Data and operational rules:** Reads CAND_THOR, supplemental JustFormHR and StatusJustEpisode, plus a prebuilt full_list object. Joins justification attributes on JustId and center information on PX_ID.
- **What to learn:** Person-level overlapping-listing selection, grouped date filling and consolidation of same-day events show the event-table requirements for longitudinal exception analysis.
- **Pitfalls / limits:** The prebuilt pipeline is a dependency, not reconstructed here. Keeping the latest overlapping registration and taking last nonmissing values for same-day events are study-specific rules; ties and join multiplicity need checking.

### dyjohnson/psr_heart

- **Source / scope:** [psr_heart.Rmd, lines 1–200](https://github.com/dyjohnson/psr_heart/blob/aa66dd9b1b49fb67d83ee6bf390a0ea3812f8280/psr_heart.Rmd#L1-L200); commit `aa66dd9b1b49fb67d83ee6bf390a0ea3812f8280`. Targeted source inspection only.
- **Context:** Heart program ratings linked to recipients; R/readxl and haven.
- **Data and operational rules:** Reads TX_HR and CAND_THOR and a workbook of center ratings; joins REC_CTR_CD to CTR_CD-derived Center_Code.
- **What to learn:** Shows how public program-level tables can be combined with recipient records, including release-specific sheet handling.
- **Pitfalls / limits:** The inspected code selects the latest of three death dates with pmax. Its variable named dcd is DON_TY == C, which is also the filter applied to all recipients, making that predictor constant in this cohort. Kidney-derived scores and median imputation must not be adopted as validated heart definitions.

### 08wparker/KDPI_decision_curve_analysis

- **Source / scope:** [01_decision_curve_analysis.Rmd, lines 1–200](https://github.com/08wparker/KDPI_decision_curve_analysis/blob/6cb5ac2ecd8b729373a8136206107df993dbb467/01_decision_curve_analysis.Rmd#L1-L200); commit `6cb5ac2ecd8b729373a8136206107df993dbb467`. Targeted source inspection only.
- **Context:** Kidney KDPI decision curves; R/survival.
- **Data and operational rules:** Reads TX_KI and an external percentile mapping CSV; adult 2010–2015 transplants. Computes a KDRI linear predictor and derives graft-survival time.
- **What to learn:** Links score construction, reference-year normalization, survival prediction and threshold-based evaluation in one script.
- **Pitfalls / limits:** Failure date takes priority over death without a minimum-date comparison. The diabetes default assigns the unknown-status contribution to all remaining codes. Exact equality when extracting the five-year baseline hazard can return no row. Coefficients, mapping vintage and event construction are not independently validated.

### 08wparker/mixed_effects_survival_benefit_heart_tx

- **Source / scope:** [data_set_prep.Rmd, lines 1–200](https://github.com/08wparker/mixed_effects_survival_benefit_heart_tx/blob/70ce68d61a0881abc187f0dc1ee7da36aead927f/data_set_prep.Rmd#L1-L200); commit `70ce68d61a0881abc187f0dc1ee7da36aead927f`. Targeted source inspection only.
- **Context:** Heart center survival-benefit study; R/haven and tidyverse.
- **Data and operational rules:** Q3 2018 SAF inputs include CAND_THOR, STATHIST_THOR, STATJUST_HR1A/HR1B, TX_HR, DONOR_DECEASED and INSTITUTION; adult listings 2006–2015.
- **What to learn:** The preparation excerpt documents historical justification-file dependencies and center-volume eligibility, with follow-up attached by PX_ID.
- **Pitfalls / limits:** Event coding includes TFL_LASTATUS R as well as D; death-date precedence is OPTN then SSA rather than earliest available. Outcome flags, dates and repeat-transplant handling require reconciliation. The downstream mixed-effects model was not inspected.

### 08wparker/new_heart_allocation_policy

- **Source / scope:** [data_preparation.Rmd, lines 1–200](https://github.com/08wparker/new_heart_allocation_policy/blob/8f0a566c938d2d242b54a1b3c0197559156f887d/data_preparation.Rmd#L1-L200); commit `8f0a566c938d2d242b54a1b3c0197559156f887d`. Targeted source inspection only.
- **Context:** Heart allocation-policy comparison; R/haven and tidyverse.
- **Data and operational rules:** Combines CAND_THOR, TX_HR and historical STATJUST_HR1A/HR1B with supplemental pipe-delimited status 1–6 justification files.
- **What to learn:** Retrospective classification of older listings into newer status groups demonstrates the need to retain device, dose and hemodynamic histories and explicit policy dates.
- **Pitfalls / limits:** Device lists and clinical cutoffs are historical study rules, not current policy verification. A join omits an explicit key, and the excerpt overwrites status with text before comparing it with a numeric status code; inspect these before reusing the classification.

### Healthcare-Allocation-Lab/survival_benefit_kidney

- **Source / scope:** [data_prep_model_fit.Rmd, lines 1–200](https://github.com/Healthcare-Allocation-Lab/survival_benefit_kidney/blob/9dab91afbb9204da7f29a97e7c752aba90a02b61/data_prep_model_fit.Rmd#L1-L200); commit `9dab91afbb9204da7f29a97e7c752aba90a02b61`. Targeted source inspection only.
- **Context:** Kidney survival-benefit preparation; R/haven and tidyverse.
- **Data and operational rules:** The inspected excerpt references CAND_KIPA and TX_KI and groups registrations using PERS_ID and CAN_PREV_TX.
- **What to learn:** Its surrounding preparation logic distinguishes registration collapse, death-source consolidation and recipient follow-up; this is a useful area for later verified inspection.
- **Pitfalls / limits:** Further inspection is blocked: data_prep_model_fit.Rmd contains an embedded person-identifier literal whose provenance is not established. The value is not reproduced. Obtain confirmation that it is synthetic or inspect a sanitized source version before further review; do not open its data or outputs.

### kevinz1194/Kidney-Transplant-Disparities

- **Source / scope:** [KDPI_for_EPTS.Rmd, lines 1–200](https://github.com/kevinz1194/Kidney-Transplant-Disparities/blob/7e2775962e842e06de5639d4aa8b70f0a90c516e/KDPI_for_EPTS.Rmd#L1-L200); commit `7e2775962e842e06de5639d4aa8b70f0a90c516e`. Targeted source inspection only.
- **Context:** Kidney donor scoring for an EPTS-disparities analysis; R/haven.
- **Data and operational rules:** Uses DONOR_DECEASED and DONOR_DISPOSITION, selecting kidney organs and disposition codes, then joins a KDRI-to-KDPI mapping CSV.
- **What to learn:** Separates recovery eligibility, field transformations, score calculation and percentile conversion; makes capping and unknown-status substitutions visible.
- **Pitfalls / limits:** DCD is inferred from presence of an agonal timestamp. One age/creatinine branch subtracts the HCV contribution through a '- +' expression while others add it. The scaling factor is labeled 2021. These are source observations, not endorsed score definitions; exact coefficients and codes need authoritative verification.

### kevinz1194/Heart-Continuous-Score

- **Source / scope:** [6week_death_data_prep.Rmd, lines 1–200](https://github.com/kevinz1194/Heart-Continuous-Score/blob/a30051838eb60f20e149b194c9ed2b1918d7e7a1/6week_death_data_prep.Rmd#L1-L200); commit `a30051838eb60f20e149b194c9ed2b1918d7e7a1`. Targeted source inspection only.
- **Context:** Heart six-week mortality; R/tidyverse, haven and expss.
- **Data and operational rules:** Starts from a prebuilt heart_data_pipeline event CSV, then reads JustFormHRStat1–4 and joins by trimmed JustId. Listings are selected from 2019–2022.
- **What to learn:** The opening sections show event-based transplant censoring and separation of baseline, laboratory, hemodynamic and treatment fields. Section headings identify later interval, history and imputation steps.
- **Pitfalls / limits:** Bulk column renaming depends on source-column order. The prebuilt pipeline, later 14-day interval construction and six-week outcome code were not inspected, nor was correspondence with the published correction established.

### danieljaechulahn/LVAD

- **Source / scope:** [lvad_data_cleaning.Rmd, lines 1–200](https://github.com/danieljaechulahn/LVAD/blob/c11ef57ceec8f75f52b09deb5e1b485fff4787a8/lvad_data_cleaning.Rmd#L1-L200); commit `c11ef57ceec8f75f52b09deb5e1b485fff4787a8`. Targeted source inspection only.
- **Context:** Heart LVAD candidates; R/tidyverse and haven.
- **Data and operational rules:** Loads CAND_THOR/status history and supplemental JustFormHR, JustFormHRDataLink, RiskStratDataHR, status-specific forms and ThorSupportDevice.
- **What to learn:** WlregAuditId, JustId, PX_ID and DeviceId have distinct linkage roles. The code combines device codes, status criteria and free text to identify durable LVADs.
- **Pitfalls / limits:** Same-day selection uses maximum JustId; final candidate records use the first duplicated-PX_ID occurrence without an explicit clinical ordering. Repeated import blocks and inconsistent object names complicate reproduction. Device code lists remain release-specific and unverified.

### danieljaechulahn/Adult-Nonstandardized-MELD-Exceptions

- **Source / scope:** [NLRBCensoring.R, lines 1–200](https://github.com/danieljaechulahn/Adult-Nonstandardized-MELD-Exceptions/blob/fe7727d4c8833692b461706bc2eee7088a3d95fc/NLRBCensoring.R#L1-L200); commit `fe7727d4c8833692b461706bc2eee7088a3d95fc`. Targeted source inspection only.
- **Context:** Liver MELD exceptions; R/dplyr.
- **Data and operational rules:** Starts with a prepared candidatelist, institution and status-history objects; reconstructs pre-policy follow-up at 2019-05-14 and joins STATHIST_LIIN by PX_ID.
- **What to learn:** Makes post-removal death windows, administrative censoring, status-1 exclusion and allocation-versus-laboratory score decoding inspectable.
- **Pitfalls / limits:** The 180-day death window is measured from listing, not removal. Death-source priority is OPTN then SSA then candidate death. Transplant categories include hard-coded removal codes requiring codebook checking. Cohort preparation and later modeling were not inspected.

### mollywhite19/US-CRS-2.0

- **Source / scope:** [match-run-data.R, lines 1–135](https://github.com/mollywhite19/US-CRS-2.0/blob/55a1eb99da00b14a320200bc6b7f42cec79760ca/match-run-data.R#L1-L135); commit `55a1eb99da00b14a320200bc6b7f42cec79760ca`. Targeted source inspection only.
  Also [README.md, lines 1–37](https://github.com/mollywhite19/US-CRS-2.0/blob/55a1eb99da00b14a320200bc6b7f42cec79760ca/README.md#L1-L37).
- **Context:** Heart US-CRS 2.0 and match-run linkage; R.
- **Data and operational rules:** README describes continuous-to-weekly conversion and marginal structural mortality models. The inspected match-run script loads fitted models, weekly records and trimming thresholds.
- **What to learn:** Produces candidate/date risk summaries for later PTR linkage; distinguishes first-week hazard from six-week survival and retains model-specific predictions.
- **Pitfalls / limits:** Weekly covariates can differ from values at an intraweek offer, as the source notes. The actual PTR join, upstream weighting and fitted artifacts were not inspected. Readable coefficient calculations are a comparison aid, not verification of a deployed risk model.

### juliagegeran/geo_var_heart_tx_list

- **Source / scope:** [part2_analysis_final.do, lines 1–168](https://github.com/juliagegeran/geo_var_heart_tx_list/blob/7af488b2761b34ec9a31d169add2727dce736180/part2_analysis_final.do#L1-L168); commit `7af488b2761b34ec9a31d169add2727dce736180`. Targeted source inspection only.
- **Context:** Heart listing geography and center effects; Stata.
- **Data and operational rules:** Consumes a prepared final_sample.csv and variable_coding.do, with candidate characteristics, center/OPO identifiers, policy period and transplant counts.
- **What to learn:** Shows separate candidate-, center- and OPO-level terms, policy interactions and center-specific random effects.
- **Pitfalls / limits:** Center counts and volumes are repeated across candidate rows; the unit and weighting must be checked before interpreting center summaries. The inspected file does not establish geographic linkage or cohort construction. Several community-contributed Stata commands and local paths are required.

### ochristensen628/Kidney-Transplant-and-Place-Based-Disadvantage

- **Source / scope:** [data_prep_final.Rmd, lines 1–200](https://github.com/ochristensen628/Kidney-Transplant-and-Place-Based-Disadvantage/blob/68e757da6e09bca3e39a7a497015c11541b81000/data_prep_final.Rmd#L1-L200); commit `68e757da6e09bca3e39a7a497015c11541b81000`. Targeted source inspection only.
- **Context:** Kidney and kidney–pancreas access and place-based disadvantage; R.
- **Data and operational rules:** Loads CAND_KIPA, STATHIST_KIPA, supplemental candidate ZIP, SVI, SVM, DCI and a ZIP–tract crosswalk; adult 2014–2022 listings.
- **What to learn:** Explicitly separates single, concurrent and sequential registrations, using PERS_ID, PX_ID, transplant dates and waitlist end dates.
- **Pitfalls / limits:** End dates are chosen by precedence rather than earliest event. Bidirectional transplant-date filling can spread future information; comments already flag negative dialysis times. Registration-collapse logic needs tracing before reuse. Geographic linkage and final competing outcomes lie beyond the inspected excerpt.

### the-markup/investigation-organs

- **Source / scope:** [01_data/01_master_organs_data_clean.R, lines 1–200](https://github.com/the-markup/investigation-organs/blob/ba4042a893ac16a2b4b70888a30ec01c98e18bf8/01_data/01_master_organs_data_clean.R#L1-L200); commit `ba4042a893ac16a2b4b70888a30ec01c98e18bf8`. Targeted source inspection only.
- **Context:** Liver access journalism; R/tidyverse and sf.
- **Data and operational rules:** Source imports institution/hospital, candidate, donor, transplant and disposition CSVs plus CDC WONDER, OPTN counts and state geometry.
- **What to learn:** Demonstrates leading-zero ZIP preservation, state assignment from coordinates and normalization of labeled registry exports. Selection uses listing OR transplant within the study window.
- **Pitfalls / limits:** Adult groups include unknown age; spreadsheet-mangled age-band labels require repair. Redacted filenames do not establish safe provenance. Raw files, outputs and notebooks were not opened; the selected cleaning excerpt does not verify later aggregations.

### bowang-lab/Transplant_Time_Series

- **Source / scope:** [Models/common/dataloader.py, lines 1–149](https://github.com/bowang-lab/Transplant_Time_Series/blob/a85e29499a85d072fd657ec6d9829323eef4b405/Models/common/dataloader.py#L1-L149); commit `a85e29499a85d072fd657ec6d9829323eef4b405`. Targeted source inspection only.
  Also [Preprocessing/prep_data_liver.R, lines 1–140](https://github.com/bowang-lab/Transplant_Time_Series/blob/a85e29499a85d072fd657ec6d9829323eef4b405/Preprocessing/prep_data_liver.R#L1-L140).
- **Context:** Liver longitudinal prediction; R preprocessing and PyTorch.
- **Data and operational rules:** Preparation reads TX_LI, TXF_LI, CAND_LIIN and initial/follow-up immunosuppression text exports, linking by TRR_ID. The loader consumes per-record tensor sequences.
- **What to learn:** Shows ordering of repeated follow-up, drug grouping, padded variable-length batches and separate one-/five-year label blocks.
- **Pitfalls / limits:** Cause-of-death values are propagated from the last visit, multiple causes are excluded, and patients classified as surviving lose the last five follow-up years. Label padding uses -1 while features use zero; downstream masking must be checked. Hard-coded class-index ranges are cohort-specific. No tensors or outputs opened.

### petergraffy/environment_transplant_survival

- **Source / scope:** [code/daily_pollution_inputs.R, lines 1–96](https://github.com/petergraffy/environment_transplant_survival/blob/4d0a873be65ee4809c22c422f1013dd9380f318f/code/daily_pollution_inputs.R#L1-L96); commit `4d0a873be65ee4809c22c422f1013dd9380f318f`. Targeted source inspection only.
- **Context:** Cross-organ environmental linkage helper; R/data.table, Arrow and dplyr.
- **Data and operational rules:** The inspected helper expands follow-up into calendar months and aggregates external daily PM2.5/ozone by ZIP/year/month or ZIP/year.
- **What to learn:** Makes exposure coverage rules explicit: minimum 20 observed days monthly or 300 annually, plus file-metadata cache signatures and bounded-memory yearly processing.
- **Pitfalls / limits:** ZIP-level exposure is not an individual measurement. The helper does not establish exact person-time clipping within first/last months or adverse-outcome definitions; those caller scripts were not read. It writes a cache under data/cache when no destination is supplied; do not run unchanged in the package.

### ronirg/liver-rsf-waitlist-mortality

- **Source / scope:** [scripts/01_prepare_and_split_data.R, lines 1–41](https://github.com/ronirg/liver-rsf-waitlist-mortality/blob/30e717c4ca5409561e7b80ff4abb7477dc3644d5/scripts/01_prepare_and_split_data.R#L1-L41); commit `30e717c4ca5409561e7b80ff4abb7477dc3644d5`. Targeted source inspection only.
  Also [R/02_calculate_meld.R, lines 1–82](https://github.com/ronirg/liver-rsf-waitlist-mortality/blob/30e717c4ca5409561e7b80ff4abb7477dc3644d5/R/02_calculate_meld.R#L1-L82).
- **Context:** Liver waitlist mortality prediction; R/caret.
- **Data and operational rules:** The preparation script expects an already constructed data_for_model, excludes HCC and missing MELD3, and forms event-stratified training/test and training-only cross-validation sets. A separate score helper was also inspected.
- **What to learn:** Useful separation of holdout data from internal folds; exposes the required outcome, identifier and score columns.
- **Pitfalls / limits:** A binary 180-day flag treats all other records alike, so censoring before 180 days needs checking in evaluation. Raw SAF construction is not shown. The MELD helper is scalar and has no dialysis argument; its coefficients and bounds are not verified as allocation-policy definitions.

### rziemba/SRTR_transplant_trends

- **Source / scope:** [README.md, lines 1–2](https://github.com/rziemba/SRTR_transplant_trends/blob/556dc707923e51eff575d34ef224d3fd3ea7bc85/README.md#L1-L2); commit `556dc707923e51eff575d34ef224d3fd3ea7bc85`. README and tree only.
- **Context:** Kidney transplant time-series placeholder.
- **Data and operational rules:** The repository tree at this commit contains only README.md and .gitignore; the README gives a one-line project description.
- **What to learn:** Retain as a discovery lead, not an implementation reference.
- **Pitfalls / limits:** No analysis source, input specification, endpoint definition or executable workflow is available to annotate at this revision.

### CU-Anschutz-DOS-CORP/sas-macros

- **Source / scope:** [ukdcdrisk.sas, lines 1–135](https://github.com/CU-Anschutz-DOS-CORP/sas-macros/blob/29f5e021a74c9ae02dee10a63d325fba905dfb95/ukdcdrisk.sas#L1-L135); commit `29f5e021a74c9ae02dee10a63d325fba905dfb95`. Targeted source inspection only.
- **Context:** Liver UK DCD risk-score macro; SAS DATA step.
- **Data and operational rules:** The macro accepts donor age/BMI/warm ischemia, recipient age/MELD/prior transplant and cold ischemia; it returns a weighted score only when every input is nonmissing.
- **What to learn:** A small, isolated implementation with explicit strict thresholds and a cited derivation paper is useful for boundary-by-boundary comparison.
- **Pitfalls / limits:** The cold-ischemia documentation says minutes, but its threshold is 6 and its published-example inputs use values on that scale: resolve units against the cited article before use. Score coefficients were not independently checked; missing-input output behavior needs caller initialization. Other macros were not reviewed.
- **Rechecked 2026-11-20** (same commit; headers and parameter documentation only):
  - [kdpi.sas, lines 1–170](https://github.com/CU-Anschutz-DOS-CORP/sas-macros/blob/29f5e021a74c9ae02dee10a63d325fba905dfb95/kdpi.sas#L1-L170): KDRI and KDPI with a `version` switch between the 2024 refit (no race, no HCV) and the earlier formula. Unknown hypertension or diabetes history is filled with the reference population's share, taken from the OPTN mapping table the user loads; the scaling factor comes from the same table. Creatinine outside 0.01–40 is set to missing.
  - [meld.sas, lines 1–80](https://github.com/CU-Anschutz-DOS-CORP/sas-macros/blob/29f5e021a74c9ae02dee10a63d325fba905dfb95/meld.sas#L1-L80): MELD, MELD-Na and MELD 3.0, optional capping at 6–40, missing dialysis treated as no dialysis, and the OPTN policy periods for each score (the MELD-Na start date is left unresolved in the source).
  - Both are useful for comparing outputs on made-up donors and candidates. GPL-3: compare results, do not copy code. Coefficients were not checked against the defining papers.

### akhan390/KDRI

- **Source / scope:** [code/1_UNOS-registry-data-extraction/extractor.py, lines 1–40](https://github.com/akhan390/KDRI/blob/fbbd11037a2d9d0136ef8cbba2718d1d229aa661/code/1_UNOS-registry-data-extraction/extractor.py#L1-L40); commit `fbbd11037a2d9d0136ef8cbba2718d1d229aa661`. Targeted source inspection only.
- **Context:** Kidney registry extraction; Python/pandas and SQLite.
- **Data and operational rules:** The inspected extractor expects an existing SQLite database derived from UNOS-style kidney/pancreas and donor files, then exports selected rows to CSV.
- **What to learn:** Illustrates a separate extraction layer before modeling; input date-column mappings are explicit.
- **Pitfalls / limits:** The year argument is ignored in favor of a fixed SQL year, and exit() inside the loop stops after the first table. It is not a SAF loader or a verified implementation of race-free KDRI. The advertised model, SQL transformations and notebooks were not inspected.

### akhan390/decision-curve-analysis-kdri

- **Source / scope:** [trainingjob/train.py, lines 1–135](https://github.com/akhan390/decision-curve-analysis-kdri/blob/b0389e1f4eb0e6f027706beb01e5a081461c01b9/trainingjob/train.py#L1-L135); commit `b0389e1f4eb0e6f027706beb01e5a081461c01b9`. Targeted source inspection only.
- **Context:** Kidney graft-survival model training; Python/scikit-survival.
- **Data and operational rules:** Reads a prepared cloud CSV, indexes by TRR_ID, and uses REC_GRAFT_STAT and Graft_Survival_Time as the survival target.
- **What to learn:** Shows survival-forest fitting, parameter-grid search and artifact export; requires explicit preprocessing and endpoint construction upstream.
- **Pitfalls / limits:** The same held-out split selects hyperparameters and reports the best score; it is not an untouched final test set. The script performs cloud reads/writes at top level. Decision-curve calculation and KDRI reconstruction were not established from this file; no cloud objects were accessed.

### pairs-jh/beta

- **Source / scope:** [act_0/act_0_2/act_0_2_1/2.graft.survival.do, lines 1–28](https://github.com/pairs-jh/beta/blob/5e1c66fd90406797c2f678c66dcd2836157b8f13/act_0/act_0_2/act_0_2_1/2.graft.survival.do#L1-L28); commit `5e1c66fd90406797c2f678c66dcd2836157b8f13`. Targeted source inspection only.
- **Context:** Graft survival definitions; Stata.
- **Data and operational rules:** The source fragment refers to death, retransplant and several release-specific graft-failure dates, with administrative censoring.
- **What to learn:** Useful as a checklist of endpoint components and the explicit rule that failure tied with death may count in death-censored analysis.
- **Pitfalls / limits:** The published fragment is incomplete: acgf_dt is labeled without being generated, and the dcgf_dt expression is cut off. Administrative dates differ between sections. It is not directly runnable or a validated endpoint; companion files and the referenced older SAF fields remain unchecked.
- **Rechecked 2026-11-20** (same commit; Stata; no license file, so cite, do not copy). The folder is a set of Johns Hopkins teaching recipes for kidney SAFs. Files read in full:
  - [1.patient.survival.do](https://github.com/pairs-jh/beta/blob/5e1c66fd90406797c2f678c66dcd2836157b8f13/act_0/act_0_2/act_0_2_1/1.patient.survival.do#L1-L31): death is the earliest of `PERS_SSA_DEATH_DT`, `PERS_OPTN_DEATH_DT`, `PERS_RESTRICT_DEATH_DT` and `TFL_DEATH_DT`. For waitlist mortality, removal codes 8 (died), 13 (too sick) and 5 (medically unsuitable) count as death, and transplant removals are censored.
  - [2.graft.survival.do](https://github.com/pairs-jh/beta/blob/5e1c66fd90406797c2f678c66dcd2836157b8f13/act_0/act_0_2/act_0_2_1/2.graft.survival.do#L1-L28) and [15.duration.of.dialysis.do, lines 39–58](https://github.com/pairs-jh/beta/blob/5e1c66fd90406797c2f678c66dcd2836157b8f13/act_0/act_0_2/act_0_2_1/15.duration.of.dialysis.do#L39-L58): death-censored graft failure is the earliest of `TFL_GRAFT_DT`, two ESRD-linked failure dates, `PERS_RETX`, `REC_FAIL_DT` and a resumed-dialysis date; a failure on the day of death counts. The dialysis file fills kidney-pancreas grafts from `TFL_GRAFT_DT_KI` and `PERS_RETXKI`, moves a failure date before transplant to the transplant date, and caps each graft's failure date at the same person's next transplant date (by `PERS_ID`).
  - [5.acute.rejection.do](https://github.com/pairs-jh/beta/blob/5e1c66fd90406797c2f678c66dcd2836157b8f13/act_0/act_0_2/act_0_2_1/5.acute.rejection.do#L1-L148): rejection on a follow-up form is `TFL_ACUTE_REJ_EPISODE` codes 1 or 2 (treated or untreated); 998 is missing. The file has two window rules. The first ("simple version", line 7) keeps the scheduled 6-month and 1-year forms (`TFL_FOL_CD` 3, 6, 10) and the death, graft failure and lost-to-follow-up forms (800, 801, 998, 999) only when dated within 365 days. The later 6-month, 1-year and 2-year windows (lines 31–34) apply the day limit only to the exceptional forms: a scheduled form enters its window whatever its date, so a 1-year form dated after day 365 still counts. The 6-month exceptional list leaves out 801. Biopsy confirmation and treatment are separate indicators, combined by taking the maximum per `TRR_ID`.
  - [28.transplant.date.do](https://github.com/pairs-jh/beta/blob/5e1c66fd90406797c2f678c66dcd2836157b8f13/act_0/act_0_2/act_0_2_1/28.transplant.date.do#L1-L13): from candidate files, deceased-donor transplant is removal codes 4, 18, 19, 21 and 22; 14 (transplant elsewhere) and 15 (living donor) are not.
  - Pitfalls: the waitlist censoring line compares `can_rem_cd` with `death_dt` (a code with a date), so it does not do what its comment says; the two rejection window rules give different cohorts for the same window; the ESRD-linked dates exist only in some releases; removal code meanings were not checked against the release's format.

### adi2809/A-Data-Driven-Approach-towards-Improving-Deceased-Donor-Kidney-Utilization

- **Source / scope:** [kidney_utilization/labeling.py, lines 1–135](https://github.com/adi2809/A-Data-Driven-Approach-towards-Improving-Deceased-Donor-Kidney-Utilization/blob/75156d44d1e256a61dd6d042e522d6dd2166e8d8/kidney_utilization/labeling.py#L1-L135); commit `75156d44d1e256a61dd6d042e522d6dd2166e8d8`. Targeted source inspection only.
- **Context:** Kidney match-run outcome labels; Python/pandas.
- **Data and operational rules:** derive_match_labels takes offer rows and donor-disposition rows, preserving match ID, candidate ID, sequence, row order and kidney organ/disposition fields.
- **What to learn:** Distinguishes observed acceptance, placement without observed acceptance, and orphan acceptance flags; keeps an audit reason instead of collapsing every discrepancy into nonuse.
- **Pitfalls / limits:** If the acceptance column is absent, all offers default to N. Placement is evaluated at match-run level, without checking that the first accepting candidate is the placed recipient. Missing acceptance can therefore change run classification. The matching/linkage builder and code meanings were not reviewed.

### uclamii/liver_allocation_simulation

- **Source / scope:** [simulation/engine.py, lines 1–200](https://github.com/uclamii/liver_allocation_simulation/blob/39150fa4aaf855cde487a2d2a340977d9cd6ba10/simulation/engine.py#L1-L200); commit `39150fa4aaf855cde487a2d2a340977d9cd6ba10`. Targeted source inspection only.
- **Context:** Liver allocation simulator configuration; Python/pandas.
- **Data and operational rules:** Engine specifies candidate/organ playback, progression, initial-list and prior-transplant inputs; configuration includes HCC delay, MMaT rules and distance settings.
- **What to learn:** Keeps transplant, retransplant, relisting and other-removal outputs separate, suggesting distinct event records rather than one terminal-outcome flag.
- **Pitfalls / limits:** This is simulator state/configuration, not evidence that the input files are synthetic. Allocation algorithms and input provenance were not inspected. Mutable class-level state and relative output paths need checking across replications before execution.

### jojal5/KidneyAllocation.jl

- **Source / scope:** [src/preprocess.jl, lines 1–200](https://github.com/jojal5/KidneyAllocation.jl/blob/4a764a8cf0d9137222b318cd2077f3cfccde52c3/src/preprocess.jl#L1-L200); commit `4a764a8cf0d9137222b318cd2077f3cfccde52c3`. Targeted source inspection only.
- **Context:** Kidney allocation simulation with Québec data; Julia.
- **Data and operational rules:** Preprocessing expects local donor/recipient CSV schemas with CAN_ID, UPDATE_TM, OUTCOME and HLA columns; donor selection explicitly references Transplant Québec.
- **What to learn:** Status-history arrival/departure inference, missing-HLA handling and donor object construction are useful patterns for comparison.
- **Pitfalls / limits:** This is not a direct SAF implementation. Filling a missing HLA partner from the observed allele and using a far-future departure date encode assumptions. Arrival/departure uses the first row's listing date while ordering status separately. Clinical code meanings and KDRI implementation remain unchecked.

### Anivader/LDLT_survival_benefit_ML_tool

- **Source / scope:** [Codes/Analysis_main.py, lines 1–200](https://github.com/Anivader/LDLT_survival_benefit_ML_tool/blob/4e74c861bf5b277ad4db97159f01ccbf69644e44/Codes/Analysis_main.py#L1-L200); commit `4e74c861bf5b277ad4db97159f01ccbf69644e44`. Targeted source inspection only.
- **Context:** Living- versus deceased-donor liver survival modeling; Python.
- **Data and operational rules:** The main script consumes already prepared SRTR or UHN datasets and harmonizes age, sex, blood group, anthropometry, diagnosis and MELD with event/waiting-time columns.
- **What to learn:** Separates cross-source feature harmonization, matching and survival-model calls; matching retains living/deceased group membership.
- **Pitfalls / limits:** Raw registry cohort and endpoint construction are upstream and not inspected. Several alternative analyses are commented out, so named models are not all executed by this script. Local paths, imported helpers and optional GPU dependencies must be resolved; matched comparisons do not by themselves establish causal benefit.

### criticalml-uw/DeepMASH

- **Source / scope:** [model_scripts/data_processing.py, lines 1–200](https://github.com/criticalml-uw/DeepMASH/blob/9a66127230da4feee1a638d14cd4d2545186051d/model_scripts/data_processing.py#L1-L200); commit `9a66127230da4feee1a638d14cd4d2545186051d`. Targeted source inspection only.
- **Context:** Liver/MASH static and dynamic feature construction; Python/pandas.
- **Data and operational rules:** Reads a prepared candidate/transplant spreadsheet and STATHIST_LIIN; feature extractors preserve PX_ID and longitudinal dates.
- **What to learn:** Separates static listing information from status-history features and makes categorical encodings and imputation choices visible.
- **Pitfalls / limits:** Global replacement of 996/998 is not field-specific. ABO values not explicitly recognized become O, including unknowns; mean imputation is fit on the supplied frame. Split timing and outcome construction must be checked before reuse. No spreadsheets or model artifacts opened.

### Afarzindar/deep-survival

- **Source / scope:** [FeatureEncoder.py, lines 1–197](https://github.com/Afarzindar/deep-survival/blob/304dff85e8bb013b59127862dfa04fcad0ed3684/FeatureEncoder.py#L1-L197); commit `304dff85e8bb013b59127862dfa04fcad0ed3684`. Targeted source inspection only.
  Also [SurvivalAnalysis_Main.py, lines 1–140](https://github.com/Afarzindar/deep-survival/blob/304dff85e8bb013b59127862dfa04fcad0ed3684/SurvivalAnalysis_Main.py#L1-L140).
- **Context:** Liver/STAR-style deep survival pipeline; Python/scikit-learn and TensorFlow.
- **Data and operational rules:** Consumes prebuilt train/test CSVs with GTIME and horizon-specific graft-status targets. Separates numeric imputation/scaling from categorical encoding fitted on training data.
- **What to learn:** Useful pattern for reusing fitted preprocessing on test records and making unknown-category handling explicit.
- **Pitfalls / limits:** Feature selection is dtype-based: outcome exclusions occur only in the categorical branch, so floating-point targets could enter predictors. Integer measurements can be treated as categories. Older APIs appear in the source; compatibility and endpoint semantics were not executed or verified.

### ceharvs/transplant2mongo

- **Source / scope:** [import_scripts/add_patients.py, lines 1–157](https://github.com/ceharvs/transplant2mongo/blob/4e6070d43966a46cc7a126a22002643ed89207e4/import_scripts/add_patients.py#L1-L157); commit `4e6070d43966a46cc7a126a22002643ed89207e4`. Targeted source inspection only.
- **Context:** OPTN STAR import to MongoDB; Python.
- **Data and operational rules:** Reads tab-delimited .DAT records and a matching HTML header, with caller-supplied database, collection and optional identifier.
- **What to learn:** Illustrates schema-driven batch ingestion and explicit record-key selection across organ families.
- **Pitfalls / limits:** Only column names containing DATE receive date parsing; decimal and negative values remain strings. String identity tests are used for blanks, and a final empty insert batch is possible. It writes to MongoDB on execution; no database was contacted. This is a STAR ingestion example, not a SAF dictionary validator.

### rjcc/ic_v_ex

- **Source / scope:** [heart.sas, lines 1–167](https://github.com/rjcc/ic_v_ex/blob/a82d316df34208904b8ba3fe83de70a404d8e9dc/heart.sas#L1-L167); commit `a82d316df34208904b8ba3fe83de70a404d8e9dc`. Targeted source inspection only.
- **Context:** Heart preservation-fluid analysis; SAS extraction.
- **Data and operational rules:** Joins deceased-donor and thoracic STAR files on DONOR_ID; selects adult heart-only recipients and derives flush groups from codes plus free text.
- **What to learn:** Shows why donor procedure details may require a separate donor file and why coded/free-text classification needs a documented precedence.
- **Pitfalls / limits:** The cohort filters specific flush codes before free-text classification, so not every recognizable text value enters. Different downstream groupings collapse fluids differently. Code meanings were not checked against STAR documentation; the follow-up join is commented out and Stata models were not inspected.

### ClevelandClinicQHS/COMET

- **Source / scope:** [R/matching.R, lines 1–167](https://github.com/ClevelandClinicQHS/COMET/blob/62e77bf1aadc7ac5a8ea061054bf7d4711b45f78/R/matching.R#L1-L167); commit `62e77bf1aadc7ac5a8ea061054bf7d4711b45f78`. Targeted source inspection only.
  Also [R/accept_organ.R, lines 1–114](https://github.com/ClevelandClinicQHS/COMET/blob/62e77bf1aadc7ac5a8ea061054bf7d4711b45f78/R/accept_organ.R#L1-L114).
- **Context:** Lung allocation simulation linked by the COMET papers; R.
- **Data and operational rules:** Matching combines height, ABO, sensitization, distance and organ-count screens with LAS/CAS components, then nests ranked offers by donor/organ. Acceptance uses center, donor features, offer rank and fitted coefficients.
- **What to learn:** Clear separation of compatibility, priority and stochastic acceptance is useful for allocation-method comparisons. Candidate/donor identifiers differ from SAF keys and require an explicit adapter.
- **Pitfalls / limits:** Unseen centers map to a fallback level; simulated acceptance draws are not observed decisions. Fitted coefficients, synthetic generators, current policy concordance and initialization were not audited. Supports PMC11261589/PMC10956776 as implementation context, not validation of their results.

### survival-lumc/Validation_Under_Interventions

- **Source / scope:** [analysis_cox_model_validation.R, lines 1–200](https://github.com/survival-lumc/Validation_Under_Interventions/blob/33eaef1974961725026cc23426bd1f1bab3cfbbb/analysis_cox_model_validation.R#L1-L200); commit `33eaef1974961725026cc23426bd1f1bab3cfbbb`. Targeted source inspection only.
  Also [README.md, lines 1–8](https://github.com/survival-lumc/Validation_Under_Interventions/blob/33eaef1974961725026cc23426bd1f1bab3cfbbb/README.md#L1-L8).
- **Context:** Counterfactual prediction validation; simulation code linked by PMC11332371.
- **Data and operational rules:** The inspected Cox-validation section uses long person/visit data, time-varying treatment/confounders, artificial censoring and cumulative inverse-probability weights.
- **What to learn:** Contrasts never-treated and always-treated risks; shows that validation under an intervention needs its own weighting, beyond fitting a prediction model.
- **Pitfalls / limits:** The simulation assumes treatment continues once begun; its always-treated weights therefore need not vary over time. This assumption cannot be transferred silently to other interventions. Chronological order is required for cumulative products. README identifies this as simulation-study code and recommends ipeval for applications; ipeval itself was not inspected.


## SAS, Stata, SPSS and Python search — 2026-11-20

GitHub code search (repositories in any language) was run for SAF variable
names, including `REC_TX_DT`, `TFL_DEATH_DT`, `TFL_GRAFT_DT`,
`PERS_OPTN_DEATH_DT`, `PERS_SSA_DEATH_DT`, `TFL_LAFUDATE`, `TFL_ENDTXFU`,
`PERS_RETX`, `CAN_LISTING_DT`, `CAN_REM_CD`, `CAN_REM_DT`, `REC_CTR_CD` and
`TFL_PX_STAT_DT`, restricted to SAS, Stata (`.do`), SPSS (`.sps`), Python,
Jupyter, SQL and Julia. Web searches covered SRTR and OPTN pages, journal
supplements, SAS conference papers and data repositories. Results:

- Public SAS written against SRTR SAFs is rare: one heart cohort program and
  one macro library (below and above). SRTR's SAF pages describe the files and
  the dictionary and offer no sample programs.
- No SPSS syntax was found. Stata hits were `pairs-jh/beta` (above) and one
  teaching file (below). SQL and Julia hits matched only generic strings.
- GitHub code search indexes default branches only and returns at most 100
  results per query, so this is not exhaustive.

Only code was read. Data files, outputs and notebooks' saved results were not
opened.

### bnallamo/Golbus-Circulation-2020-Mechanical-Devices-Transplant

- **Source / scope:** [Circulation_Change in Mechanical Circulatory Support_Final Code.sas, lines 1–330](https://github.com/bnallamo/Golbus-Circulation-2020-Mechanical-Devices-Transplant/blob/12809004cfa1740af32d7111019ce5d32c838b4a/Circulation_Change%20in%20Mechanical%20Circulatory%20Support_Final%20Code.sas#L1-L330); commit `12809004cfa1740af32d7111019ce5d32c838b4a`. CC0.
- **Context:** Adult heart transplants before and after the October 2018 heart allocation change (Golbus et al., *Circulation* 2020); SAS on `TX_HR` plus the institution file.
- **Data and operational rules:** Adults by `CAN_AGE_AT_LISTING`; transplants in October 2018 dropped as a transition month; candidates transplanted after the change under an old status removed; Puerto Rico centers dropped; device type from `REC_VAD_TY`, `REC_VAD1`, `REC_VAD2`, `REC_ECMO` and `REC_IABP`; centers joined on `REC_CTR_ID`.
- **What to learn:** A worked example of setting policy eras by transplant date and of excluding the transition month.
- **Pitfalls / limits:** No outcomes are built. The center join checks only that the copied merge key equals its source column before merging; the merge keeps every transplant (`if A`) without checking that each found an institution row or that institution keys are unique. Era dates are written as literals; verify against the OPTN policy notice. Device code meanings were not checked against the release's formats.

### Vince-Jin/nyu

- **Source / scope:** [Visit 1/donor_st.do, lines 1–100](https://github.com/Vince-Jin/nyu/blob/4591bc016caabb35908422d7deae65459c8358e6/Visit%201/donor_st.do#L1-L100); commit `4591bc016caabb35908422d7deae65459c8358e6`. No license file.
- **Context:** Teaching exercise on living-donor mortality; Stata on `DONOR_LIVE`.
- **Data and operational rules:** Death from `PERS_SSA_DEATH_DT` only, administratively censored at the end of 2011; 90-day mortality set up with `stset`.
- **What to learn:** A minimal survival setup from the donor file.
- **Pitfalls / limits:** One death source only, so deaths missed by the Social Security file count as survival; the 2011 cut-off reflects when that linkage changed and must be reset for later releases.

### Olukhunlay-hub/kidney-transplant-immunosuppression-survival

- **Source / scope:** [survival_analysis_revision.ipynb](https://github.com/Olukhunlay-hub/kidney-transplant-immunosuppression-survival/blob/662381315eca75ed60d934cb040430093a6820f7/survival_analysis_revision.ipynb), code cells only; commit `662381315eca75ed60d934cb040430093a6820f7`. MIT. Code for a *PLOS ONE* paper (article e0339109).
- **Context:** Kidney immunosuppression regimens and survival; Python on an OPTN STAR extract, not SAFs.
- **Data and operational rules:** Graft time from `GTIME_KI`, patient time from `PTIME`; rows with nonpositive times dropped.
- **What to learn:** STAR files ship precomputed times and status flags, unlike SAFs, where they are built from dates.
- **Pitfalls / limits:** The graft event is taken from `PSTATUS` (patient status) rather than the graft status flag, so graft failure is likely mislabeled; the paper's text says graft failure is return to dialysis or retransplant with death censored.

### acmilannesta/dialysis_facility_kidney_tx

- **Source / scope:** [Cohort development/](https://github.com/acmilannesta/dialysis_facility_kidney_tx/tree/da97ccb20689f40a5948fd7f8a310bc01dd79603/Cohort%20development), SAS programs, variable and data step lines only; commit `da97ccb20689f40a5948fd7f8a310bc01dd79603`.
- **Context:** Dialysis facility profit status and waitlisting; SAS on USRDS core files and the USRDS copy of UNOS transplant data, not SRTR SAFs.
- **What to learn:** Competing first events (waitlisting, living- and deceased-donor transplant, death) as the earliest of their dates with a fixed study end.
- **Pitfalls / limits:** USRDS variable names differ from SAF names. The same author's `Adult_readmission` repository holds data files; they were not opened.

### Code outside GitHub

- **Stanford Digital Repository, `wp663jb5042`:** SAS/SQL and Stata programs for a UNOS STAR heart preservation-solution study (2023, CC BY), https://purl.stanford.edu/wp663jb5042. The file list loads only in a browser; not read.
- **NIDDK Central Repository, A2ALL retrospective dataset integrity check:** Appendix B has the coordinating center's SAS for constructed variables, https://repository.niddk.nih.gov/media/studies/a2all1/A2ALL_DSIC_Retrospective.pdf. It uses study variable names, not SAF names, and defines no graft failure or follow-up end.
