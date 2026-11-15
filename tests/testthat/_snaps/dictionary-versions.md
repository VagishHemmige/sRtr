# the parser errors when the title has no release

    Code
      .srtr_parse_dictionary_page(path)
    Condition
      Error:
      ! This page's title does not give an SRTR dictionary release:
        '<page>'
      i Expected a title like "SRTR 2609 Public SAFs Data Dictionary"; found "Some other page".

# the parser errors when the page has no dataset sections

    Code
      .srtr_parse_dictionary_page(path)
    Condition
      Error:
      ! This page has no dataset or no format sections:
        '<page>'
      i Found 0 dataset sections and 1 format section.

# a page with a missing or empty table is not stored

    Code
      .srtr_versions_add_page(dir, broken, source = "fake")
    Condition
      Error:
      ! This dictionary page was not read completely, so it was not stored:
        '<page>'
      x "dictionary TX_LI (missing_table)"
      i Check whether the page layout changed before adding it.

# the comparison can be written as a short report

    Code
      writeLines(.srtr_versions_report(versions, "9901-1", "9904-1", problems = NULL))
    Output
      Compared with the stored snapshot `9901-1`, the dictionary page `9904-1` (SRTR 9904 Public SAFs Data Dictionary) has:
      
      - Variables: 1 added, 1 removed, 0 changed.
      - Format codes: 0 added, 0 removed, 0 changed.
      
      ### Variables added
      
      - `TX_KI` `REC_FAKE_NEW`
      
      ### Variables removed
      
      - `TX_KI` `REC_FAKE_GONE`

