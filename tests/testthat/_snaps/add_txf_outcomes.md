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

