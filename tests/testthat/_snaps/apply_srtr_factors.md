# verbose = TRUE reports each labeled variable

    Code
      out <- apply_srtr_factors(fake_tx_ki(), file_key = "TX_KI", verbose = TRUE)
    Message
      v Labeled variable: `CAN_ABO` (format "ABO").

# verbose = TRUE says where an inferred file_key came from

    Code
      out <- apply_srtr_factors(df, verbose = TRUE)
    Message
      Using `file_key` "TX_KI" from the data frame's attribute.
      v Labeled variable: `CAN_ABO` (format "ABO").

# an unknown file_key warns and returns the data unchanged

    Code
      out <- apply_srtr_factors(df, file_key = "NOT_A_FILE")
    Condition
      Warning:
      "NOT_A_FILE" is not a dataset in the bundled SRTR data dictionary, so nothing was labeled.
      i Supply `file_key`, for example `file_key = "TX_KI"`.

# a file_key that cannot be worked out warns

    Code
      out <- apply_srtr_factors(fake_tx_ki())
    Condition
      Warning:
      Could not work out `file_key`, so nothing was labeled.
      i The data frame has no `file_key` attribute and was not passed by name.
      i Supply `file_key`, for example `file_key = "TX_KI"`.

