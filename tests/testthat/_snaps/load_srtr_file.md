# an unset SRTR_WD gives an error that says what to do

    Code
      load_fake("TX_KI")
    Condition
      Error:
      ! SRTR_WD is not set. Call `set_srtr_wd("path/to/your/SAFs")` first.

# an unknown file key names the folder searched

    Code
      load_fake("TX_LI")
    Condition
      Error:
      ! File key 'TX_LI' not found in SRTR_WD (<SRTR_WD>).

