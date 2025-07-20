#' Set the SRTR working directory
#'
#' Sets the SRTR working directory for the current session, or optionally saves it permanently
#' in the user's `.Renviron` file as the environment variable `SRTR_WD`.
#'
#' @param path Path to the SRTR data folder
#' @param permanent Logical; if TRUE, appends the setting to `.Renviron` for persistence
#' @return The normalized path, invisibly
#' @export
#'
#' @examples
#' \dontrun{
#' set_srtr_wd("C:/Data/SRTR")          # Session only
#' set_srtr_wd("C:/Data/SRTR", TRUE)    # Persistent across sessions
#' }
set_srtr_wd <- function(path, permanent = FALSE) {
  if (!dir.exists(path)) stop("Directory does not exist: ", path)
  normalized <- normalizePath(path, winslash = "/", mustWork = TRUE)

  # Set for current session
  Sys.setenv(SRTR_WD = normalized)

  if (permanent) {
    renv_path <- path.expand("~/.Renviron")
    line <- sprintf('SRTR_WD="%s"', normalized)

    if (!file.exists(renv_path)) {
      writeLines(line, renv_path)
      message("Created ~/.Renviron and added:\n", line)
    } else {
      renv <- readLines(renv_path)

      # Check if SRTR_WD already exists
      if (any(grepl("^SRTR_WD=", renv))) {
        # Replace existing line
        renv <- sub("^SRTR_WD=.*", line, renv)
        message("Updated SRTR_WD in ~/.Renviron:\n", line)
      } else {
        renv <- c(renv, line)
        message("Appended SRTR_WD to ~/.Renviron:\n", line)
      }

      writeLines(renv, renv_path)
    }

    message("Restart R or call `Sys.getenv(\"SRTR_WD\")` to confirm.")
  }

  # Clear and re-map after setting
  .srtr_env$initialized <- FALSE
  .map_srtr_files()

  invisible(normalized)
}
