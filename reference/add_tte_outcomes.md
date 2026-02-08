# Add appropriate TTE outcome variables to a data frame based on the df attributes, if the file was loaded using a load function.

Uses the helper functions to create three columns for an outcome defined
by an event date and a censor date:

- prefix_CENSOR: event date if present, otherwise censor date

- prefix_BINARY: 1 if event date present, else 0

- prefix_unit: numeric time from start_date to prefix_CENSOR in chosen
  units

## Usage

``` r
add_tte_outcomes(df)
```
