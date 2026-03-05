#' Return the local user's Canvas token and domain
#'
#' @description
#' `cnvs_token()` returns the Canvas API token from the `CANVAS_API_TOKEN`
#' environment variable. Most Canvas API requests require a token to prove
#' the request is authorized by a specific Canvas user.
#'
#' `cnvs_domain()` returns the Canvas domain URL from the `CANVAS_DOMAIN`
#' environment variable. This is your institution's Canvas URL, e.g.
#' `https://canvas.instructure.com` or `https://myuni.instructure.com`.
#'
#' You can generate a token from your Canvas profile settings page at
#' `{CANVAS_DOMAIN}/profile/settings` under "Approved Integrations".
#'
#' See [cnvs_whoami()] for more details on setting up your credentials.
#'
#' @return A string. For `cnvs_token()`, the return value has an S3 class
#'   to ensure that simple printing strategies don't reveal the entire token.
#'   Both functions error if the corresponding environment variable is not set.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' cnvs_token()
#' cnvs_domain()
#'
#' format(cnvs_token())
#' }
cnvs_token <- function() {
  token <- Sys.getenv("CANVAS_API_TOKEN", unset = "")
  if (token == "") {
    cli::cli_abort(c(
      "No Canvas API token available.",
      "i" = "Set the {.envvar CANVAS_API_TOKEN} environment variable.",
      "i" = "Generate a token at {.path {CANVAS_DOMAIN}/profile/settings}",
      "i" = "See {.fun cnvs_whoami} for more information."
    ))
  }
  new_cnvs_token(token)
}

#' @export
#' @rdname cnvs_token
cnvs_token_exists <- function() {
  tryCatch(nzchar(cnvs_token()), error = function(e) FALSE)
}

#' @export
#' @rdname cnvs_token
cnvs_domain <- function() {
 domain <- Sys.getenv("CANVAS_DOMAIN", "")
 if (domain == "") {
   cli::cli_abort(c(
     "No Canvas domain available.",
     "i" = "Set the {.envvar CANVAS_DOMAIN} environment variable.",
     "i" = "See {.fun cnvs_whoami} for more information."
   ))
 }
 domain
}

cnvs_auth <- function(token) {
  if (isTRUE(token != "")) {
    c("Authorization" = paste("Bearer", trim_ws(token)))
  } else {
    character()
  }
}

# cnvs_token class: exists to have a print method that hides info ----
new_cnvs_token <- function(x) {
  if (is.character(x) && length(x) == 1) {
    structure(x, class = "cnvs_token")
  } else {
    cli::cli_abort("A Canvas token must be a string")
  }
}

#' @export
format.cnvs_token <- function(x, ...) {
  if (x == "") {
    "<no token>"
  } else {
    obfuscate(x)
  }
}

#' @export
print.cnvs_token <- function(x, ...) {
  cat(format(x), sep = "\n")
  invisible(x)
}

#' @export
str.cnvs_token <- function(object, ...) {
  cat(paste0("<cnvs_token> ", format(object), "\n", collapse = ""))
  invisible()
}

obfuscate <- function(x, first = 4, last = 4) {
  paste0(
    substr(x, start = 1, stop = first),
    "...",
    substr(x, start = nchar(x) - last + 1, stop = nchar(x))
  )
}
