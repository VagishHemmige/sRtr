# Column names used in data-masked code. List columns only, never functions:
# a function listed here hides a missing pkg:: prefix from R CMD check.
utils::globalVariables(c(
  ".File_List_clean", ".File_List_csv_clean", ".File_List_csv_raw",
  ".File_List_sas_clean", ".File_List_sas_raw", "file_path", "file_name", "file_root",
  "code", "meaning", "Format", "FormatID", "Dataset",
  "Variable", "variable_upper", ".patient_lafu", ".graft_lafu",
  ".death_event", ".death_censor"
))


#' @importFrom rlang .data :=
#' @noRd
.onLoad <- function(libname, pkgname) {
  try(.map_srtr_files(), silent = TRUE)
  options(arrow.skip_nul = TRUE)
}
