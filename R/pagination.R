
extract_link <- function(gh_response, link) {
  headers <- attr(gh_response, "response")
  links <- headers$link
  if (is.null(links)) {
    return(NA_character_)
  }
  links <- trim_ws(strsplit(links, ",")[[1]])
  link_list <- lapply(links, function(x) {
    x <- trim_ws(strsplit(x, ";")[[1]])
    name <- sub("^.*\"(.*)\".*$", "\\1", x[2])
    value <- sub("^<(.*)>$", "\\1", x[1])
    c(name, value)
  })
  link_list <- structure(
    vapply(link_list, "[", "", 2),
    names = vapply(link_list, "[", "", 1)
  )

  if (link %in% names(link_list)) {
    link_list[[link]]
  } else {
    NA_character_
  }
}

gh_has <- function(gh_response, link) {
  url <- extract_link(gh_response, link)
  !is.na(url)
}

gh_has_next <- function(gh_response) {
  gh_has(gh_response, "next")
}

gh_link_request <- function(gh_response, link) {

  stopifnot(inherits(gh_response, "gh_response"))

  url <- extract_link(gh_response, link)
  if (is.na(url)) throw(new_error("No ", link, " page"))

  list(method = attr(gh_response, "method"),
       url = url,
       headers = attr(gh_response, ".send_headers"))

}

gh_link <- function(gh_response, link) {
  req <- gh_link_request(gh_response, link)
  raw <- gh_make_request(req)
  gh_process_response(raw)
}

#' Get the next, previous, first or last page of results
#'
#' @details
#' Note that these are not always defined. E.g. if the first
#' page was queried (the default), then there are no first and previous
#' pages defined. If there is no next page, then there is no
#' next page defined, etc.
#'
#' If the requested page does not exist, an error is thrown.
#'
#' @param response An object returned by a \code{cnvs()} call.
#' @return Answer from the API.
#'
#' @seealso The `.limit` argument to [cnvs()] supports fetching more than
#'   one page.
#'
#' @name cnvs_next
#' @export
#' @examples
#' \dontrun{
#' x <- cnvs()
#' sapply(x, "[[", "login")
#' x2 <- cnvs_next(x)
#' sapply(x2, "[[", "login")
#' }

cnvs_next <- function(response) gh_link(response, "next")

#' @name cnvs_next
#' @export

cnvs_prev <- function(response) gh_link(response, "prev")

#' @name cnvs_next
#' @export

cnvs_first <- function(response) gh_link(response, "first")

#' @name cnvs_next
#' @export

cnvs_last <- function(response) gh_link(response, "last")
