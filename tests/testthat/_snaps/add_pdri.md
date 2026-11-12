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

