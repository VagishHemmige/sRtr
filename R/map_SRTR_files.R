#' Internal: Map SRTR data files in the working directory
#'
#' Scans the directory set by the SRTR_WD environment variable and stores
#' a cleaned file list in the package's internal environment for downstream use.
#'
#' This function is intended for internal use only and is automatically
#' run on package load if SRTR_WD is set.
#'
#' @keywords internal
#' @importFrom dplyr bind_rows mutate
#' @importFrom tibble tibble
#' @importFrom fs path_file
#' @importFrom tidyr separate
#' @importFrom magrittr %>%

.map_SRTR_files <- function() {
  SRTR_wd <- Sys.getenv("SRTR_WD")
  if (SRTR_wd == "") {
    warning("SRTR_WD is not set. Use `set_SRTR_wd()` to configure your working directory.")
    return(invisible(NULL))
  }

  list_and_clean <- function(pattern) {
    raw_files <- list.files(path = SRTR_wd, pattern = pattern, recursive = TRUE)
    tibble::tibble(file_path = raw_files) %>%
      mutate(
        file_name = fs::path_file(file_path),
        file_path = file.path(SRTR_wd, file_path)
      )
  }

  File_List_clean <- bind_rows(
    list_and_clean("sas7bdat$"),
    list_and_clean("parquet$")
  ) %>%
    tidyr::separate(file_name, c("file_root", "file_suffix"),
                    sep = "\\.(?=[^.]+$)", remove = FALSE)

  .srtr_env$file_list <- File_List_clean
  .srtr_env$initialized <- TRUE

  invisible(File_List_clean)
}
