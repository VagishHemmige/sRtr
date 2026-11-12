# a missing follow-up date column is a clear error

    Code
      add_time_to_event_outcomes(kp)
    Condition
      Error:
      ! `df` is missing the follow-up date column(s) `TFL_LAFUDATEPA` needed to censor outcomes.

---

    Code
      add_time_to_event_outcomes(ki)
    Condition
      Error:
      ! `df` is missing the follow-up date column(s) `TFL_LAFUDATE` needed to censor outcomes.

# TX_KP warns when follow-up rows are coded neither KI nor PA

    Code
      out <- add_txf_outcomes(fake_tx("TX_KP"))
    Condition
      Warning:
      TXF_KP follow-up rows with ORG_TY 'KP' are not KI or PA; their rejections are not assigned to an organ.

