# Set the SRTR working directory

Sets the SRTR working directory for the current session, or optionally
saves it permanently in the user's `.Renviron` file as the environment
variable `SRTR_WD`.

## Usage

``` r
set_srtr_wd(path, permanent = FALSE)
```

## Arguments

- path:

  Path to the SRTR data folder

- permanent:

  Logical; if TRUE, appends the setting to `.Renviron` for persistence

## Value

The normalized path, invisibly

## Examples

``` r
if (FALSE) { # \dontrun{
set_srtr_wd("C:/Data/SRTR")          # Session only
set_srtr_wd("C:/Data/SRTR", TRUE)    # Persistent across sessions
} # }
```
