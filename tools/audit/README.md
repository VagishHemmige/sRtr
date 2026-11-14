# Synthetic checks retained from the package review

Small, reusable reproductions and proposals, not a replacement for a fresh review.
No package functions, installed tests or active workflows are changed by this bundle.
It is excluded from package builds. No patient data, raw review output, downloaded
runtime, or reviewer transcripts are included.

## Run

Use a separate, inspected checkout with R, package Imports, `pkgload`, `testthat`
(3.2.3 or newer), `withr` and `sf` installed. Arrow must support parquet.
From its repository root, in Bash (Git Bash on Windows):

```sh
bash tools/audit/run.sh contracts
bash tools/audit/run.sh installed
bash tools/audit/run.sh decisions
```

The contract and installed checks return nonzero when a discrepancy remains.
The decisions mode reports observed behavior without asserting a selected policy.
The commands do
not download dependencies. `AUDIT_RSCRIPT` may name an explicit Rscript executable.
The installed check installs only this package into a temporary library.

Inspect startup, source and metadata provenance before execution on a different
revision. The launcher disables live tests, unsets the data directory, disables
startup files and uses `--vanilla`. A harmless synthetic startup trap checks an
inheriting child without `--vanilla`. Package code and public metadata are copied
to `tempdir()`; original package tests and user files are not copied or executed.
File checks generate their own tiny SAS/parquet files in temporary directories.
Follow-up tests mock the loader; they establish derivation behavior, not actual
SAF loading or registry validity. The installed check deliberately avoids
`load_all()`, attachment and metadata injection.

## Recorded execution

Rechecked 2026-11-14 against default-branch commit
[`8bc630d95716989d4c12eadb01eb2cf2449af241`](https://github.com/VagishHemmige/sRtr/commit/8bc630d95716989d4c12eadb01eb2cf2449af241).
These are adapted checks from the review of `ebd869a`, not an independent new audit.
Only documentation/comments in package R code changed between those revisions;
the existing tests and workflows did not change.

Personally executed on Linux with R 4.5.0, testthat 3.2.3, pkgload 1.4.0,
dplyr 1.1.4, haven 2.5.4, arrow 26.0.1 and sf 1.0-19:

- Contract checks after review cleanup: 18 cases; 30 passing expectations, 14 failed expectations,
  four errors, two warnings, no skips. Four cases pass completely. Failures remain
  visible rather than being converted into expected failures or skipped.
- Installed package: installation succeeds; both factor and variable label calls
  fail because the dictionary/formats lookup does not find installed metadata.
- Parent/child startup isolation passes in both modes.
- The retained time-conversion proposal was executed in the earlier isolated
  proposal check: four passing expectations. The redundant SAS proposal was
  removed; existing loader tests already read synthetically generated SAS files. Both patches pass
  `git apply --check`. The CI step itself has not run on GitHub.
- Decisions mode observes selection of SYNTHETIC SAS when both formats exist;
  it does not count that observation as a defect or approved preference.
- Development loading also emits Arrow/dplyr method-registration warnings
  with this dependency combination; these are separate from the two date warnings.

No real-SAF, Windows, full-package check or vignette run is claimed for this PR.
The original review's package-suite results are historical, not a new execution.

## Expectations and destinations

The test descriptions are the identifiers; no private report IDs are needed.
Issue links below explain the proposed acceptance contracts. A failing candidate
is not authorization to change behavior or automatically a settled scientific rule.

| Checks | Independent basis and disposition |
| --- | --- |
| PDRI retains caller dot columns; character missing race | Preserve caller data and missingness across representations; [column loss](https://github.com/VagishHemmige/sRtr/issues/99) and [missing race](https://github.com/VagishHemmige/sRtr/issues/96). Retain failing candidates until fixes are approved. |
| No-op ordered factors; repeated factor labels | A transformation with no matched missing code preserves levels/order; applying labels twice must not erase values. [Factor order](https://github.com/VagishHemmige/sRtr/issues/20), [repeat labeling](https://github.com/VagishHemmige/sRtr/issues/15). Promote with fixes. |
| Undated positive follow-up forms | Missing date is not an infinite date; [undated forms](https://github.com/VagishHemmige/sRtr/issues/97). Retain failing candidate. |
| Pre-origin event with epsilon | A negative raw interval must not become valid through the offset; [negative-time finding](https://github.com/VagishHemmige/sRtr/issues/120). Documentation contract, not a censoring-policy assertion. |
| Time units | Hand-counted 366-day leap-year interval. Passing; complete permanent-test proposal below. |
| Follow-up table keys | Canonical `TX_` to `TXF_` mapping for seven organs; passing. Mocked loader proves routing only. Add to existing outcome tests when expanding organ integration. |
| PDRI raw versus labeled input | Equivalent representation should preserve the score; passing. Retain as integration candidate, not coefficient validation. |
| Raw versus labeled index rejection | Equivalent code/label should give equal status, date and time; [representation mismatch](https://github.com/VagishHemmige/sRtr/issues/121). Does not approve length-of-stay as a clinical onset date. |
| Empty composite death | Typed empty output; passing. Merge into existing composite tests if not covered by a later revision. |
| Unknown factor normalization | Bundled SRLSTT maps U to U: Unknown; [normalization gap](https://github.com/VagishHemmige/sRtr/issues/19). Missing-code policy still needs variable-specific validation. |
| Orchestration caller columns | Preserve pre-existing caller column; [orchestration](https://github.com/VagishHemmige/sRtr/issues/24). Retain candidate. |
| Missing transplant identifiers | Two unknown keys do not establish identity; [missing-key match](https://github.com/VagishHemmige/sRtr/issues/123). Retain candidate. |
| Uppercase extension | [Case discovery](https://github.com/VagishHemmige/sRtr/issues/125). Retain failing candidate. |
| Duplicate keys (decision-dependent) | [File-selection policy](https://github.com/VagishHemmige/sRtr/issues/124). `decisions.R` observes current selection. Alternatives: reject ambiguity, document format precedence with a message, or require explicit selection. Maintainer choice precedes any permanent expectation. |
| Empty ranking; metadata collisions | One result per candidate per help contract; [ranking errors](https://github.com/VagishHemmige/sRtr/issues/126). No collision renaming policy is prescribed. |
| Installed label calls | Exported functions should work with `sRtr::` alone; [namespace lookup](https://github.com/VagishHemmige/sRtr/issues/90). Separate process catches what development loading masks. |

Field names are from the bundled public dictionary. Every fixture value is
fabricated: IDs 900001+, year-2000 dates, and planar unit squares. The rejection
label comes from the bundled code mapping. Clinical interpretation is discussed
in [database background](../../reference/codebook-notes.md) and
[methodological background](../../reference/methodology-review.md).

## Proposed ongoing testing changes

| Priority | Proposal | Benefit, cost and prerequisite |
| --- | --- | --- |
| First | [regular-tests.patch](proposals/regular-tests.patch) | Appends one exact time-conversion test to the existing time-to-event tests. Four arithmetic/status/date expectations, no files or network. The existing loader suite already tests SAS filtering with column projection; no duplicate proposal is retained. |
| First, with namespace repair | [installed-ci.patch](proposals/installed-ci.patch) | Adds the installed check after the main package check in the existing OS/R matrix. `!cancelled()` allows it to run after an earlier failure without continuing a canceled job; failures remain visible and cannot prevent the main check. One temporary install per job; no new downloads beyond existing dependencies. Currently fails on known metadata lookup: do not activate as a green gate before the repair. Windows/Git Bash and older R still require CI validation. |
| With each approved fix | Move relevant failing cases next to their existing function tests | Demonstrate failure before repair and success after; avoid a permanent separate regression suite. Strengthen numeric/labeled and empty/missing matrices instead of duplicating these exact examples indefinitely. |
| Next | Unmocked cross-function synthetic file → label → normalize → outcome check | Existing mocked derivations do not establish the complete path. Add organ-specific KI/KP/thoracic fixtures after namespace and representation issues are resolved; keep clinical onset and censoring decisions explicit. |

Patches are inert. Review with `git apply --stat tools/audit/proposals/*.patch`;
check applicability with `git apply --check` on each. Do not apply them on a
connected working folder. Regular tests should then run under the same process
isolation. No recurring job, new workflow, or real-data CI is proposed.

## What was not carried forward

- The old assertion censoring every graft failure after last follow-up was
  rejected: it encoded a scientific preference. PR 130 now documents retention
  of a failure before death. The negative raw-time check is a separate concern.
- Printed PDRI coefficient discrepancies, rejection date proxies and all-missing
  coverage totals remain scientific questions, not approved regression values.
  The rounded Table 2 spot-check is not included as coefficient validation.
- Persistence remains source-inspection evidence; this runner never invokes
  `permanent = TRUE` or rewrites HOME. The proposal does not retest that path.
- Documentation scans, exploratory metadata inspection, duplicated source-only
  probes, runtime-install scripts, logs and raw output were omitted. The original
  audit archive retains history; this bundle is intentionally a selected useful
  subset, not all original issue reproducers or whole-package coverage.

When fixing a listed issue, the implementation PR should move useful coverage
into the existing function tests (failure before the fix, success after), remove
the standalone case and update this table. If coverage already exists or the
expectation is rejected, remove the case with a short rationale instead. The PR
reviewer checks that disposition; scientific decisions must be settled first.

For a fresh review, derive expectations from current contracts and primary
sources before reconciling these historical cases. Update or retire each case
when its owning issue is resolved; do not interpret rerunning this bundle as a
fresh whole-package review.
