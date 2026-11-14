# Whole-package review protocol

This document records the protocol for an explicitly commissioned deep review of
sRtr: current code, every open issue, and gaps for future development.
[REVIEWING.md](REVIEWING.md) remains the protocol for individual PR reviews.
Saving this protocol does not mean an audit has been performed.

Read current [AGENTS.md](AGENTS.md), applicable subdirectory guidance, and
relevant decision and handoff records before starting. Use REVIEWING.md's
evidence, severity, and reporting standards, but use whole-package scope here.
This is a commissioned review plan, not an expansion of permissions or a
replacement for repository policy. Explicit maintainer instructions govern.
Record material conflicts and resolve them before dependent work.

## Purpose and boundaries

Determine whether the package implements defensible scientific definitions,
behaves correctly, supports credible research workflows, and communicates its
limitations. Assess whether users can obtain invalid analyses even when code
works as written, including misleading names, unsafe defaults, and unsupported
generalizations across organs.

Review is read-only with respect to package implementation. Do not silently fix
code or decide scientific defaults. Proposed repairs and methodological choices
belong in the report for maintainer consideration.

Never access, copy, upload, or expose patient-level SRTR data. Never execute
real-SAF tests, even if environment variables enable them. The connected working
folder, synced references, and sources/ are read-only; do not use the maintainer's
active RStudio session. Execute checks only in an isolated workspace after
inspecting startup files, configuration, paths, and test guards. Do not edit or
regenerate data/. Inspect data-raw/ source without running regeneration.
If provenance is uncertain, report the path and request verification without
reproducing values. Only provenance-confirmed public metadata and obviously
synthetic fixtures may be supplied to reviewers.

## Review team

Use independent AI reviewer roles with fresh contexts where supported. These
are specialist perspectives, not claims of human credentials or substitutes for
authoritative evidence and human subspecialty validation. Schedule roles in
waves if concurrency is limited; do not omit a role to fit available slots.

| Role | Required focus |
| --- | --- |
| Kidney and pancreas transplant clinician-researcher | Return to dialysis, organ-specific graft failure, rejection, simultaneous and sequential transplantation, retransplantation, and PDRI |
| Heart and lung transplant clinician-researcher | Thoracic outcome definitions, rejection, graft outcomes, heart-lung records, and applicability of shared helpers |
| Liver and intestinal transplant clinician-researcher | Liver, intestinal and multivisceral records, graft failure, retransplantation, and applicability of shared definitions |
| Transplant infectious diseases and oncology reviewer | Infection-related variables and claims, malignancy ascertainment, recurrent versus de novo disease, and registry limitations |
| OPTN/SRTR registry methodology specialist | Field meanings, form structure and reporting periods, coding and release changes, organ-specific availability, identifiers and linkage |
| Biostatistician and epidemiologist | Time origins, estimands, event ascertainment, censoring, competing events, missingness, composite outcomes, risk calculations, and units |
| Senior R package engineer | Every exported function and internal helper, contracts, types, attributes, dependencies, namespace, errors, side effects, and architecture |
| Data and spatial methods engineer | SAS/parquet input, identifiers, joins, factors, dictionary mappings, performance, HRSA access, CRS, geometries, overlap and population weighting |
| Independent testing and reproducibility engineer | Independently justified expectations, mocks, boundary cases, integration tests, skips, CI, clean-session operation, and Windows |
| Scientific librarian and provenance reviewer | Sources for every scientific definition, code set, coefficient and methodological claim, including release/version and section |
| Researcher using the package | Installation, README, help, vignettes and website; discoverability, comprehensibility, practical misuse risks, and missing capabilities |

Split data engineering and spatial methods into separate reviewers when the
inventory warrants it. Review existing capabilities and relevant gaps; do not
invent unsupported outcomes merely to fill a specialty's assignment.

The coordinator maintains coverage, verifies findings, reconciles duplicates,
and assembles the report. The coordinator is not blind. No reviewer is expected
to inspect every file, but every in-scope file must have an assigned reader.
Shared scientific functions receive clinical review from each affected organ
specialty, as well as registry, statistical, and implementation review.

Use available package-development, critical-code-review, test-review, testthat,
design, and accessibility guidance where relevant. Apply pkgdown and R package
requirements rather than importing analysis-project Quarto or reporting rules
that do not fit this repository. Record unavailable capabilities.

## 1. Freeze and inventory the review target

Record repository, actual default branch, full commit SHA, date, package version,
policy revision, website URL and observed deployment revision when available.
For GitHub reviews, explicitly exclude unpushed changes. If local review is
requested, identify the actual working copy and staged, unstaged and relevant
untracked scope; execute only in an isolated copy.

Inventory all tracked files and functions, tests, documentation topics,
vignettes, workflows, metadata, public reference sources, and every open issue
and PR. Paginate collection reads and reconcile counts. Check relevant closed
issues and merged PRs for duplicates and previously resolved findings.

Keep unmerged work separate from current default-branch behavior. A proposed
fix does not resolve a current-code finding.

Maintain a coverage ledger:

| Item or function | Revision | Assigned reviewers | Read | Executed checks | Source verification | Disposition or remaining gap |
| --- | --- | --- | --- | --- | --- | --- |

Read all human-written in-scope code and documentation, not a sample. Check
generated documentation against its source. Record the treatment of generated
assets and binaries; inventory is not permission to open uncertain data.
Name every exclusion and its reason. Persist progress and reviewer assignments
so an interrupted audit can resume without silently losing coverage.

## 2. Independent first passes

Give reviewers the frozen source, applicable rules, role questions, and relevant
public references. Do not give them other reviewers' findings, private
conversation history, or issue diagnoses during the initial pass. Reviewers may
read public material necessary to verify a claim. Record any unavoidable
exposure and do not claim full blindness when it was not achieved.

Require each reviewer to inspect actual implementation, not infer behavior from
function names, tests, documentation, or author claims.

For each function, compare purpose, documented input/output contract, actual
behavior, and downstream use. Trace loading -> labeling -> missing-value
handling -> derivation -> analysis-ready output. Check interactions, not merely
isolated helpers.

Prioritize plausible silent errors: missed events, inflated observation time,
wrong organ assignment, duplicated rows, identifier coercion, lost attributes,
unknown values treated as negatives, incorrect units, and misleading defaults.
Check empty inputs, missing dates, repeated records, unsupported organ patterns,
and numeric versus labeled values.

## 3. Scientific definition audit

Build a definition table for each clinically meaningful derived variable or
score: intended outcome, supported organs and populations, source fields,
codes, coefficients, dates, missingness, timing rules, source release/section,
package assumptions, implementation location, and test coverage.

Require three checks:
1. Clinical validity for each affected organ.
2. Registry support for interpreting the fields that way.
3. Correct implementation, including timing and missingness.

Do not treat agreement among AI reviewers as evidence. Preserve disagreements
and state what would settle them. Distinguish source-backed facts from package
choices and unresolved questions. A scientific choice needs options, consequences,
and a named maintainer decision; do not add options merely to avoid deciding.

## 4. Independent validation

Inspect test expectations independently of implementation. Use authoritative
definitions and hand-worked synthetic examples. Assess whether mocks bypass the
behavior claimed, and whether tests would detect meaningful incorrect results.

Reproduce serious suspected defects when feasible. Test workflow interactions
and both event indicators and observation times. Choose validation scope from
downstream reach; start focused, then broaden where justified. For a whole-package
audit, assess the complete suite and package checks when safely feasible, while
ensuring real-SAF tests cannot execute. Do not run restricted or expensive
operations merely to fill the ledger.

Record actual OS, R version, dependency versions, commands, results and skips.
Separate personally executed synthetic checks, source inspection, observed CI
at the reviewed revision, author-reported checks, and unverified claims.
If R or dependencies are unavailable, investigate safe isolated alternatives
and report the exact blocker. Do not claim execution from inspection alone.

Synthetic checks establish behavior, not validity on real SAFs. Give focused,
exact commands for the maintainer's remaining data-dependent checks, and
vignette rebuilds where applicable, without requesting patient-level output.

## 5. Reconcile every open issue

After independent discovery, give the relevant reviewers the full issue and
discussion, linked PRs and supporting material. Each open issue receives a
substantive assessment, even if it is mistaken, duplicated, already fixed,
intentional incremental work, or a valid future enhancement.

For every issue record:
- Number, title, URL, reviewed timestamp and code revision.
- Whether its premise is supported and what evidence establishes that.
- Current implementation and downstream consequences.
- Whether the suggested fix solves the underlying problem or creates others.
- Related findings, issues, PRs, and whether fixes are merged or merely proposed.
- Missing tests, source verification, and remaining scientific decisions.
- Recommended disposition and a complete draft comment.

Do not accept an issue's proposed solution as authoritative. Do not use generic
"still relevant" comments in place of analysis. Refresh the issue inventory at
report completion; account for newly opened or closed issues explicitly.

## 6. Cross-specialty challenge and future gaps

After the independent passes, have clinical and statistical reviewers challenge
outcome definitions together; registry and engineering reviewers examine data
representation and linkage; the test reviewer challenges claimed guarantees.
Recheck findings against source, downgrade unsupported claims, and record
corrections. Merge duplicates without discarding distinct consequences.

Assess future needs against concrete transplant research workflows and the
documented SAF capabilities. For each gap, state the use case, available source
support, why it belongs in sRtr rather than an individual analysis, dependencies,
priority, and an acceptance criterion. Separate correctness blockers, validation
gaps, design decisions, documentation needs, and optional enhancements.
Consider reuse of existing capabilities before proposing new APIs.

## 7. Consolidated report and completion criteria

Deliver:
- Executive assessment and prioritized findings.
- A complete issue-by-issue assessment and draft comment for every open issue.
- Proposed new issues, deduplicated against open and closed issues.
- Scientific decision register with alternatives and consequences.
- Definition/source tables and coverage ledger.
- Validation log, limitations, reviewer disagreements and corrections.
- Staged roadmap appropriate to the package's development stage.

Give each finding a stable ID, severity (Must fix / Should fix / Consider),
classification (verified defect / concern / validation gap / decision /
documentation / enhancement), location at a fixed revision, evidence,
consequence, confidence, proposed remedy, and acceptance check.
Keep classifications separate from severity. Do not report suggestions as bugs.

An audit is complete only when every in-scope file, function and open issue has
a disposition; serious findings have a reproducer or a specific verification
blocker; scientific claims have sources or explicit uncertainty; and draft issue
comments and new-issue proposals are ready for maintainer review. A disposition
of "not assessed" remains a coverage gap, not completed substantive review.
If gaps remain, label the report partial and state what remains to finish.

## 8. Report first, posting afterwards

Present the consolidated report to the maintainer before posting any audit
comments or new issues. Wait for the maintainer's response selecting or
authorizing the posting step; elapsed time is not approval.

The planned follow-up is a substantive comment on every still-open issue and
new issues for accepted findings. Prepare all drafts in the report first.
Before posting, refresh revisions and discussions, check for duplicate comments
and issues, and revise drafts when intervening work changes the conclusion.
Confirm writes succeeded and map report IDs to posted URLs.

Do not close issues, formally approve or merge PRs, or modify package code as
part of this audit. Those actions require their own authorization. Behavior
changes require per-file approval of concrete, self-reviewed drafts under the
maintainer's working instructions. This document grants no standing posting,
implementation, or automated-review permissions.
