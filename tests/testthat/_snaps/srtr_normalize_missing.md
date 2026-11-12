# verbose = TRUE reports processed and skipped columns

    Code
      out <- srtr_normalize_missing(df, missing_vals = list(FAKE_A = -99,
        FAKE_NOT_THERE = -99), verbose = TRUE)
    Message
      Processing FAKE_A.
      Skipping FAKE_NOT_THERE: not in the data.

