#' Plot STROBE Derivation Diagram
#'
#' Creates a STROBE flow diagram from the filtering log recorded via
#' `strobe_initialize()` and `strobe_filter()`. The main inclusion path flows
#' top-to-bottom, and exclusions are drawn as horizontal arrows pointing to
#' dashed boxes to the right, originating from the connecting lines.
#'
#' @param export_file Optional file path (e.g., "diagram.png" or "diagram.svg") to save the diagram.
#' @param incl_width Width of inclusion boxes in inches. If NULL, auto-sizes to content.
#' @param incl_height Height of inclusion boxes in inches. If NULL, auto-sizes to content.
#' @param excl_width Width of exclusion boxes in inches. If NULL, auto-sizes to content.
#' @param excl_height Height of exclusion boxes in inches. If NULL, auto-sizes to content.
#' @param incl_fontsize Font size for inclusion box text (default 14).
#' @param excl_fontsize Font size for exclusion box text (default 12).
#'
#' @return The DiagrammeR graph object.
#' @export
plot_strobe_diagram <- function(export_file = NULL,
                                incl_width = 3, incl_height = NULL,
                                excl_width = 2.5, excl_height = NULL,
                                incl_fontsize = 14, excl_fontsize = 12) {
  if (is.null(.srtr_env$strobe_df) || nrow(.srtr_env$strobe_df) == 0) {
    stop("No STROBE log found. Run strobe_initialize() and at least one strobe_filter() step.")
  }
  df <- .srtr_env$strobe_df

  # Inclusion node labels
  incl_labels <- paste0(df$inclusion_label, "\n(n = ", df$remaining, ")")

  # Exclusion nodes (dashed side boxes)
  excl_idx <- which(!is.na(df$exclusion_reason))
  excl_labels <- if (length(excl_idx) > 0) {
    paste0(df$exclusion_reason[excl_idx], "\n(n = ", df$dropped[excl_idx], ")")
  } else {
    character(0)
  }

  # Build DOT code directly for proper STROBE layout
  dot_code <- paste0(
    "digraph strobe {\n",
    "  rankdir=TB;\n",
    "  ranksep=1.5;\n",
    "  nodesep=3;\n",
    "  node [fontname=Helvetica];\n",
    "  edge [fontname=Helvetica];\n",
    "  \n"
  )

  # Add inclusion nodes
  for (i in 1:nrow(df)) {
    # Build size attributes
    size_attrs <- ""
    if (!is.null(incl_width)) {
      size_attrs <- paste0(size_attrs, "width=", incl_width, ", ")
    }
    if (!is.null(incl_height)) {
      size_attrs <- paste0(size_attrs, "height=", incl_height, ", ")
    }
    if (!is.null(incl_width) && !is.null(incl_height)) {
      size_attrs <- paste0(size_attrs, "fixedsize=true, ")
    }

    dot_code <- paste0(dot_code,
                       "  incl", i, " [label=\"", gsub("\"", "\\\"", incl_labels[i]), "\", ",
                       "shape=box, style=solid, fontsize=", incl_fontsize, ", ",
                       size_attrs, "margin=0.2];\n"
    )
  }

  # Add exclusion nodes
  if (length(excl_idx) > 0) {
    for (i in seq_along(excl_idx)) {
      # Build size attributes
      size_attrs <- ""
      if (!is.null(excl_width)) {
        size_attrs <- paste0(size_attrs, "width=", excl_width, ", ")
      }
      if (!is.null(excl_height)) {
        size_attrs <- paste0(size_attrs, "height=", excl_height, ", ")
      }
      if (!is.null(excl_width) && !is.null(excl_height)) {
        size_attrs <- paste0(size_attrs, "fixedsize=true, ")
      }

      dot_code <- paste0(dot_code,
                         "  excl", i, " [label=\"", gsub("\"", "\\\"", excl_labels[i]), "\", ",
                         "shape=box, style=dashed, fontsize=", excl_fontsize, ", ",
                         size_attrs, "margin=0.2];\n"
      )
    }
  }

  # Add invisible nodes at midpoints for exclusion arrows
  if (length(excl_idx) > 0) {
    for (i in seq_along(excl_idx)) {
      dot_code <- paste0(dot_code,
                         "  mid", i, " [shape=point, style=invis, width=0, height=0];\n"
      )
    }
  }

  dot_code <- paste0(dot_code, "\n")

  # Add inclusion edges and midpoint connections
  excl_counter <- 1

  # Process each row to create edges
  for (i in 1:nrow(df)) {
    if (!is.na(df$parent[i])) {
      # Find the parent node index
      parent_row <- which(df$id == df$parent[i])
      child_row <- i

      # Check if this transition has an exclusion
      has_exclusion <- child_row %in% excl_idx

      if (has_exclusion) {
        # Split the edge: parent -> midpoint -> child
        dot_code <- paste0(dot_code,
                           "  incl", parent_row, " -> mid", excl_counter, " [arrowhead=none, color=black];\n",
                           "  mid", excl_counter, " -> incl", child_row, " [arrowhead=normal, color=black];\n"
        )

        # Add rank constraint to keep midpoint and exclusion box aligned
        dot_code <- paste0(dot_code,
                           "  {rank=same; mid", excl_counter, "; excl", excl_counter, ";}\n"
        )

        # Add exclusion arrow from midpoint to exclusion box
        dot_code <- paste0(dot_code,
                           "  mid", excl_counter, " -> excl", excl_counter,
                           " [arrowhead=normal, color=gray40];\n"
        )

        excl_counter <- excl_counter + 1
      } else {
        # Normal inclusion edge
        dot_code <- paste0(dot_code,
                           "  incl", parent_row, " -> incl", child_row,
                           " [arrowhead=normal, color=black];\n"
        )
      }
    }
  }

  dot_code <- paste0(dot_code, "}\n")

  # Optional export
  if (!is.null(export_file)) {
    # Create the graph object for export
    g <- DiagrammeR::grViz(dot_code)

    ext <- tools::file_ext(export_file)
    if (!requireNamespace("DiagrammeRsvg", quietly = TRUE) ||
        !requireNamespace("rsvg", quietly = TRUE)) {
      stop("To export the diagram, install both DiagrammeRsvg and rsvg packages.")
    }
    svg <- DiagrammeRsvg::export_svg(g)
    raw <- charToRaw(svg)
    if (tolower(ext) == "png") {
      rsvg::rsvg_png(raw, file = export_file)
    } else if (tolower(ext) == "svg") {
      writeLines(svg, con = export_file)
    } else {
      stop("Unsupported export format. Use .png or .svg.")
    }
  }

  # Render and display the diagram (must be last for printing)
  DiagrammeR::grViz(dot_code)
}
