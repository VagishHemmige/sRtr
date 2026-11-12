# death_window = 'ascertainment' needs one valid ascertainment_date

    Code
      add_time_to_event_outcomes(death_cohort(), death_window = "ascertainment")
    Condition
      Error:
      ! `death_window = "ascertainment"` needs `ascertainment_date`: one date up to which deaths are ascertained in the SAF release.

---

    Code
      add_time_to_event_outcomes(death_cohort(), death_window = "ascertainment",
      ascertainment_date = as.Date(c("2005-01-01", "2006-01-01")))
    Condition
      Error:
      ! `death_window = "ascertainment"` needs `ascertainment_date`: one date up to which deaths are ascertained in the SAF release.

