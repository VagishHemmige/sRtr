# srtr_composite_death() errors when a death date column is missing

    Code
      srtr_composite_death(df)
    Condition
      Error in `srtr_composite_death()`:
      ! `df` is missing 1 required column: PERS_SSA_DEATH_DT.

# srtr_composite_death() errors on death dates that are not Date

    Code
      srtr_composite_death(df)
    Condition
      Error in `srtr_composite_death()`:
      ! `df` has 2 date columns not stored as <Date>: PERS_OPTN_DEATH_DT and TFL_DEATH_DT.
      i SAS files read with `load_srtr_file()` give <Date> for dates; convert other sources before calling this function.

# conflict_days must be one non-negative number

    Code
      srtr_composite_death(spread_deaths(), conflict_days = -1)
    Condition
      Error in `srtr_composite_death()`:
      ! `conflict_days` must be one non-negative number of days.

---

    Code
      srtr_composite_death(spread_deaths(), conflict_days = c(1, 2))
    Condition
      Error in `srtr_composite_death()`:
      ! `conflict_days` must be one non-negative number of days.

---

    Code
      srtr_composite_death(spread_deaths(), conflict_days = "7")
    Condition
      Error in `srtr_composite_death()`:
      ! `conflict_days` must be one non-negative number of days.

