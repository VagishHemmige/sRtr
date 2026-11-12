test_that(".srtr_as_date() works without lubridate attached", {
  expect_false("package:lubridate" %in% search())

  out <- .srtr_as_date(c("2001-02-03", "", "99999999"))

  expect_s3_class(out, "Date")
  expect_equal(out, as.Date(c("2001-02-03", NA, NA)))
})
