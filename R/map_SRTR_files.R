# The SRTR file list, scanning SRTR_WD when needed: on first use, when SRTR_WD
# has changed since the last scan, or when `refresh = TRUE`.
.srtr_file_list <- function(refresh = FALSE) {
  SRTR_wd <- Sys.getenv("SRTR_WD")
  if (!nzchar(SRTR_wd)) {
    stop(
      "SRTR_WD is not set. Call `set_srtr_wd(\"path/to/your/SAFs\")` first.",
      call. = FALSE
    )
  }
  if (!dir.exists(SRTR_wd)) {
    stop("The SRTR_WD folder does not exist: ", SRTR_wd, call. = FALSE)
  }

  stale <- is.null(.srtr_env$file_list) ||
    !identical(.srtr_env$scanned_wd, SRTR_wd)
  if (refresh || stale) {
    .map_srtr_files()
  }
  .srtr_env$file_list
}

#' Internal: Map SRTR data files in the working directory
#'
#' Scans the directory set by the SRTR_WD environment variable and stores
#' a cleaned file list in the package's internal environment for downstream use.
#'
#' Called by `.srtr_file_list()` when `load_srtr_file()` needs the list, and by
#' `set_srtr_wd()`.
#'
#' @keywords internal

.map_srtr_files <- function() {
  SRTR_wd <- Sys.getenv("SRTR_WD")

  list_and_clean <- function(pattern) {
    raw_files <- list.files(path = SRTR_wd, pattern = pattern, recursive = TRUE)
    tibble::tibble(file_path = raw_files) |>
      dplyr::mutate(
        file_name = fs::path_file(.data$file_path),
        file_path = file.path(SRTR_wd, .data$file_path)
      )
  }

  File_List_clean <- dplyr::bind_rows(
    list_and_clean("sas7bdat$"),
    list_and_clean("parquet$")
  ) |>
    tidyr::separate(
      "file_name",
      c("file_root", "file_suffix"),
      sep = "\\.(?=[^.]+$)",
      remove = FALSE
    )

  .srtr_env$file_list <- File_List_clean
  .srtr_env$scanned_wd <- SRTR_wd

  invisible(File_List_clean)
}
