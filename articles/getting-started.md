# Getting started with sRtr

sRtr loads and labels the Scientific Registry of Transplant Recipients
(SRTR) standard analysis files (SAFs) in R. This article takes you from
installing the package to one checked load of a transplant file. Most of
the code needs your own SAFs, so it is shown here but not run. Terms
such as `TRR_ID`, SAF and release are defined in the
[glossary](https://vagishhemmige.github.io/sRtr/articles/glossary.html).

## Install and load

``` r

# install.packages("remotes")
remotes::install_github("VagishHemmige/sRtr")
```

``` r

library(sRtr)
library(dplyr)
```

## Point sRtr at your SAFs

[`set_srtr_wd()`](https://vagishhemmige.github.io/sRtr/reference/set_srtr_wd.md)
tells sRtr which folder holds your SAF delivery. sRtr finds `.sas7bdat`
(and `.parquet`) files anywhere inside it, by file name.

``` r

set_srtr_wd("path/to/your/SAFs", release = "2303")
```

Give the release your files come from. SRTR names releases by year and
month, so `"2303"` is the March 2023 release. Codes and labels change
from release to release, and sRtr uses the release to choose its
dictionary entries. If your folder is named after the release (such as
`pubsaf2303`), sRtr reads the release from the name.

sRtr stores copies of SRTR’s online data dictionary from some releases
only. For a release in between, it uses the entries that are the same in
the copies on either side, so the labels may not be the exact ones SRTR
published for that release. The check after loading shows which you got;
[Releases, the data dictionary and
warnings](https://vagishhemmige.github.io/sRtr/articles/releases-and-warnings.html)
explains it in full.

To keep the folder for later sessions, add `permanent = TRUE`. This
writes the path to your `~/.Renviron` file.

To see which files sRtr can find:

``` r

list.files(Sys.getenv("SRTR_WD"), pattern = "\\.(sas7bdat|parquet)$",
           recursive = TRUE)
```

## Load a file

Each file has a key: its file name without the extension, such as
`TX_KI` for kidney transplants. The keys in sRtr’s bundled data
dictionary are:

``` r

sort(unique(sRtr::dictionary$Dataset))
#>  [1] "CAND_KIPA"            "CAND_LIIN"            "CAND_THOR"           
#>  [4] "DON_LIV_FOL"          "DONOR_DECEASED"       "DONOR_DISPOSITION"   
#>  [7] "DONOR_LIVE"           "FOL_IMMUNO"           "HIST_OPO_TXC"        
#> [10] "IMMUNO"               "INSTITUTION"          "MALIG"               
#> [13] "MPEXCEPT"             "MPEXCEPT_ORIG_TUMORS" "MPEXCEPT_TUMORS"     
#> [16] "PRA_HIST"             "REC_HISTO"            "REC_HISTO_XMAT"      
#> [19] "STATHIST_KIPA"        "STATHIST_LIIN"        "STATHIST_THOR"       
#> [22] "STATJUST_HR1A"        "STATJUST_HR1B"        "STATJUST_LI1"        
#> [25] "STATJUST_LI2A"        "STATJUST_LI2B"        "TREATMENT"           
#> [28] "TX_HL"                "TX_HR"                "TX_IN"               
#> [31] "TX_KI"                "TX_KP"                "TX_LI"               
#> [34] "TX_LU"                "TX_PA"                "TXF_HL"              
#> [37] "TXF_HR"               "TXF_IN"               "TXF_KI"              
#> [40] "TXF_KP"               "TXF_LI"               "TXF_LU"              
#> [43] "TXF_PA"
```

Your delivery has only the files you requested, so it may not include
all of these. The main ones are:

- `TX_*`: one row per transplant registration (`TX_KI` kidney, `TX_LI`
  liver, `TX_HR` heart, `TX_LU` lung, `TX_KP` kidney-pancreas, and so
  on).
- `TXF_*`: follow-up forms after transplant, several per registration.
- `CAND_*`: waitlist registrations (`CAND_KIPA` kidney and pancreas,
  `CAND_LIIN` liver and intestine, `CAND_THOR` heart and lung).
- `DONOR_DECEASED` and `DONOR_LIVE`: donors.

Files that cover more than one organ, such as `CAND_KIPA`, need
filtering to the organ you study.

Load a file with
[`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md).
Transplant files are large, so select the columns you need; this is much
faster than reading every column.

``` r

tx <- load_srtr_file(
  "TX_KI",
  col_select = c("TRR_ID", "PERS_ID", "REC_TX_DT", "REC_AGE_AT_TX",
                 "DON_RACE", "TFL_GRAFT_DT", "TFL_LAFUDATE")
)
```

Then check what came back:

``` r

dim(tx)
attr(tx, "srtr_release")      # the release and dictionary used
range(tx$REC_TX_DT, na.rm = TRUE)
```

In `attr(tx, "srtr_release")`, `dictionary` names the stored copy used
when sRtr has one for your release (such as `"2609-1"` for release
2609), and says `"interpolated"` when it filled the gap between two
copies, as for release 2303. With no release given, it says `"bundled"`.
Transplant dates are `Date` columns, ready for date arithmetic.

## Labels and codes

[`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)
labels the data as it loads it. There are two kinds of label:

- A **variable label** describes the column. It is stored as an
  attribute, so the values do not change.
- A **factor label** replaces a coded value with its meaning from the
  SRTR format, so the column becomes a factor.

``` r

attr(tx$DON_RACE, "label")   # variable label: what the column is
levels(tx$DON_RACE)          # factor labels: what each code means
```

Factor labels make tables readable. Keep the raw codes instead when your
code matches on them, for example when selecting follow-up forms by a
response code: matching on label text breaks when the wording differs
from what you typed.

``` r

tx_codes <- load_srtr_file("TX_KI", factor_labels = FALSE,
                           col_select = c("TRR_ID", "DON_RACE"))
```

Codes that no format lists are kept and named `<code>: not in format`,
with a warning. [Checking sRtr on your own
SAFs](https://vagishhemmige.github.io/sRtr/articles/checking-your-safs.html)
shows how to count them.

## Join files on their keys

`TRR_ID` identifies a transplant registration and `PERS_ID` a person.
One person can have several transplants, and one transplant several
follow-up forms. To load only the follow-up forms of the transplants you
selected, pass their `TRR_ID` values to `trr_id_filter`. sRtr still
reads every row and then keeps the matching ones, so also select only
the columns you need:

``` r

recent <- filter(tx, REC_TX_DT >= as.Date("2020-01-01"))
txf <- load_srtr_file("TXF_KI", trr_id_filter = recent$TRR_ID,
                      col_select = c("TRR_ID", "TFL_PX_STAT_DT"))

c(people = n_distinct(recent$PERS_ID),
  transplants = n_distinct(recent$TRR_ID),
  forms = nrow(txf))
```

These three counts usually differ. Say which unit each result counts.
[Files, keys and
joins](https://vagishhemmige.github.io/sRtr/articles/files-and-keys.html)
covers the other files and how to check a join.

## Share counts, never rows

The SRTR data use agreement does not allow sharing patient-level data.
Share aggregate counts only, and mask any count from 1 to 10:

``` r

mask_n <- function(n) {
  noquote(ifelse(n > 0 & n < 11, "<11", format(n, big.mark = ",")))
}
mask_n(c(transplants = nrow(recent), forms = nrow(txf)))
```

Masking each number is not enough: a total shared beside masked parts
lets a reader work out the small count by subtraction. [Checking sRtr on
your own
SAFs](https://vagishhemmige.github.io/sRtr/articles/checking-your-safs.html#share-counts-only)
explains this in full. [Data protection and
security](https://vagishhemmige.github.io/sRtr/articles/data-protection.html)
covers where to keep the files and what sRtr does to protect them.

## If something goes wrong

- **No file for a key.** The error names the folder sRtr searched. Check
  that
  [`set_srtr_wd()`](https://vagishhemmige.github.io/sRtr/reference/set_srtr_wd.md)
  points at your delivery and that the file name, less its extension,
  matches the key.
- **A warning about missing columns.** Your file’s columns differ from
  the dictionary for that release. Check the release you gave
  [`set_srtr_wd()`](https://vagishhemmige.github.io/sRtr/reference/set_srtr_wd.md).
  The `column_check` argument turns this into an error or turns it off.
- **Slow loads or running out of memory.** Use `col_select`: it is the
  only option that reads less of the file. `trr_id_filter` makes the
  result smaller, not the read.
- **Blank text.** Blank text values become `NA` before labelling. Use
  `blank_text = "keep"` to keep them as they are.

The [`load_srtr_file()` help
page](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.html)
describes every loading option, and [Releases, the data dictionary and
warnings](https://vagishhemmige.github.io/sRtr/articles/releases-and-warnings.html)
explains each warning and how to collect warnings in a script.

## Next steps

- [Checking sRtr on your own
  SAFs](https://vagishhemmige.github.io/sRtr/articles/checking-your-safs.html):
  confirm that sRtr reads your release correctly.
- [Files, keys and
  joins](https://vagishhemmige.github.io/sRtr/articles/files-and-keys.html):
  link the files you load without changing what a row means.
- [Missing
  data](https://vagishhemmige.github.io/sRtr/articles/missing-data.md):
  decide what unknown and not-done codes mean for your analysis.
- [Building cohorts with flow
  diagrams](https://vagishhemmige.github.io/sRtr/articles/building-cohort-with-flowchart.md):
  select a cohort with a record of each exclusion.
- [Adding risk
  scores](https://vagishhemmige.github.io/sRtr/articles/adding-columns.md):
  KDPI, EPTS, PDRI and other published scores.
- [Rejection and malignancy on follow-up
  forms](https://vagishhemmige.github.io/sRtr/articles/follow-up-forms.html)
  and [Death, graft failure, and
  censoring](https://vagishhemmige.github.io/sRtr/articles/follow-up-windows.html):
  pitfalls in post-transplant outcomes.
- [Mapping transplant
  geography](https://vagishhemmige.github.io/sRtr/articles/mapping.md).
