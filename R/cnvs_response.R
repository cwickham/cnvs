cnvs_process_response <- function(resp, cnvs_req) {
  stopifnot(inherits(resp, "httr2_response"))

  content_type <- httr2::resp_content_type(resp)

  is_raw <- identical(content_type, "application/octet-stream")
  is_ondisk <- inherits(resp$body, "httr2_path") && !is.null(cnvs_req$dest)
  is_empty <- length(resp$body) == 0

  if (is_ondisk) {
    res <- as.character(resp$body)
    file.rename(res, cnvs_req$dest)
    res <- cnvs_req$dest
  } else if (is_empty) {
    res <- list()
  } else if (grepl("^application/json", content_type, ignore.case = TRUE)) {
    res <- httr2::resp_body_json(resp)
  } else if (is_raw) {
    res <- httr2::resp_body_raw(resp)
  } else {
    if (grepl("^text/html", content_type, ignore.case = TRUE)) {
      warning("Response came back as html :(", call. = FALSE)
    }
    res <- list(message = httr2::resp_body_string(resp))
  }

  attr(res, "response") <- httr2::resp_headers(resp)
  attr(res, "request") <- remove_headers(cnvs_req)

  if (is_ondisk) {
    class(res) <- c("cnvs_response", "path")
  } else if (is_raw) {
    class(res) <- c("cnvs_response", "raw")
  } else {
    class(res) <- c("cnvs_response", "list")
  }
  res
}

remove_headers <- function(x) {
  x[names(x) != "headers"]
}

# Add vctrs methods that strip attributes from cnvs_response when combining,
# enabling rectangling via unnesting etc
# See <https://github.com/cwickham/cnvs/issues/161> for more details
#' @exportS3Method vctrs::vec_ptype2
vec_ptype2.cnvs_response.cnvs_response <- function(x, y, ...) {
  list()
}

#' @exportS3Method vctrs::vec_cast
vec_cast.list.cnvs_response <- function(x, to, ...) {
  attributes(x) <- NULL
  x
}
