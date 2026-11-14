# Reference-driven synthetic checks

Target: `c36dcc26bfa4d5b7cc9b7762d150bff44b01fb51`, isolated
`srtr-reference-followup` workspace, 2026-11-14. Proposed review artifacts only;
not installed package tests. No R execution by this reviewer. Coordinator owns
execution and runtime/dependency reporting. No patient data, data files or
`data/` changes. All fixture values are invented inline; `SYNTHETIC-*` strings
make their provenance explicit. Column names come from package input contracts;
`PERS_ID` and `DONOR_ID` are retained metadata for the identity stress case, not
a claim that the cited papers name those exact SAF fields.

## Scope and independence

Read AGENTS.md, REVIEWING.md, PACKAGE_REVIEW.md and reference/README.md; applied
the r-testthat guidance. Read the complete outcome and composite-death source,
existing outcome tests and test helpers, startup hooks, and targeted loader
source. Inspected selected new PMC annotations and repository annotation
locators, not earlier audit artifacts, issue discussions or tools/audit tests.
Existing package tests contain issue numbers; those were unavoidable source
context, not read as issue findings. This is a focused test-design follow-up,
not a full test/CI or package audit.

The first three checks were independently designed. After that first-pass
design was sent, the coordinator supplied another reviewer's composition
observation and asked for the fourth check. That check is explicitly
cross-review reconciliation, not independent discovery.

## Cases

| Check | Source and intended contract | Code path and existing overlap | Why meaningful / limitation |
| --- | --- | --- | --- |
| Report order and duplicates | PMC11426084, Exposures: malignancy comes to center attention, often at annual follow-up. The contract under test is earliest **positive report**, not clinical onset. | `add_txf_outcomes()`; existing cases test one positive form and general sorting but do not combine earlier negative reports, unordered repeated positives and duplicate forms. | Duplicating or permuting records must not create a second event or shift its observed report date. Does not infer onset between visits or validate a de novo cancer definition. |
| Repeat person and donor pair | PMC11935373, Methods/Table 1: recipient outcomes within shared-donor pairs; repeat transplants occur. `dyjohnson/opo_survival_analysis` annotation at `4f0362aa46633c27191b0991fe66093bbcea8925`, data_prep.Rmd 1–200, distinguishes person and registration/transplant units. | `add_txf_outcomes()` -> loader filter -> per-TRR matching; existing simple cohorts have unique unrelated IDs. | One person has two transplants, one of those shares a donor with another person. Only the correct episode receives its positive form. Preserve cohort order, rows, IDs and metadata. This is outcome attachment, not a donor-pair matching algorithm or validation of candidate-to-transplant linkage. |
| Ascertainment extension | Outcome helper's documented death-window contract; PMC11935373 illustrates distinct mortality/graft endpoints, not authority for the package's definitions. | Full `add_time_to_event_outcomes()` pipeline with only file loading replaced. Existing tests compare follow-up versus ascertainment and graft invariance separately. | Extend a fixed ascertainment date: an already observed death is unchanged, a newly eligible death changes status, a survivor gains exactly 730 days, and **all other columns** remain unchanged. Also retains the documented graft event after graft last-follow-up but before death. Tests cross-outcome isolation without prescribing a different censoring rule. |
| Death-composite composition probe | Existing `srtr_composite_death(prefer_earliest=TRUE)` contract versus outcome pipeline's unconditional recomputation. Introduced during cross-review reconciliation. | `srtr_composite_death()` -> `srtr_time_to_event()` contrasted with `add_time_to_event_outcomes()`; existing composite tests cover source choice, but not passing a chosen composite through the full pipeline. | SSA 2001, OPTN 2003, follow-up 2002: caller-selected earliest date gives death event 1; pipeline replaces it with 2003 and gives death event 0. A graft failure in mid-2001 is counted by the pipeline. This is current-behavior characterization and an API/scientific-choice observation, **not** a test that earliest is the correct default. Do not install this contrast as a permanent guarantee before the maintainer resolves the contract. |

The report-after-death scenario is left as an unresolved scientific question,
not encoded as an expected failure: a clinical event might precede death while
its report date follows it. Choosing automatic suppression would silently
equate report timing with onset. Existing all-missing-positive-date concerns
were not duplicated in these new checks.

### Reconciliation addition: affirmative rejection with missing admission duration

`test-reference-rejection-evidence.R` adds two proposed regression cases after
the coordinator supplied a second papers-a observation. These are not independent
discoveries. Both inpatient and later follow-up reports affirm treated rejection,
but `REC_POSTX_LOS` is missing. The current admission-first `case_when()` selects
a missing date and `srtr_time_to_event()` consequently returns binary zero.
The KI case and both KP grafts assert positive follow-up evidence survives and
the binary indicator is one. They deliberately do not assert which onset date
should be assigned. Missing timing must not erase known event evidence; whether
to retain missing onset, use a report-date proxy or expose separate timing/evidence
outputs remains a maintainer decision. The passing positive-report-date assertions
separate extraction from the suspected downstream loss. Existing tests exercise
known admission duration and no inpatient rejection, but not this combination.

PMC11426084's distinction between report and onset motivates avoiding a chosen
timing fallback here; it is malignancy context, not a source defining rejection
or admission-duration imputation. The affirmative rejection label is the existing
package contract. These checks are expected from source inspection to fail at
the binary assertions; actual execution is the coordinator's responsibility.

## Source verification

- [PMC11426084](https://pmc.ncbi.nlm.nih.gov/articles/PMC11426084/): independently
  opened and read targeted Exposures/Study population passages, notably the
  annual reporting statement, on 2026-11-14. No complete-paper reading claim.
- [PMC11935373](https://pmc.ncbi.nlm.nih.gov/articles/PMC11935373/): opened and
  inspected targeted paired-recipient/Table 1 and retransplant passages on
  2026-11-14; combined with the Methods annotation in batch-08. Exact censoring
  combination remains unverified here. Its death-inclusive graft endpoint is
  not imported into these death-censored package tests.
- [PMC11317850](https://pmc.ncbi.nlm.nih.gov/articles/PMC11317850/): repeat
  transplant inclusion noted in batch-11, but independent retrieval returned
  a browser-check page. Not needed to establish a clinical expected value.
- [dyjohnson/opo_survival_analysis source](https://github.com/dyjohnson/opo_survival_analysis/blob/4f0362aa46633c27191b0991fe66093bbcea8925/data_prep.Rmd#L1-L200):
  annotation-only context in this pass; source code not independently retrieved.
  No data, external repository output or patient-level artifact opened.

## Execution prerequisites

No `.Rprofile` or `.Renviron` appeared in the isolated tree inventory.
`R/zzz.R` has no `.onLoad`; `R/internal_env.R` only creates an empty environment.
`helper-srtr.R` requires both `SRTR_LIVE_TESTS=true` and nonempty `SRTR_WD` for
live tests. Other inspected helpers construct synthetic in-memory fixtures.
The proposed file replaces only the package's `load_srtr_file`, leaving
derivations real; it does not call the actual SAF reader or write files.

Before execution, the coordinator must use the PACKAGE_REVIEW.md isolated
runner: empty persistent startup files with absolute `R_ENVIRON_USER` and
`R_PROFILE_USER`, fresh `Rscript --vanilla`, first statements setting
`SRTR_LIVE_TESTS=false` and unsetting `SRTR_WD`, and validated harmless child
startup isolation. No connected checkout or active RStudio session.

After loading the inspected package with helpers disabled, execute this
directory in the sRtr test namespace (so `local_mocked_bindings()` finds the
package's own loader). For example, within the safeguarded process:

```r
pkgload::load_all(".", helpers = FALSE)
testthat::test_dir(
  "tools/reference-review/new-tests",
  package = "sRtr", load_package = "none", reporter = "summary"
)
```

Use an available testthat version exposing `local_mocked_bindings`; package
DESCRIPTION currently declares only testthat >= 3.0.0. Loading the package
may need all Imports including arrow; this design does not claim dependencies
are installed. No snapshots, network services, real SAF tests, generated
documentation or package checking are needed for these focused probes.
Synthetic results establish software behavior only. The maintainer still
owns release-specific field coding, form completeness and clinical validation.
