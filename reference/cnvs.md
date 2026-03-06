# Query the Canvas LMS API

This is an extremely minimal client. You need to know the API to be able
to use this client. All this function does is:

- Try to substitute each listed parameter into `endpoint`, using the
  `{parameter}` or `:parameter` notation.

- If a GET request (the default), then add all other listed parameters
  as query parameters.

- If not a GET request, then send the other parameters in the request
  body, as JSON.

- Convert the response to an R list using
  [`jsonlite::fromJSON()`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html).

## Usage

``` r
cnvs(
  endpoint = "/api/v1/courses",
  ...,
  per_page = NULL,
  .per_page = NULL,
  .token = NULL,
  .destfile = NULL,
  .overwrite = FALSE,
  .api_url = NULL,
  .method = "GET",
  .limit = NULL,
  .accept = "application/json",
  .send_headers = NULL,
  .progress = TRUE,
  .params = list(),
  .max_wait = 600,
  .max_rate = NULL
)
```

## Arguments

- endpoint:

  Canvas API endpoint. Defaults to `/api/v1/courses` which lists your
  courses. Must be one of the following forms:

  - `METHOD path`, e.g. `GET /api/v1/courses`,

  - `path`, e.g. `/api/v1/courses`,

  - `METHOD url`, e.g.
    `GET https://canvas.instructure.com/api/v1/courses`,

  - `url`, e.g. `https://canvas.instructure.com/api/v1/courses`.

  If the method is not supplied, will use `.method`, which defaults to
  `"GET"`.

- ...:

  Name-value pairs giving API parameters. Will be matched into
  `endpoint` placeholders, sent as query parameters in GET requests, and
  as a JSON body of POST requests. If there is only one unnamed
  parameter, and it is a raw vector, then it will not be JSON encoded,
  but sent as raw data, as is. This can be used for example to add
  assets to releases. Named `NULL` values are silently dropped. For GET
  requests, named `NA` values trigger an error. For other methods, named
  `NA` values are included in the body of the request, as JSON `null`.

- per_page, .per_page:

  Number of items to return per page. If omitted, will be substituted by
  `max(.limit, 100)` if `.limit` is set, otherwise determined by the API
  (never greater than 100).

- .token:

  Authentication token. Defaults to
  [`cnvs_token()`](https://cwickham.github.io/cnvs/reference/cnvs_token.md).

- .destfile:

  Path to write response to disk. If `NULL` (default), response will be
  processed and returned as an object. If path is given, response will
  be written to disk in the form sent. cnvs writes the response to a
  temporary file, and renames that file to `.destfile` after the request
  was successful. The name of the temporary file is created by adding a
  `-<random>.cnvs-tmp` suffix to it, where `<random>` is an ASCII string
  with random characters. cnvs removes the temporary file on error.

- .overwrite:

  If `.destfile` is provided, whether to overwrite an existing file.
  Defaults to `FALSE`. If an error happens the original file is kept.

- .api_url:

  Canvas domain URL. Used if `endpoint` just contains a path. Defaults
  to `CANVAS_DOMAIN` environment variable if set.

- .method:

  HTTP method to use if not explicitly supplied in the `endpoint`.

- .limit:

  Number of records to return. This can be used instead of manual
  pagination. By default it is `NULL`, which means that the defaults of
  the Canvas API are used. You can set it to a number to request more
  (or less) records, and also to `Inf` to request all records. Note,
  that if you request many records, then multiple Canvas API calls are
  used to get them, and this can take a potentially long time.

- .accept:

  The value of the `Accept` HTTP header. Defaults to
  `"application/json"`. If `Accept` is given in `.send_headers`, then
  that will be used.

- .send_headers:

  Named character vector of header field values (except `Authorization`,
  which is handled via `.token`). This can be used to override or
  augment the default `User-Agent` header:
  `"https://github.com/cwickham/cnvs"`.

- .progress:

  Whether to show a progress indicator for calls that need more than one
  HTTP request.

- .params:

  Additional list of parameters to append to `...`. It is easier to use
  this than `...` if you have your parameters in a list already.

- .max_wait:

  Maximum number of seconds to wait if rate limited. Defaults to 10
  minutes.

- .max_rate:

  Maximum request rate in requests per second. Set this to automatically
  throttle requests.

## Value

Answer from the API as a `cnvs_response` object, which is also a `list`.
Failed requests will generate an R error. Requests that generate a raw
response will return a raw vector.

## See also

[`cnvs_whoami()`](https://cwickham.github.io/cnvs/reference/cnvs_whoami.md)
for details on Canvas API token management,
[`cnvs_upload()`](https://cwickham.github.io/cnvs/reference/cnvs_upload.md)
for uploading files to Canvas.

## Examples

``` r
if (FALSE) { # \dontrun{
## List your courses
cnvs("/api/v1/courses")

## Get a specific course
cnvs("/api/v1/courses/{course_id}", course_id = 123456)

## Same thing with :param syntax
cnvs("/api/v1/courses/:course_id", course_id = 123456)

## List assignments for a course
cnvs("/api/v1/courses/{course_id}/assignments", course_id = 123456)

## Create an assignment
cnvs(
  "POST /api/v1/courses/{course_id}/assignments",
  course_id = 123456,
  assignment = list(
    name = "Homework 1",
    points_possible = 10
  )
)

## Automatic pagination - get all students
students <- cnvs(
  "/api/v1/courses/{course_id}/users",
  course_id = 123456,
  enrollment_type = "student",
  .limit = Inf
)
} # }

```
