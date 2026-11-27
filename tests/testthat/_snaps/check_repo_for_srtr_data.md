# the warning names paths only, and a clean folder gives a message

    Code
      check_repo_for_srtr_data(dir)
    Condition
      Warning:
      2 files look like SRTR data and could be committed from '<project>' (folder scan; not a git repository):
      * 'tx.sas7bdat' (data format)
      * '{odd} name.csv' (identifier column)
      i Move SAFs and files made from them out of the project, or add them to '.gitignore'.

# bad arguments are errors

    Code
      check_repo_for_srtr_data(tempdir(), files = 1)
    Condition
      Error in `check_repo_for_srtr_data()`:
      ! `files` must be a character vector of paths, not a number.

