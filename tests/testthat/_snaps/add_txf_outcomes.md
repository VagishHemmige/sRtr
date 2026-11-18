# a missing follow-up date column is a clear error

    Code
      add_time_to_event_outcomes(kp)
    Condition
      Error in `add_time_to_event_outcomes()`:
      ! `df` is missing 1 required column: TFL_LAFUDATEPA.
      i Follow-up dates are needed to censor outcomes.

---

    Code
      add_time_to_event_outcomes(ki)
    Condition
      Error in `add_time_to_event_outcomes()`:
      ! `df` is missing 1 required column: TFL_LAFUDATE.
      i Follow-up dates are needed to censor outcomes.

# TX_KP warns when follow-up rows are coded neither KI nor PA

    Code
      out <- add_txf_outcomes(fake_tx("TX_KP"))
    Condition
      Warning:
      'TXF_KP' follow-up rows with ORG_TY "KP" are not "KI" or "PA".
      i Their rejections are not assigned to an organ.

# an undated admission rejection is reported

    Code
      out <- add_time_to_event_outcomes(admission_rejection_cohort())
    Condition
      Warning:
      1 recipient had a treated rejection during the transplant admission with no usable length of stay or discharge date.
      i It counts as a rejection with an unknown time: FIRST_REJ_DATE_BINARY is 1 and the time is `NA`.

# an event reported only on undated forms is reported

    Code
      out <- add_time_to_event_outcomes(df)
    Condition
      Warning:
      1 recipient had a rejection reported only on follow-up forms with no date.
      i It counts as a rejection with an unknown time: FIRST_REJ_DATE_BINARY is 1 and the time is `NA`.
      Warning:
      1 recipient had a malignancy reported only on follow-up forms with no date.
      i It counts as a malignancy with an unknown time: FIRST_FU_MALIG_DATE_BINARY is 1 and the time is `NA`.

