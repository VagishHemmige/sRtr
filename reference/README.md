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
