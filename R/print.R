
#' Print the result of a Canvas API call
#'
#' @param x The result object.
#' @param ... Ignored.
#' @return The JSON result.
#'
#' @importFrom jsonlite prettify toJSON
#' @export
#' @method print cnvs_response

print.cnvs_response <- function(x, ...) {
  if (inherits(x, c("raw", "path"))) {
    attr(x, c("method")) <- NULL
    attr(x, c("response")) <- NULL
    attr(x, ".send_headers") <- NULL
    print.default(x)
  } else {
    print(toJSON(unclass(x), pretty = TRUE, auto_unbox = TRUE))
  }
}
