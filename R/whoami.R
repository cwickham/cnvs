#' Info on current Canvas user, domain and token
#'
#' Reports name and Canvas login ID for the current authenticated user, the
#' Canvas domain and the first bit of the token.
#'
#' Your canvas domain is the address of your organizations' canvas site, e.g.
#' \code{https://oregonstate.instructure.com/}, provide this to \code{.api_url}.
#'
#' Get a personal access token for your Canvas domain from
#' \code{\{CANVAS_DOMAIN/profile/settings\}}. The token itself is a string of 66
#' letters and digits. You can store it any way you like and provide explicitly
#' via the \code{.token} argument to \code{\link{cnvs}()}.
#'
#' However, many prefer to define an environments variable \code{CANVAS_API_TOKEN},
#' and \code{CANVAS_DOMAIN}, with these values in their \code{.Renviron} file. Add
#' lines that looks like these, substituting your domain and token:
#'
#' \preformatted{
#' CANVAS_DOMAIN="https://canvas.instructure.com"
#' CANVAS_API_TOKEN= "mvvGbKyGK9n5T57qhEu8K1sNMt85OLoNGTepqd3v5NEcWMuxArSz5aaXppPjodr5eU"
#' }
#'
#' Put a line break at the end! If you’re using an editor that shows line
#' numbers, there should be (at least) three lines, where the third one is empty.
#' Restart R for this to take effect. Call \code{cmvs_whoami()} to confirm
#' success.
#'
#' To get complete information on the authenticated user, call
#' \code{cnvs("/api/v1/user/self")}.
#'
#' @inheritParams cnvs
#'
#' @return A \code{cnvs_response} object, which is also a \code{list}.
#' @export
#'
#' @examples
#' \dontrun{
#' cnvs_whoami()
#'
#' ## explicit token + domain
#' cnvs_whoami(.token = "mvvGbKyGK9n5T57qhEu8K1sNMt85OLoNGTepqd3v5NEcWMuxArSz5aaXppPjodr5eU",
#'           .api_url = "https://canvas.instructure.com")
#' }
cnvs_whoami <- function(.token = NULL, .api_url = NULL, .send_headers = NULL) {
  .token <- .token %||% cnvs_token()
  .domain <- .api_url %||% cnvs_domain()

  res <- cnvs(endpoint = "/api/v1/users/self/profile", .token = .token,
            .api_url = .api_url, .send_headers = .send_headers)
  res <- res[c("name", "login_id")]
  res$domain <- .domain
  res$token <- obfuscate(.token)
  ## 'gh_response' class has to be restored
  class(res) <- c("cnvs_response", "list")
  res
}

obfuscate <- function(x, first = 2, last = 0) {
  paste0(substr(x, start = 1, stop = first),
         "...",
         substr(x, start = nchar(x) - last + 1, stop = nchar(x)))
}
