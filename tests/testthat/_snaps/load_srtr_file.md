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

# trr_id_filter on a file with no TRR_ID column is an error

    Code
      load_cols("TX_KI", col_select = "REC_BMI", trr_id_filter = 900002)
    Condition
      Error in `load_srtr_file()`:
      ! `trr_id_filter` needs a TRR_ID column, and the "TX_KI" file has none.
      i Leave `trr_id_filter` as `NULL` for this file.

# TFL_LAFUDATE can't be derived without both follow-up dates

    Code
      load_cols("TX_KP", col_select = "TFL_LAFUDATE")
    Condition
      Error in `load_srtr_file()`:
      ! Can't derive TFL_LAFUDATE: the "TX_KP" file has no TFL_LAFUDATEPA column.
      i TFL_LAFUDATE is the later of TFL_LAFUDATEKI and TFL_LAFUDATEPA.

# TX_KP without col_select and a follow-up date missing is an error

    Code
      load_cols("TX_KP")
    Condition
      Error in `load_srtr_file()`:
      ! Can't derive TFL_LAFUDATE: the "TX_KP" file has no TFL_LAFUDATEPA column.
      i TFL_LAFUDATE is the later of TFL_LAFUDATEKI and TFL_LAFUDATEPA.

