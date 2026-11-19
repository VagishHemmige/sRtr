# Missing data

``` r

library(sRtr)
```

SRTR variables record missing information in many ways, and the codes
differ from variable to variable. Code `4` is “Unknown” in one format,
“N/A” in another and “Not tested” in a third. sRtr handles this in three
steps that can be used separately:

1.  `missing_codes` says what each code means.
2.  [`srtr_missing_report()`](https://vagishhemmige.github.io/sRtr/reference/srtr_missing_report.md)
    counts what is in your data.
3.  [`srtr_normalize_missing()`](https://vagishhemmige.github.io/sRtr/reference/srtr_normalize_missing.md)
    turns the kinds you choose into `NA`.

The rows below are made up. They use column names from `TX_KI`.

``` r

tx_ki <- data.frame(
  DON_ANTI_HCV = c("P", "N", "U", "ND", "I", "PD"),
  DON_HIST_DIAB = c(1, 5, 998, 998, 2, NA),
  CAN_MALIG = c("Y", "N", "U", "", "ND", "N")
)
```

With real data, `load_srtr_file("TX_KI")` records the dataset on the
data frame, so `file_key` does not need to be given.

## What the codes mean

`missing_codes$formats` classifies the format codes that may stand for
missing information. Each code has one type.

``` r

codes <- missing_codes$formats
codes[codes$Format == "SRLSTT", c("Code", "Meaning", "missing_type")]
#>     Code            Meaning    missing_type
#> 234    C C: Cannot Disclose cannot_disclose
#> 235    I   I: Indeterminate   indeterminate
#> 236   ND       ND: Not Done        not_done
#> 237   PD        PD: Pending         pending
#> 238    U         U: Unknown         unknown
```

The types are `unknown`, `not_applicable`, `not_done`, `pending`,
`cannot_disclose`, `indeterminate`, `partial` (part of the answer is
known, such as “Yes, duration unknown”), `sas_missing` and `none` (an
ordinary value). They are sRtr’s grouping of the meanings in the SRTR
data dictionary, not an SRTR classification.

`missing_codes$variables` covers flag columns that have no format, with
values such as a blank, `U` or `ND`. The SRTR dictionary does not
document these values; they are listed from experience with the files.

## What is in the data

[`srtr_missing_report()`](https://vagishhemmige.github.io/sRtr/reference/srtr_missing_report.md)
counts the codes by type and changes nothing.

``` r

srtr_missing_report(tx_ki, file_key = "TX_KI")
#> # A tibble: 10 × 5
#>    variable      format  missing_type      n percent
#>    <chr>         <chr>   <chr>         <int>   <dbl>
#>  1 DON_ANTI_HCV  SRLSTT  unknown           1    16.7
#>  2 DON_ANTI_HCV  SRLSTT  not_done          1    16.7
#>  3 DON_ANTI_HCV  SRLSTT  pending           1    16.7
#>  4 DON_ANTI_HCV  SRLSTT  indeterminate     1    16.7
#>  5 DON_HIST_DIAB HSTDBDR unknown           2    33.3
#>  6 DON_HIST_DIAB HSTDBDR partial           1    16.7
#>  7 DON_HIST_DIAB HSTDBDR na                1    16.7
#>  8 CAN_MALIG     NA      unknown           1    16.7
#>  9 CAN_MALIG     NA      not_done          1    16.7
#> 10 CAN_MALIG     NA      sas_missing       1    16.7
```

`detail = "code"` lists every classified code with its count, including
codes that do not occur.

``` r

srtr_missing_report(
  tx_ki,
  cols = "DON_ANTI_HCV",
  file_key = "TX_KI",
  detail = "code"
)
#> # A tibble: 5 × 7
#>   variable     format code  meaning            missing_type        n percent
#>   <chr>        <chr>  <chr> <chr>              <chr>           <int>   <dbl>
#> 1 DON_ANTI_HCV SRLSTT U     U: Unknown         unknown             1    16.7
#> 2 DON_ANTI_HCV SRLSTT ND    ND: Not Done       not_done            1    16.7
#> 3 DON_ANTI_HCV SRLSTT PD    PD: Pending        pending             1    16.7
#> 4 DON_ANTI_HCV SRLSTT C     C: Cannot Disclose cannot_disclose     0     0  
#> 5 DON_ANTI_HCV SRLSTT I     I: Indeterminate   indeterminate       1    16.7
```

## Choosing what becomes NA

By default,
[`srtr_normalize_missing()`](https://vagishhemmige.github.io/sRtr/reference/srtr_normalize_missing.md)
uses the `"analysis"` policy.

``` r

srtr_normalize_missing(tx_ki, file_key = "TX_KI")
#>   DON_ANTI_HCV DON_HIST_DIAB CAN_MALIG
#> 1            P             1         Y
#> 2            N             5         N
#> 3         <NA>            NA      <NA>
#> 4         <NA>            NA      <NA>
#> 5            I             2      <NA>
#> 6         <NA>            NA         N
```

Unknown, not done, pending, withheld and blank values became `NA`.
“Indeterminate” and the partly known diabetes code were kept, because
they say something about the patient.

Once they are `NA`, “unknown” and “not done” look the same. To keep the
difference, ask for reason columns: `reason = "changed"` adds a `_MISS`
column for each variable that changed, recording why each value became
`NA`.

``` r

srtr_normalize_missing(tx_ki, reason = "changed", file_key = "TX_KI")
#>   DON_ANTI_HCV DON_HIST_DIAB CAN_MALIG DON_ANTI_HCV_MISS DON_HIST_DIAB_MISS
#> 1            P             1         Y              <NA>               <NA>
#> 2            N             5         N              <NA>               <NA>
#> 3         <NA>            NA      <NA>           unknown            unknown
#> 4         <NA>            NA      <NA>          not_done            unknown
#> 5            I             2      <NA>              <NA>               <NA>
#> 6         <NA>            NA         N           pending               <NA>
#>   CAN_MALIG_MISS
#> 1           <NA>
#> 2           <NA>
#> 3        unknown
#> 4    sas_missing
#> 5       not_done
#> 6           <NA>
```

Which kinds of missing value to drop depends on the analysis. Three
policies cover common choices:

| Kind | `"analysis"` | `"strict"` | `"tag_only"` |
|----|----|----|----|
| unknown, pending, cannot disclose, blank | `NA` | `NA` | kept |
| not done, not tested | `NA` | `NA` | kept |
| not applicable | kept | `NA` | kept |
| indeterminate | kept | `NA` | kept |
| partly known | kept | `NA` | kept |

`"strict"` leaves only substantive values. `"tag_only"` changes no value
and adds a reason column for each variable that holds a recognised code.

### Adjusting a policy

A test that was not done can be informative in itself. To keep “not
done” as a value everywhere:

``` r

srtr_normalize_missing(
  tx_ki,
  actions = c(not_done = "keep"),
  file_key = "TX_KI"
)
#>   DON_ANTI_HCV DON_HIST_DIAB CAN_MALIG
#> 1            P             1         Y
#> 2            N             5         N
#> 3         <NA>            NA      <NA>
#> 4           ND            NA      <NA>
#> 5            I             2        ND
#> 6         <NA>            NA         N
```

To change the rule for one variable only:

``` r

srtr_normalize_missing(
  tx_ki,
  overrides = list(DON_ANTI_HCV = c(indeterminate = "na")),
  file_key = "TX_KI"
)
#>   DON_ANTI_HCV DON_HIST_DIAB CAN_MALIG
#> 1            P             1         Y
#> 2            N             5         N
#> 3         <NA>            NA      <NA>
#> 4         <NA>            NA      <NA>
#> 5         <NA>             2      <NA>
#> 6         <NA>            NA         N
```

### Other choices

- `output = "append"` leaves the original columns as they are and adds
  the normalized values in `_NORM` columns.
- `na_level = "Missing"` makes missing its own group in factor and
  character columns, which is useful for descriptive tables.
- `extra_codes` adds your own codes, for example
  `extra_codes = list(MY_VAR = c("9" = "unknown"))`.

``` r

srtr_normalize_missing(
  tx_ki,
  cols = "CAN_MALIG",
  na_level = "Missing",
  file_key = "TX_KI"
)
#>   DON_ANTI_HCV DON_HIST_DIAB CAN_MALIG
#> 1            P             1         Y
#> 2            N             5         N
#> 3            U           998   Missing
#> 4           ND           998   Missing
#> 5            I             2   Missing
#> 6           PD            NA         N
```

## What this does not cover

A blank can mean that a field was not collected in that era, and a
continuous variable can hold an implausible value or a placeholder such
as 999. Neither is a coded missing value, and
[`srtr_normalize_missing()`](https://vagishhemmige.github.io/sRtr/reference/srtr_normalize_missing.md)
does not look for them.

## Next steps

- [Building cohorts with flow
  diagrams](https://vagishhemmige.github.io/sRtr/articles/building-cohort-with-flowchart.md):
  apply these choices when you select the cohort, with unknown values as
  their own step.
