# A new, empty folder for a made-up analysis project, deleted when the test
# ends. It sits in the session's temporary folder, outside any git repository.
local_project_folder <- function(env = parent.frame()) {
  dir <- withr::local_tempdir(pattern = "project-", .local_envir = env)
  normalizePath(dir, winslash = "/")
}
