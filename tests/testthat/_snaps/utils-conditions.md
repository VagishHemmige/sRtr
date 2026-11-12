# check_columns() lists the missing columns

    Code
      f(df)
    Condition
      Error in `f()`:
      ! `data` is missing 2 required columns: FAKE_B and FAKE_C.

# check_columns() can say why the columns are needed

    Code
      check_columns(df, "FAKE_B", why = "They are needed to censor outcomes.")
    Condition
      Error:
      ! `df` is missing 1 required column: FAKE_B.
      i They are needed to censor outcomes.

