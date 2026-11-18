# add_pdri() names the missing columns

    Code
      add_pdri(df, variant = "KP")
    Condition
      Error in `add_pdri()`:
      ! `df` is missing 1 required column: DON_CREAT.

# add_pdri(verbose = TRUE) reports the variant and BMI

    Code
      out <- add_pdri(df, verbose = TRUE)
    Message
      Using PDRI variant "KP".
      i Could not tell KP from PA, so used the default.
      DON_BMI not found; computing it from DON_WGT_KG and DON_HGT_CM.

# an infinite PDRI is reported

    Code
      out <- add_pdri(df, variant = "KP")
    Condition
      Warning:
      1 row gave Inf in PDRI (the linear predictor overflowed).
      i Check inputs in that row for unit or coding errors or extreme values.
      i First rows: 1; linear predictors: 2178.23.

# continuous inputs must be numeric

    Code
      add_pdri(df, variant = "KP")
    Condition
      Error in `add_pdri()`:
      ! `df` has 1 continuous input that is not numeric: DON_BMI.
      i Convert it to numbers first; a factor's level positions are not its values.

