
skip_if_offline <- (function() {
  domain <- Sys.getenv("CANVAS_TESTING_DOMAIN", NA_character_)
  if (is.na(domain) ){
    skip("No Canvas domain")
  }
  offline <- NA
  function() {
    if (is.na(offline)) {
      offline <<- tryCatch(
        is.na(pingr::ping_port(domain, count = 1, timeout = 1)),
        error = function(e) TRUE
      )
    }
    if (offline) skip("Offline")
  }
})()

skip_if_no_token <- function() {
  if (is.na(Sys.getenv("CANVAS_TESTING_TOKEN", NA_character_))) {
    skip("No Canvas token")
  }
}
