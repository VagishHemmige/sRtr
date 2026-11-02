# Methodology review

One section per methodological question. Each gives SRTR's practice (where
known), how other projects handled it, what sRtr does now, and the related
issues. Sources are in [`web-sources.md`](web-sources.md) and
[`repositories.md`](repositories.md). Started 2026-11-02; extend as issues
are worked.

## Waitlist outcomes and competing risks

- **SRTR:** transplant and death compete. About 1% of candidates die or are
  transplanted before their removal date, so the earliest of removal, death
  and transplant dates matters. Some removals for transplant have no
  transplant record.
- **Others:** the kidney calculator takes the earliest event across sources
  and keeps an event-type label, but miscodes removal code 14, censors
  living-donor transplant, and counts deaths after unrelated removal. Wood
  et al. use IPCW because transplant is informative censoring.
- **sRtr:** no waitlist outcome function yet.
- **Decisions to make:** death window (on the list vs from listing);
  living-donor transplant as competing or censored; whether "too sick" and
  "medically unsuitable" count as death.
- **Issues:** #6, #11

## Death ascertainment and censoring

- **SRTR:** precedence OPTN > SSDMF > CMS. Patients not reported dead in any
  source are assumed alive. External sources under-count deaths. Some
  calculations exclude deaths after loss to follow-up.
- **Others:** the kidney calculator takes the earliest of four sources.
- **sRtr:** `srtr_composite_death()` combines OPTN, SSA and TFL with OPTN
  first; `add_tte_outcomes()` counts SSA deaths after last follow-up but
  censors survivors at last follow-up, which overstates mortality.
- **Issues:** #5, #18, #22

## Status history and time-varying covariates

- **SRTR:** not reviewed yet.
- **Others:** Wood et al. build start–stop intervals from `STATHIST_*`,
  handling post-allocation rows, an off-by-one day at transplant, and
  administrative censoring. Carry-forward must be grouped by candidate
  (the data_clean_up notebook shows the failure).
- **sRtr:** no status history support yet.
- **Issues:** #7, #9

## Post-transplant follow-up

- **SRTR:** graft failure recorded before the transplant date is censored
  at day 0.
- **Others:** day-range windows instead of the follow-up code.
- **sRtr:** `add_txf_outcomes()` uses every follow-up form, including those
  after graft failure, and dates events by the form date.
- **Issues:** #10, #16, #21, #22

## Joining files

- **SRTR:** keys and grain are not documented reliably; the dictionary labels
  `TRR_ID` a "unique key" in `TXF_KI`/`TXF_KP`, which have many rows per
  recipient. Keys are numeric in every file. `TX_ID` is shared across organ
  files for multi-organ transplants; `TX_KP` has `TRR_ID` and `TRR_ID_PA`.
- **Repeated columns:** files share many non-key columns (50 between `TX_KI`
  and `CAND_KIPA`; 240 between `TX_KI` and `TX_LI`), so a join without `by`
  silently drops rows and a join with `by` makes `.x`/`.y` pairs.
- **Others:** the kidney calculator avoids joins by using columns repeated in
  `CAND_KIPA`; Wood et al. copy only needed columns by `px_id` lookup; the
  data_clean_up notebook intersects ID sets across three files and reports
  the counts lost.
- **sRtr:** two joins, both in `add_txf_outcomes()`, without `by`.
  `load_srtr_file()` can only filter on `TRR_ID`.
- **Issues:** #3, #34, #35, #36, #37, #38, #39, #40

## Missing values

- **SRTR:** "Unknown" is missing. Missing values are multiply imputed
  (chained equations, 10 iterations). For program evaluation only, missing
  values get the least beneficial value; that is an incentive device, not a
  research method.
- **Codebook:** several kinds of missing (unknown, not applicable, not done,
  pending, cannot disclose, indeterminate, partly known) and inconsistent
  code numbers across formats.
- **sRtr:** `srtr_normalize_missing()` maps a hand-written list to one
  replacement; 13 labels don't match their formats; level order changes.
- **Issues:** #19, #20, #27, #28, #29

## Implausible values

- **SRTR:** conservative plausible ranges set by expert opinion; values
  outside are treated as missing. Ranges not found published. Separately,
  1st/99th percentile truncation for modelling.
- **Others:** ad hoc cut-offs (BMI ≤ 0 or > 100).
- **sRtr:** none, apart from a height check in `add_pdri()`.
- **Issues:** #30, #31, #32

## Codes, labels and codebook versions

- **Others:** every project reviewed hard-codes code lists, and each has
  errors; label matching breaks on padded Stata labels.
- **sRtr:** labels from a single undated snapshot; codes missing from a
  format become NA.
- **Issues:** #2, #15, #26

## Scores

- **MELD family:** coefficients and bounds to come from the primary papers
  and OPTN policy, not from other code (#8). Match MELD decoding (#9).
- **PDRI:** implemented in `add_pdri()`.

## Geography

- **OPTN regions:** Vermont and Virginia are split between regions; sRtr
  assigns each whole state to one region, and "Northern Virginia" is dropped
  by a join (#14).
- **PSR data:** public center-level tables join on `CTR_CD == OTCCode` (#13).
