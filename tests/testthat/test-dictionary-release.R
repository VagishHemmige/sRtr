test_that("a release with a stored snapshot gets that snapshot", {
  skip_if_not_installed("xml2")
  skip_if_not_installed("digest")
  versions <- local_versions(fake_two_releases())

  out <- .srtr_dictionary_for("9904", versions)

  expect_equal(out$snapshot, "9904-1")
  expect_equal(out$basis, "observed")
  expect_equal(out$dictionary, .srtr_versions_view(versions, "9904-1", "dictionary"))
  expect_equal(out$formats, .srtr_versions_view(versions, "9904-1", "formats"))
})

test_that("the latest revision of a release is used", {
  skip_if_not_installed("xml2")
  skip_if_not_installed("digest")
  pages <- fake_two_releases()
  revised <- pages[[2]]
  revised$data$TX_KI$Label[3] <- "Revised label"
  versions <- local_versions(c(pages, list(revised)))

  out <- .srtr_dictionary_for("9904", versions)

  expect_equal(out$snapshot, "9904-2")
  expect_equal(out$dictionary$Label[out$dictionary$Variable == "REC_FAKE_SAME"], "Revised label")
})

test_that("a release between snapshots keeps entries that did not change", {
  skip_if_not_installed("xml2")
  skip_if_not_installed("digest")
  versions <- local_versions(fake_two_releases())

  out <- .srtr_dictionary_for("9902", versions, gaps = "nearest")

  expect_equal(out$basis, "interpolated")
  expect_equal(out$snapshot, NA_character_)
  expect_contains(out$dictionary$Variable, "REC_FAKE_SAME")
  expect_equal(nrow(out$formats), 1)
})

test_that("entries present on only one side of a gap need the file's columns", {
  skip_if_not_installed("xml2")
  skip_if_not_installed("digest")
  versions <- local_versions(fake_two_releases())

  without <- .srtr_dictionary_for("9902", versions, columns = "REC_FAKE_SAME", file_key = "TX_KI")
  with_old <- .srtr_dictionary_for("9902", versions, columns = c("REC_FAKE_SAME", "REC_FAKE_OLD"))
  with_new <- .srtr_dictionary_for("9902", versions, columns = c("REC_FAKE_SAME", "REC_FAKE_NEW"))

  expect_equal(intersect(without$dictionary$Variable, c("REC_FAKE_OLD", "REC_FAKE_NEW")), character())
  expect_contains(with_old$dictionary$Variable, "REC_FAKE_OLD")
  expect_equal(with_old$dictionary$Label[with_old$dictionary$Variable == "REC_FAKE_OLD"], "Old only")
  expect_contains(with_new$dictionary$Variable, "REC_FAKE_NEW")
})

test_that("an entry that changed across a gap is reported", {
  skip_if_not_installed("xml2")
  skip_if_not_installed("digest")
  versions <- local_versions(fake_two_releases())

  expect_warning(
    warned <- .srtr_dictionary_for("9902", versions, columns = "REC_FAKE_CHANGED"),
    class = "sRtr_warning_dictionary_gap"
  )
  expect_equal(
    warned$dictionary$Label[warned$dictionary$Variable == "REC_FAKE_CHANGED"],
    "Old label"
  )
  expect_snapshot(
    out <- .srtr_dictionary_for("9902", versions, columns = "REC_FAKE_CHANGED")
  )
  expect_error(
    .srtr_dictionary_for("9902", versions, columns = "REC_FAKE_CHANGED", gaps = "error"),
    class = "sRtr_error_dictionary_gap"
  )
  expect_no_warning(
    .srtr_dictionary_for("9902", versions, columns = "REC_FAKE_CHANGED", gaps = "nearest")
  )
})

test_that("a release outside the stored snapshots uses the nearest one, with a warning", {
  skip_if_not_installed("xml2")
  skip_if_not_installed("digest")
  versions <- local_versions(fake_two_releases())

  expect_warning(
    newer <- .srtr_dictionary_for("9912", versions),
    class = "sRtr_warning_release_outside_snapshots"
  )
  expect_equal(newer$snapshot, "9904-1")
  expect_warning(
    older <- .srtr_dictionary_for("9812", versions),
    class = "sRtr_warning_release_outside_snapshots"
  )
  expect_equal(older$snapshot, "9901-1")
  expect_snapshot(out <- .srtr_dictionary_for("9912", versions))
})

test_that("no release gives the bundled dictionary and formats", {
  out <- .srtr_dictionary_for(NULL)

  expect_equal(out$basis, "default")
  expect_identical(out$dictionary, sRtr::dictionary)
  expect_identical(out$formats, sRtr::formats)
})

test_that("a release must be four digits naming a year and month", {
  expect_error(.srtr_dictionary_for("26"), class = "sRtr_error_invalid_release")
  expect_error(.srtr_dictionary_for("2613"), class = "sRtr_error_invalid_release")
  expect_snapshot(.srtr_dictionary_for("26"), error = TRUE)
})

test_that("the release is read from a pubsafYYMM folder name", {
  expect_equal(.srtr_release_from_path("/data/pubsaf2303"), "2303")
  expect_equal(.srtr_release_from_path("/data/PUBSAF2609/SAS"), "2609")
  expect_equal(.srtr_release_from_path("C:/Data/pubsaf2303"), "2303")
  expect_equal(.srtr_release_from_path("/data/saf_files"), NA_character_)
  expect_equal(.srtr_release_from_path("/data/pubsaf2313"), NA_character_)
  expect_equal(.srtr_release_from_path("/data/mypubsaf2303x"), NA_character_)
})

test_that("set_srtr_wd() records a release, given or from the folder name", {
  withr::local_envvar(SRTR_WD = NA)
  root <- withr::local_tempdir()
  named <- file.path(root, "pubsaf2303")
  plain <- file.path(root, "saf_files")
  dir.create(named)
  dir.create(plain)

  set_srtr_wd(named)
  expect_equal(.srtr_current_release(), list(release = "2303", basis = "folder name"))

  set_srtr_wd(plain, release = "2609")
  expect_equal(.srtr_current_release(), list(release = "2609", basis = "supplied"))

  set_srtr_wd(plain)
  expect_equal(.srtr_current_release(), list(release = NA_character_, basis = "none"))

  expect_warning(
    set_srtr_wd(named, release = "2609"),
    class = "sRtr_warning_release_conflict"
  )
  expect_equal(.srtr_current_release(), list(release = "2609", basis = "supplied"))
})

test_that("load_srtr_file() records the release and dictionary it used", {
  skip_if_not_installed("xml2")
  skip_if_not_installed("digest")
  versions <- local_versions(fake_two_releases())
  local_mocked_bindings(.srtr_bundled_versions = function() versions)
  withr::local_envvar(SRTR_WD = NA)
  dir <- file.path(withr::local_tempdir(), "pubsaf9904")
  dir.create(dir)
  withr::local_options(lifecycle_verbosity = "quiet")
  haven::write_sas(
    data.frame(REC_FAKE_NEW = "x", REC_FAKE_SAME = "y"),
    file.path(dir, "TX_KI.sas7bdat")
  )
  set_srtr_wd(dir)

  out <- load_srtr_file("TX_KI", column_check = "none")

  expect_equal(
    attr(out, "srtr_release"),
    list(release = "9904", dictionary = "9904-1", basis = "folder name")
  )
  expect_equal(labelled::var_label(out$REC_FAKE_NEW), "New only")

  override <- load_srtr_file("TX_KI", column_check = "none", release = "9901")
  expect_equal(attr(override, "srtr_release")$dictionary, "9901-1")
  expect_equal(.srtr_current_release()$release, "9904")
})

test_that("variable labels use the release given to them", {
  skip_if_not_installed("xml2")
  skip_if_not_installed("digest")
  versions <- local_versions(fake_two_releases())
  local_mocked_bindings(.srtr_bundled_versions = function() versions)
  df <- tibble::tibble(REC_FAKE_CHANGED = "x")

  old <- apply_srtr_varlabels(df, file_key = "TX_KI", release = "9901")
  new <- apply_srtr_varlabels(df, file_key = "TX_KI", release = "9904")

  expect_equal(labelled::var_label(old$REC_FAKE_CHANGED), "Old label")
  expect_equal(labelled::var_label(new$REC_FAKE_CHANGED), "New label")
})

test_that("srtr_dictionary() returns a release's table and says where it came from", {
  skip_if_not_installed("xml2")
  skip_if_not_installed("digest")
  versions <- local_versions(fake_two_releases())
  local_mocked_bindings(.srtr_bundled_versions = function() versions)

  dict <- srtr_dictionary("9904")
  fmt <- srtr_dictionary("9904", table = "formats")

  expect_equal(dict$Variable, c("REC_FAKE_CHANGED", "REC_FAKE_NEW", "REC_FAKE_SAME"))
  expect_equal(attr(dict, "snapshot"), "9904-1")
  expect_equal(attr(dict, "basis"), "observed")
  expect_equal(fmt$Code, "1")
  expect_equal(attr(srtr_dictionary(), "basis"), "default")
})

test_that("gaps = 'error' is applied even after a lenient load of the same file", {
  skip_if_not_installed("xml2")
  skip_if_not_installed("digest")
  versions <- local_versions(fake_two_releases())
  local_mocked_bindings(.srtr_bundled_versions = function() versions)
  withr::local_envvar(SRTR_WD = NA)
  dir <- file.path(withr::local_tempdir(), "pubsaf9902")
  dir.create(dir)
  withr::local_options(lifecycle_verbosity = "quiet")
  haven::write_sas(
    data.frame(REC_FAKE_CHANGED = "x", REC_FAKE_SAME = "y"),
    file.path(dir, "TX_KI.sas7bdat")
  )
  set_srtr_wd(dir)

  expect_no_warning(load_srtr_file("TX_KI", column_check = "none", gaps = "nearest"))
  expect_error(
    load_srtr_file("TX_KI", column_check = "none", gaps = "error"),
    class = "sRtr_error_dictionary_gap"
  )
  expect_no_warning(
    load_srtr_file("TX_KI", column_check = "none", gaps = "nearest", col_select = "REC_FAKE_CHANGED")
  )
})

test_that("a release between snapshots uses the latest revision of the earlier one", {
  skip_if_not_installed("xml2")
  skip_if_not_installed("digest")
  pages <- fake_two_releases()
  revised <- pages[[1]]
  revised$data$TX_KI$Label[1] <- "Revised old label"
  versions <- local_versions(list(pages[[1]], revised, pages[[2]]))

  out <- .srtr_dictionary_for(
    "9902", versions, columns = "REC_FAKE_CHANGED", file_key = "TX_KI", gaps = "nearest"
  )

  expect_equal(
    out$dictionary$Label[out$dictionary$Variable == "REC_FAKE_CHANGED"],
    "Revised old label"
  )
})

test_that("srtr_dictionary() keeps a variable that changed between versions and reports it", {
  skip_if_not_installed("xml2")
  skip_if_not_installed("digest")
  versions <- local_versions(fake_two_releases())
  local_mocked_bindings(.srtr_bundled_versions = function() versions)

  expect_warning(
    dict <- srtr_dictionary("9902"),
    class = "sRtr_warning_dictionary_gap"
  )
  expect_equal(dict$Variable, c("REC_FAKE_CHANGED", "REC_FAKE_SAME"))
  expect_equal(dict$Label[1], "Old label")
  expect_error(srtr_dictionary("9902", gaps = "error"), class = "sRtr_error_dictionary_gap")
})

test_that("factors use the release given to them", {
  skip_if_not_installed("xml2")
  skip_if_not_installed("digest")
  pages <- fake_two_releases()
  pages[[1]]$data$TX_KI$FormatID <- c("FAKEFMT", "", "")
  pages[[2]]$data$TX_KI$FormatID <- c("", "", "")
  versions <- local_versions(pages)
  local_mocked_bindings(.srtr_bundled_versions = function() versions)
  df <- tibble::tibble(REC_FAKE_CHANGED = "1")

  old <- apply_srtr_factors(df, file_key = "TX_KI", release = "9901")
  new <- apply_srtr_factors(df, file_key = "TX_KI", release = "9904")

  expect_equal(as.character(old$REC_FAKE_CHANGED), "1: Meaning 1")
  expect_equal(new$REC_FAKE_CHANGED, "1")
})
