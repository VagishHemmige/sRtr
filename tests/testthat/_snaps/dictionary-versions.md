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

