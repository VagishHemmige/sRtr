# Run only through run.sh decisions. Observation, not an approved API contract.
local({
  dir <- withr::local_tempdir()
  withr::local_envvar(SRTR_WD = dir)
  x <- data.frame(FAKE_SOURCE = "SYNTHETIC SAS")
  suppressWarnings(haven::write_sas(x, file.path(dir, "AUDIT.sas7bdat")))
  x$FAKE_SOURCE <- "SYNTHETIC PARQUET"
  arrow::write_parquet(x, file.path(dir, "AUDIT.parquet"))
  result <- tryCatch(sRtr::load_srtr_file("AUDIT", factor_labels = FALSE,
    var_labels = FALSE), error = identity)
  if (inherits(result, "error")) {
    cat("Duplicate key: error:", conditionMessage(result), "\n")
  } else {
    cat("Duplicate key selected:", result$FAKE_SOURCE, "\n")
  }
  cat("DECISION PENDING: reject ambiguity, document format precedence with a",
      "message, or require an explicit selection. No pass/fail policy asserted.\n")
})
