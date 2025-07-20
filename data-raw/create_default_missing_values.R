## code to prepare `create_default_missing_values` dataset goes here


#Initialize list
default_missing_vars <- list()

# Variables that use SRLSTT format
srlstt_vars <- sRtr::dictionary %>%
  dplyr::filter(FormatID == "SRLSTT") %>%
  dplyr::pull(Variable) %>%
  unique()

# Full labeled missing values
srlstt_missing <- c(
  "C: Cannot Disclose",
  "ND: Not Done",
  "PD: Pending",
  "U: Unknown"
)

# Assign to the internal default_missing_vars list
for (var in srlstt_vars) {
  default_missing_vars[[var]] <- srlstt_missing
}


cols <- c("DON_GENDER", "DON_PRERECOV_DIURETICS", "DON_DDAVP",
          "DON_INSULIN", "DON_DOPAMINE", "DON_DOBUTAMINE",
          "DON_INOTROP_SUPPORT", "DON_INOTROP_AGENT_GE3", "DON_HIST_IV_DRUG",
          "DON_CONT_IV_DRUG", "DON_HIST_CIGARETTE_GT20_PKYR", "DON_CONT_CIGARETTE",
          "DON_HIST_COCAINE", "DON_CONT_COCAINE", "DON_HIST_OTHER_DRUG",
          "DON_CONT_OTHER_DRUG", "DON_MEET_CDC_HIGH_RISK", "DON_NON_HR_BEAT",
          "DON_CARDIAC_ARREST_AFTER_DEATH", "DON_LI_BIOPSY", "REC_TX_EXTRA_VESSEL",
          "REC_HOSP_90_DAYS", "REC_DGN_OSTXT", "REC_WORK_INCOME",
          "REC_CMV_IGG", "REC_CMV_IGM", "REC_CMV_STAT",
          "REC_HBV_ANTIBODY", "REC_HBV_SURF_ANTIGEN", "REC_EBV_STAT",
          "REC_MALIG", "REC_IMMUNO_MAINT_MEDS", "REC_PX_RESEARCH",
          "REC_ANTIVRL_THERAPY", "REC_OTHER_THERAPY", "REC_LIFE_SUPPORT",
          "REC_GRAFT_STAT", "REC_VALCYTE", "REC_TUMOR",
          "REC_PB_CREDIT", "REC_PB_DEBT", "REC_VARICEAL_BLEEDING",
          "REC_ASCITES", "REC_ON_VENTILATOR", "REC_INOTROP_BP_SUPPORT",
          "REC_TOLERANCE_INDUCTION_TECH", "REC_PORTAL_HYPERTEN_BLEED", "REC_BACTERIA_PERIT",
          "REC_PORTAL_VEIN", "REC_TIPSS", "REC_FAIL_PRIME_GRAFT_FAIL",
          "REC_FAIL_VASC_THROMB", "REC_FAIL_BILIARY", "REC_FAIL_HEP_DENOVO",
          "REC_FAIL_HEP_RECUR", "REC_FAIL_RECUR_DISEASE", "REC_FAIL_REJ_ACUTE",
          "REC_FAIL_INFECT", "REC_HEPATIC_ARTER_THROMB", "REC_HEPATIC_OUTFLOW_OBSTRUCT",
          "REC_PORTAL_VEIN_THROMB", "REC_PREV_NONFUNCTN_TX", "REC_PREV_ABDOM_SURG",
          "CAN_INIT_SRTR_LAB_MELD_TY", "CAN_LAST_SRTR_LAB_MELD_TY", "CAN_LAST_DIAL_PRIOR_WEEK",
          "CAN_SOURCE", "CAN_DRUG_TREAT_HYPERTEN", "CAN_CEREB_VASC",
          "CAN_PERIPH_VASC", "CAN_DRUG_TREAT_COPD", "CAN_PULM_EMBOL",
          "CAN_PREV_TXFUS", "CAN_MALIG", "CAN_BACTERIA_PERIT",
          "CAN_PORTAL_VEIN", "CAN_TIPSS", "CAN_PREV_ABDOM_SURG", "REC_HIV_STAT", "REC_HCV_STAT",
          "DON_LF_KI_BIOPSY", "DON_LF_KI_PUMP", "DON_RT_KI_BIOPSY", "DON_RT_KI_PUMP", "REC_PRETX_DIAL",
          "REC_PRETX_BIOPSY", "REC_PRETX_TXFUS", "REC_GROWTH_HORMONE", "REC_FRAC_PASTYR", "REC_AVN",
          "REC_RESUM_MAINT_DIAL", "REC_FAIL_GRAFT_THROMB", "REC_FAIL_SURG_COMPL", "REC_FAIL_UROL_COMPL",
          "REC_PROD_URINE_GT40_24HRS", "REC_FIRST_WEEK_DIAL", "REC_CREAT_DECLINE_GE25", "CAN_PREV_KI_TX_FUNCTN"
)


# Assign to the internal default_missing_vals list
for (var in cols) {
  default_missing_vars[[var]] <- c("", "ND", "U")
}


usethis::use_data(default_missing_vars, overwrite = TRUE, internal = TRUE)



#Way to obtain list of variables whose values need to be changed to missing
#names(tx_li)[sapply(tx_li, function(col) {
#  if (is.factor(col) || is.character(col)) {
#    any(as.character(col) == "", na.rm = TRUE)
#  } else {
#    FALSE
#  }
#})]
