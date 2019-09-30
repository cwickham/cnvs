
skip_if_offline <- (function() {
  offline <- NA
  function() {
    if (is.na(offline)) {
      offline <<- tryCatch(
        is.na(pingr::ping_port("instructure.com", count = 1, timeout = 1)),
        error = function(e) TRUE
      )
    }
    if (offline) skip("Offline")
  }
})()

skip_if_no_token <- function() {
  if (is.na(Sys.getenv("CANVAS_TESTING", NA_character_))) {
    skip("No Canvas token")
  }
}
