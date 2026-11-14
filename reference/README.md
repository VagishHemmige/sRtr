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
paper's statistics or mention sRtr code.

**Catalog header.** Give the search string, run date, records returned, and
records kept. Counts with no screening log in the repository are marked
*reported*.

**Index columns.** PMC link, organ, SRTR role, publication year(s), reading
status.

- *SRTR role:* `SAF analysis`; `External linkage` (SRTR joined to another
  source and analyzed); `Case-finding or local source` (SRTR used to find
  cases, or as one part of a local data warehouse); `Methods or simulation`.
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
  and censoring sources, policy eras. End with tags from the list below.
- **Data pitfalls:** missing data, ambiguous or duplicate fields, timing
  traps. Write each one as a statement that can be checked.
- **Locators:** the sections and tables used.

**Provenance tags.** Every file, field, or definition carries one:
`[reported §…]` (the paper states it); `[inferred: <dictionary>]` (deduced
from a named dictionary, such as `sRtr::dictionary` at a given commit, and not
stated by the paper); `[external]` (needs data outside the SAFs);
`[not in SAFs]` (the paper or dictionary shows it is unavailable).

**Data-need tags.** `cross-organ-link`, `repeat-transplant`, `donor-pair`,
`candidate-registration`, `status-history`, `post-removal-death`,
`death-source`, `follow-up-horizon`, `policy-era`, `derived-score`,
`external-linkage`, `geography`, `living-donor`. Add a new tag here before
using it.

**Checking an entry.**

- Every claim has a provenance tag; every reported claim has a locator.
- Field names match the named dictionary.
- The reading status matches what was read; nothing unread is cited.
- Pitfalls describe the data, not the paper's analysis or sRtr code.
- Tags come from the list above.

Example:

```markdown
### PMC12851315

Intestine–kidney timing · doi:10.1016/j.intf.2024.100005 · SAF analysis ·
1995–2023 (abstract says 1994) · MT, 2026-11-14

- **Population / unit:** first intestine transplant, on dialysis and listed
  for kidney before it; 54 people. Unit: person.
- **Files and fields:** `tx_in`, `tx_ki`, `txf_in`, `PERS_ID` [reported
  §Study design]; `CAN_DIAL` [reported §Patients], which is in CAND_LIIN and
  CAND_KIPA, not TX_IN [inferred: `sRtr::dictionary`, e7a74d1]. Source of
  kidney listing not reported.
- **Data needs:** link organ files by person; keep the earliest intestine
  transplant; group by days from intestine to kidney transplant (7 used);
  graft failure includes death; 2,000-day horizon; second time origin at
  kidney transplant. Tags: `cross-organ-link`, `repeat-transplant`,
  `follow-up-horizon`, `derived-score`.
- **Data pitfalls:** day 7 itself, and kidney before intestine, are not
  assigned to a group. The delayed group is defined by a later event (median
  3,087 days after intestine transplant), so its earlier time is not time at
  risk of that exposure. Diabetes and dialysis start were too sparse for
  EPTS; values were substituted.
- **Locators:** Methods (Study design; Patients and study groups;
  Statistical analysis); Results.
```
