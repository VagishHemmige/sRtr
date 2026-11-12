test_that("set_srtr_wd() errors on a folder that does not exist", {
  withr::local_envvar(SRTR_WD = NA)
  withr::local_dir(withr::local_tempdir())
  expect_error(
    set_srtr_wd("no-such-folder"),
    class = "sRtr_error_folder_missing"
  )
  expect_snapshot(error = TRUE, set_srtr_wd("no-such-folder"))
  expect_equal(Sys.getenv("SRTR_WD"), "")
})
