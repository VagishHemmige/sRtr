# Set the SRTR working directory

Sets the SRTR working directory for the current session, or optionally
saves it permanently in the user's `.Renviron` file as the environment
variable `SRTR_WD`.

## Usage

``` r
set_srtr_wd(path, permanent = FALSE, release = NULL)
```

## Arguments

- path:

  Path to the SRTR data folder

- permanent:

  Logical; if TRUE, appends the setting to `.Renviron` for persistence

- release:

  Optional. The SAF release the folder holds, as year and month
  (`"2609"` for September 2026). Files loaded from the folder use the
  SRTR data dictionary for that release. If `NULL` (the default), the
  release is read from a folder name like `pubsaf2609` (the folder or
  its parent); if there is none, files use the bundled
  [dictionary](https://vagishhemmige.github.io/sRtr/reference/dictionary.md)
  and
  [formats](https://vagishhemmige.github.io/sRtr/reference/formats.md).
  A `release` that differs from the folder name wins, with a warning.
  Only the folder is saved by `permanent = TRUE`, not the release.

## Value

The normalized path, invisibly

## Data safety check

If the folder is inside a git repository and git does not ignore it,
`set_srtr_wd()` warns, naming the folder and the repository, because a
SAF there could be committed. Turn the check off with
`options(sRtr.safety_check = FALSE)`. See
[`check_repo_for_srtr_data()`](https://vagishhemmige.github.io/sRtr/reference/check_repo_for_srtr_data.md).

## See also

Guides:

- [Point sRtr at your
  SAFs](https://vagishhemmige.github.io/sRtr/articles/getting-started.html#point-srtr-at-your-safs)

- [Telling sRtr your
  release](https://vagishhemmige.github.io/sRtr/articles/releases-and-warnings.html#telling-srtr-your-release)

## Examples

``` r
if (FALSE) { # \dontrun{
set_srtr_wd("C:/Data/SRTR")          # Session only
set_srtr_wd("C:/Data/SRTR", TRUE)    # Persistent across sessions
set_srtr_wd("C:/Data/SRTR", release = "2609")  # Files are release 2609
} # }
```
