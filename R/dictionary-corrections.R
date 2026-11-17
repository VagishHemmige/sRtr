# Corrections to SRTR's web data dictionary.
#
# The stored snapshots (`dictionary_versions`) and the bundled `dictionary`
# stay exact copies of SRTR's web page. Corrections are applied on top, when
# a dictionary is resolved for a release (`.srtr_enforce_release()`), unless
# the caller asks for `view = "web"`.
#
# Each row changes one field of one dictionary entry:
#   id        stable ID, recorded on results that used the correction
#   Dataset, Variable
#   field     the dictionary column changed
#   from      the value SRTR's dictionary is expected to have
#   to        the corrected value
#   reason, evidence
# A correction is applied only when the entry still has `from`. If it already
# has `to` (SRTR fixed it), it is skipped quietly; any other value, or a
# target format that does not exist, is left alone with a warning. A test
# checks every `from` against the latest stored snapshot.
#
# Codes seen in data but in no format are not corrections: they keep warning
# until a source documents their meaning.
.srtr_dictionary_corrections <- data.frame(
  id = "SRTR-DC-001",
  Dataset = c(
    "TX_HL", "TX_HR", "TX_IN", "TX_KI", "TX_KP", "TX_LI", "TX_LU", "TX_PA"
  ),
  Variable = "REC_COD",
  field = "FormatID",
  from = "THCOD",
  to = "COD",
  reason = paste(
    "REC_COD is given the thoracic cause-of-death format THCOD in every TX",
    "dataset, but liver recipients' codes are in COD. THCOD's 75 codes are",
    "all in COD with the same meanings (COD prefixes their labels with",
    "\"TH:\"), so COD loses no code. Applied to every TX dataset as a",
    "generalization; checked on real data for TX_LI only."
  ),
  evidence = paste(
    "SRTR web dictionary snapshots 2203-1 and 2609-1 (THCOD for REC_COD;",
    "THCOD contained in COD). Real 2303 TX_LI: about 89% of recorded REC_COD",
    "values are COD codes not in THCOD. Issue #191."
  )
)

# Applies `corrections` to resolved `tables` (a list with `dictionary` and
# `formats`) for `view = "corrected"`; `view = "web"` leaves them as SRTR
# published them. Adds `view` and `corrections` (the IDs applied) to the
# list.
.srtr_apply_corrections <- function(
  tables,
  view = "corrected",
  corrections = .srtr_dictionary_corrections
) {
  tables$view <- view
  tables$corrections <- character()
  if (view == "web") {
    return(tables)
  }
  dictionary <- tables$dictionary
  conflicts <- list()
  for (i in seq_len(nrow(corrections))) {
    row <- corrections[i, ]
    at <- which(
      dictionary$Dataset == row$Dataset & dictionary$Variable == row$Variable
    )
    if (length(at) == 0) {
      next
    }
    current <- unique(dictionary[[row$field]][at])
    if (identical(current, row$to)) {
      next
    }
    if (row$field == "FormatID" && !row$to %in% tables$formats$Format) {
      problem <- paste0("format ", row$to, " is not in this release's formats")
    } else if (!identical(current, row$from)) {
      problem <- paste0(
        "SRTR's dictionary has ", paste(current, collapse = ", "),
        ", not ", row$from, " as expected"
      )
    } else {
      dictionary[[row$field]][at] <- row$to
      tables$corrections <- union(tables$corrections, row$id)
      next
    }
    conflicts[[length(conflicts) + 1]] <- data.frame(
      id = row$id,
      entry = paste(row$Dataset, row$Variable),
      problem = problem
    )
  }
  if (length(conflicts) > 0) {
    .srtr_warn_correction_conflicts(do.call(rbind, conflicts))
  }
  tables$dictionary <- dictionary
  tables
}

# One warning for all corrections not applied, one bullet per correction ID
# and problem.
.srtr_warn_correction_conflicts <- function(conflicts) {
  groups <- split(conflicts, list(conflicts$id, conflicts$problem), drop = TRUE)
  bullets <- vapply(
    groups,
    function(g) {
      paste0(g$id[1], " (", paste(g$entry, collapse = ", "), "): ", g$problem[1], ".")
    },
    character(1)
  )
  ids <- unique(conflicts$id)
  srtr_warn(
    c(
      "{length(ids)} dictionary correction{?s} not applied; using SRTR's values.",
      stats::setNames(bullets, rep("*", length(bullets)))
    ),
    class = "dictionary_correction_conflict",
    ids = ids
  )
}

# The view recorded on `df` by load_srtr_file(), or "corrected".
.srtr_view_of <- function(df) {
  view <- attr(df, "srtr_release")$view
  if (is.null(view) || is.na(view)) "corrected" else view
}
