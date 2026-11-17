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
