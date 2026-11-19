# Check the navbar menus against the article index, after pkgdown has built
# the site into docs/. Run from the package root:
#   Rscript tools/check-site-navbar.R
# Fails if an article listed under `articles:` in _pkgdown.yml is in no navbar
# menu, if a menu links to a page that was not built, or if a menu links to an
# anchor that the page does not have.

`%||%` <- function(x, y) if (is.null(x)) y else x

config <- yaml::read_yaml("_pkgdown.yml")
site <- "docs"

menu_links <- unlist(lapply(config$navbar$components, function(component) {
  vapply(component$menu %||% list(), function(item) item$href %||% NA_character_,
         character(1))
}))
menu_links <- menu_links[!is.na(menu_links) & !grepl("^https?://", menu_links)]

article_pages <- unlist(lapply(config$articles, function(group) {
  paste0("articles/", basename(group$contents), ".html")
}))

problems <- character()

missing_from_menus <- setdiff(article_pages, sub("#.*$", "", menu_links))
if (length(missing_from_menus) > 0) {
  problems <- c(problems, paste("Article in no navbar menu:", missing_from_menus))
}

for (link in unique(menu_links)) {
  page <- sub("#.*$", "", link)
  path <- file.path(site, page)
  if (!file.exists(path)) {
    problems <- c(problems, paste("Navbar link to a page that was not built:", link))
    next
  }
  if (grepl("#", link, fixed = TRUE)) {
    anchor <- sub("^[^#]*#", "", link)
    html <- paste(readLines(path, warn = FALSE), collapse = "\n")
    if (!grepl(paste0('id="', anchor, '"'), html, fixed = TRUE)) {
      problems <- c(problems, paste("Navbar link to a missing anchor:", link))
    }
  }
}

if (length(problems) > 0) {
  writeLines(problems)
  stop(length(problems), " navbar problem(s); see above.", call. = FALSE)
}
cat("Navbar check passed:", length(unique(menu_links)), "links,",
    length(article_pages), "articles.\n")
