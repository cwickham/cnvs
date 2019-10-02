context("test-package")

test_that("GET requests work", {
  skip_if_offline()
  skip_if_no_token()
  skip_on_cran()

  req <- cnvs(.token = tt(), .api_url = td())
  expect_s3_class(req, "cnvs_response")
  }
)

test_that("POST, PUT and DELETE requests work on module", {
  skip_if_offline()
  skip_if_no_token()
  skip_on_cran()

  test_course <- 1732420
  create <- cnvs("POST /api/v1/courses/:course_id/modules",
    course_id = test_course,
    module = list(
      name = "First module",
      position = 1
    ), .token = tt(), .api_url = td())
  update <- cnvs("PUT /api/v1/courses/:course_id/modules/:id",
    course_id = 1732420,
    id = create$id,
    module = list(
      name = "Module 1"
    ),
    .token = tt(), .api_url = td()
  )
  delete <- cnvs("DELETE /api/v1/courses/:course_id/modules/:id",
    course_id = test_course,
    id = create$id,
    .token = tt(), .api_url = td())
  expect_s3_class(create, "cnvs_response")
  expect_s3_class(update, "cnvs_response")
  expect_s3_class(delete, "cnvs_response")

  expect_equal(create$name, "First module")
  expect_equal(update$name, "Module 1")
  expect_equal(create$id, update$id)
  }
)

