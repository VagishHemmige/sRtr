# Find files in a project that look like SRTR data

**\[experimental\]**

Scans a project folder for files that look like SRTR standard analysis
file (SAF) data and that could be committed to git. It applies the same
three rules as the check that runs on sRtr's own repository on GitHub:

- **Data formats:** files in the formats SAFs come in or are converted
  to (`.sas7bdat`, `.sas7bcat`, `.xpt`, `.parquet`, `.feather`,
  `.arrow`, `.dta`, `.sav`), in any letter case.

- **Identifier columns:** `.csv`, `.tsv` and `.txt` files whose first
  line names an SRTR identifier column (`TRR_ID`, `TRR_FOL_ID`, `PX_ID`,
  `PERS_ID`, `DONOR_ID`, `CAN_ID`, `TX_ID` or `REC_ID`). Files under
  `tests/testthat/fixtures/` whose names start with `synthetic-` are
  skipped, as in sRtr's own repository.

- **Large files:** any file over 5 MB, which may hold data in another
  format.

The scan only reads: it lists files and reads the first line of text
files. It changes nothing.

## Usage

``` r
check_repo_for_srtr_data(path = ".", files = NULL, staged = FALSE)
```

## Arguments

- path:

  The project folder to scan. Defaults to the working directory.

- files:

  Optional. Paths of files to check, relative to `path`, instead of the
  file list described under "Which files are scanned". Files that do not
  exist are skipped.

- staged:

  If `TRUE`, check the files staged for the next commit in the git
  repository that holds `path`, as they are staged rather than as they
  are in the folder. Paths in the result are then relative to the top of
  the repository. This is what
  [`use_srtr_commit_check()`](https://vagishhemmige.github.io/sRtr/reference/use_srtr_gitignore.md)'s
  hook runs. Cannot be used with `files`.

## Value

A tibble with one row per finding, returned invisibly: `path` (relative
to the folder scanned), `problem` (`"data format"`,
`"identifier column"`, `"unreadable file"` or `"large file"`) and
`detail`. A text file whose first line cannot be read is reported as
unreadable rather than passed as clean. A file can appear more than
once. The scan warns, naming the paths only, when it finds anything, and
gives a message when it finds nothing.

## Which files are scanned

In a git repository, the scan covers the files git would commit: tracked
files and untracked files that `.gitignore` does not exclude. A SAF that
is ignored is not reported. When `path` is not in a git repository, or
git is not installed, every file under `path` is scanned, except those
in hidden folders such as `.git`.

The scan finds the usual formats and headers only. It does not find SRTR
data saved as `.rds` or `.RData` files, or text files without an
identifier column, so an empty result is not proof that a project holds
no SRTR data. See the [data protection
guide](https://vagishhemmige.github.io/sRtr/articles/data-protection.html).

## Check when sRtr is attached

When you call [`library(sRtr)`](https://github.com/VagishHemmige/sRtr)
from inside a git repository, sRtr runs the same scan on that repository
and shows a short message, naming paths only, if it finds files git
would commit that look like SRTR data. The message also says when the
repository's ignore rules do not cover every SAF format
([`use_srtr_gitignore()`](https://vagishhemmige.github.io/sRtr/reference/use_srtr_gitignore.md)
adds them) and when no commit check is installed
([`use_srtr_commit_check()`](https://vagishhemmige.github.io/sRtr/reference/use_srtr_gitignore.md)).
Nothing is shown when there is nothing to report.
[`set_srtr_wd()`](https://vagishhemmige.github.io/sRtr/reference/set_srtr_wd.md)
warns when the SAF folder itself is inside a git repository and not
ignored.

Turn both checks off with `options(sRtr.safety_check = FALSE)`, for
example in your `.Rprofile`. The attach message is a package startup
message, so
[`suppressPackageStartupMessages()`](https://rdrr.io/r/base/message.html)
hides it too. Both are skipped during `R CMD check`, and the attach
check is skipped while a document is being knitted, so its message never
appears in a report.

## See also

Other data protection:
[`use_srtr_gitignore()`](https://vagishhemmige.github.io/sRtr/reference/use_srtr_gitignore.md)

## Examples

``` r
# A made-up project with one file that looks like data
project <- file.path(tempdir(), "made-up-project")
dir.create(project, showWarnings = FALSE)
writeLines("TRR_ID,AGE", file.path(project, "cohort.csv"))
writeLines("x <- 1", file.path(project, "analysis.R"))

findings <- check_repo_for_srtr_data(project)
#> Warning: 1 file looks like SRTR data and could be committed from
#> /tmp/RtmprydEfS/made-up-project (folder scan; not a git repository):
#> • cohort.csv (identifier column)
#> ℹ Move SAFs and files made from them out of the project, or add them to
#>   .gitignore.
findings
#> # A tibble: 1 × 3
#>   path       problem           detail
#>   <chr>      <chr>             <chr> 
#> 1 cohort.csv identifier column TRR_ID

unlink(project, recursive = TRUE)
```
