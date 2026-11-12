# an unset SRTR_WD gives an error that says what to do

    Code
      load_fake("TX_KI")
    Condition
      Error in `load_srtr_file()`:
      ! `SRTR_WD` is not set.
      i Call `set_srtr_wd("path/to/your/SAFs")` first.

# an SRTR_WD folder that does not exist gives an error

    Code
      load_fake("TX_KI")
    Condition
      Error in `load_srtr_file()`:
      ! The `SRTR_WD` folder does not exist:
        'no-such-folder'

# an unknown file key names the folder searched

    Code
      load_fake("TX_LI")
    Condition
      Error in `load_srtr_file()`:
      ! No file for `file_key` "TX_LI".
      i Looked for a '.sas7bdat' or '.parquet' file in `SRTR_WD`:
        '<SRTR_WD>'

