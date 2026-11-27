# attaching in an unprotected repository reports what is missing

    Code
      .srtr_attach_check(dir)
    Message
      sRtr data safety check of the git repository at '<project>':
      ! 1 file looks like SRTR data and git would commit it:
        'tx.sas7bdat'
      i Git does not ignore 8 SAF formats ("sas7bdat", "sas7bcat", "xpt", "parquet", "feather", "arrow", "dta", and "sav"). Add the patterns with `sRtr::use_srtr_gitignore("<project>")`.
      i No commit check is installed. Add one with `sRtr::use_srtr_commit_check("<project>")`.
      i Turn this check off with `options(sRtr.safety_check = FALSE)`.

# set_srtr_wd() warns about a SAF folder git would commit

    Code
      set_srtr_wd(saf)
    Condition
      Warning:
      Your SAF folder is inside a git repository, and git does not ignore it.
      i SAF folder:
        '<project>/safs'
      i Repository:
        '<project>'
      i Move the SAFs out of the repository, or add the folder to the repository's '.gitignore'.
      i Turn this check off with `options(sRtr.safety_check = FALSE)`.

