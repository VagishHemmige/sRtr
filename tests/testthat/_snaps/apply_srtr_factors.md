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

