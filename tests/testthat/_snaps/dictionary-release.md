# an entry that changed across a gap is reported

    Code
      out <- .srtr_dictionary_for("9902", versions, columns = "REC_FAKE_CHANGED")
    Condition
      Warning:
      1 dictionary entry changed between the stored snapshots around release "9902", so its value at that release is not known: "TX_KI REC_FAKE_CHANGED".
      i Using the earlier snapshot's value. Set `gaps = "nearest"` to do so without this warning, or `gaps = "error"` to stop.

# a release outside the stored snapshots uses the nearest one, with a warning

    Code
      out <- .srtr_dictionary_for("9912", versions)
    Condition
      Warning:
      No stored SRTR dictionary is close to release "9912"; using snapshot "9904-1".
      i Stored snapshots: "9901-1" and "9904-1".

# a release must be four digits naming a year and month

    Code
      .srtr_dictionary_for("26")
    Condition
      Error:
      ! `release` must be one SAF release written as year and month, like "2609".
      x Got "26".

