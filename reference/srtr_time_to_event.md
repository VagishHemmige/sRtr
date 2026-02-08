# Helper function to add a time-to-event outcome from a date function

Creates three columns for an outcome defined by an event date and a
censor date:

- prefix_CENSOR: event date if present, otherwise censor date

- prefix_BINARY: 1 if event date present, else 0

- prefix_unit: numeric time from start_date to prefix_CENSOR in chosen
  units

## Usage

``` r
srtr_time_to_event(
  df,
  event_date,
  start_date,
  censor_date,
  prefix,
  units = c("years", "months", "days"),
  add_epsilon = 1,
  warn_negative = TRUE
)
```

## Arguments

- df:

  A data frame.

- event_date:

  Event date column (unquoted).

- start_date:

  Start date column (unquoted), e.g., `REC_TX_DT`.

- censor_date:

  Censor/last-follow-up date column (unquoted), e.g., `TFL_LAFUDATEPA`.

- prefix:

  String used for new columns (e.g., "REC_DEATH").

- units:

  One of "years", "months", or "days". Default "years".

- add_epsilon:

  Numeric days to add to time (to avoid zero-time issues). Default 1.
  Set to 0 to disable. Logical TRUE/FALSE also accepted (treated as 1/0)
  for backward compatibility.

- warn_negative:

  Warn and set to NA if computed time is negative. Default TRUE.

## Value

`df` with added columns: `{prefix}_CENSOR`, `{prefix}_BINARY`,
`{prefix}_{units-suffix}`.

## Details

Units suffix mapping: `years -> "_yrs"`, `months -> "_months"`,
`days -> "_days"`. Negative times (e.g., when
`start_date > censor/event`) trigger a warning, and the numeric time is
set to `NA`.#'
