# Reference-informed follow-up, 2026-11-14

Reviewed default-branch commit `c36dcc26bfa4d5b7cc9b7762d150bff44b01fb51` in an isolated checkout. This is a focused scientific follow-up, not another whole-package audit. GitHub scope excludes unpushed work. Open reference PR #154 was inspected separately; its additions were not treated as merged evidence.

## Findings and decisions

| Finding | Evidence and consequence | Disposition |
| --- | --- | --- |
| Affirmative rejection becomes a non-event | In KI and both KP grafts, inpatient rejection is affirmative, `REC_POSTX_LOS` is missing, and a later positive follow-up is dated. Extraction succeeds; admission-first date selection yields NA and final binary outcome becomes zero. Three executed assertions fail. | Defect: extend [#21](https://github.com/VagishHemmige/sRtr/issues/21) with this reproducer. Keep #121's numeric-code defect distinct. Preserve occurrence independently from timing; onset fallback needs a decision. |
| Selected death composite is overwritten | Pipeline calls `srtr_composite_death(df)` with default precedence. Synthetic SSA death 2001, OPTN death 2003, last follow-up 2002: selected earliest death gives event 1; pipeline replaces it and gives event 0. Five executed characterization assertions pass. | Interface/scientific decision for [#5](https://github.com/VagishHemmige/sRtr/issues/5), before [#24](https://github.com/VagishHemmige/sRtr/issues/24) export: propagate policy or define precomputed-input contract. PMC11972892 supports an earliest-date use case, not a universal default. |
| PSR equivalence is overstated | Help calls ascertainment mode the SRTR PSR patient-survival method, but does not reproduce its full source set, cohort exclusions and reporting horizons. Official technical methods Section C checked. | Documentation correction under #24: describe a generic administrative mortality window requiring caller-established coverage. Do not change death precedence, same-day conventions or intentional post-follow-up graft failure by implication. |
| KP organ linkage remains unverified | Dictionaries list `TRR_ID` and `TRR_ID_PA`; current KP tests assume shared IDs. Labels do not establish actual TXF mapping. | Validation gap under [#37](https://github.com/VagishHemmige/sRtr/issues/37)/[#65](https://github.com/VagishHemmige/sRtr/issues/65). Verify mapping before implementing a two-ID join. |
| Same-stay repeat-transplant timing needs verification | Bundled LOS label references first transplant in the stay; code adds LOS to the row's transplant date. | Conditional concern, not a demonstrated real-SAF defect. Verify exact release semantics; admission-derived rejection timing remains a proxy. |

Existing negative-time/epsilon, all-missing-positive-date and missing-race findings remain owned by #120, #97 and #96. PDRI equation-copy provenance remains unresolved under #93; this review does not establish that the package coefficient is wrong. No duplicate new issues are proposed. Selective draft updates below were not posted.

## Coverage and independence

Six AI workstreams covered three paper groups, external code, official definitions and test design. Prior audit reports and issue diagnoses were withheld until first-pass delivery. Catalogue annotations and existing tests were visible: independent implementation assessment, **not blind literature interpretation**. First three tests were independently designed; composition and rejection checks followed cross-review reconciliation.

| Material | Completed | Limits |
| --- | --- | --- |
| 89 paper annotations | All read and dispositioned: [29 papers](papers-a.md), [30 papers](papers-b.md), [30 papers](papers-c.md); [inventory](coverage.json) | Paper reviewers verified targeted original passages for 11 papers. Test design checked two targeted papers, including one blocked in paper review. Not 89 new full-text/supplement reads. Access failures recorded individually. |
| 40 external repositories | All catalogue entries assessed in [code ledger](external-code.md) | Eleven original scripts rechecked: eight complete, three bounded. Remaining 29 annotation-only. No whole-repository certification or external code execution. |
| Official methods/codebooks | All three assigned catalogues read; [source dispositions](definitions.md) | Targeted PSR, Alliance PDRI copy, ADR and dictionary checks; not a full release comparison or resolution of conflicting equation copies. |
| Issues/PRs | All 70 open issue bodies inventoried for deduplication; relevant threads read after first pass; PR #154 excluded from current behavior | Not a new substantive review of all 70 issues. Definitions reviewer had issue bodies only. |

These are dated package-assessment records, not a second reference catalogue. Background facts remain in `reference/`. No raw transcripts, runtime logs or dependency bundles are committed. Ledgers preserve per-source dispositions so future reviews can distinguish considered, deferred and unverified material.

## Executed checks and proposed permanent tests

From an **isolated, inspected clone** with R and dependencies already installed:

```sh
bash tools/reference-review/run.sh
```

`AUDIT_RSCRIPT` may select another Rscript executable. The runner suppresses user/site startup files, disables live SAF tests, unsets `SRTR_WD`, and verifies a harmless non-vanilla child ignores project startup traps. It copies inspected package source/public metadata and these synthetic tests to `tempdir()`; original tests are not executed. Loaders are mocked with invented inline identifiers/dates. No patient data or real-SAF tests were accessed.

Actual runtime: Linux R 4.5.0; testthat 3.2.3, pkgload 1.4.0, dplyr 1.1.4, haven 2.5.4, arrow 26.0.1, sf 1.0-19. Child isolation passed. **Six cases: 21 passed expectations, three failed expectations, zero test errors/skips/warnings.** Four developer warnings about missing dplyr `filter_out` registration occurred during loading, outside tests. Exit is nonzero because rejection regression cases expose current behavior.

| Check | Result | Permanent role |
| --- | --- | --- |
| Positive report dates invariant to ordering/duplicates | 3 passed | Regular `add_txf_outcomes` test. |
| Repeat person/shared donor preserve transplant episodes | 5 passed | Regular `add_txf_outcomes` test; not real identifier validation. |
| Ascertainment extension affects only eligible mortality outputs | 5 passed | Regular outcome integration test. |
| Earliest-composite overwrite demonstration | 5 passed | Review-only characterization; do not enshrine overwrite as desirable behavior. |
| KI missing-LOS rejection | 1 passed, 1 failed | Regression accompanying an approved correction. |
| KP missing-LOS rejection, both grafts | 2 passed, 2 failed | Regression accompanying an approved correction. |

[Test rationale/source locators](new-tests/design.md). [Inert permanent-test patch](permanent-tests.patch) adds only the first three passing cases to owning existing files. It is not applied. Failing cases remain review-only until correction approval. Full package checks, installed-namespace tests, documentation generation and Windows execution were not performed. Synthetic checks establish code behavior, not clinical validity.

The frozen revision returned no combined commit statuses through the available endpoint; this does not establish whether all GitHub check-runs were absent or passed. No workflows changed or activated. The proposed tests can use existing synthetic CI after promotion; no additional workflow is warranted. Existing installed-namespace audit work remains separate.

## Scientific decision register

All choices are proposed, not approved. Published practice does not establish universal package defaults.

| Existing owner | Decision | Next useful check/evidence |
| --- | --- | --- |
| #5/#24 | Earliest versus precedence; preserve selected policy/provenance | Conflicting sources straddling cutoff must retain the selected policy through the pipeline. |
| #21/#60/#42/#118 | Occurrence, unknown timing, negative evidence and absent observation differ; report date is not onset | Missing-LOS regression; positive-undated, unknown-only and no-form cases; endpoint observation before general last contact; retrospective reports after death without silently assigning onset. |
| #24/#118 | Recorded failure, death-inclusive loss, relisting/retransplant composite and PSR endpoints differ | Same timeline under explicitly named definitions. Preserve intentional failure-after-follow-up behavior pending a separate decision. |
| #34/#36/#37/#38/#43/#65 | Person, registration, transplant, organ and donor pair are distinct units | Verified separate KI/PA IDs; repeated transplants; duplicate/missing IDs; donor pair losing an eligible member. |
| #6/#7 | Origin, delayed entry, competing event class and time-dependent exposure are separate | Listing/activation/transfer/policy/transplant timeline; no pre-treatment exposed time or duplicated person-time. Prefer a synthetic recipe before broad APIs. |
| #26/#29/#93/#96 | SAF release, score vintage, structural missingness and imputation differ | Numeric/character/factor unknowns; missing PAK history; reference-donor equation tests after source provenance resolves. |
| Deferred capabilities | External cancer linkage, historical geography, aggregate PSR ingestion and new scores require inputs/definitions beyond annotations | Retain scoped discovery leads; no new phenotype, coefficient or historical-coverage promise justified yet. |

## Selective draft issue updates

Link each update to this bundle at its published commit. No broad repeated boilerplate is needed.

**#21 — Rejection evidence:** At the reviewed commit, affirmative inpatient rejection plus missing `REC_POSTX_LOS` masks a later dated positive follow-up. The synthetic tests reproduce this for KI and both KP grafts: extraction retains positive reports, but final rejection indicators become zero. Preserve affirmative evidence independently from date availability. Choose timing representation explicitly; tests do not prescribe imputed onset. This differs from #121's numeric-label matching defect.

**#5, cross-link #24 — Composite propagation:** The pipeline recomputes death with default precedence, replacing a selected earliest composite. With SSA 2001, OPTN 2003 and follow-up 2002, the executed example changes a selected death event to censoring. Define how the chosen policy reaches the pipeline before export; source-vector generalization alone does not resolve this. PMC11972892 Methods supplies an earliest-date use case, not a mandatory default.

**#24 — Qualify PSR language:** Suggested wording: “This option uses an administrative mortality window but does not reproduce the complete SRTR program-specific report patient-survival calculation. The caller must establish source coverage and select the study population and reporting horizon.” The helper does not reproduce the PSR source set/cohort exclusions/horizons. Preserve current scientific choices pending separate decisions.

**#60/#21 — Observation coverage:** Record endpoint-assessed dates separately from general contact. Registry-linked cancer, center-reported malignancy and treated-rejection reports differ in coverage/timing. Add positive-undated, unknown-only and no-observation cases; none should automatically mean verified negative. PMC10919340 cancer-registry censoring is a study-specific example, not a SAF-wide rule.

**#37/#65 — KP linkage:** Existing synthetic KP tests assume a shared transplant identifier. Verify the release-specific role of `TRR_ID_PA` before claiming pancreas follow-up completeness. Then add distinct organ IDs, repeated transplants and row-preservation assertions. Labels establish a question, not the correct join.

Other decision-table criteria can be added when their owning work is taken up. This follow-up does not reopen resolved claims or replace the prior complete issue review.
