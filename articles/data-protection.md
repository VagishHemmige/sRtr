# Data protection and security

SRTR standard analysis files (SAFs) are restricted data. This page says
what sRtr does to help keep them protected, what it does not do, and
what is planned. It is a first version: sRtr’s protections are still
being built, and each one is added here when it arrives. Planned items
link to their GitHub issue, where the design is discussed.

Nothing here replaces your data use agreement (DUA) or your data
security plan. They decide what you may do; sRtr can only make the safe
path easier.

## At a glance

| Topic | Protection | Status |
|:---|:---|:---|
| [Where sRtr reads and writes](#reads-and-writes) | Reads SAFs only from the folder you set with set_srtr_wd() | in place |
|  | Sends nothing from your files over the network | in place |
|  | Writes nothing outside tempdir() unless you give a path | in place |
|  | Warns when your SAF folder is inside a git repository and not ignored | planned ([\#294](https://github.com/VagishHemmige/sRtr/issues/294)) |
| [Keep SAFs out of version control](#version-control) | .gitignore patterns for SAF formats (in sRtr’s own repository) | in place |
|  | CI check that fails on SAF formats and identifier columns (in sRtr’s own repository) | in place |
|  | Scan a project folder for files that look like SRTR data | planned ([\#294](https://github.com/VagishHemmige/sRtr/issues/294)) |
|  | Check your project when sRtr is attached | planned ([\#294](https://github.com/VagishHemmige/sRtr/issues/294)) |
|  | Add SAF patterns to your project’s .gitignore | planned ([\#294](https://github.com/VagishHemmige/sRtr/issues/294)) |
|  | Commit hook that stops SRTR data being committed | planned ([\#294](https://github.com/VagishHemmige/sRtr/issues/294)) |
| [Share results, not records](#sharing-results) | Rules for sharing counts safely | in place |
|  | Small-cell check for tables and figures | planned ([\#295](https://github.com/VagishHemmige/sRtr/issues/295)) |
|  | Small-cell flags in summary functions | planned ([\#11](https://github.com/VagishHemmige/sRtr/issues/11)) |
| [Contributing without SRTR data](#contributing) | Synthetic test data only; live tests skip without SAFs | in place |
|  | Contributor guide to keeping SRTR data out of the repository | planned ([\#94](https://github.com/VagishHemmige/sRtr/issues/94)) |
|  | Synthetic SAF generator for tests and examples | planned ([\#1](https://github.com/VagishHemmige/sRtr/issues/1)) |
|  | Public center-level tables for examples that need no DUA | planned ([\#13](https://github.com/VagishHemmige/sRtr/issues/13)) |

## Your agreement sets the rules

SRTR releases SAFs only under a signed DUA, and every request that needs
a DUA must also have a data security plan and a research plan ([SRTR
2026](#ref-srtr-requests)). Those documents decide where the files may
be stored, who may see them, and what may be reported from them. sRtr
cannot check any of this.

SRTR’s public pages state no rule on the smallest count you may report.
The signed DUA is not public, so read yours for a reporting clause. For
data linked to Medicare records, the CMS cell size suppression policy
applies: no count from 1 to 10, and no number from which such a count
can be worked out ([CMS 2020](#ref-cms)). For SRTR data alone, masking
counts below 11 is common practice rather than a published SRTR rule.
sRtr’s articles follow it.

Nothing on this page is legal advice. A protection marked “in place”
lowers a risk; it does not show that an analysis meets your agreement.

## Where sRtr reads and writes

- **Reading.**
  [`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)
  reads SAFs only from the folder you set with
  [`set_srtr_wd()`](https://vagishhemmige.github.io/sRtr/reference/set_srtr_wd.md)
  (the `SRTR_WD` environment variable), on your own computer.
- **The network.** sRtr sends nothing from your files anywhere. Only two
  functions use the network, and both download public map layers from
  HRSA without sending anything about your data:
  [`get_hrsa_transplant_centers()`](https://vagishhemmige.github.io/sRtr/reference/get_hrsa_transplant_centers.md)
  and
  [`get_hrsa_opo_service_areas()`](https://vagishhemmige.github.io/sRtr/reference/get_hrsa_opo_service_areas.md).
  The [Coverage
  gain](https://vagishhemmige.github.io/sRtr/articles/geographic-coverage-gain.md)
  article also downloads public Census data, with your own API key.
- **Writing.** sRtr’s functions write nothing outside R’s temporary
  folder ([`tempdir()`](https://rdrr.io/r/base/tempfile.html)) unless
  you give them a path. One function writes outside it when you ask:
  `set_srtr_wd(path, permanent = TRUE)` saves the folder’s path, not any
  data, to your `~/.Renviron` file.

Keep the SAF folder where your security plan says. In particular, keep
it out of any folder tracked by git, and out of folders that a cloud
service synchronizes, unless your plan covers that service.

**Planned:**
[`set_srtr_wd()`](https://vagishhemmige.github.io/sRtr/reference/set_srtr_wd.md)
will warn when the folder is inside a git repository and not ignored
([\#294](https://github.com/VagishHemmige/sRtr/issues/294)).

## Keep SAFs out of version control

A SAF, or any file made from one, that is committed to git is copied to
every clone and stays in the history after it is deleted. Pushing it to
a private repository is still a disclosure.

sRtr’s own repository has two guards. Its `.gitignore` file keeps SAF
formats out of commits, and a check on GitHub fails on SAF formats, on
text files whose headers have SRTR identifier columns, and on files over
5 MB. You can add the same patterns to the `.gitignore` of your own
analysis project:

    # SRTR data: never commit
    *.[sS][aA][sS]7[bB][dD][aA][tT]
    *.[sS][aA][sS]7[bB][cC][aA][tT]
    *.[xX][pP][tT]
    *.[pP][aA][rR][qQ][uU][eE][tT]
    *.[fF][eE][aA][tT][hH][eE][rR]
    *.[aA][rR][rR][oO][wW]
    *.[dD][tT][aA]
    *.[sS][aA][vV]

These patterns catch the usual file formats only. They do not catch
`.rds`, `.RData` or `.csv` files you write from a SAF, and `git add -f`
overrides them. Keep files made from SAFs in the same protected folder
as the SAFs, not in the project.

**Planned** ([\#294](https://github.com/VagishHemmige/sRtr/issues/294);
function names are provisional):

- a function that scans a project folder for files that look like SRTR
  data;
- a check when sRtr is attached, which warns, naming paths only, about
  such files that git does not ignore (on by default, with an option to
  turn it off);
- helpers that add the patterns above to your project’s `.gitignore` and
  install a commit hook that runs the scan on staged files.

## Share results, not records

Share aggregate results only, never rows. Mask any count from 1 to 10,
and do not share a total beside masked parts, or two counts that differ
by a little, because a reader can work out the small count by
subtraction. [Checking sRtr on your own
SAFs](https://vagishhemmige.github.io/sRtr/articles/checking-your-safs.html#share-counts-only)
explains each rule with code.

**Planned:** a function that checks tables, model output and figures for
small cells, with the threshold set by an option
([\#295](https://github.com/VagishHemmige/sRtr/issues/295)), and
small-cell flags in sRtr’s summary functions
([\#11](https://github.com/VagishHemmige/sRtr/issues/11)).

## AI assistants and help requests

A chat with an AI assistant, a GitHub issue, a forum post and an email
to a colleague outside your agreement are all disclosures. When you ask
for help:

- share your code, column names and masked counts;
- do not paste rows, printed data frames, or the output of
  [`head()`](https://rdrr.io/r/utils/head.html),
  [`str()`](https://rdrr.io/r/utils/str.html) or
  [`View()`](https://rdrr.io/r/utils/View.html) on SAF data, and do not
  attach files made from SAFs;
- treat sRtr’s error and warning messages, and test failures, as output
  from your files: they can include exact counts, and some quote values
  from a column (for example, codes that no format lists). Before you
  share one, replace every count, value and identifier it contains, or
  reproduce the message on a few made-up rows and share that instead.

An assistant that can read your files or run commands on your computer
can read the SAF folder too. Do not give it access to that folder unless
your security plan covers the tool.

## Contributing without SRTR data

sRtr is developed without SRTR data. Its tests run on small, made-up
data; the tests that need real SAFs skip unless `SRTR_LIVE_TESTS` and
`SRTR_WD` are set, and are run only by people whose own DUA covers the
files, on their own computers. Results from those runs are shared as
masked aggregate counts. [Development and how to
contribute](https://vagishhemmige.github.io/sRtr/articles/development.md)
lists work that needs no SAFs.

**Planned:** a contributor guide to keeping SRTR data out of the
repository ([\#94](https://github.com/VagishHemmige/sRtr/issues/94)), a
synthetic SAF generator for tests and examples
([\#1](https://github.com/VagishHemmige/sRtr/issues/1)), and public
center-level tables for examples that need no DUA
([\#13](https://github.com/VagishHemmige/sRtr/issues/13)).

## What sRtr does not do

- sRtr is not a secure computing environment. It does not encrypt files,
  control who can open them or keep an audit log; your institution’s
  environment provides those.
- Its checks, now and planned, look for common patterns. A clean check
  does not show that a folder or a repository holds no patient data.
- It does not decide what your DUA allows.

## Next steps

- [Checking sRtr on your own
  SAFs](https://vagishhemmige.github.io/sRtr/articles/checking-your-safs.md):
  check a release, sharing only masked counts.
- [Getting
  started](https://vagishhemmige.github.io/sRtr/articles/getting-started.md):
  point sRtr at your SAFs and load a first file.

## References

Centers for Medicare & Medicaid Services. CMS cell size suppression
policy. 2020.
<https://www.hhs.gov/guidance/document/cms-cell-suppression-policy>

Scientific Registry of Transplant Recipients. Data requests. Accessed
2026-11-20. <https://srtr.hrsa.gov/requesting-data/data-requests/>
