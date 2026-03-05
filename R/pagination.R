extract_link <- function(cnvs_response, link) {
  headers <- attr(cnvs_response, "response")
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

cnvs_has <- function(cnvs_response, link) {
  url <- extract_link(cnvs_response, link)
  !is.na(url)
}

cnvs_has_next <- function(cnvs_response) {
  cnvs_has(cnvs_response, "next")
}

cnvs_link_request <- function(cnvs_response, link, .token, .send_headers) {
  stopifnot(inherits(cnvs_response, "cnvs_response"))

  url <- extract_link(cnvs_response, link)
  if (is.na(url)) cli::cli_abort("No {link} page")

  req <- attr(cnvs_response, "request")
  req$url <- url
  req$token <- .token
  req$send_headers <- .send_headers
  req <- cnvs_set_headers(req)
  req
}

cnvs_link <- function(cnvs_response, link, .token, .send_headers) {
  req <- cnvs_link_request(cnvs_response, link, .token, .send_headers)
  raw <- cnvs_make_request(req)
  cnvs_process_response(raw, req)
}

cnvs_extract_pages <- function(cnvs_response) {
  last <- extract_link(cnvs_response, "last")
  if (!is.na(last)) {
    as.integer(httr2::url_parse(last)$query$page)
  } else {
    NA
  }
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
#' @param cnvs_response An object returned by a [cnvs()] call.
#' @inheritParams cnvs
#' @return Answer from the API.
#'
#' @seealso The `.limit` argument to [cnvs()] supports fetching more than
#'   one page.
#'
#' @name cnvs_next
#' @export
#' @examples
#' \dontrun{
#' x <- cnvs("/api/v1/courses")
#' x2 <- cnvs_next(x)
#' }
cnvs_next <- function(cnvs_response, .token = NULL, .send_headers = NULL) {
  cnvs_link(cnvs_response, "next", .token = .token, .send_headers = .send_headers)
}

#' @name cnvs_next
#' @export

cnvs_prev <- function(cnvs_response, .token = NULL, .send_headers = NULL) {
  cnvs_link(cnvs_response, "prev", .token = .token, .send_headers = .send_headers)
}

#' @name cnvs_next
#' @export

cnvs_first <- function(cnvs_response, .token = NULL, .send_headers = NULL) {
  cnvs_link(cnvs_response, "first", .token = .token, .send_headers = .send_headers)
}

#' @name cnvs_next
#' @export

cnvs_last <- function(cnvs_response, .token = NULL, .send_headers = NULL) {
  cnvs_link(cnvs_response, "last", .token = .token, .send_headers = .send_headers)
}
