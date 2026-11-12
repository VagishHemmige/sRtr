# Internal: Map SRTR data files in the working directory

Scans the directory set by the SRTR_WD environment variable and stores a
cleaned file list in the package's internal environment for downstream
use.

## Usage

``` r
.map_srtr_files()
```

## Details

Called by `.srtr_file_list()` when
[`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)
needs the list, and by
[`set_srtr_wd()`](https://vagishhemmige.github.io/sRtr/reference/set_srtr_wd.md).
