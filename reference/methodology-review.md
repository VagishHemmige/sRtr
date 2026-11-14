# Methodological background

Background for interpreting and analyzing SRTR data, not a review of sRtr
functions. Sources and retrieval limits are recorded in [web-sources.md](web-sources.md),
[repositories.md](repositories.md), and [codebook-notes.md](codebook-notes.md).
Updated 2026-11-14 using the completed review's source verification. These notes
identify methodological choices; they do not select package defaults.

## Waitlist outcomes and competing risks

Death while listed and death from the date of listing are different estimands.
Living-donor transplant may be a competing event or receive different treatment
under a specified estimand. Combining death with too-sick or medically unsuitable
removal also changes the endpoint. Removal code 14 alone does not identify donor
type. Use dated events and release-specific administrative follow-up, rather than
assuming that removal codes alone settle all event histories.

The external kidney calculator illustrates earliest-event selection; Wood et al.
illustrate inverse probability of censoring weighting for informative transplant
censoring. Their implementations are comparisons, not universal definitions.

## Death and graft outcome ascertainment

The official PSR methods describe OPTN, SSDMF, and CMS death-source precedence.
A follow-up death field is not automatically interchangeable with a CMS source.
Death ascertainment and last clinical follow-up are separate observation processes;
consistent censoring requires a stated endpoint and source coverage window.

PSR graft-survival definitions differ by organ. Death-censored reported graft
failure, overall graft loss, dialysis return, and retransplantation are not
interchangeable endpoints. Verify whether an organ/release's derived graft date
already incorporates component events before constructing a composite. Equal
failure and death dates do not establish within-day event ordering.

For a concrete organ comparison, consult the PSR source entry's Section C
locator and the [pancreas annual-report entry](web-sources.md#optnsrtr-2024-annual-data-report-pancreas).
They distinguish outcome components and observation windows. Match the organ,
report purpose, population, and policy era before reusing either definition.

## Status histories and units of analysis

A person, listing, transplant episode, and follow-up form are different units.
Repeated follow-up forms can share a transplant identifier even when the field
label calls it a unique key. Verify table grain and release-specific linkage
before joining; missing identifiers do not establish a relationship.

Wood et al. illustrate start-stop intervals from status histories, grouping
carry-forward by candidate and handling rows around transplantation. Their
bootstrap resamples candidates, not individual intervals. Interval boundaries,
administrative censoring, and simultaneous events require explicit definitions.

## Follow-up reports and event dates

In the inspected dictionary, TFL_PX_STAT_DT is a patient status date, while
rejection fields refer to events during a follow-up period. A first positive
report date need not be the clinical onset date. Discharge timing is also a proxy
for an event during admission. Known occurrence with an unknown date must remain
distinguishable from an observed negative report, an unknown response, and no
eligible follow-up. A later report can describe an earlier event; report receipt
and event chronology should not be conflated.

Treated rejection differs from all rejection. A malignancy flag alone does not
establish incident versus recurrent cancer or complete ascertainment; cancer
registry linkage studies provide relevant limitations. Organ-specific studies
in the source catalogue require their stated retrieval qualifications.

## Linking records and describing cohorts

Explicit keys, expected cardinality, and row-count reconciliation protect the
unit of analysis. Shared non-key columns are not evidence of a join relationship.
TX_KP contains TRR_ID and TRR_ID_PA in the inspected metadata; organ-specific
linkage must be checked rather than inferred from similar names.

Nesting repeated records under a parent is one way to preserve parent grain;
aggregation on long tables is another. Neither representation alone validates a
cohort. Distinguish unmatched records, missing keys, duplicate parents, and
intentional exclusions. No follow-up is an observation-completeness question,
not a universal exclusion rule for every survival analysis.

## Medication exposures

Separate recorded drug identity, indication, timing, and class assignment.
A medication record does not by itself establish induction treatment; multiple
records may represent a regimen. Absence of records, unknown indication, and
observed records without induction are different observation states. Preserve
those distinctions before constructing research exposure categories. See the
[medication metadata notes](codebook-notes.md#admission-timing-and-medication-indication)
for the verified fields and the limits of drug-name-based classification.

## Missing values, plausibility, and modeling

The registry distinguishes unknown, not applicable, not done, pending,
indeterminate, and other states, with format-specific encodings. Structural
absence across collection eras differs from a recorded unknown response.
Collapsing these categories is an analysis choice, not a universal cleaning rule.

The cited SRTR modeling paper describes conservative expert-defined plausibility
ranges, imputation, and separate percentile truncation for model fitting. These
serve different purposes. The earlier source review did not locate a complete
published per-variable range list; do not invent one from observed sample extrema.
Program-evaluation missing-data rules should not be adopted as generic research
methods. Retain release and transformation provenance.

## Risk scores and allocation scores

PDRI is a relative risk index, not an absolute failure probability. Its source
population and SPK/PAK/PTA distinctions matter. The original-paper copies disagree
on a printed BMI coefficient; see the source entry before choosing an equation.
A prior-kidney field alone requires validation before being treated as a complete
PAK classification rule.

MELD model equations, allocation policy, and encoded match scores are different
objects. Use primary equations and applicable policy eras for bounds, units,
dialysis rules, and eligibility; do not derive MELD versus PELD solely from a
61xx/62xx prefix.

## Geography and population coverage

OPTN membership is versioned and includes substate assignments; whole-state
outlines cannot represent every region exactly. The Census 2018 1:20,000,000
boundary metadata describes generalized display geometry and excludes precise
geographic/area analysis. Reprojection does not restore omitted detail.

Counting every intersected population polygon, assigning its centroid, and
allocating population by intersected area answer different questions. Area
weighting assumes uniform distribution within each polygon. State the method,
source vintage, geographic exclusions, and treatment of missing population totals.
Public PSR tables and HRSA center/OPO layers also have distinct units and release
or snapshot dates.
