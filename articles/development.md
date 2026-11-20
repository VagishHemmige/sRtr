# Development and how to contribute

sRtr is in early development (version 0.0.0.9000, before its first CRAN
release), so functions and their arguments can still change. Most of the
code is written by Claude, an AI model, and reviewed by an automated
ChatGPT review and by the maintainer, Vagish Hemmige. What sRtr needs
most from people is judgment: checking that a calculation matches its
source, and deciding what a definition should be. Neither needs much R,
and most of it needs no SRTR data.

This page lists tasks you can start today, then every open project.

## Start with one of these

Each of these has a defined finish, and none needs SRTR data.

### Check PDRI against its defining paper ([\#93](https://github.com/VagishHemmige/sRtr/issues/93))

*Verify existing work; Pancreas, Kidney-pancreas.*

- **Question:** Do
  [`add_pdri()`](https://vagishhemmige.github.io/sRtr/reference/add_pdri.md)’s
  coefficients, variable definitions and reference values match Axelrod
  and colleagues (2010)?
- **What you produce:** A comparison table: each coefficient and
  definition in sRtr beside the paper’s, with page and table numbers.
- **What you need:** The paper, the
  [`add_pdri()`](https://vagishhemmige.github.io/sRtr/reference/add_pdri.md)
  help page, and the [formula as sRtr implements
  it](https://github.com/VagishHemmige/sRtr/blob/master/R/add_PDRI.R)
  (search the file for `linear predictor`). No SRTR data.
- **Done when:** The table is posted on the issue. Any difference
  becomes a fix that Claude prepares.

### Find the defining formulas for MELD, MELD-Na and MELD 3.0 ([\#8](https://github.com/VagishHemmige/sRtr/issues/8))

*Verify existing work; Liver.*

- **Question:** What exactly do the defining papers specify for each
  MELD version: coefficients, bounds, rounding and the inputs used?
- **What you produce:** A table for each version, with the source of
  every value.
- **What you need:** The defining papers. No SRTR data.
- **Done when:** The tables are posted on the issue; Claude writes the
  function from them and you check it.

### Check whether a coordinate-system report is already fixed ([\#49](https://github.com/VagishHemmige/sRtr/issues/49))

*Verify existing work; Not organ-specific.*

- **Question:** Does
  [`get_hrsa_optn_regions()`](https://vagishhemmige.github.io/sRtr/reference/get_hrsa_optn_regions.md)
  still document one coordinate system and return another?
- **What you produce:** A short note: still a problem, or fixed, with
  the line of the help page or code that shows it.
- **What you need:** The function’s help page. No SRTR data.
- **Done when:** The note is posted and the issue is closed or kept
  open.

### Decide whether graft failure counts retransplant ([\#238](https://github.com/VagishHemmige/sRtr/issues/238))

*Supervise something new; All organs.*

- **Question:** SRTR counts a retransplant as graft failure for every
  organ except lung and heart-lung; sRtr does not yet. Should it, and
  how?
- **What you produce:** Your reading of the options on the issue and a
  recommendation.
- **What you need:** SRTR’s published definitions, linked on the issue.
  No SRTR data.
- **Done when:** A decision is recorded on the issue; Claude implements
  it.

## How to take one on

1.  Comment on the issue with one sentence saying what you will do, for
    example “I can check the PDRI coefficients against the paper and
    post my comparison.”
2.  A maintainer replies with the scope, who will review it, and what to
    post. Please wait for that reply before starting substantial work.
3.  Post your result on the issue. A comparison, a reading of the
    options or a short note is a complete contribution, even if it never
    becomes a code change.

To suggest work that is not listed, open a [new
issue](https://github.com/VagishHemmige/sRtr/issues/new/choose) with the
**Task** form. It asks for what “done” looks like and a few of the
labels below; leave anything you are unsure of, and a maintainer fills
it in. There are also forms for a **Decision** and a **Bug**.

Pull requests are reviewed by an automated ChatGPT review and merged by
the maintainer. A pull request into the main branch (`master`) cannot be
merged until that review has run. If you are a trainee working with the
maintainer, start through your usual supervision channel instead of a
public comment.

## Keep SRTR data out of public places

Most tasks need no SRTR data. Tasks labelled `needs SAF access` need
your own access to SRTR’s standard analysis files, under your own data
use agreement (DUA) with SRTR.

Never post patient-level data, or anything that looks like it, in an
issue or a pull request. Real results go on GitHub only as aggregate
counts with no cell from 1 to 10, and only when no hidden cell can be
recovered by subtracting one posted number from another. [Checking sRtr
on your own
SAFs](https://vagishhemmige.github.io/sRtr/articles/checking-your-safs.html#share-counts-only)
explains how to do this. Made-up examples and zero counts are fine.

## Find work by organ

- [Kidney](https://github.com/VagishHemmige/sRtr/issues?q=is%3Aissue%20is%3Aopen%20label%3A%22organ%3A%20kidney%22%2C%22organ%3A%20all%22)
- [Liver](https://github.com/VagishHemmige/sRtr/issues?q=is%3Aissue%20is%3Aopen%20label%3A%22organ%3A%20liver%22%2C%22organ%3A%20all%22)
- [Pancreas](https://github.com/VagishHemmige/sRtr/issues?q=is%3Aissue%20is%3Aopen%20label%3A%22organ%3A%20pancreas%22%2C%22organ%3A%20all%22)
- [Kidney-pancreas](https://github.com/VagishHemmige/sRtr/issues?q=is%3Aissue%20is%3Aopen%20label%3A%22organ%3A%20kidney-pancreas%22%2C%22organ%3A%20all%22)
- [Heart](https://github.com/VagishHemmige/sRtr/issues?q=is%3Aissue%20is%3Aopen%20label%3A%22organ%3A%20heart%22%2C%22organ%3A%20all%22)
- [Lung](https://github.com/VagishHemmige/sRtr/issues?q=is%3Aissue%20is%3Aopen%20label%3A%22organ%3A%20lung%22%2C%22organ%3A%20all%22)
- [Heart-lung](https://github.com/VagishHemmige/sRtr/issues?q=is%3Aissue%20is%3Aopen%20label%3A%22organ%3A%20heart-lung%22%2C%22organ%3A%20all%22)
- [Not about any organ’s
  data](https://github.com/VagishHemmige/sRtr/issues?q=is%3Aissue%20is%3Aopen%20label%3A%22organ%3A%20none%22):
  geography, the website and the package’s own setup

Each organ link includes the methods that apply to every organ, such as
joins and outcome definitions. To find something you can finish without
SRTR data, open [tasks you can verify without SRTR
data](https://github.com/VagishHemmige/sRtr/issues?q=is%3Aissue%20is%3Aopen%20label%3A%22role%3A%20verify%22%20label%3A%22no%20SAF%20needed%22)
or [decisions and designs to supervise without SRTR
data](https://github.com/VagishHemmige/sRtr/issues?q=is%3Aissue%20is%3Aopen%20label%3A%22role%3A%20supervise%20new%22%20label%3A%22no%20SAF%20needed%22).

## All projects

Each project is a GitHub issue that lists its tasks and says who is
working on what.

- **Joins, keys and analysis grain**
  ([\#270](https://github.com/VagishHemmige/sRtr/issues/270)). *Data
  handling; All organs.* Record each file’s grain and keys, check joins,
  and bring analyses to one row per person, listing or transplant.
- **Multi-organ and kidney-pancreas linkage**
  ([\#269](https://github.com/VagishHemmige/sRtr/issues/269)). *Data
  handling; Kidney-pancreas, All organs.* Count each graft and recipient
  correctly in kidney-pancreas and simultaneous multi-organ transplants.
- **Loading and files**
  ([\#278](https://github.com/VagishHemmige/sRtr/issues/278)). *Data
  handling; All organs.* Find every SAF file, handle odd layouts
  clearly, and read large files quickly.
- **Data quality and missingness**
  ([\#279](https://github.com/VagishHemmige/sRtr/issues/279)). *Data
  quality; All organs.* Find values that are structurally missing,
  implausible or out of order, following SRTR’s own approach.
- **Checks of the existing calculators**
  ([\#271](https://github.com/VagishHemmige/sRtr/issues/271)).
  *Validation; Kidney, Pancreas, Kidney-pancreas, Heart.* Check every
  risk score sRtr computes against its defining paper and against real
  data.
- **Liver risk scores**
  ([\#276](https://github.com/VagishHemmige/sRtr/issues/276)). *Derived
  variables; Liver.* Compute MELD and the main liver risk scores exactly
  as their defining papers specify.
- **Treatment and center variables**
  ([\#281](https://github.com/VagishHemmige/sRtr/issues/281)). *Derived
  variables; All organs.* Add induction therapy classes and center
  volume with documented definitions.
- **Post-transplant outcome definitions**
  ([\#280](https://github.com/VagishHemmige/sRtr/issues/280)).
  *Outcomes; All organs.* Settle the open definitions for graft failure,
  death, rejection and malignancy, and export the outcome function.
- **Waitlist analyses**
  ([\#275](https://github.com/VagishHemmige/sRtr/issues/275)).
  *Waitlist; All organs, Liver.* Status intervals, removal outcomes with
  competing risks, and decoded status codes for candidates.
- **Heart, lung and heart-lung support**
  ([\#277](https://github.com/VagishHemmige/sRtr/issues/277)). *New
  organ support; Heart, Lung, Heart-lung.* Load, label and build
  outcomes for thoracic files as sRtr does for kidney and liver.
- **Geography**
  ([\#274](https://github.com/VagishHemmige/sRtr/issues/274)).
  *Geography; Not organ-specific.* Match OPTN’s regions, including split
  states, and make the coverage calculations behave at the edges.
- **Validation against published numbers**
  ([\#282](https://github.com/VagishHemmige/sRtr/issues/282)).
  *Validation; All organs.* Check sRtr’s results against numbers SRTR
  and published papers report.
- **Documentation and site**
  ([\#283](https://github.com/VagishHemmige/sRtr/issues/283)).
  *Documentation; Not organ-specific.* Help a new reader go from a first
  load to a defined outcome, and see where to contribute.
- **Package infrastructure and CRAN**
  ([\#284](https://github.com/VagishHemmige/sRtr/issues/284)).
  *Infrastructure; Not organ-specific.* Prepare the package and
  repository for a first CRAN release and for more contributors.

## What the labels mean

Every task on GitHub carries four kinds of label.

| Label | Meaning |
|----|----|
| `organ: ...` | The organ whose data the task concerns. `organ: all` means a method for every organ’s data; `organ: none` means the task is not about any organ’s data. |
| `role: verify` | Check existing or generated work against a known answer, such as a paper, a published table or a real-data run. |
| `role: supervise new` | Decide what should be built, or judge whether a new design or definition is right. Claude drafts the options. |
| `complexity: low`, `medium`, `high` | How complex the thing being checked or built is: one function with a known answer, several pieces or a judgment between options, or shared machinery many analyses depend on. |
| `no SAF needed`, `needs SAF access` | Whether finishing the task needs your own access to SRTR data. |

Project types (data handling, outcomes, geography and so on) are written
on each project issue and in the list above, not as labels.
