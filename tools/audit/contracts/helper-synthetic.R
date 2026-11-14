# Small synthetic generators. SRTR column names are from bundled dictionary;
# all values are fabricated; IDs 900001+ are test-only and dates use year 2000.
synthetic_square <- function() {
  square <- sf::st_polygon(list(rbind(c(0, 0), c(1, 0), c(1, 1),
                                      c(0, 1), c(0, 0))))
  sf::st_sf(count = 100, geometry = sf::st_sfc(square, crs = 5070))
}
synthetic_donor <- function() {
  tibble::tibble(DON_GENDER = "M", DON_AGE_IN_MONTHS = 336,
    DON_CREAT = 1, DON_RACE = 8, DON_BMI = 24, DON_HGT_CM = 173,
    DON_COD_DON_STROKE = 0, REC_PA_PRESERV_TM = 12, DON_NON_HR_BEAT = "N")
}
synthetic_cohort <- function(organ = "KI") {
  x <- tibble::tibble(TRR_ID = 900001, REC_TX_DT = as.Date("2000-01-01"),
    REC_POSTX_LOS = 1, REC_ACUTE_REJ_EPISODE = "3: No",
    PERS_OPTN_DEATH_DT = as.Date(NA), PERS_SSA_DEATH_DT = as.Date(NA),
    TFL_DEATH_DT = as.Date(NA), TFL_GRAFT_DT = as.Date(NA),
    TFL_LAFUDATE = as.Date("2000-01-10"))
  attr(x, "file_key") <- paste0("TX_", organ)
  x
}
synthetic_followup <- function(date = as.Date("2000-01-05"), organ = "KI") {
  tibble::tibble(TRR_ID = 900001, ORG_TY = organ, TFL_MALIG = "Y",
    TFL_ACUTE_REJ_EPISODE = "1: Yes, at least one episode treated with anti-rejection agent",
    TFL_PX_STAT_DT = date)
}
