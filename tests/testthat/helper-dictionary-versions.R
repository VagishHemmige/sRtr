# Builds a small, made-up page laid out like the SRTR SAF data dictionary,
# for testing the parser without the real page.
#
# `data`: named list, one element per dataset. Each element is a data frame
#   with columns Variable, Type, Length, FormatID and Label.
# `formats`: named list, one element per format. Each element is a data frame
#   with columns Code and Meaning.
# `data_file`: optional named character vector giving the "Data File:" text
#   for a dataset whose section id is cut short.
fake_dictionary_page <- function(
  release = "9901",
  data = list(),
  formats = list(),
  data_file = character(),
  title = paste("SRTR", release, "Public SAFs Data Dictionary")
) {
  cell <- function(x) {
    paste0('<td class="dataTableCell dataValue">', x, " </td>")
  }
  fmt_cell <- function(x) {
    if (!nzchar(x)) {
      return('<td class="c dataTableCell dataValue">  </td>')
    }
    paste0(
      '<td class="c dataTableCell dataValue"><a href="javascript:void(0);" ',
      "onclick=\"displayFmt('fmt_", x, "' );\">$", x, " </a></td>"
    )
  }
  data_divs <- vapply(
    names(data),
    function(ds) {
      vars <- data[[ds]]
      rows <- vapply(
        seq_len(nrow(vars)),
        function(i) {
          paste0(
            "<tr>",
            cell(vars$Variable[i]),
            cell(vars$Type[i]),
            cell(vars$Length[i]),
            fmt_cell(vars$FormatID[i]),
            cell(vars$Label[i]),
            "</tr>"
          )
        },
        character(1)
      )
      file_name <- if (ds %in% names(data_file)) data_file[[ds]] else ds
      paste0(
        '<div id="data_General_', ds, '" style="display: none">',
        '<table><tbody><tr><td class="sectionTitle">Data File: ',
        file_name, "</td></tr></tbody></table>",
        '<table class="dataTable"><thead><tr><th>Variable</th><th>Type</th>',
        "<th>Length</th><th>Format</th><th>Label</th></tr></thead><tbody>",
        paste(rows, collapse = ""),
        "</tbody></table></div>"
      )
    },
    character(1)
  )
  fmt_divs <- vapply(
    names(formats),
    function(fmt) {
      codes <- formats[[fmt]]
      rows <- vapply(
        seq_len(nrow(codes)),
        function(i) {
          paste0("<tr>", cell(codes$Code[i]), cell(codes$Meaning[i]), "</tr>")
        },
        character(1)
      )
      paste0(
        '<div id="fmt_', fmt, '" class="fmtDiv">',
        '<table><tbody><tr><td class="sectionTitle">Format: $', fmt,
        "</td></tr></tbody></table>",
        '<table class="dataTable"><thead><tr><th>Code</th>',
        "<th>Description</th></tr></thead><tbody>",
        paste(rows, collapse = ""),
        "</tbody></table></div>"
      )
    },
    character(1)
  )
  paste0(
    "<!doctype html><html><head><title>", title, "</title></head><body>",
    '<div id="grp_General">',
    paste(data_divs, collapse = ""),
    "</div>",
    paste(fmt_divs, collapse = ""),
    "</body></html>"
  )
}

local_dictionary_page <- function(..., env = parent.frame()) {
  path <- withr::local_tempfile(fileext = ".html", .local_envir = env)
  writeLines(fake_dictionary_page(...), path)
  path
}

fake_vars <- function(Variable, Type = "char", Length = "1", FormatID = "",
                      Label = paste("Label of", Variable)) {
  data.frame(
    Variable = Variable,
    Type = Type,
    Length = Length,
    FormatID = FormatID,
    Label = Label
  )
}

fake_codes <- function(Code, Meaning = paste0(Code, ": Meaning ", Code)) {
  data.frame(Code = Code, Meaning = Meaning)
}

# A snapshot table for the run functions: one row per entry.
fake_snapshot <- function(Variable, Label) {
  tibble::tibble(Dataset = "TX_KI", Variable = Variable, Label = Label)
}

# Replace each ASCII placeholder `word` in raw `bytes` with `with`.
.fake_replace_bytes <- function(bytes, word, with) {
  pattern <- charToRaw(word)
  n <- length(pattern)
  out <- raw()
  i <- 1L
  while (i <= length(bytes)) {
    if (i + n - 1L <= length(bytes) && identical(bytes[i:(i + n - 1L)], pattern)) {
      out <- c(out, with)
      i <- i + n
    } else {
      out <- c(out, bytes[i])
      i <- i + 1L
    }
  }
  out
}
