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
  if (!dir.exists(path)) {
    srtr_abort(
      c("The folder does not exist:", " " = "{.path {path}}"),
      class = "folder_missing"
    )
  }
  normalized <- normalizePath(path, winslash = "/", mustWork = TRUE)

  # Set for current session
  Sys.setenv(SRTR_WD = normalized)

  if (permanent) {
    renv_path <- path.expand("~/.Renviron")
    line <- sprintf('SRTR_WD="%s"', normalized)

    if (!file.exists(renv_path)) {
      writeLines(line, renv_path)
      srtr_inform(
        c("v" = "Created {.file ~/.Renviron} and added:", " " = "{.code {line}}"),
        class = "renviron_updated"
      )
    } else {
      renv <- readLines(renv_path)

      # Check if SRTR_WD already exists
      if (any(grepl("^SRTR_WD=", renv))) {
        # Replace existing line
        renv <- sub("^SRTR_WD=.*", line, renv)
        srtr_inform(
          c("v" = "Updated {.envvar SRTR_WD} in {.file ~/.Renviron}:", " " = "{.code {line}}"),
          class = "renviron_updated"
        )
      } else {
        renv <- c(renv, line)
        srtr_inform(
          c("v" = "Added {.envvar SRTR_WD} to {.file ~/.Renviron}:", " " = "{.code {line}}"),
          class = "renviron_updated"
        )
      }

      writeLines(renv, renv_path)
    }

    srtr_inform(
      c("i" = "Restart R to use it in new sessions; it is already set for this one."),
      class = "renviron_updated"
    )
  }

  # Re-map after setting
  .map_srtr_files()

  invisible(normalized)
}
