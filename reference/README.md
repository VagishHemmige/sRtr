# Reference material

Background about the SRTR database and its use: data definitions, collection
eras, official methods, research literature, and external analysis examples.
This README is the guide to where new reference information belongs.

This folder is excluded from the package build (`.Rbuildignore`).

| File | What it holds |
|---|---|
| [`methodology-review.md`](methodology-review.md) | Topic-by-topic background: estimands, ascertainment, methodological alternatives, and limitations |
| [`repositories.md`](repositories.md) | Other code repositories reviewed, with the commit read and what was learned |
| [`web-sources.md`](web-sources.md) | Websites and papers consulted, with access dates and key passages |
| [`pmc-2024.md`](pmc-2024.md) | 89 SRTR studies from a 2024 PMC publication search: index with organ, SRTR role and reading status; annotations of data needs |
| [`codebook-notes.md`](codebook-notes.md) | Field and code meanings checked against named dictionary/codebook versions |

## Scope and placement

Keep sRtr function behavior, defects, proposed fixes, test results, and package
implementation decisions out of this folder. Those belong in issues/PRs, tests,
function documentation, or dated review records. For example, report date versus
clinical onset is reference background; whether a particular sRtr helper handles
that distinction correctly is an issue or implementation concern.

Use the table above to choose one primary home. Link related entries rather than
copying them. Issues and PRs cite reference sections; reference entries do not
link back to issues or track implementation status. Record scientific uncertainty
without turning alternatives into approved package defaults. Amend existing topical entries; do not append entire review
reports or reviewer transcripts. External code is an example to assess, not an
authority for clinical definitions or permission to open its data.

## Conventions

- **No SRTR patient-level data**, ever: no rows, values, or outputs from SAFs.
  Counts from public reports are fine.
- Record **what was actually read**: the commit hash for a repository, the
  access date for a web page. Mark anything cited from memory or second-hand
  as *not yet verified*.
- Prefer concise source summaries with section/table locators. Use a short exact
  quotation only when the wording matters. Keep implementation discussion out
  of the reference entry.
- Code claims ("removal code 14 means ...") should be checked against
  `data-raw/` or the SRTR data dictionary before being relied on, and say
  which was checked.

## Literature annotations

Catalog files (`pmc-<year>.md`) list papers that use SRTR data, with links and
short annotations. An annotation records what data the paper shows a user
needs, and where the data can lead to a wrong result. It does not appraise the
paper's statistics or mention sRtr code. A design feature such as competing
risks, time-varying exposure, matching, or weighting is named when it explains
why particular records, identifiers, or follow-up intervals are needed.

Longer catalogs may keep annotations in `pmc-<year>/batch-NN.md`, linked from
individual index rows. Earlier annotations may remain in the catalog itself.
Batch numbers organize reading work, not topics. During concurrent annotation
work, each batch changes only its own file. Update the shared catalog links,
roles and reading statuses together after the reviewed batches merge; verify
those values against the final entries and check every link before merging
the catalog update.

**Catalog header.** Give the search string, run date, records returned, and
records kept. Counts with no screening log in the repository are marked
*reported*.

**Index columns.** PMC link, organ, SRTR role, publication year(s), reading
status.

- *SRTR role:* `SAF analysis`; `External linkage` (SRTR joined to another
  source and analyzed); `Case-finding or local source` (SRTR used to find
  cases, or as one part of a local data warehouse); `Methods or simulation`;
  `Not recorded` (role not yet checked).
- *Reading status:* `Screened` (title, abstract, targeted passages); `MT`
  (complete main text); `MT+T` (plus tables and figure captions); `MT+T+S`
  (plus supplements).

**Entries.** The heading is `### PMC<id>` alone, so the link anchor is
`#pmc<id>`. Fields, in this order:

- First line: topic · DOI · SRTR role · study period and data cutoff · reading
  status and date.
- **Population / unit:** cohort, and unit of analysis (person, registration,
  transplant, donor, or donor pair).
- **Files and fields:** each with a provenance tag (below).
- **Data needs:** links and identifiers, timing rules, definitions, outcome
  and censoring sources, policy eras, and any design feature that drives them.
  End with tags from the list below.
- **Data pitfalls:** missing data, ambiguous or duplicate fields, timing
  traps. Write each one as a statement that can be checked.
- **Locators:** the sections and tables used.

**Provenance tags.** Every statement has a source basis. One tag at the end of
a bullet covers the whole bullet; tag a clause separately only when its basis
differs.

- `[reported §…]`: the paper states it.
- `[dictionary: <name and version>]`: checked against a named dictionary, such
  as `sRtr::dictionary` at a given commit; not stated by the paper.
- `[inference]`: the annotator's reasoning, including record families the
  analysis clearly needs but the paper does not name. Never give exact file or
  field names under this tag.
- `[unclear §…]`: the paper leaves it open; keep its wording and do not
  resolve it.
- `[external]`: needs data outside the SAFs.
- `[not in SAFs]`: the paper or a dictionary shows it is unavailable.

**Data-need tags.** `cross-organ-link`, `repeat-transplant`, `donor-pair`,
`candidate-registration`, `status-history`, `post-removal-death`,
`death-source`, `follow-up-horizon`, `policy-era`, `derived-score`,
`external-linkage`, `geography`, `living-donor`. Add a new tag here before
using it.

**Checking an entry.**

- Every bullet has a source basis; `[reported]` and `[unclear]` tags have a
  locator.
- Exact file and field names are reported or dictionary-checked, never
  inferred.
- The reading status matches what was read; nothing unread is cited.
- Pitfalls describe the data, not the paper's analysis or sRtr code.
- Tags come from the list above.

Example:

```markdown
### PMC12851315

Intestine–kidney timing · doi:10.1016/j.intf.2024.100005 · SAF analysis ·
1995–2023 (abstract says 1994) · MT, 2026-11-14

- **Population / unit:** first intestine transplant, on dialysis and listed
  for kidney before it; 54 people. Unit: person. [reported §Patients;
  Results]
- **Files and fields:** `tx_in`, `tx_ki`, `txf_in`, `PERS_ID` [reported
  §Study design]; `CAN_DIAL` [reported §Patients] is in CAND_KIPA, CAND_LIIN
  and CAND_THOR, not TX_IN [dictionary: `sRtr::dictionary` at e7a74d1].
  Kidney waitlisting needs candidate registration records; the paper names no
  source [inference].
- **Data needs:** link organ files by person; keep the earliest intestine
  transplant; group by days from intestine to kidney transplant (seven-day
  window); graft failure includes death; 2,000-day horizon; second time
  origin at kidney transplant. [reported §Study design; Patients; Statistical
  analysis; Results] Tags: `cross-organ-link`, `repeat-transplant`,
  `candidate-registration`, `follow-up-horizon`, `derived-score`.
- **Data pitfalls:** the paper does not say which group day 7 falls in, or how
  a kidney transplant before the intestine transplant was handled; it uses
  "within" and "following" seven days [unclear §Patients]. The delayed group
  waited a median of 3,087 days for the kidney [reported §Results], so time
  before that date cannot count as delayed-group time at risk [inference].
  Diabetes and dialysis start were too sparse for EPTS, and values were
  substituted [reported §Statistical analysis].
- **Locators:** Methods (Study design; Patients and study groups;
  Statistical analysis); Results.
```
