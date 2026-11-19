# Releases, the data dictionary and warnings

Most of the warnings a new sRtr user sees come from one question: which
version of the SRTR data dictionary describes my files? This article
answers it, explains each warning
[`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)
gives, and shows how a script can count warnings instead of hiding them.

The examples use sRtr’s stored dictionaries and one tiny made-up file,
so they run on this site.

``` r

library(sRtr)
```

## Releases

SRTR delivers standard analysis files (SAFs) in releases named by year
and month: `"2303"` is the March 2023 release. Variables are added and
dropped between releases, so the dictionary that labels your files
should be the one for your release.

sRtr stores copies of SRTR’s public data dictionary page, one per
version it has seen:

``` r

dictionary_versions$releases[, c("snapshot", "release", "retrieved")]
#>   snapshot release            retrieved
#> 1   2203-1    2203                     
#> 2   2609-1    2609 2026-11-15T13:24:37Z
```

For a release that has a stored copy, sRtr uses that copy. For a release
between two copies, it uses what the two have in common:

``` r

d2303 <- srtr_dictionary("2303")
attr(d2303, "basis")
#> [1] "interpolated"
```

## What a release between two copies can and cannot know

Between the stored 2203 and 2609 copies, no variable’s label, type or
format changed, and no format code changed meaning. The differences are
variables that appear in only one copy:

``` r

key <- function(d) paste(d$Dataset, d$Variable)
d2203 <- srtr_dictionary("2203")
d2609 <- srtr_dictionary("2609")

c(
  only_in_2203 = length(setdiff(key(d2203), key(d2609))),
  only_in_2609 = length(setdiff(key(d2609), key(d2203))),
  in_both = length(intersect(key(d2203), key(d2609)))
)
#> only_in_2203 only_in_2609      in_both 
#>           27           22         5193
head(setdiff(key(d2203), key(d2609)), 3)
#> [1] "CAND_KIPA CAN_LISTING_CTR_ID" "CAND_LIIN CAN_LISTING_CTR_ID"
#> [3] "CAND_THOR CAN_LISTING_CTR_ID"
head(setdiff(key(d2609), key(d2203)), 3)
#> [1] "CAND_KIPA CAN_LISTING_CTR_CD" "CAND_KIPA CAN_LISTING_CTR_TY"
#> [3] "CAND_LIIN CAN_LISTING_CTR_CD"
```

For example, the waitlist files list `CAN_LISTING_CTR_ID` in 2203 and
`CAN_LISTING_CTR_CD` with `CAN_LISTING_CTR_TY` in 2609. Whether a 2303
file has the old column, the new ones or both cannot be known from the
two copies, so the 2303 dictionary leaves all of them out:

``` r

nrow(d2303) == length(intersect(key(d2203), key(d2609)))
#> [1] TRUE
```

[`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)
does not lose those columns: it reads them from your file and labels
them from whichever copy lists them.

Two more points about the stored copies:

- A copy’s date is when SRTR published that page or sRtr retrieved it,
  not when a variable was first collected. A variable that first appears
  in the 2609 copy may have been collected long before. To find when a
  variable is actually filled in, look at the data (see [Missing
  data](https://vagishhemmige.github.io/sRtr/articles/missing-data.md)).
- If a later copy changes a variable between two copies, a release in
  between gets the earlier definition, with a warning. `gaps = "error"`
  stops instead, and `gaps = "nearest"` stays silent. With the two
  copies sRtr has now, this does not happen.

A release before the first copy or after the last uses the nearest one,
with a warning:

``` r

early <- srtr_dictionary("2101")
#> Warning: No stored SRTR dictionary is close to release "2101"; using snapshot "2203-1".
#> ℹ Stored snapshots: "2203-1" and "2609-1".
attr(early, "snapshot")
#> [1] "2203-1"
```

## Telling sRtr your release

sRtr takes the release from, in order:

1.  the `release` argument of
    [`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md);
2.  `set_srtr_wd(release = )`;
3.  a folder named `pubsafYYMM`, such as `pubsaf2303`;
4.  otherwise, the bundled dictionary
    ([`sRtr::dictionary`](https://vagishhemmige.github.io/sRtr/reference/dictionary.md)).

Every loaded file records which it used. Here is a tiny made-up waitlist
file in a folder named for release 2303.

On your own files you would call
[`set_srtr_wd()`](https://vagishhemmige.github.io/sRtr/reference/set_srtr_wd.md).
That changes the folder and release for the whole R session, so the
example instead points sRtr at the made-up folder only while each call
runs, with `in_example()`. Your own folder and release are untouched if
you run it.

``` r

dir <- file.path(tempdir(), "pubsaf2303")
dir.create(dir, showWarnings = FALSE)
cand <- data.frame(
  PX_ID = 1:4,
  CAN_LISTING_CTR_ID = c(11, 11, 12, 13),
  CAN_ABO = c("A", "O", "UNK", "B"),
  CAN_LISTING_DT = as.Date("2021-01-01") + 0:3
)
suppressWarnings(haven::write_sas(cand, file.path(dir, "cand_kipa.sas7bdat")))

# Instead of set_srtr_wd(dir), for this example only.
in_example <- function(expr) withr::with_envvar(c(SRTR_WD = dir), expr)
```

``` r

cand_kipa <- in_example(load_srtr_file("CAND_KIPA"))
#> Warning: The "CAND_KIPA" file is missing 189 columns that the bundled SRTR data
#> dictionary lists: CAN_ACADEMIC_LEVEL, CAN_ACADEMIC_PROGRESS,
#> CAN_ACCEPT_HIV_ORG, CAN_ACPT_HBC_POS, CAN_ACPT_HCV_POS,
#> CAN_ACPT_ORG_OTHER_TEAM, CAN_ACTIVATE_DT, CAN_AGE_AT_LISTING, CAN_AGE_DIAB,
#> CAN_AGE_IN_MONTHS_AT_LISTING, CAN_ANASTOMOSIS, CAN_ANESTH_PRIOR_DEATH,
#> CAN_ANGINA, CAN_ANGINA_CAD, CAN_AVN, CAN_BMI, CAN_CEREB_VASC, CAN_CITIZENSHIP,
#> …, REC_TX_PROCEDURE_TY, and WL_ORG.
#> ℹ The file may come from a different SAF release than the dictionary. Code that
#>   needs these columns will not work with this file.
#> ℹ Set `column_check = "none"` to skip this check.
#> Warning: `CAN_ABO`: 1 value with 1 code not in format "ABO", kept as its own level:
#> "UNK: not in format".
```

The two warnings are the subject of the next sections. First, what was
recorded:

``` r

str(attr(cand_kipa, "srtr_release"))
#> List of 5
#>  $ release    : chr "2303"
#>  $ dictionary : chr "interpolated"
#>  $ basis      : chr "folder name"
#>  $ view       : chr "corrected"
#>  $ corrections: chr "SRTR-DC-001"
```

`release` came from the folder name (`basis`), and `dictionary` says it
was filled in between two copies. To repeat your labels, someone needs
all of this attribute and the same version of sRtr, because a later
version can store another copy of the dictionary or change a correction.
Save the attribute with your results, and record the sRtr version you
used:

``` r

packageVersion("sRtr")
# Installed from GitHub: the commit, if recorded
packageDescription("sRtr")$RemoteSha
```

A lockfile (for example from renv) pins the version for you.

`CAN_LISTING_CTR_ID` kept its label even though the 2303 dictionary left
it out:

``` r

attr(cand_kipa$CAN_LISTING_CTR_ID, "label")
#> [1] "CAN_LISTING_ Center ID"
```

## Missing columns

The first warning lists the dictionary’s columns that the file lacks.
This made-up file has only four columns. On real files, the usual causes
are a dictionary for the wrong release, or an extract SRTR delivered
with fewer columns. Check the release first. `column_check = "error"`
turns the warning into an error, and `column_check = "none"` turns it
off.

The check runs only when you read every column. With `col_select`, sRtr
reads the columns you name (a name the file lacks is an error) and does
not compare the file with the dictionary, so no warning there says
nothing about the columns you did not select.

## Codes in no format

The second warning is about values that no SRTR format lists, here
`"UNK"` in `CAN_ABO`. Their meaning is not documented, so sRtr keeps
them as their own factor level and names them as such:

``` r

table(cand_kipa$CAN_ABO)
#> 
#>                 A: A               A1: A1             A1B: A1B 
#>                    1                    0                    0 
#>               A2: A2             A2B: A2B               AB: AB 
#>                    0                    0                    0 
#>                 B: B                 O: O Z: Z (In Utero Only) 
#>                    1                    1                    0 
#>   UNK: not in format 
#>                    1
```

sRtr warns every time, rather than recoding them, because only a source
document can say what they mean. Decide for your analysis, and say what
you decided. [Checking sRtr on your own
SAFs](https://vagishhemmige.github.io/sRtr/articles/checking-your-safs.md)
shows how to count these values on your files.

## Corrections to SRTR’s dictionary

sRtr corrects a few entries of SRTR’s web dictionary that do not match
the files. Each has an ID, and every load records which were applied
(the `corrections` field above). The one correction so far gives
`REC_COD`, the recipient cause of death, the format `COD` instead of the
thoracic `THCOD`:

``` r

web <- srtr_dictionary("2609", view = "web")
corrected <- srtr_dictionary("2609")
c(
  web = unique(web$FormatID[web$Variable == "REC_COD"]),
  corrected = unique(corrected$FormatID[corrected$Variable == "REC_COD"])
)
#>       web corrected 
#>   "THCOD"     "COD"
```

`view = "web"`, in
[`srtr_dictionary()`](https://vagishhemmige.github.io/sRtr/reference/srtr_dictionary.md)
or
[`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md),
gives the dictionary as SRTR’s pages have it, without corrections. For a
release between two stored copies, it is still filled in from the copies
on either side; before the first or after the last, it uses the nearest
copy, with a warning. The [`srtr_dictionary()` help
page](https://vagishhemmige.github.io/sRtr/reference/srtr_dictionary.md)
lists every correction and its evidence.

## Counting warnings instead of hiding them

[`suppressWarnings()`](https://rdrr.io/r/base/warning.html) hides every
warning, including ones you have not seen before. Every sRtr warning has
a class, so a script can collect each kind and decide what to do with
it:

``` r

seen <- list()
collect <- function(expr) {
  withCallingHandlers(
    expr,
    sRtr_warning = function(w) {
      kind <- class(w)[1]
      seen[[kind]] <<- c(seen[[kind]], conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )
}

cand_kipa <- collect(in_example(load_srtr_file("CAND_KIPA")))
lengths(seen)
#> sRtr_warning_missing_columns   sRtr_warning_unknown_codes 
#>                            1                            1
```

Warnings from other packages still reach you. Read `seen` yourself; on
real files the messages can contain values from your data, so do not
share them as they are (see [Share counts
only](https://vagishhemmige.github.io/sRtr/articles/checking-your-safs.html#share-counts-only)).

To silence one kind you have already looked at, and only that kind:

``` r

quiet_codes <- function(expr) {
  withCallingHandlers(
    expr,
    sRtr_warning_unknown_codes = function(w) invokeRestart("muffleWarning")
  )
}
cand_kipa <- quiet_codes(in_example(load_srtr_file("CAND_KIPA")))
#> Warning: The "CAND_KIPA" file is missing 189 columns that the bundled SRTR data
#> dictionary lists: CAN_ACADEMIC_LEVEL, CAN_ACADEMIC_PROGRESS,
#> CAN_ACCEPT_HIV_ORG, CAN_ACPT_HBC_POS, CAN_ACPT_HCV_POS,
#> CAN_ACPT_ORG_OTHER_TEAM, CAN_ACTIVATE_DT, CAN_AGE_AT_LISTING, CAN_AGE_DIAB,
#> CAN_AGE_IN_MONTHS_AT_LISTING, CAN_ANASTOMOSIS, CAN_ANESTH_PRIOR_DEATH,
#> CAN_ANGINA, CAN_ANGINA_CAD, CAN_AVN, CAN_BMI, CAN_CEREB_VASC, CAN_CITIZENSHIP,
#> …, REC_TX_PROCEDURE_TY, and WL_ORG.
#> ℹ The file may come from a different SAF release than the dictionary. Code that
#>   needs these columns will not work with this file.
#> ℹ Set `column_check = "none"` to skip this check.
```

The codes warning is gone; the missing-columns warning still shows.

## Checklist

- Know your release, and give it to
  [`set_srtr_wd()`](https://vagishhemmige.github.io/sRtr/reference/set_srtr_wd.md)
  or name the folder `pubsafYYMM`.
- Save `attr(x, "srtr_release")` and the sRtr version with your
  analysis.
- Read each missing-columns warning once; check the release if you did
  not expect it.
- Decide what each code in no format means for your analysis.
- Collect warnings by class rather than suppressing them all.

## Next steps

- [Files, keys and
  joins](https://vagishhemmige.github.io/sRtr/articles/files-and-keys.md):
  link the files you have loaded.
- [Checking sRtr on your own
  SAFs](https://vagishhemmige.github.io/sRtr/articles/checking-your-safs.md):
  check a release systematically before an analysis.
