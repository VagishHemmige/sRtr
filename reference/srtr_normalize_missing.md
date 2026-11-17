# Normalize missing-value codes in SRTR data

SRTR variables record missing information in many ways: "Unknown", "Not
done", "N/A", "Pending", blanks, and codes whose number differs from
variable to variable. `srtr_normalize_missing()` recognises these codes
from
[missing_codes](https://vagishhemmige.github.io/sRtr/reference/missing_codes.md),
by what they mean in each variable's own format, and turns the ones you
choose into `NA`.

## Usage

``` r
srtr_normalize_missing(
  df,
  cols = NULL,
  policy = c("analysis", "strict", "tag_only"),
  actions = NULL,
  overrides = NULL,
  output = c("replace", "append"),
  reason = NULL,
  na_level = NULL,
  file_key = NULL,
  release = NULL,
  extra_codes = NULL,
  verbose = FALSE
)
```

## Arguments

- df:

  A data frame from an SRTR SAF file. Raw codes and labelled columns
  (from
  [`apply_srtr_factors()`](https://vagishhemmige.github.io/sRtr/reference/apply_srtr_factors.md))
  are handled alike.

- cols:

  Names of the columns to normalize. `NULL` (the default) takes every
  column that
  [missing_codes](https://vagishhemmige.github.io/sRtr/reference/missing_codes.md)
  covers.

- policy:

  The set of rules to start from: `"analysis"` (the default), `"strict"`
  or `"tag_only"`. See Policies.

- actions:

  Changes to the policy by kind of missing value: a named character
  vector such as `c(not_done = "keep", indeterminate = "na")`. Names are
  types from
  [missing_codes](https://vagishhemmige.github.io/sRtr/reference/missing_codes.md);
  values are `"na"` or `"keep"`.

- overrides:

  Changes for single variables: a named list with one element per
  column, each a vector like `actions`, such as
  `list(REC_HIV_STAT = c(not_done = "keep"))`. These win over `actions`.

- output:

  `"replace"` (the default) changes the columns in place. `"append"`
  leaves them as they are and adds the normalized values in new columns
  named with `_NORM` added.

- reason:

  Which reason columns to add: `"none"` adds no columns; `"changed"`
  records the kind of each changed value; `"all"` records the kind of
  every recognised code, changed or not. `NULL` (the default) means
  `"none"`, except under `policy = "tag_only"`, where it means `"all"`.
  See Reason columns.

- na_level:

  A string, such as `"Missing"`, to use in place of `NA` in the
  normalized factor and character columns, so that missing values form
  their own group in a table. It covers values that were `NA` already.
  For a factor it becomes the last level. Numeric columns keep `NA`.
  `NULL` (the default) leaves `NA`.

- file_key:

  The dataset `df` comes from, such as `"TX_KI"`. `NULL` uses the
  `file_key` attribute that
  [`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md)
  sets. If there is none, variables are looked up by name alone, and a
  variable whose format differs between datasets is skipped, with a
  message.

- release:

  The SAF release, as in
  [`load_srtr_file()`](https://vagishhemmige.github.io/sRtr/reference/load_srtr_file.md).
  `NULL` uses the release recorded on `df`, or else the bundled
  dictionary.

- extra_codes:

  Your own codes, for values that
  [missing_codes](https://vagishhemmige.github.io/sRtr/reference/missing_codes.md)
  does not cover: a named list with one element per column, each a named
  character vector giving the type of each value, such as
  `list(MY_VAR = c("9" = "unknown"))`. These win over
  [missing_codes](https://vagishhemmige.github.io/sRtr/reference/missing_codes.md),
  and apply alike to raw codes and to labelled columns. If two codes of
  a format share one label, both must be given the same type.

- verbose:

  If `TRUE`, report how many values were changed in how many variables.

## Value

`df` with the chosen codes replaced, and any reason columns added at the
end. For factors, the levels that became `NA` are removed; the other
levels keep their order, so the reference level does not depend on the
order of the rows. Ordered factors stay ordered, and attributes such as
variable labels are kept.

## Details

Which kinds become `NA` is a judgement that depends on the analysis, so
it is a choice. `policy` picks a sensible set in one word; `actions` and
`overrides` adjust it by kind of missing value and by variable. Run
[`srtr_missing_report()`](https://vagishhemmige.github.io/sRtr/reference/srtr_missing_report.md)
first to see what the data hold.

## Policies

|  |  |  |  |
|----|----|----|----|
| Kind (type) | `"analysis"` | `"strict"` | `"tag_only"` |
| `unknown`, `pending`, `cannot_disclose` | `NA` | `NA` | kept |
| `sas_missing` (blank) | `NA` | `NA` | kept |
| `not_done` (not done, not tested) | `NA` | `NA` | kept |
| `not_applicable` | kept | `NA` | kept |
| `indeterminate` | kept | `NA` | kept |
| `partial` (such as "Yes, duration unknown") | kept | `NA` | kept |

- `"analysis"` removes what carries no information about the patient and
  keeps what does: "not applicable" and "indeterminate" are findings,
  and a partly known answer still says yes.

- `"strict"` leaves only substantive values.

- `"tag_only"` changes no value and adds a reason column for each
  variable that holds a recognised code.

Whether "not done" is information depends on the question: a test that
was not ordered can itself be informative. Use
`actions = c(not_done = "keep")` to keep it.

Values that are already `NA` stay `NA`. Values that a format does not
list are left alone.

## Reason columns

Once "unknown" and "not done" have both become `NA`, they can no longer
be told apart. `reason = "changed"` keeps that information: a column
named after the variable with `_MISS` added records the kind of each
value that was changed. It is `NA` for values that were not changed,
including values that were `NA` already, and a variable gets the column
only if one of its values changed. No reason columns are added by
default, because a wide file can gain hundreds of them.

## See also

[`srtr_missing_report()`](https://vagishhemmige.github.io/sRtr/reference/srtr_missing_report.md),
[missing_codes](https://vagishhemmige.github.io/sRtr/reference/missing_codes.md)

## Examples

``` r
# Made-up rows using TX_KI column names
df <- data.frame(
  DON_ANTI_CMV = c("P", "N", "U", "ND", "I"),
  DON_HIST_DIAB = c(1, 5, 998, 998, 2)
)

srtr_normalize_missing(df, file_key = "TX_KI")
#>   DON_ANTI_CMV DON_HIST_DIAB
#> 1            P             1
#> 2            N             5
#> 3         <NA>            NA
#> 4         <NA>            NA
#> 5            I             2

# Keep "not done" as a value
srtr_normalize_missing(
  df,
  actions = c(not_done = "keep"),
  file_key = "TX_KI"
)
#>   DON_ANTI_CMV DON_HIST_DIAB
#> 1            P             1
#> 2            N             5
#> 3         <NA>            NA
#> 4           ND            NA
#> 5            I             2

# Only substantive values, recording why each value became NA
srtr_normalize_missing(
  df,
  policy = "strict",
  reason = "changed",
  file_key = "TX_KI"
)
#>   DON_ANTI_CMV DON_HIST_DIAB DON_ANTI_CMV_MISS DON_HIST_DIAB_MISS
#> 1            P             1              <NA>               <NA>
#> 2            N            NA              <NA>            partial
#> 3         <NA>            NA           unknown            unknown
#> 4         <NA>            NA          not_done            unknown
#> 5         <NA>             2     indeterminate               <NA>
```
