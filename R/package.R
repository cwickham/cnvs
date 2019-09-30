
#' Canvas LMS API
#'
#' Minimal wrapper to access the Canvas LMS API.
#'
#' @docType package
#' @name cnvs
NULL

#' Query the Canvas LMS API
#'
#' This is an extremely minimal client. You need to know the API
#' to be able to use this client. All this function does is:
#' \itemize{
#'   \item Try to substitute each listed parameter into
#'     \code{endpoint}, using the \code{:parameter} notation.
#'   \item If a GET request (the default), then add
#'     all other listed parameters as query parameters.
#'   \item If not a GET request, then send the other parameters
#'     in the request body, as JSON.
#'   \item Convert the response to an R list using
#'     \code{jsonlite::fromJSON}.
#' }
#'
#' @param endpoint Canvas LMS API endpoint. Must be one of the following forms:
#'
#'    \itemize{
#'      \item "METHOD path", e.g. "GET /api/v1/courses"
#'      \item "path", e.g. "/api/v1/courses".
#'      \item "METHOD url", e.g. "GET https://canvas.instructure.com/api/v1/courses"
#'      \item "url", e.g. "https://canvas.instructure.com/api/v1/courses".
#'    }
#'
#'    If the method is not supplied, will use \code{.method}, which defaults
#'    to \code{GET}.
#' @param ... Name-value pairs giving API parameters. Will be matched
#'   into \code{url} placeholders, sent as query parameters in \code{GET}
#'   requests, and in the JSON body of \code{POST} requests.
#' @param per_page Number of items to return per page. If omitted,
#'   will be substituted by `max(.limit, 100)` if `.limit` is set,
#'   otherwise determined by the API (never greater than 100).
#' @param .destfile path to write response to disk.  If NULL (default), response will
#'   be processed and returned as an object.  If path is given, response will
#'   be written to disk in the form sent.
#' @param .overwrite if \code{destfile} is provided, whether to overwrite an
#'   existing file.  Defaults to FALSE.
#' @param .token Authentication token. Defaults to CANVAS_API_TOKEN
#'   environment variable, if set.
#' @param .api_url Canvas domain. Used
#'   if \code{endpoint} just contains a path. Defaults to CANVAS_DOMAIN
#'   environment variable, if set.
#' @param .method HTTP method to use if not explicitly supplied in the
#'    \code{endpoint}.
#' @param .limit Number of records to return. This can be used
#'   instead of manual pagination. By default it is \code{NULL},
#'   which means that the defaults of the Canvas API are used.
#'   You can set it to a number to request more (or less)
#'   records, and also to \code{Inf} to request all records.
#'   Note, that if you request many records, then multiple Canva
#'   API calls are used to get them, and this can take a potentially
#'   long time.
#' @param .send_headers Named character vector of header field values
#'   (excepting \code{Authorization}, which is handled via
#'   \code{.token}). This can be used to override or augment the
#'   defaults, which are as follows: the \code{Accept} field defaults
#'   to \code{"application/json"} and the
#'   \code{User-Agent} field defaults to
#'   \code{"https://github.com/cwickham/cnvs"}. This can be used
#'   to, e.g., provide a custom media type, in order to access a
#'   preview feature of the API.
#'
#' @return Answer from the API as a \code{gh_response} object, which is also a
#'   \code{list}. Failed requests will generate an R error. Requests that
#'   generate a raw response will return a raw vector.
#'
#' @importFrom httr content add_headers headers
#'   status_code http_type GET POST PATCH PUT DELETE
#' @importFrom jsonlite fromJSON toJSON
#' @importFrom utils URLencode capture.output
#' @export
#' @seealso \code{\link{cnvs_whoami}()} for details on Canvas API token
#'   management.
#' @examples
#' \dontrun{
#' ## Your courses
#' cnvs("/api/v1/courses")
#' }
#'

cnvs <- function(endpoint, ..., per_page = NULL, .token = NULL, .destfile = NULL,
               .overwrite = FALSE, .api_url = NULL, .method = "GET",
               .limit = NULL, .send_headers = NULL
               ) {

  params <- list(...)

  if (is.null(per_page)) {
    if (!is.null(.limit)) {
      per_page <- max(min(.limit, 100), 1)
    }
  }

  if (!is.null(per_page)) {
    params <- c(params, list(per_page = per_page))
  }

  req <- gh_build_request(endpoint = endpoint, params = params,
                          token = .token, destfile = .destfile,
                          overwrite = .overwrite,
                          send_headers = .send_headers,
                          api_url = .api_url, method = .method)

  raw <- gh_make_request(req)

  res <- gh_process_response(raw)

  while (!is.null(.limit) && length(res) < .limit && gh_has_next(res)) {
    res2 <- gh_next(res)
    res3 <- c(res, res2)
    attributes(res3) <- attributes(res2)
    res <- res3
  }

  if (! is.null(.limit) && length(res) > .limit) {
    res_attr <- attributes(res)
    res <- res[seq_len(.limit)]
    attributes(res) <- res_attr
  }

  res
}

gh_make_request <- function(x) {

  method_fun <- list("GET" = GET, "POST" = POST, "PATCH" = PATCH,
                     "PUT" = PUT, "DELETE" = DELETE)[[x$method]]
  if (is.null(method_fun)) throw(new_error("Unknown HTTP verb"))

  raw <- do.call(method_fun,
                 compact(list(url = x$url, query = x$query, body = x$body,
                              add_headers(x$headers), x$dest)))
  raw
}
