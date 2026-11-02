# Reference material

Notes on how other people and SRTR itself handle the methodological questions
behind sRtr, so the same sources don't have to be found again.

This folder is excluded from the package build (`.Rbuildignore`).

| File | What it holds |
|---|---|
| [`methodology-review.md`](methodology-review.md) | Topic-by-topic summary: what SRTR does, what others did, what sRtr does, and the related issues |
| [`repositories.md`](repositories.md) | Other code repositories reviewed, with the commit read and what was learned |
| [`web-sources.md`](web-sources.md) | Websites and papers consulted, with access dates and key passages |
| [`codebook-notes.md`](codebook-notes.md) | Code tables checked against `data-raw/`, where other projects got them wrong |

## Conventions

- **No SRTR patient-level data**, ever: no rows, values, or outputs from SAFs.
  Counts from public reports are fine.
- Record **what was actually read**: the commit hash for a repository, the
  access date for a web page. Mark anything cited from memory or second-hand
  as *not yet verified*.
- Quote sources exactly when a passage is the reason for a design decision,
  and link the issue it informs.
- Code claims ("removal code 14 means ...") should be checked against
  `data-raw/` or the SRTR data dictionary before being relied on, and say
  which was checked.
