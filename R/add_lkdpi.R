#' Add the Living Kidney Donor Profile Index
#'
#' Computes the Living Kidney Donor Profile Index (LKDPI) for living donor
#' kidney transplants and appends it (default column `LKDPI`). The LKDPI is on
#' the same scale as the deceased donor KDPI, but it is not limited to 0-100:
#' a negative value means less risk than any deceased donor kidney in the
#' reference population.
#'
#' The inputs come from both the living donor file (`DONOR_LIVE`) and the
#' kidney transplant file (`TX_KI`), so join them first:
#'
#' | Factor | Columns |
#' |---|---|
#' | Donor age | `DON_AGE` |
#' | Donor eGFR | computed with [add_donor_egfr()] from `creatinine`, `DON_AGE`, `DON_GENDER` and race |
#' | Donor BMI | `DON_WGT_KG`, `DON_HGT_CM` |
#' | Donor African American | `DON_RACE_BLACK_AFRICAN_AMERICAN` (Y/N), or `DON_RACE` = 16 (1024 = unknown) |
#' | Donor cigarette use | `DON_HIST_CIGARETTE` (Y/N) |
#' | Donor systolic blood pressure | `DON_BP_PREOP_SYST` |
#' | Male donor to male recipient | `DON_GENDER`, `CAN_GENDER` |
#' | ABO incompatible | `DON_ABO`, `CAN_ABO` |
#' | Unrelated donor | `DON_RELATIONSHIP_TY` |
#' | HLA-B and HLA-DR mismatches | `REC_B_MM_EQUIV_TX`, `REC_DR_MM_EQUIV_TX` |
#' | Donor/recipient weight ratio | `DON_WGT_KG`, `REC_WGT_KG` |
#'
#' The paper states its factors but not how each was read from SRTR fields.
#' The mapping above, and these rules, are this package's reading:
#' * ABO incompatible means the donor carries an A or B antigen the recipient
#'   lacks (A, A1 and A2 carry A; AB, A1B and A2B carry both).
#' * Unrelated means a non-biological relationship: codes 7 to 12, 15 and
#'   999 of format `LVDNRL`.
#'
#' @param df A data frame of living donor kidney transplants, one row each.
#' @param creatinine Name of the donor creatinine column used for eGFR.
#'   Defaults to `"DON_KI_CREAT_PREOP"` (pre-donation creatinine), a
#'   convention.
#' @param egfr_equation eGFR equation passed to [add_donor_egfr()].
#'   `"ckd_epi_2009"` (default) is the CKD-EPI equation the paper used.
#'   `"ckd_epi_2021"` is the newer equation without race; the coefficients
#'   were not fit with it.
#' @param a2_donor Whether an A2 or A2B donor counts as ABO incompatible with a
#'   recipient lacking the A antigen. `"incompatible"` (default) follows the
#'   antigens; `"compatible"` treats A2 as lacking A, as in A2-to-B
#'   allocation. Both are conventions; the paper does not say.
#' @param lkdpi_col Name of the output column.
#' @param return_terms If `TRUE`, also add a list-column `LKDPI_terms` with
#'   each row's components.
#'
#' @return `df` with a new column.
#'
#' @references
#' Massie AB, Leanza J, Fahmy LM, et al. A risk index for living donor kidney
#' transplantation. *Am J Transplant* 2016;16:2077-2084.
#' \doi{10.1111/ajt.13709} (Results, "Calculation of the LKDPI".)
#'
#' @examples
#' pairs <- data.frame(
#'   DON_AGE = 60, DON_GENDER = "M", CAN_GENDER = "M",
#'   DON_HGT_CM = 180, DON_WGT_KG = 90, REC_WGT_KG = 80,
#'   DON_KI_CREAT_PREOP = 1.0, DON_RACE = 8, DON_HIST_CIGARETTE = "N",
#'   DON_BP_PREOP_SYST = 125, DON_ABO = "O", CAN_ABO = "A",
#'   DON_RELATIONSHIP_TY = 4, REC_B_MM_EQUIV_TX = 1, REC_DR_MM_EQUIV_TX = 1
#' )
#' add_lkdpi(pairs)
#' @export
add_lkdpi <- function(
  df,
  creatinine = "DON_KI_CREAT_PREOP",
  egfr_equation = c("ckd_epi_2009", "ckd_epi_2021"),
  a2_donor = c("incompatible", "compatible"),
  lkdpi_col = "LKDPI",
  return_terms = FALSE
) {
  egfr_equation <- rlang::arg_match(egfr_equation)
  a2_donor <- rlang::arg_match(a2_donor)
  check_columns(df, c(
    "DON_AGE", "DON_GENDER", "CAN_GENDER", "DON_HGT_CM", "DON_WGT_KG",
    "REC_WGT_KG", creatinine, "DON_HIST_CIGARETTE", "DON_BP_PREOP_SYST",
    "DON_ABO", "CAN_ABO", "DON_RELATIONSHIP_TY", "REC_B_MM_EQUIV_TX",
    "REC_DR_MM_EQUIV_TX"
  ))
  if (!any(c("DON_RACE_BLACK_AFRICAN_AMERICAN", "DON_RACE") %in% names(df))) {
    check_columns(df, "DON_RACE", why = "Or supply {.field DON_RACE_BLACK_AFRICAN_AMERICAN}.")
  }
  .warn_overwrite(df, c(lkdpi_col, if (return_terms) "LKDPI_terms"))

  # eGFR as in the paper: all ages, since living donors are adults.
  egfr <- suppressMessages(add_donor_egfr(
    df,
    equation = egfr_equation,
    creatinine = creatinine,
    adults_only = FALSE,
    egfr_col = ".lkdpi_egfr"
  )$.lkdpi_egfr)
  age <- as.numeric(df$DON_AGE)
  bmi <- as.numeric(df$DON_WGT_KG) / (as.numeric(df$DON_HGT_CM) / 100)^2
  black <- .donor_black(df)
  sex <- function(x) toupper(trimws(sub(":.*$", "", as.character(x))))
  don_sex <- sex(df$DON_GENDER)
  rec_sex <- sex(df$CAN_GENDER)
  male_male <- ifelse(
    don_sex %in% c("M", "F") & rec_sex %in% c("M", "F"),
    as.numeric(don_sex == "M" & rec_sex == "M"),
    NA_real_
  )
  relation <- .srtr_code(df$DON_RELATIONSHIP_TY)
  unrelated <- ifelse(
    relation %in% c(1:6, 13, 14),
    0,
    ifelse(relation %in% c(7:12, 15, 999), 1, NA_real_)
  )
  ratio <- as.numeric(df$DON_WGT_KG) / as.numeric(df$REC_WGT_KG)

  terms <- list(
    intercept = rep(-11.30, nrow(df)),
    age = 1.85 * pmax(age - 50, 0),
    egfr = -0.381 * egfr,
    bmi = 1.17 * bmi,
    black = 22.34 * black,
    cigarette = 14.33 * as.numeric(.srtr_yes(df$DON_HIST_CIGARETTE)),
    sbp = 0.44 * as.numeric(df$DON_BP_PREOP_SYST),
    male_to_male = -21.68 * male_male,
    abo_incompatible = 27.30 * .abo_incompatible(df$DON_ABO, df$CAN_ABO, a2_donor),
    unrelated = -10.61 * unrelated,
    hla_b = 8.57 * as.numeric(df$REC_B_MM_EQUIV_TX),
    hla_dr = 8.26 * as.numeric(df$REC_DR_MM_EQUIV_TX),
    weight_ratio = -50.87 * pmin(ratio, 0.9)
  )
  lkdpi <- Reduce(`+`, terms)
  .inform_missing_score(lkdpi, "LKDPI")

  attr(lkdpi, "label") <- "Living Kidney Donor Profile Index"
  df[[lkdpi_col]] <- lkdpi
  if (return_terms) {
    df[["LKDPI_terms"]] <- lapply(seq_len(nrow(df)), function(i) {
      vapply(terms, `[`, numeric(1), i)
    })
  }
  df
}

# 1 if the donor carries an A or B antigen the recipient lacks, else 0; NA if
# either blood type is not a known code.
.abo_incompatible <- function(donor, recipient, a2_donor = "incompatible") {
  antigens <- function(x, a2_lacks_a = FALSE) {
    x <- toupper(trimws(sub(":.*$", "", as.character(x))))
    known <- x %in% c("O", "A", "A1", "A2", "B", "AB", "A1B", "A2B")
    has_a <- x %in% c("A", "A1", "A2", "AB", "A1B", "A2B")
    if (a2_lacks_a) {
      has_a <- has_a & !x %in% c("A2", "A2B")
    }
    has_b <- x %in% c("B", "AB", "A1B", "A2B")
    list(a = ifelse(known, has_a, NA), b = ifelse(known, has_b, NA))
  }
  d <- antigens(donor, a2_lacks_a = a2_donor == "compatible")
  r <- antigens(recipient)
  as.numeric((d$a & !r$a) | (d$b & !r$b))
}
