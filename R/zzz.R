# Column names used in data-masked code. List columns only, never functions:
# a function listed here hides a missing pkg:: prefix from R CMD check.
utils::globalVariables(c(
  ".File_List_clean", ".File_List_csv_clean", ".File_List_csv_raw",
  ".File_List_sas_clean", ".File_List_sas_raw", "file_path", "file_name", "file_root",
  "code", "meaning", "Format", "FormatID", "Dataset",
  "Variable", "variable_upper", ".patient_lafu", ".graft_lafu",
  ".death_event", ".death_censor"
))


# No .onLoad(): loading sRtr does not scan SRTR_WD or change options. The
# folder is scanned when load_srtr_file() first needs it (.srtr_file_list()).

#' @importFrom rlang .data :=
#' @noRd
NULL
