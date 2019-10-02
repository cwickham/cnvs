context("build_request")

test_that("all forms of specifying endpoint are equivalent", {
  r1 <- gh_build_request("GET /courses", api_url = "https://canvas.instructure.com/api/v1",
    token = "")
  expect_equal(r1$method, "GET")
  expect_equal(r1$url, "https://canvas.instructure.com/api/v1/courses")

  expect_equal(gh_build_request("/courses", api_url = "https://canvas.instructure.com/api/v1", token = ""), r1)
  expect_equal(gh_build_request("GET https://canvas.instructure.com/api/v1/courses", token = ""), r1)
  expect_equal(gh_build_request("https://canvas.instructure.com/api/v1/courses", token = ""), r1)
})

test_that("method arg sets default method", {
  r <- gh_build_request("/courses", method = "POST", token = "",
    api_url = "https://canvas.instructure.com/api/v1")
  expect_equal(r$method, "POST")
})

test_that("parameter substitution is equivalent to direct specification", {
  subst <-
    gh_build_request("POST /repos/:org/:repo/issues/:number/labels",
      params = list(org = "ORG", repo = "REPO", number = "1",
                    "body"),
      token = "",
      api_url = "https://canvas.instructure.com/api/v1")
  spec <-
    gh_build_request("POST /repos/ORG/REPO/issues/1/labels",
      params = list("body"),
      token = "",
      api_url = "https://canvas.instructure.com/api/v1")
  expect_identical(subst, spec)
})
