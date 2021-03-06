
## Headers to send with each API request
default_send_headers <- c("Accept" = "application/json",
                          "User-Agent" = "https://github.com/cwickham/cnvs",
                          "Content-Type" = "application/json")

gh_build_request <- function(endpoint = "/api/v1/courses", params = list(),
                             token = NULL, destfile = NULL, overwrite = NULL,
                             send_headers = NULL,
                             api_url = NULL, method = "GET") {

  working <- list(method = method, url = character(), headers = NULL,
                  query = NULL, body = NULL,
                  endpoint = endpoint, params = params,
                  token = token, send_headers = send_headers, api_url = api_url,
                  dest = destfile, overwrite = overwrite)

  working <- gh_set_verb(working)
  working <- gh_set_endpoint(working)
  working <- gh_set_query(working)
  working <- gh_set_body(working)
  working <- gh_set_headers(working)
  working <- gh_set_url(working)
  working <- gh_set_dest(working)
  working[c("method", "url", "headers", "query", "body", "dest")]

}


## gh_set_*(x)
## x = a list in which we build up an httr request
## x goes in, x comes out, possibly modified

gh_set_verb <- function(x) {
  if (!nzchar(x$endpoint)) return(x)

  # No method defined, so use default
  if (grepl("^/", x$endpoint) || grepl("^http", x$endpoint)) {
    return(x)
  }

  x$method <- gsub("^([^/ ]+)\\s+.*$", "\\1", x$endpoint)
  stopifnot(x$method %in% c("GET", "POST", "PATCH", "PUT", "DELETE"))
  x$endpoint <- gsub("^[A-Z]+ ", "", x$endpoint)
  x
}

gh_set_endpoint <- function(x) {
  params <- x$params
  if (!grepl(":", x$endpoint) || length(params) == 0L || has_no_names(params)) {
    return(x)
  }

  named_params <- which(has_name(params))
  done <- rep_len(FALSE, length(params))
  endpoint <- endpoint2 <- x$endpoint

  for (i in named_params) {
    n <- names(params)[i]
    p <- params[[i]][1]
    endpoint2 <- gsub(paste0(":", n, "\\b"), p, endpoint)
    if (endpoint2 != endpoint) {
      endpoint <- endpoint2
      done[i] <- TRUE
    }
  }

  x$endpoint <- endpoint
  x$params <- x$params[!done]
  x$params <- cleanse_names(x$params)
  x

}

gh_set_query <- function(x) {
  params <- x$params
  if (x$method != "GET" || length(params) == 0L) {
    return(x)
  }
  stopifnot(all(has_name(params)))
  x$query <- params
  x$params <- NULL
  x
}

gh_set_body <- function(x) {
  if (length(x$params) == 0L) return(x)
  if (x$method == "GET") {
    warning("This is a 'GET' request and unnamed parameters are being ignored.")
    return(x)
  }
  x$body <- toJSON(x$params, auto_unbox = TRUE)
  x
}

gh_set_headers <- function(x) {
  auth <- cnvs_auth(x$token %||% cnvs_token())
  send_headers <- gh_send_headers(x$send_headers)
  x$headers <- c(send_headers, auth)
  x
}

gh_set_url <- function(x) {
  if (grepl("^https?://", x$endpoint)) {
    x$url <- URLencode(x$endpoint)
  } else {
    api_url <- x$api_url %||% cnvs_domain()
    x$url <- URLencode(paste0(api_url, x$endpoint))
  }

  x
}

#' @importFrom httr write_disk write_memory
gh_set_dest <- function(x) {
  if (is.null(x$dest)) {
    x$dest <- write_memory()
  } else {
    x$dest <- write_disk(x$dest, overwrite = x$overwrite)
  }
  x
}

## functions to retrieve request elements
## possibly consult an env var or combine with a built-in default

#' Return the local user's Canvas token and domain
#'
#' You will need a Canvas access token, which you can get by following the instructions here:
#'  <https://canvas.instructure.com/doc/api/file.oauth.html#manual-token-generation>
#'
#' Canvas access tokens are specific to your user account on a specific
#' canvas domain, e.g. you cannot use the token for your University's site on
#' the instructure site (<https://canvas.instructure.com>).
#'
#' Currently, it consults the `CANVAS_API_TOKEN` and `CANVAS_DOMAIN`
#' environment variables. Read more about setting these in \code{\link{cnvs_whoami}}.
#'
#' @return A string, with the token, or a zero length string scalar,
#' if no token or domain is available.
#'
#' @export

cnvs_token <- function() {
  token <- Sys.getenv("CANVAS_API_TOKEN", "")
  if (isTRUE(token == "")) {
    stop("No personal access token (PAT) available.\n",
      "Obtain a PAT from here:\n",
      cnvs_domain(), "/profile/settings\n",
      "For more on what to do with the PAT, see ?cnvs_whoami.",
      call. = FALSE)
    return(invisible(NULL))
  }
  token
}

#' @rdname cnvs_token
#' @export
cnvs_domain <- function() {
  domain <- Sys.getenv("CANVAS_DOMAIN", "")
  if (isTRUE(domain == "")) {
    stop("No Canvas domain available.\n",
      "Either set the environment variable CANVAS_DOMAIN, \n",
      "or, pass the argument `.api_url`.\n",
      "For more info see ?cnvs_whoami.", call. = FALSE)
  }
  domain
}

cnvs_auth <- function(token) {
  if (isTRUE(token != "")) {
    c("Authorization" = paste("Bearer", token))
  } else {
    character()
  }
}

gh_send_headers <- function(headers = NULL) {
  modify_vector(default_send_headers, headers)
}
