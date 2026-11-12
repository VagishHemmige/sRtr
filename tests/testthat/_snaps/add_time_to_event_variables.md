# death_window = 'ascertainment' needs one valid ascertainment_date

    Code
      add_time_to_event_outcomes(death_cohort(), death_window = "ascertainment")
    Condition
      Error in `add_time_to_event_outcomes()`:
      ! `death_window = "ascertainment"` needs `ascertainment_date`.
      i Give one date up to which deaths are ascertained in the SAF release.

---

    Code
      add_time_to_event_outcomes(death_cohort(), death_window = "ascertainment",
      ascertainment_date = as.Date(c("2005-01-01", "2006-01-01")))
    Condition
      Error in `add_time_to_event_outcomes()`:
      ! `death_window = "ascertainment"` needs `ascertainment_date`.
      i Give one date up to which deaths are ascertained in the SAF release.

# srtr_time_to_event() warns about negative times and sets them to NA

    Code
      out <- srtr_time_to_event(df, event, start, censor, prefix = "FAKE", units = "days",
        add_epsilon = 0)
    Condition
      Warning:
      1 row had a negative FAKE time; set to NA.

