# Internal: Map SRTR data files in the working directory

Scans the directory set by the SRTR_WD environment variable and stores a
cleaned file list in the package's internal environment for downstream
use.

## Usage

``` r
.map_srtr_files()
```

## Details

This function is intended for internal use only and is automatically run
on package load if SRTR_WD is set.
