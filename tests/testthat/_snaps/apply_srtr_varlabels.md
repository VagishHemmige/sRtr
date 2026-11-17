# verbose = TRUE says how many labels were kept

    Code
      out <- apply_srtr_varlabels(df, file_key = "TX_KI", verbose = TRUE)
    Message
      i Kept the existing label on 1 variable.
        Use `overwrite = TRUE` to replace it with dictionary labels.
      v Labeled variable: `CAN_GENDER` (Patient/s Gender).

# an unknown file_key warns and returns the data unchanged

    Code
      out <- apply_srtr_varlabels(df, file_key = "NOT_A_FILE")
    Condition
      Warning:
      "NOT_A_FILE" is not a dataset in the bundled SRTR data dictionary, so nothing was labeled.
      i Supply `file_key`, for example `file_key = "TX_KI"`.

# a file_key that cannot be worked out warns

    Code
      out <- apply_srtr_varlabels(tibble::tibble(CAN_ABO = "A"))
    Condition
      Warning:
      Could not work out `file_key`, so nothing was labeled.
      i The data frame has no `file_key` attribute and was not passed by name.
      i Supply `file_key`, for example `file_key = "TX_KI"`.

# file_key must be a single string

    Code
      apply_srtr_varlabels(df, file_key = 1)
    Condition
      Error in `apply_srtr_varlabels()`:
      ! `file_key` must be a single string.

