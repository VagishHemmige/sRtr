# A tiny synthetic IMMUNO file: every column the bundled dictionary lists for
# IMMUNO, two made-up rows. Only the column names come from the dictionary.
fake_immuno <- function() {
  tibble::tibble(
    REC_DRUG_ANTI_REJ = c(1, 2),
    REC_DRUG_CD = c(1, 2),
    REC_DRUG_DAYS = c(1, 2),
    REC_DRUG_INDUCTION = c(1, 2),
    REC_DRUG_MAINT = c(1, 2),
    TRR_ID = c(900001, 900002)
  )
}

# A tiny synthetic TX_LI file with blank text: one column with a format
# (DON_ANTI_HCV, format SRLSTT) and one without (REC_FAIL_INFECT). SAS stores
# missing text as blanks. Made-up rows; only the column names and the codes
# come from the dictionary.
fake_tx_blank_text <- function() {
  tibble::tibble(
    TRR_ID = c(900001, 900002, 900003),
    REC_AGE_AT_TX = c(1, 2, NA),
    DON_ANTI_HCV = c("P", "", "  "),
    REC_FAIL_INFECT = c("Y", "", " ")
  )
}

# A temporary SRTR_WD holding empty files named `files`, with sRtr's session
# state cleared and restored afterwards.
local_srtr_folder <- function(files, env = parent.frame()) {
  dir <- withr::local_tempdir(.local_envir = env)
  file.create(file.path(dir, files))
  withr::local_envvar(SRTR_WD = dir, .local_envir = env)
  saved <- as.list(.srtr_env, all.names = TRUE)
  rm(list = ls(.srtr_env, all.names = TRUE), envir = .srtr_env)
  withr::defer(
    {
      rm(list = ls(.srtr_env, all.names = TRUE), envir = .srtr_env)
      list2env(saved, envir = .srtr_env)
    },
    envir = env
  )
  dir
}

# A temporary SRTR_WD holding `data` as a .sas7bdat file for `file_key`.
local_sas_file <- function(data, file_key, env = parent.frame()) {
  dir <- local_srtr_folder(character(), env = env)
  withr::local_options(lifecycle_verbosity = "quiet")
  haven::write_sas(data, file.path(dir, paste0(file_key, ".sas7bdat")))
  dir
}

# A tiny synthetic TX_LI file for the REC_COD dictionary correction. Made-up
# rows; the codes come from the COD and THCOD formats: 4600 is in COD only,
# 2000 in both, 998 (Unknown) in COD only.
fake_tx_cause_of_death <- function() {
  tibble::tibble(
    TRR_ID = c(900001, 900002, 900003),
    REC_COD = c(4600, 2000, 998)
  )
}
