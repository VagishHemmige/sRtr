#' Add a donor's estimated glomerular filtration rate
#'
#' Computes creatinine-based estimated glomerular filtration rate (eGFR, in
#' mL/min/1.73 m\eqn{^2}) for donors with a CKD-EPI equation and appends it
#' (default column `DON_EGFR`).
#'
#' Input columns: `DON_AGE` (years), `DON_GENDER` (`F` or `M`), and the serum
#' creatinine column named by `creatinine` (mg/dL). The 2009 equation also
#' needs `DON_RACE_BLACK_AFRICAN_AMERICAN` (Y/N), or `DON_RACE` (16 = Black or
#' African American; 1024 = unknown) when that column is absent. A creatinine
#' that is not a positive number, an unknown sex and, for the 2009 equation, an
#' unknown race give a missing value.
#'
#' A deceased donor's creatinine is often not at a steady state, so this
#' value describes the creatinine more than the kidney's filtration rate.
#'
#' @param df A data frame of donors or transplants, one row each.
#' @param equation `"ckd_epi_2021"` (default), refit without race, or
#'   `"ckd_epi_2009"`, the earlier equation with a race coefficient, for
#'   comparison with older work.
#' @param creatinine Name of the creatinine column. Defaults to `"DON_CREAT"`
#'   (deceased donor terminal creatinine). Other choices include
#'   `"DON_KI_CREAT_PREOP"` for living donors, or a peak or final value.
#' @param adults_only If `TRUE` (default), donors under 18 get a missing
#'   value: CKD-EPI was developed in adults.
#' @param egfr_col Name of the output column.
#'
#' @return `df` with a new column.
#'
#' @references
#' Inker LA, Eneanya ND, Coresh J, et al. New creatinine- and cystatin
#' C-based equations to estimate GFR without race. *N Engl J Med*
#' 2021;385:1737-1749. \doi{10.1056/NEJMoa2102953} (Table 2, which gives both
#' the 2021 equation and the 2009 equation.)
#'
#' Levey AS, Stevens LA, Schmid CH, et al. A new equation to estimate
#' glomerular filtration rate. *Ann Intern Med* 2009;150:604-612.
#' \doi{10.7326/0003-4819-150-9-200905050-00006}
#'
#' @examples
#' donors <- data.frame(
#'   DON_AGE = c(50, 30),
#'   DON_GENDER = c("F", "M"),
#'   DON_CREAT = c(0.6, 2.0)
#' )
#' add_donor_egfr(donors)
#' @export
add_donor_egfr <- function(
  df,
  equation = c("ckd_epi_2021", "ckd_epi_2009"),
  creatinine = "DON_CREAT",
  adults_only = TRUE,
  egfr_col = "DON_EGFR"
) {
  equation <- rlang::arg_match(equation)
  check_columns(df, c("DON_AGE", "DON_GENDER", creatinine))
  if (equation == "ckd_epi_2009" &&
    !any(c("DON_RACE_BLACK_AFRICAN_AMERICAN", "DON_RACE") %in% names(df))) {
    check_columns(df, "DON_RACE", why = "Or supply {.field DON_RACE_BLACK_AFRICAN_AMERICAN}.")
  }
  .warn_overwrite(df, egfr_col)

  age <- as.numeric(df$DON_AGE)
  scr <- .positive_finite(df[[creatinine]])
  sex <- toupper(trimws(sub(":.*$", "", as.character(df$DON_GENDER))))
  female <- ifelse(sex == "F", TRUE, ifelse(sex == "M", FALSE, NA))

  co <- .ckd_epi_coefficients[[equation]]
  kappa <- ifelse(female, 0.7, 0.9)
  a1 <- ifelse(female, co[["a1_female"]], co[["a1_male"]])
  egfr <- co[["mu"]] *
    pmin(scr / kappa, 1)^a1 *
    pmax(scr / kappa, 1)^co[["a2"]] *
    co[["age"]]^age *
    ifelse(female, co[["female"]], 1)
  if (equation == "ckd_epi_2009") {
    egfr <- egfr * ifelse(.donor_black(df) == 1, co[["black"]], 1)
  }
  if (adults_only) {
    egfr[!is.na(age) & age < 18] <- NA_real_
  }
  .inform_missing_score(egfr, "Donor eGFR")

  attr(egfr, "label") <- paste0("Donor eGFR, ", sub("ckd_epi_", "CKD-EPI ", equation))
  df[[egfr_col]] <- egfr
  df
}

# Inker 2021, Table 2: the 2009 CKD-EPI creatinine equation (eGFRcr ASR) and
# the 2021 equation (eGFRcr AS).
.ckd_epi_coefficients <- list(
  ckd_epi_2009 = c(
    mu = 141, a1_female = -0.329, a1_male = -0.411, a2 = -1.209,
    age = 0.9929, female = 1.018, black = 1.159
  ),
  ckd_epi_2021 = c(
    mu = 142, a1_female = -0.241, a1_male = -0.302, a2 = -1.200,
    age = 0.9938, female = 1.012
  )
)
