# Keep SAF files out of a project's git commits

**\[experimental\]**

Two opt-in helpers for your own analysis project. Each writes only
inside the project folder you give it.

- `use_srtr_gitignore()` adds patterns for the file formats SAFs come in
  (`.sas7bdat`, `.sas7bcat`, `.xpt`, `.parquet`, `.feather`, `.arrow`,
  `.dta`, `.sav`, in any letter case) to the project's `.gitignore`,
  creating the file if needed. Patterns already there are not added
  again.

- `use_srtr_commit_check()` installs a git pre-commit hook that runs
  [`check_repo_for_srtr_data()`](https://vagishhemmige.github.io/sRtr/reference/check_repo_for_srtr_data.md)
  on the files staged for each commit and stops the commit when it finds
  any that look like SRTR data. It will not replace a pre-commit hook it
  did not write.

## Usage

``` r
use_srtr_gitignore(path)

use_srtr_commit_check(path)
```

## Arguments

- path:

  The project folder. There is no default: these functions change files
  in the folder you name. For `use_srtr_commit_check()`, the folder must
  be inside a git repository; the hook is installed for that repository.

## Value

The path of the file written, invisibly.

## Limits

The `.gitignore` patterns catch the usual SAF formats only: not `.rds`,
`.RData` or `.csv` files made from a SAF, and `git add -f` overrides
them.

The commit hook lives in the project's own `.git` folder, so it is not
copied when someone clones the project; each person runs
`use_srtr_commit_check()` in their own copy. `git commit --no-verify`
skips it. It checks each staged file as it was staged, even when the
copy in the folder has changed since. It needs `Rscript` on the path
that git uses and sRtr installed in that R; if either is missing, it
stops the commit and says so. On Windows, Git for Windows runs the hook
with its own shell, so check once that a commit with a made-up
`.sas7bdat` file is stopped.

None of this makes a repository a safe place for SRTR data, and a
private repository is still a disclosure. See the [data protection
guide](https://vagishhemmige.github.io/sRtr/articles/data-protection.html).

## See also

Other data protection:
[`check_repo_for_srtr_data()`](https://vagishhemmige.github.io/sRtr/reference/check_repo_for_srtr_data.md)

## Examples

``` r
project <- file.path(tempdir(), "made-up-project")
dir.create(project, showWarnings = FALSE)
use_srtr_gitignore(project)
#> ✔ Added 8 SAF patterns to .gitignore:
#>   /tmp/RtmprydEfS/made-up-project/.gitignore
#> ℹ Files git already tracks stay tracked; remove them with `git rm --cached
#>   <file>`.
readLines(file.path(project, ".gitignore"))
#> [1] "# SRTR data: never commit (added by sRtr::use_srtr_gitignore())"
#> [2] "*.[sS][aA][sS]7[bB][dD][aA][tT]"                                
#> [3] "*.[sS][aA][sS]7[bB][cC][aA][tT]"                                
#> [4] "*.[xX][pP][tT]"                                                 
#> [5] "*.[pP][aA][rR][qQ][uU][eE][tT]"                                 
#> [6] "*.[fF][eE][aA][tT][hH][eE][rR]"                                 
#> [7] "*.[aA][rR][rR][oO][wW]"                                         
#> [8] "*.[dD][tT][aA]"                                                 
#> [9] "*.[sS][aA][vV]"                                                 

# A second call adds nothing.
use_srtr_gitignore(project)
#> ✔ .gitignore already has sRtr's SAF patterns:
#>   /tmp/RtmprydEfS/made-up-project/.gitignore

unlink(project, recursive = TRUE)
```
