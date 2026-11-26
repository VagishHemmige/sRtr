#' Set the SRTR working directory
#'
#' Sets the SRTR working directory for the current session, or optionally saves it permanently
#' in the user's `.Renviron` file as the environment variable `SRTR_WD`.
#'
#' @seealso Guides:
#' * [Point sRtr at your SAFs](https://vagishhemmige.github.io/sRtr/articles/getting-started.html#point-srtr-at-your-safs)
#' * [Telling sRtr your release](https://vagishhemmige.github.io/sRtr/articles/releases-and-warnings.html#telling-srtr-your-release)
#' @param path Path to the SRTR data folder
#' @param permanent Logical; if TRUE, appends the setting to `.Renviron` for persistence
#' @param release Optional. The SAF release the folder holds, as year and
#'   month (`"2609"` for September 2026). Files loaded from the folder use the
#'   SRTR data dictionary for that release. If `NULL` (the default), the
#'   release is read from a folder name like `pubsaf2609` (the folder or its
#'   parent); if there is none, files use the bundled [dictionary] and
#'   [formats]. A `release` that differs from the folder name wins, with a
#'   warning. Only the folder is saved by `permanent = TRUE`, not the release.
#' @section Data safety check:
#' If the folder is inside a git repository and git does not ignore it,
#' `set_srtr_wd()` warns, naming the folder and the repository, because a
#' SAF there could be committed. Turn the check off with
#' `options(sRtr.safety_check = FALSE)`. See [check_repo_for_srtr_data()].
#' @return The normalized path, invisibly
#' @export
#'
#' @examples
#' \dontrun{
#' set_srtr_wd("C:/Data/SRTR")          # Session only
#' set_srtr_wd("C:/Data/SRTR", TRUE)    # Persistent across sessions
#' set_srtr_wd("C:/Data/SRTR", release = "2609")  # Files are release 2609
#' }
set_srtr_wd <- function(path, permanent = FALSE, release = NULL) {
  if (!dir.exists(path)) {
    srtr_abort(
      c("The folder does not exist:", " " = "{.path {path}}"),
      class = "folder_missing"
    )
  }
  if (!is.null(release)) {
    .srtr_check_release(release)
  }
  normalized <- normalizePath(path, winslash = "/", mustWork = TRUE)

  # Set for current session
  Sys.setenv(SRTR_WD = normalized)
  .srtr_set_release_state(normalized, release)
  .srtr_check_saf_folder(normalized)

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
