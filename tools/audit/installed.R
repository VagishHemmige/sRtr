Sys.setenv(SRTR_LIVE_TESTS = "false")
Sys.unsetenv("SRTR_WD")
.libPaths(c(Sys.getenv("SRTR_AUDIT_LIBRARY"), .libPaths()))
stopifnot(!"package:sRtr" %in% search())
# No library(sRtr), data(), load_all() or namespace injection: ordinary :: use.
x <- tibble::tibble(CAN_ABO = "A")
failures <- 0L
for (fun in c("apply_srtr_factors", "apply_srtr_varlabels")) {
  tryCatch({
    y <- getExportedValue("sRtr", fun)(x, file_key = "TX_KI")
    if (fun == "apply_srtr_factors") {
      stopifnot(identical(as.character(y$CAN_ABO), "A: A"))
    } else {
      stopifnot(is.character(labelled::var_label(y$CAN_ABO)),
                nzchar(labelled::var_label(y$CAN_ABO)))
    }
    cat(fun, "PASS\n")
  }, error = function(e) {
    failures <<- failures + 1L
    cat(fun, "FAIL:", conditionMessage(e), "\n")
  })
}
stopifnot(!"package:sRtr" %in% search())
quit(status = as.integer(failures > 0L))
