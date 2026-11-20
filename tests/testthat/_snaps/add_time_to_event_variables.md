# a recipient with no TFL_ENDTXFU has no death event or time, with a warning

    Code
      out <- add_time_to_event_outcomes(df)
    Condition
      Warning:
      2 recipients have no TFL_ENDTXFU.
      i Their death events are not counted and their times are missing.

# ascertainment_date names a column that must exist and hold dates

    Code
      add_time_to_event_outcomes(df)
    Condition
      Error in `add_time_to_event_outcomes()`:
      ! `df` is missing 1 required column: TFL_ENDTXFU.
      i It gives where death ascertainment ends; use `death_window = "follow_up"` or give one date instead.

---

    Code
      add_time_to_event_outcomes(df)
    Condition
      Error in `add_time_to_event_outcomes()`:
      ! `df` has 1 date column not stored as <Date>: TFL_ENDTXFU.
      i SAS files read with `load_srtr_file()` give <Date> for dates; convert other sources before calling this function.

# death_window = 'ascertainment' needs one valid ascertainment_date

    Code
      add_time_to_event_outcomes(death_cohort(), ascertainment_date = NULL)
    Condition
      Error in `add_time_to_event_outcomes()`:
      ! `death_window = "ascertainment"` needs `ascertainment_date`.
      i Give a date column such as "TFL_ENDTXFU", or one date up to which deaths are ascertained in the SAF release.

---

    Code
      add_time_to_event_outcomes(death_cohort(), death_window = "ascertainment",
      ascertainment_date = as.Date(c("2005-01-01", "2006-01-01")))
    Condition
      Error in `add_time_to_event_outcomes()`:
      ! `death_window = "ascertainment"` needs `ascertainment_date`.
      i Give a date column such as "TFL_ENDTXFU", or one date up to which deaths are ascertained in the SAF release.

# retransplant = 'ignore' leaves retransplant out

    Code
      add_time_to_event_outcomes(df)
    Condition
      Error in `add_time_to_event_outcomes()`:
      ! `df` is missing 1 required column: PERS_RETX.
      i All-cause graft failure counts graft failure and retransplant; use `retransplant = "ignore"` to leave retransplant out.

# srtr_time_to_event() warns about negative times and sets them to NA

    Code
      out <- srtr_time_to_event(df, event, start, censor, prefix = "FAKE", units = "days",
        add_epsilon = 0)
    Condition
      Warning:
      1 row had a negative FAKE time; set to NA.

# srtr_time_to_event() stops on infinite dates

    Code
      srtr_time_to_event(df, event, start, censor, prefix = "X")
    Condition
      Error in `srtr_time_to_event()`:
      ! `event_date` has infinite dates in 1 row.
      i An infinite date comes from an error upstream, such as `min()` of no dates. Set it to `NA` or fix the source.

