# an entry that no longer has the expected value is left alone, with a warning

    Code
      out <- .srtr_apply_corrections(tables, "corrected", corrections)
    Condition
      Warning:
      1 dictionary correction not applied; using SRTR's values.
      * SRTR-DC-001 (TX_HL REC_COD, TX_HR REC_COD, TX_IN REC_COD, TX_KI REC_COD, TX_KP REC_COD, TX_LI REC_COD, TX_LU REC_COD, TX_PA REC_COD): SRTR's dictionary has THCOD, not SOMETHING_ELSE as expected.

