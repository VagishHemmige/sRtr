# Whole-package review protocol

This document records the protocol for an explicitly commissioned deep review of
sRtr: current code, every open issue, and gaps for future development.
[REVIEWING.md](REVIEWING.md) remains the protocol for individual PR reviews.
This protocol applies when the maintainer commissions a package-wide deep review,
including ordinary-language requests routed here by REVIEWING.md. Naming this
file or repeating a commissioning prompt is unnecessary. Its presence alone does
not trigger an audit or govern routine PR reviews. Saving this protocol does not
mean an audit has been performed.

Read current [AGENTS.md](AGENTS.md) and applicable subdirectory guidance before
starting. The coordinator inventories the repository reference records named
below and any maintainer-supplied decision or handoff context, recording which
revision was read. Outside context is for the coordinator only; do not reproduce
private conversations or project notes in reviewer packets or public findings.
Use REVIEWING.md's
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
belong in the report for maintainer consideration. Review work includes writing
and running independent synthetic audit tests in the isolated workspace and
preparing concrete test and CI patches for review. Preserve these as deliverables;
do not silently install them into the package or activate changed workflows.

Never access, copy, upload, or expose patient-level SRTR data. Never execute
real-SAF tests, even if environment variables enable them. The connected working
folder and synced references are read-only; do not use the maintainer's active
RStudio session. These mean the maintainer's connected checkout and externally
synced reference locations, including a `sources/` directory if present; they
are not assumed repository paths. Identify applicable locations at intake.
Execute checks only in an isolated workspace after
inspecting startup files, configuration, paths, and test guards. Do not edit or
regenerate data/. Inspect data-raw/ source without running regeneration.
If provenance is uncertain, report the path and request verification without
reproducing values. Only provenance-confirmed public metadata and obviously
synthetic fixtures may be supplied to reviewers.

Before loading package code or tests, the isolated runner must set
`SRTR_LIVE_TESTS=false` and unset `SRTR_WD`. Launch a fresh process with startup
profiles and environment files disabled; do not rely on the caller's environment.
For Rscript use `--vanilla`, and make the runner's first R statements:

```r
Sys.setenv(SRTR_LIVE_TESTS = "false")
Sys.unsetenv("SRTR_WD")
```

Before launching R, create empty startup files in the isolated workspace and
set `R_ENVIRON_USER` and `R_PROFILE_USER` to their absolute paths in the runner's
process environment. Keep those files available for the entire run and ensure
child processes, including those launched by package checks, inherit these
settings. Do not edit the maintainer's startup files. Retain the explicit
live-test disablement and `SRTR_WD` removal above.

Validate startup isolation using harmless synthetic startup files and a child
process before relying on the runner for package checks. Record the commands,
runtime and observed result; documenting these settings alone is not evidence
that child-process isolation has been tested.

Apply the same isolation to spawned R processes. Inspect startup, helper, setup,
and test code beforehand for alternate data paths or code that restores live
settings. Check the effective guards before test execution; if real-data access
cannot be excluded, do not execute that check. Record the blocker. These measures
do not authorize opening SAFs or modifying the maintainer's configuration.

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
| Independent testing and reproducibility engineer | Owns the existing-test and CI audit, creation and execution of reusable synthetic audit tests, and concrete permanent-test and CI proposals; challenges expectations, mocks, boundary cases, integration coverage, skips, clean-session operation, and Windows |
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

## Reference resources and reviewer packets

Use the existing [reference catalogue](reference/README.md); do not create a
competing catalogue:

- [repositories.md](reference/repositories.md): external code repositories,
  reviewed revisions, and discoveries still awaiting inspection.
- [web-sources.md](reference/web-sources.md): official methods and papers,
  distinguishing retrieved sources from unverified citations.
- [codebook-notes.md](reference/codebook-notes.md): prior code-table checks to
  reverify against the applicable registry documentation.
- [methodology-review.md](reference/methodology-review.md): prior methodological
  comparisons and issue links, for reconciliation after independent discovery.

The coordinator and scientific librarian prepare role-specific source packets
from these records before the initial passes. Supply source links, pinned code
locations, relevant primary methods and factual scope metadata; withhold the
catalogue's existing diagnoses, judgments about sRtr, and issue conclusions until
reconciliation. If a reviewer has already seen them, record that exposure.
Do not forward the annotated reference files wholesale and call the pass blind.

For each source identify organ, population/era, outcome or method, relevant SAF
fields, exact paper section or script/function, retrieval/review status, and the
package capability it informs. Reviewers may discover additional sources; record
these in the shared source manifest and reconcile additions into the existing
catalogue as proposed documentation changes. Verify historical claims rather
than treating a prior review or external code as authoritative. Inspect external
code only after checking provenance; never open uncertain data or outputs.

At intake, check the tracked repository for any additional PMC paper list,
inventory its actual location and revision, and incorporate relevant papers into
these packets. Incorporate later additions as well. Do not assume a list exists
or wait for a future list to begin. Reviewers should fill organ/method
coverage gaps with primary literature, including PMC full text and supplements
where available; record unresolved access or evidence gaps. Distinguish papers
linked to their own code from separate comparison implementations.

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

## 4. Independent validation, test creation, and CI

The testing and reproducibility engineer owns this workstream. Clinical,
registry, and statistical reviewers establish the scientific basis for expected
results; package and data engineers help construct fixtures and integration
checks. The testing reviewer independently challenges those expectations and
implementations. Every reviewer contributes relevant failure cases.

### Existing tests and CI

Audit every test file and workflow, including helper/setup code. Map existing
tests to functions, scientific definitions, organ-specific paths, and complete
user workflows. Record what is untested; line coverage alone does not establish
correctness.

For CI, inspect triggers and path filters, tested revisions, R/OS matrices,
dependency installation and caching, optional dependencies, permissions,
secrets handling, external-service access, timeouts, skips, failure propagation,
and retained logs/artifacts. Check whether meaningful failures can be hidden by
continue-on-error, unconditional skips, or jobs that never run. Distinguish
workflow configuration from observed execution. Inspect required-check settings
where access permits; unavailable settings are an explicit verification gap.
Assess synthetic SAS/parquet paths, Windows behavior, package checks, documentation
builds, and data-safety guards where relevant. Do not execute documentation or
examples that access real SAFs.

### Create and preserve independent audit tests


Inspect test expectations independently of implementation. Use authoritative
definitions and hand-worked synthetic examples. Assess whether mocks bypass the
behavior claimed, and whether tests would detect meaningful incorrect results.

Reproduce serious suspected defects when feasible. Test workflow interactions
and both event indicators and observation times. Choose validation scope from
downstream reach; start focused, then broaden where justified. For a whole-package
audit, assess the complete suite and package checks when safely feasible, while
ensuring real-SAF tests cannot execute. Do not run restricted or expensive
operations merely to fill the ledger.

Write meaningful new synthetic tests for uncovered high-risk behavior and
suspected defects during the audit; do not defer all test creation to later
implementation. Preserve reusable test files, small documented synthetic
fixtures or fixture generators, and an exact runner with the report. Any committed
synthetic fixture must follow `tests/testthat/fixtures/synthetic-*` and the data
guard; audit artifacts are not an exception. Keep audit
additions distinct from the frozen baseline and identify which checks are
existing tests versus new audit tests. A later test author must be able to rerun
them against the same revision without reconstructing the review conversation.

For each new test, record its purpose, independently justified expectation,
source or accepted contract, affected paths, finding/issue IDs, dependencies,
command, and result. Include regression and integration tests as appropriate;
for outcomes, check event status, assigned date, censoring date, and elapsed time.
Do not create tests that merely restate implementation or enforce an unresolved
scientific preference.

Classify deliverables as:

- Passing: evidence for specified behavior and candidate permanent coverage.
- Failing: a reproducible discrepancy linked to a finding, with defect versus
  incorrect-test-expectation distinguished by evidence.
- Decision-dependent: alternative synthetic comparisons awaiting a scientific
  decision; do not encode one alternative as the approved expectation.
- Blocked or not run: exact execution blocker and remaining verification work.

Retain a failing reproducer even if the package fix is outside review scope.
Do not make it pass by weakening assertions, adding unjustified skips, or
silently changing package behavior. After approval to implement, demonstrate
failure before the fix and success afterwards where feasible.

### Concrete test and CI proposals

Deliver reviewable test additions and targeted workflow patches for material
gaps, not only recommendations to add tests or improve CI. Identify destination
files, rationale, commands/jobs, platform and dependency requirements, expected
signals, approximate resource needs where known, and validation already performed.
Separate fast routine checks from justified broader or scheduled checks. Tie
each proposed change to a finding or documented coverage gap; if no change is
warranted, state that conclusion and its evidence rather than inventing work.

Show complete proposed new files and readable diffs for changed files. Preserve
patches and test artifacts with the report in durable, maintainer-accessible
storage: an authorized task branch or PR in this repository, with commit-pinned
links in the coverage ledger. Store workflow proposals as inert patch artifacts,
not active workflow files. If repository publication is not authorized, deliver
maintainer-accessible files using the session's permitted durable storage and
record that location; do not publish private material to satisfy this requirement.
Do not rely on temporary workspace paths as the only retained copies.

Preparing CI patches does not authorize activating workflows, changing repository
settings, using secrets, or executing untrusted PR code with elevated permissions.
State which checks were validated locally and which require a subsequently
authorized CI run. Permanent package tests and workflow installation are a
separate implementation step through task branches and PRs after maintainer
review. Any accompanying behavior change still needs per-file approval.

### Execution record and remaining checks

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
- Reusable audit tests and synthetic fixtures/generators, exact execution
  instructions, and a manifest distinguishing passing, failing,
  decision-dependent and blocked checks.
- Concrete permanent-test and CI patches addressing material gaps, with
  destination files, dependencies, validation status and proposed rollout.
- Staged roadmap appropriate to the package's development stage.

Give each finding a stable ID, severity (Must fix / Should fix / Consider),
classification (verified defect / concern / validation gap / decision /
documentation / enhancement), location at a fixed revision, evidence,
consequence, confidence, proposed remedy, and acceptance check.
Keep classifications separate from severity. Do not report suggestions as bugs.

An audit is complete only when every in-scope file, function and open issue has
a disposition; serious findings have a reproducer or a specific verification
blocker; scientific claims have sources or explicit uncertainty; and draft issue
comments and new-issue proposals are ready for maintainer review. Reusable audit
tests and justified test/CI proposals must also be preserved and linked; each
material test or CI gap needs a concrete draft or a specific blocker. A disposition
of "not assessed" remains a coverage gap, not completed substantive review.
If gaps remain, label the report partial and state what remains to finish.

### Integrate knowledge before closing the review

Retaining an audit archive and posting issues do not by themselves preserve
usable project knowledge. For each material discovery, identify its maintained
destination or explain why it belongs only in the archive. Group related results;
do not create a new ledger entry for every minor observation.

| Result | Maintained destination |
| --- | --- |
| Verified paper or official method, including conflicting source versions | `reference/web-sources.md` |
| External implementation and the capability it informs | `reference/repositories.md` |
| Field/code interpretation, organ or release limitation | `reference/codebook-notes.md` |
| Methodological comparison, assumption, or decision rationale | `reference/methodology-review.md`, linked to the owning issue |
| Reproducible defect or independent reference example | Proposed focused regression test beside the affected tests; retain the audit reproducer until implementation is approved |
| User-facing misunderstanding | Proposed correction to the relevant help or vignette |
| Review-process lesson | Proposed amendment to the applicable review protocol |

Prepare concrete, self-reviewed documentation diffs as review deliverables.
Use existing documentation permissions to preserve them on a task branch/PR;
otherwise retain the patches durably for approval. Do not edit the connected
checkout, merge changes, or interpret this step as behavior-change permission.
Record each material result as integrated (with revision/link), proposed (with
patch/link), deferred (with owning issue and reason), or archive-only (with
reason). A report that merely recommends saving sources has not completed this
step. Report analytical coverage and pending integration/approval separately.

Keep entries short and topic-based: what was verified, why it matters, applicable
organ/population/release, exact source section or code revision, verification
status/date, and the owning issue. Amend existing entries, reconcile contradictions,
and mark superseded conclusions. Preserve important disagreements and evidentiary
limits; reviewer agreement is not a scientific authority. Do not paste reviewer
transcripts, full reports, logs, or issue-comment compilations into the catalogue.

An unresolved scientific question belongs with its owning issue and supporting
reference entry. Do not present an alternative as an approved definition. Once
the maintainer decides, record the selected definition, source or explicit
package assumption, rationale, and affected tests/help in the maintained location.
The audit decision register is a dated snapshot, not a second live backlog.

Keep full coverage/evidence/progress records and reusable audit artifacts in the
permitted durable archive for resumption. The repository needs only a short dated
review record, when permitted, identifying the frozen revision, scope, material
limitations, and links to integrated knowledge and remaining work. Do not expose
private archive links. Finish with a concise handoff explaining what was preserved,
where it lives, and what remains unresolved. Future independent first-pass packets
must still exclude these accumulated diagnoses until reconciliation.

## 8. Report first, posting afterwards

Present the consolidated report to the maintainer before posting any audit
comments or new issues. Wait for the maintainer's response selecting or
authorizing the posting step; elapsed time is not approval.

The planned follow-up is a substantive comment on every still-open issue and
new issues for accepted findings. Prepare all drafts in the report first.
Before posting, refresh revisions and discussions, check for duplicate comments
and issues, and revise drafts when intervening work changes the conclusion.
A prior substantive issue comment does not substitute for this audit's assessment.
Retain a draft for every open issue as commissioned; when the conclusion is
unchanged, explain the newly checked revision, evidence and remaining work
concisely instead of repeating the earlier comment. Propose withholding a
redundant post to the maintainer in the report, but do not silently omit that
issue or change the commissioned posting scope.
Confirm writes succeeded and map report IDs to posted URLs.

Review-created tests and proposed CI patches are report deliverables. Installing
them in the package or activating workflows follows the separately authorized
implementation step; it is not implied by permission to post issue findings.

Do not close issues, formally approve or merge PRs, or modify package code as
part of this audit. Those actions require their own authorization. Behavior
changes require per-file approval of concrete, self-reviewed drafts under the
maintainer's working instructions. This document grants no standing posting,
implementation, or automated-review permissions.

## 9. Posting templates

Use these templates for the report's proposed GitHub text. Replace placeholders
and omit genuinely inapplicable sections; never fill a field with an invented
result. Scale length to the finding. Use public, commit-pinned source links and
public reference URLs; do not publish private conversations or private report
links. Report IDs remain useful even when the report is not public.

One existing-issue comment should consolidate the relevant reviewers' findings.
Do not post separate repetitive comments from each role. A finding already
covered by an issue belongs in that issue unless a distinct scope justifies a
new linked issue. Do not create or apply labels merely because a template names
a classification or severity.

### Comment on an existing open issue

```markdown
### Whole-package review: <issue topic>

**Reviewed:** <full commit SHA with link>; <date>.
**Report findings:** <IDs>.
**Assessment:** <supported / partly supported / not supported / already fixed /
duplicate / unresolved scientific decision / valid enhancement>.
**Classification and priority:** <type>; <Must fix / Should fix / Consider>.
**Confidence:** <high / medium / low, with reason>.

<Lead with the conclusion and its practical consequence. Distinguish the
issue's premise from the merits of its proposed fix.>

**Evidence and current behavior**

- <Commit-pinned file/function/line link and what it establishes.>
- <Relevant organ, input representation, or workflow; downstream consequence.>
- <Authoritative source, release/version and section where needed.>

**Assessment of the proposed solution**

<Does it solve the underlying problem? What remains missing or could regress?
Distinguish merged fixes from unmerged proposals. Preserve substantive
reviewer disagreement and state what evidence would settle it.>

**Validation**

<Checks personally executed, exact commands and observed results, or explicitly
"Source inspection only." Separate observed CI and author-reported checks.
Give a small synthetic example if useful. State remaining data-dependent
uncertainty without including patient-level values. Link retained audit tests
and relevant proposed test/CI patches when publicly available; otherwise identify
them by report artifact ID without exposing private locations.>

**Recommended next step**

<Keep open and refine scope / implement a specified repair / obtain a
methodological decision / recommend closure as fixed or unsupported /
recommend consolidation with #N. These are recommendations, not status changes.>

**Acceptance checks**

- <Observable behavior or source/documentation condition needed for resolution.>
- <Regression/integration check and remaining maintainer check, where relevant.>

**Related work:** <issue/PR links, merge status, and relationship>.
```

For an already-fixed issue, cite the fixing commit and evidence at the reviewed
revision. For an unsupported premise, explain why and acknowledge any residual
uncertainty. For a duplicate, name the substantive overlap and any unique part
that should be preserved. Do not imply that recommending closure closes it.

### New defect or validation-gap issue

Suggested title: `<function or component>: <specific incorrect behavior or gap>`.

```markdown
## Problem

<Concrete trigger, current behavior, and expected behavior. For a validation
gap, identify the unverified guarantee without asserting an unproven defect.>

**Review reference:** <report finding IDs>; <date>.
**Reviewed revision:** <full commit SHA with link>.
**Classification:** <verified defect / concern / validation gap / documentation>.
**Priority:** <Must fix / Should fix / Consider>.
**Confidence:** <level and evidence supporting it>.

## Evidence and impact

<Commit-pinned locations; affected organs, functions and downstream workflows;
why the result matters. State whether the problem is established in current
code or only suspected under a specified condition.>

## Reproduction and validation

<Minimal, obviously synthetic example and exact commands when available.
State runtime/dependencies and actual versus expected output. If not executed,
label it "Proposed reproducer, not executed" and explain the blocker.
Separate personally executed checks, observed CI, and author-reported results.
Identify retained test artifacts and any proposed permanent-test or CI patch.>

## Scientific basis

<Authoritative source URL, release/version, section/table, and what it supports.
Identify package assumptions and unresolved choices separately. Omit only if
the finding has no scientific definition or methodological claim.>

## Proposed resolution

<Focused remedy and affected paths. State methodological decisions needed
before implementation. Do not present an unapproved default as settled.>

## Acceptance criteria

- <Correct observable behavior, including relevant edge cases.>
- <Independent regression test and integration coverage where needed.>
- <Documentation/source updates and focused maintainer SAF checks if required.>

## Related work

<Existing issues and PRs checked; explain why this is a distinct issue.
Link dependencies rather than duplicating their scope.>
```

### New scientific decision issue

Suggested title: `Decision: <specific definition or methodological choice>`.

```markdown
## Decision needed

<State the exact question, affected outcomes/organs/functions, and why the
choice cannot be inferred safely from the registry documentation.>

**Review reference:** <report finding IDs>; <date>.
**Reviewed revision:** <full commit SHA with link>.
**Decision owner:** <maintainer or explicitly designated person>.
**Status:** Proposed; not decided.

## Current implementation and evidence

<Commit-pinned behavior, public source URLs with versions/sections, and
uncertainties. Separate documented registry facts from package assumptions.>

## Alternatives

| Option | Scientific meaning | Consequences and limitations | Evidence |
| --- | --- | --- | --- |
| <A> | <Definition/estimand> | <Affected outputs and users> | <Source or assumption> |
| <B> | <Definition/estimand> | <Affected outputs and users> | <Source or assumption> |

## Synthetic comparison

<Where feasible, show how the options change events, dates, denominators,
follow-up or scores using the same synthetic inputs. State whether executed
or hand-worked. Do not imply synthetic data establish clinical validity.>

## Reviewer positions

<Reasoned recommendation, substantive disagreement, and evidence that would
resolve it. Agreement among reviewers is not a scientific source.>

## Completion criteria

- Maintainer records the selected definition and rationale.
- Required behavior changes, affected files and migration implications are identified.
- Tests and documentation implement the selected definition consistently.

**Related work:** <issues/PRs and implementation dependencies>.
```

### New future-capability issue

Suggested title: `Proposal: <capability and concrete use case>`.

```markdown
## Research use case

<The workflow currently blocked or unnecessarily error-prone, and who needs it.>

**Review reference:** <report finding IDs>; <date>.
**Reviewed revision:** <full commit SHA with link>.
**Classification:** Enhancement proposal.
**Priority and rationale:** <priority relative to correctness and validation work>.

## Existing support and gap

<What sRtr already provides; why composition or an analysis-specific helper
does not adequately solve this use case. Link relevant code and documentation.>

## Source feasibility and scope

<Verified SAF fields, public APIs, or methods with sources and applicable
versions. Identify organ coverage, limitations and unresolved feasibility.
Do not promise variables or outcomes that the available data cannot support.>

## Proposed capability

<Minimal behavior and intended outputs; dependencies and alternatives.
Keep unsettled API details explicitly proposed.>

## Acceptance criteria

- <Demonstrable end-to-end synthetic workflow.>
- <Scientific source verification and needed maintainer decisions.>
- <Tests, documentation and remaining data-dependent validation.>

**Related work:** <existing issues/PRs; why this proposal is distinct>.
```

Before publication, confirm that the text matches the maintainer-reviewed
report and any authorized revisions, refresh the evidence against intervening
changes, and record the successful comment or issue URL in the posting ledger.
