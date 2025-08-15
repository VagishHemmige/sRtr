## code to prepare `create_default_missing_values` dataset goes here

library(tidyverse)

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
          "CAN_SIX_MIN_WALK_LT150",
          "CAN_INIT_SRTR_LAB_MELD_TY", "CAN_LAST_SRTR_LAB_MELD_TY", "CAN_LAST_DIAL_PRIOR_WEEK",
          "CAN_SOURCE", "CAN_DRUG_TREAT_HYPERTEN", "CAN_CEREB_VASC",
          "CAN_PERIPH_VASC", "CAN_DRUG_TREAT_COPD", "CAN_PULM_EMBOL",
          "CAN_PREV_TXFUS", "CAN_MALIG", "CAN_BACTERIA_PERIT",
          "CAN_PORTAL_VEIN", "CAN_TIPSS", "CAN_PREV_ABDOM_SURG", "REC_HIV_STAT", "REC_HCV_STAT",
          "DON_LF_KI_BIOPSY", "DON_LF_KI_PUMP", "DON_RT_KI_BIOPSY", "DON_RT_KI_PUMP", "REC_PRETX_DIAL",
          "REC_PRETX_BIOPSY", "REC_PRETX_TXFUS", "REC_GROWTH_HORMONE", "REC_FRAC_PASTYR", "REC_AVN",
          "REC_RESUM_MAINT_DIAL", "REC_FAIL_GRAFT_THROMB", "REC_FAIL_SURG_COMPL", "REC_FAIL_UROL_COMPL",
          "REC_PROD_URINE_GT40_24HRS", "REC_FIRST_WEEK_DIAL", "REC_CREAT_DECLINE_GE25", "CAN_PREV_KI_TX_FUNCTN",
          "DON_PRERECOV_T3","DON_PRERECOV_T4","REC_PULM_ART_SYST_MEDS","REC_PULM_ART_DIAST_MEDS",
          "REC_PULM_ART_MEAN_MEDS","REC_PCW_MEAN_MEDS","REC_CARDIAC_OUTPUT_MEDS","REC_CHRONIC_STEROIDS",
          "REC_TXFUS","REC_PULM_EMBOL","REC_INFECT_IV_DRUG","REC_CEREB_VASC_AFTER_LIST","REC_DIAL",
          "REC_IMPLANT_DEFIB","REC_CARDIAC_SURG","REC_LU_SURG","REC_VENTILATOR_SUPPORT","REC_TRACHEOSTOMY",
          "REC_PRIOR_THOR_SURG","REC_PRIOR_CONGEN_SURG","REC_PALL_SURG","REC_CORRECT_SURG",
          "REC_SINGLE_VENT_PHYSIOLOGY","REC_THOR_RETX","REC_POSTX_DRUG_TREAT_REJ","REC_POSTX_DRUG_TREAT_INFECT",
          "REC_POSTX_STROKE","REC_POSTX_DIAL","REC_POSTX_CARDIAC_REOP","REC_POSTX_SURG","REC_POSTX_REINTUBATED",
          "REC_POSTX_PACEMAKER","REC_POSTX_CHEST_DRAIN","REC_POSTX_AIRWAY","CAN_SUDDEN_DEATH","REC_TUMOR",
          "REC_VEIN_EXTEND_GRAFT", "REC_GRAFT_REM", "REC_FAIL_GRAFT_VASC_THROMB", "REC_FAIL_BLEEDING",
          "REC_FAIL_ANAST_LEAK", "REC_FAIL_REJ_HYPER", "REC_FAIL_BIOPSY_ISLETITIS", "REC_FAIL_PANCREATITIS",
          "REC_KI_GRAFT_STAT", "REC_KI_TX_AFTER_PA", "REC_PANCREATITIS", "REC_ANAST_LEAK", "REC_ABSCESS", "REC_BIOPSY_KI",
          "REC_RECENT_SEPT", "REC_EXHAUST_VASC","REC_LI_DYSFUNCTN","REC_NONFUNCTN_BOWEL_SEG",
          "REC_TPN_DEPND", "REC_IV_DEPND", "REC_ORAL_FEED", "REC_TUBE_FEED",
          "REC_GRAFT_STAT_PA", "REC_FAIL_REJ_ACUTE_PA", "REC_FAIL_INFECT_PA",
          "TFL_HOSP", "TFL_PX_NONCOMP",
          "TFL_CMV_IGG", "TFL_CMV_IGM", "TFL_WORK_INCOME", "TFL_REJ_TREAT", "TFL_MALIG", "TFL_MALIG_LYMPH",
          "TFL_MALIG_DON_RELATED", "TFL_MALIG_RECUR_TUMOR",
          "TFL_MALIG_TUMOR", "TFL_ANTIVRL_THERAPY", "TFL_IMMUNO_DISCONT", "TFL_PX_RESEARCH", "TFL_GRAFT_STAT",
          "TFL_HOSP_REJ", "TFL_HOSP_INFECT", "TFL_PACEMAKER", "TFL_CAD", "TFL_CLINICAL_SIGNIF_EVENT",
          "TFL_BRONC_STRICTURE", "TFL_BRONC_STRICTURE_STENT", "TFL_DRUG_HYPERTEN", "TFL_BONE_DISEASE",
          "TFL_LI_DISEASE", "TFL_CATARACTS", "TFL_RENAL_DYSFUNCTN", "TFL_CREAT_GT25", "TFL_CHRONIC_DIAL", "TFL_RENAL_TX",
          "TFL_DIAB_DURING_FOL", "TFL_INSULIN_DEPND", "TFL_STROKE", "TFL_HYPERLIPID", "TFL_BK_THERAPY",
          "TFL_URINE_PROTEIN", "TFL_FAIL_REJ_ACUTE", "TFL_FAIL_REJ_CHRONIC", "TFL_FAIL_GRAFT_THROMB",
          "TFL_FAIL_INFECT", "TFL_FAIL_UROL_COMPL", "TFL_FAIL_PX_NONCOMP",
          "TFL_FAIL_RECUR_DISEASE", "TFL_FAIL_BK", "TFL_GROWTH_HORMONE", "TFL_FRAC_PASTYR",
          "TFL_AVN", "TFL_FAIL_PRIME_GRAFT_FAIL", "TFL_FAIL_VASC_THROMB","TFL_HEPATIC_ARTER_THROMB",
          "TFL_HEPATIC_OUTFLOW_OBSTRUCT", "TFL_PORTAL_VEIN_THROMB", "TFL_FAIL_BILIARY", "TFL_FAIL_HEP_DENOVO",
          "TFL_FAIL_HEP_RECUR", "TFL_BK_THERAPY", "TFL_GRAFT_REM", "TFL_FAIL_GRAFT_VASC_THROMB",
          "TFL_FAIL_BLEEDING", "TFL_FAIL_ANAST_LEAK", "TFL_FAIL_BIOPSY_ISLETITIS", "TFL_FAIL_PANCREATITIS",
          "TFL_ENTERIC_DRAIN", "TFL_KI_GRAFT_STAT", "TFL_KI_TX_AFTER_PA",
          "TFL_PANCREATITIS", "TFL_ANAST_LEAK", "TFL_ABSCESS", "TFL_ORAL_FEED", "TFL_TUBE_FEED", "TFL_TPN_DEPND",
          "TFL_IV_DEPND", "DON_TY", "CAN_PRELIM_XMATCH_REQUEST", "CAN_ON_DIAL", "CAN_ACPT_HBC_POS",
          "CAN_ACPT_ORG_OTHER_TEAM", "CAN_ACPT_HCV_POS", "CAN_DONATED_ORG",
          "CAN_LIFE_SUPPORT", "CAN_WORK_INCOME", "CAN_NEW_PREV_PI_TX", "CAN_GROWTH_HORMONE", "CAN_EXHAUST_PERIT_ACCESS",
          "CAN_EXHAUST_VASC_ACCESS", "CAN_FRAC_PASTYR", "CAN_AVN", "DONCRIT_ACPT_DCD", "DONCRIT_ACPT_DCD_IMPORT",
          "CAN_PREV_KI_TX_FUNCTN", "CAN_ACPT_ABO_INCOMP", "CAN_ACPT_A2_DON", "CAN_ACPT_EXTRACORP_LI",
          "CAN_ACPT_LI_SEG", "CAN_ACPT_PROCUR_KI","CAN_ACPT_PROCUR_LI", "CAN_ACPT_PROCUR_PA",
          "CAN_LI_DYSFUNCTN", "CAN_NEOPLASM", "CAN_LOSS_VASC_ACCESS", "CAN_RECUR_SEPSIS","CAN_FUNGAL_SEPSIS",
          "CAN_ELECTROLYTE", "CAN_NON_RECON_GI", "CAN_ENCEPH", "CAN_VARICEAL_BLEEDING",
          "CAN_ASCITES", "CAN_BACTERIA_PERIT","CAN_MUSCLE_WASTING", "CAN_PORTAL_VEIN",
          "CAN_TIPSS", "CAN_PREV_ABDOM_SURG", "CAN_INIT_SRTR_LAB_MELD_TY", "CAN_LAST_SRTR_LAB_MELD_TY",
          "CAN_INUTERO", "CAN_ACPT_ABO_INCOMP", "CAN_ACPT_DCD", "CAN_ACPT_GENDER",
          "CAN_ACPT_HIST_CAD", "CAN_ACPT_HIST_CIGARETTE", "CAN_TAH", "CAN_VASC_ASSIST", "CAN_BALLOON",
          "CAN_ON_VENTILATOR", "CAN_ICU", "CAN_INOTROP", "CAN_ACPT_HTLV_POS", "CAN_SUDDEN_DEATH",
          "CAN_ANTI_ARRYTHM", "CAN_AMIODARONE", "CAN_IMPLANT_DEFIB", "CAN_INFECT_IV_DRUG", "CAN_TREAT_PULM_SEPSIS",
          "CAN_CORTICOST_DEPND", "CAN_RESIST_INFECT", "CAN_SIX_MIN_WALK_LT150", "CAN_PULM_ART_SYST_MEDS",
          "CAN_PULM_ART_DIAST_MEDS", "CAN_PULM_ART_MEAN_MEDS", "CAN_PCW_MEAN_MEDS",
          "CAN_CARDIAC_OUTPUT_MEDS", "CAN_CIGARETTE_GT10", "CAN_HIST_CIGARETTE",
          "CAN_OTHER_TOBACCO_USE", "CAN_CARDIAC_SURG", "CAN_LU_SURG", "CAN_PRIOR_THOR_SURG",
          "CAN_PRIOR_THOR_SURG_PRE04", "CAN_PRIOR_CONGEN_SURG", "CAN_PALL_SURG", "CAN_CORRECT_SURG",
          "CAN_SINGLE_VENT_PHYSIOLOGY", "DFL_WORK_INCOME", "DFL_HYPERTEN",
          "DFL_MAINT_DIAL", "DFL_DIAB", "DFL_READMIT", "DFL_KI_COMPL", "DFL_LI_COMPL", "DFL_COMPL",
          "DFL_LOSS_OF_INS", "DON_EDUCATION", "DON_HEALTH_INSUR", "DON_MEDICARE",
          "DON_MEDICAID", "DON_OTHER_GOVT", "DON_PRIV_INSUR", "DON_HMO_PPO", "DON_SELF", "DON_DONATION",
          "DON_FREE", "DON_WORK_INCOME", "DON_VIRUSES_TESTED", "DON_HIV_TESTED", "DON_HIV_SCREEN", "DON_HIV_CONFIRM",
          "DON_HIV_CLINICAL", "DON_HIV_ANTIBODY", "DON_HIV_RNA", "DON_CMV_TESTED", "DON_CMV", "DON_CMV_CLINICAL",
          "DON_CMV_NUCLEIC", "DON_CMV_CULT", "DON_HBV_TESTED", "DON_HBV_CLINICAL", "DON_HBV_LI_HISTOLOGY",
          "DON_HBV_ANTIBODY", "DON_HBV_SURF_ANTIGEN", "DON_HBV_DNA", "DON_HBV_HDV",
          "DON_HCV_TESTED", "DON_HCV_CLINICAL", "DON_HCV_LI_HISTOLOGY", "DON_HCV_ANTIBODY", "DON_HCV_RIBA",
          "DON_HCV_RNA", "DON_EBV_TESTED", "DON_EBV_CLINICAL", "DON_EBV_IGG", "DON_EBV_IGM",
          "DON_EBV_DNA", "DON_DIAB", "DON_HYPERTEN_DIET", "DON_HYPERTEN_DIURETICS", "DON_HYPERTEN_OTHER_MEDS",
          "DON_KI_BIOPSY", "DON_HIST_CIGARETTE", "DON_OTHER_TOBACCO_USE",
          "DON_KI_PROCEDURE_CONVERT", "DON_LU_PROCEDURE_CONVERT", "DON_INTRAOP_COMPL",
          "DON_ANASTH_COMPL", "DON_NON_AUTO_BLOOD", "DON_KI_VASC_COMPL",
          "DON_KI_OTHER_COMPL", "DON_KI_REOP", "DON_KI_READMIT",
          "DON_KI_OTHER_INTERVENTION", "DON_LI_BILIARY_COMPL", "DON_LI_VASC_COMPL", "DON_LI_OTHER_COMPL",
          "DON_LI_REOP", "DON_LI_READMIT", "DON_LI_OTHER_INTERVENTION",
          "DON_LU_COMPL", "DON_LU_READMIT", "DON_HYPERTEN_POSTOP", "DON_RECOV_TX_SAME_CTR", "DON_HLA_TYP",
          "DON_RECOV_OUT_US", "DON_REF_FLG","DON_CONSENT_WRIT_DOC_INTENT",
          "DON_CONSENT_PX_WRIT_DOC", "DON_EXPRESS_FAMILY", "DON_PROTEIN_URINE",
          "DON_PRERECOV_STEROIDS", "DON_PRERECOV_DIURETICS", "DON_PRERECOV_T3", "DON_PRERECOV_T4", "DON_ANTI_CONVULS",
          "DON_ANTI_HYPERTEN", "DON_VASODIL", "DON_DDAVP", "DON_HEPARIN", "DON_ARGININE",
          "DON_INSULIN", "DON_PRERECOV_MEDS", "DON_DOPAMINE", "DON_DOBUTAMINE", "DON_INOTROP_SUPPORT",
          "DON_INOTROP_AGENT_GE3", "DON_CLINICAL_INFECT", "DON_INFECT_BLOOD_CONFIRM", "DON_INFECT_LU_CONFIRM",
          "DON_INFECT_URINE_CONFIRM", "DON_INFECT_OTHER_CONFIRM", "DON_HIST_ALCOHOL", "DON_CONT_ALCOHOL",
          "DON_HIST_IV_DRUG", "DON_CONT_IV_DRUG", "DON_HIST_CIGARETTE_GT20_PKYR", "DON_CONT_CIGARETTE", "DON_HIST_COCAINE",
          "DON_CONT_COCAINE", "DON_CONT_OTHER_DRUG", "DON_HIST_OTHER_DRUG", "DON_HEAVY_ALCOHOL",
          "DON_TATTOOS", "DON_MEET_CDC_HIGH_RISK", "DON_HYPERTEN_DIET", "DON_HYPERTEN_DIURETICS",
          "DON_HYPERTEN_OTHER_MEDS", "DON_INTRACRANIAL_CANCER", "DON_EXTRACRANIAL_CANCER",
          "DON_SKIN_CANCER", "DON_NON_HR_BEAT", "DON_NON_HR_BEAT_CNTL", "DON_NON_HR_BEAT_CORE_COOL",
          "DON_DCD_PROGRESS_TO_BRAIN_DEATH", "DON_CARDIAC_ARREST_AFTER_DEATH", "DON_HIST_PREV_MI",
          "DON_ABNORM_VALVES", "DON_ABNORM_LVH", "DON_ABNORM_CONGEN", "DON_WALL_ABNORM_SEG", "DON_WALL_ABNORM_GLOB",
          "DON_PO2_DONE", "DON_PULM_CATH", "DON_LF_KI_BIOPSY", "DON_LF_KI_PUMP", "DON_LF_KI_TXFER_PUMP",
          "DON_RT_KI_BIOPSY", "DON_RT_KI_PUMP", "DON_RT_KI_TXFER_PUMP", "DON_TM_FOR_XMATCH",
          "DON_USE_DOUBLE_KI", "DON_LEGALLY_BRAIN_DEAD", "DON_LEFT_LUNG_PERFUSION", "DON_RIGHT_LUNG_PERFUSION",
          "DON_INTRACRANIAL_CANCER_TYPE", "DON_EXTRACRANIAL_CANCER_TYPE", "DON_SKIN_CANCER_TYPE", "DON_PREV_GASTRO_DISEASE"
)

# Assign to the internal default_missing_vals list
for (var in cols) {
  default_missing_vars[[var]] <- c("", "ND", "U", "u")
}

#Repeat for variables whose missingness indicator is numeric 998
cols<-c("DON_URINE_PREOP_PROTEIN", "DON_URINE_POSTOP_PROTEIN", "DON_VESSELS_GT50_STENOSIS")
for (var in cols) {
  default_missing_vars[[var]] <- c(998)
}

#Repeat for variables whose missingness indicator is ZZZZ
cols<-c("REC_CTR_CD")
for (var in cols) {
  default_missing_vars[[var]] <- c("ZZZZ")
}

#Repeat for variables whose missingness indicator is ZZ
cols<-c("DON_HOME_STATE")
for (var in cols) {
  default_missing_vars[[var]] <- c("ZZ: UNKNOWN")
}

#Repeat for variables whose missingness indicator is 1024
cols<-c("DON_RACE", "CAN_RACE")
for (var in cols) {
  default_missing_vars[[var]] <- c("1024: Unknown (for Donor Referral only)", "Missing")
}

#Repeat for variables whose missingness indicator is 1024
cols<-c("REC_MALIG_TY", "REC_OTHER_THERAPY_TY", "REC_CARDIAC_SURG_TY", "REC_LU_SURG_TY", "REC_ANTIVRL_THERAPY_TY")
for (var in cols) {
  default_missing_vars[[var]] <- c("Missing")
}

#Repeat for variables whose missingness indicator is 998: UNKNOWN
cols<-c("CAN_DIAB", "CAN_EDUCATION", "CAN_PEPTIC_ULCER", "DON_CAD_DON_COD", "DON_CITIZENSHIP",
        "DON_DEATH_CIRCUM", "DON_DEATH_MECH", "DON_HAPLO_TY_MATCH", "DON_HIST_CANCER", "DON_HIST_DIAB",
        "DON_HIST_INSULIN_DEPND", "DON_HIST_HYPERTEN", "PERS_OPTN_COD", "REC_COD", "REC_COD2", "REC_COD3",
        "REC_EMPL_STAT_PRE04", "REC_FUNCTN_STAT", "REC_PHYSC_CAPACITY", "CAN_PHYSC_CAPACITY", "REC_PREV_PREG",
        "REC_WORK_NO_STAT", "TFL_COD", "TFL_EMPL_STAT_PRE04", "TFL_FUNCTN_STAT", "CAN_EMPL_STAT", "TFL_DIAL_TY",
        "DON_FLUSH_INIT", "DON_FLUSH_FINAL", "DON_FLUSH_BACK_TABLE", "DON_STORAGE", "DON_MED_EXAMINER",
        "DON_TXFUS_TERMINAL_HOSP_NUM")
for (var in cols) {
  default_missing_vars[[var]] <- c("998: UNKNOWN")
}

#Repeat for variables whose missingness indicator is 998: Unknown
cols<-c("REC_KI_DON_TY", "TFL_PHYSC_CAPACITY", "TFL_ACUTE_REJ_EPISODE", "TFL_BRONC_OBLITERANS",
        "TFL_KI_DON_TY", "TFL_WORK_NO_STAT", "TFL_DISEASE_RECUR", "CAN_FUNCTN_STAT", "CAN_WORK_NO_STAT",
        "DFL_FUNCTN_STAT", "DFL_PHYSC_CAPACITY", "DFL_WORK_NO_STAT", "DFL_URINE_PROTEIN", "DON_MARITAL_STAT",
        "DON_FUNCTN_STAT", "DON_PHYSC_CAPACITY", "DON_WORK_NO_STAT")
for (var in cols) {
  default_missing_vars[[var]] <- c("998: Unknown")
}

#Repeat for variables whose missingness indicator is 998: Unknown Status
cols<-c("REC_POSTX_VENTILATOR_SUPPORT")
for (var in cols) {
  default_missing_vars[[var]] <- c("998: Unknown Status")
}

#Repeat for variables whose missingness indicator is 4: Unknown, converted
cols<-c("TFL_BLOOD_SUGAR_CNTL")
for (var in cols) {
  default_missing_vars[[var]] <- c("4: Unknown, converted")
}

#Repeat for variables whose missingness indicator is "998: Status Unknown"
cols<-c("REC_ACADEMIC_LEVEL", "REC_ACADEMIC_PROGRESS", "CAN_ACADEMIC_PROGRESS", "CAN_ANGINA_CAD",
        "TFL_ACADEMIC_LEVEL", "TFL_ACADEMIC_PROGRESS", "TFL_ACUTE_REJ_BIOPSY_CONFIRMED", "CAN_ACADEMIC_LEVEL")
for (var in cols) {
  default_missing_vars[[var]] <- c("998: Status Unknown")
}

#Repeat for variables whose missingness indicator is "998: Status Unknown"
cols<-c("REC_LIFE_SUPPORT_TY")
for (var in cols) {
  default_missing_vars[[var]] <- c(": Not Reported")
}

#Repeat for variables whose missingness indicator is "998: Status Unknown"
cols<-c("CAN_ANGINA")
for (var in cols) {
  default_missing_vars[[var]] <- c("998: Unknown if angina present")
}

#Repeat for variables whose missingness indicator is "998: Status Unknown"
cols<-c("REC_MOTOR_DEVELOP", "REC_COGNITIVE_DEVELOP", "TFL_COGNITIVE_DEVELOP", "TFL_MOTOR_DEVELOP",
        "CAN_COGNITIVE_DEVELOP", "CAN_MOTOR_DEVELOP")

for (var in cols) {
  default_missing_vars[[var]] <- c("998: Not Assessed")
}


#Repeat for variables whose missingness indicator is "998: Status Unknown"
cols<-c("REC_AGE_AT_TX")
for (var in cols) {
  default_missing_vars[[var]] <- c("Unknown")
}


#Repeat for HLA variables
cols<-c("DON_A1", "DON_A2", "DON_B1", "DON_B2", "DON_DR1", "DON_DR2", "REC_A1", "REC_A2", "REC_B1",
        "REC_B2", "REC_DR1", "REC_DR2", "CAN_WLKIPA_A1", "CAN_WLKIPA_A2", "CAN_WLKIPA_B1", "CAN_WLKIPA_B2",
        "CAN_WLKIPA_DR1", "CAN_WLKIPA_DR2", "DON_BW4", "DON_BW6", "DON_DR51", "DON_DR52", "DON_DR53", "DON_C1",
        "DON_C2", "DON_DQ1", "DON_DQ2", "DON_DP1", "DON_DP2")
for (var in cols) {
  default_missing_vars[[var]] <- c("97: Unknown","99: Not Tested")
}

#Repeat for f/u status
cols<-c("REC_PX_STAT")
for (var in cols) {
  default_missing_vars[[var]] <- c("U: UNKNOWN")
}

#Repeat for f/u dialysis status
cols<-c("REC_DIAL_TY", "CAN_DIAL")
for (var in cols) {
  default_missing_vars[[var]] <- c("998: Dialysis Status Unknown")
}

#Repeat for state
cols<-c("REC_PERM_STATE", "TFL_PERM_STATE")
for (var in cols) {
  default_missing_vars[[var]] <- c("ZZ: UNKNOWN")
}

#Repeat for primary payor
cols<-c("REC_PRIMARY_PAY", "DON_PRIMARY_PAY")
for (var in cols) {
  default_missing_vars[[var]] <- c("15: Unknown")
}

#Repeat for diabetes
cols<-c("CAN_DIAB_TY")
for (var in cols) {
  default_missing_vars[[var]] <- c("998: Diabetes Status Unknown")
}

#Repeat for hepatitis testing
cols<-c("DON_HCV_STAT", "DON_HBC_STAT")
for (var in cols) {
  default_missing_vars[[var]] <- c("3: Unknown", "4: Cannot Disclose", "5: Not Done", "7: Pending")
}

#Repeat for sternotomy
cols<-c("REC_PRIOR_STERNOTOMY")
for (var in cols) {
  default_missing_vars[[var]] <- c("1: Unknown if there were prior sternotomies")
}

#Repeat for thoracotomy
cols<-c("REC_PRIOR_THORACOT")
for (var in cols) {
  default_missing_vars[[var]] <- c("1: Unknown if there were prior thoracotomies")
}

#Repeat for donor follow up imaging
cols<-c("DFL_CAT_SCAN", "DFL_MRI", "DFL_ULTRASOUND")
for (var in cols) {
  default_missing_vars[[var]] <- c("4: Unknown", "1: Not Done")
}

#Repeat for donor follow-up activity level
cols<-c("DFL_ACTIVITY_LEVEL")
for (var in cols) {
  default_missing_vars[[var]] <- c("6: Unknown")
}

#Donor follow up for DFL and pre-tx Dukes
cols<-c("DFL_INCISION_PAIN", "MAL_PRETX_DUKES")
for (var in cols) {
  default_missing_vars[[var]] <- c("4: Unknown")
}

#Donor follow up for DFL and pre-tx Dukes
cols<-c("DON_LF_LU_BRONCHO", "DON_RT_LU_BRONCHO")
for (var in cols) {
  default_missing_vars[[var]] <- c("998: Unknown if bronchoscopy performed")
}

#Donor follow up serologies
cols<-c("DON_HIV_NAT", "DON_HBV_NAT", "DON_HCV_NAT", "DON_HTLV_NAT", "DON_CHAGAS_NAT",
        "DON_WEST_NILE_NAT", "DON_STRONGYLOIDES")
for (var in cols) {
  default_missing_vars[[var]] <- c("ND", "PD", "U")
}



#Final step, save final internal dataset
usethis::use_data(default_missing_vars, overwrite = TRUE, internal = TRUE)

#CAN_TX_COUNTRY; Unknown not transplanted abroad vs unknown unknown?  Have not done anything for now

#forcats::fct_drop ORG_TY CAN_DGN REC_DGN	REC_TX_PROCEDURE_TY REC_COD2 REC_COD3 REC_COD REC_TX_ORG_TY REC_FAIL_CAUSE_TY
#CAN_INIT_STAT	CAN_LAST_STAT TFL_COD CAN_INIT_ACT_STAT_CD REC_DGN2 CAN_INIT_SRTR_LAB_MELD CAN_LAST_SRTR_LAB_MELD CAN_REM_CD
#TFL_FAIL_CAUSE_TY CAN_REM_COD CAN_TX_COUNTRY, CAN_DGN, CAN_INIT_SRTR_LAB_MELD CAN_LAST_SRTR_LAB_MELD DFL_FOL_CD

