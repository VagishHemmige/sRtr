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
