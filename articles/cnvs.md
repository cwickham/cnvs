# Getting started with cnvs

``` r
library(cnvs)
library(purrr)
library(dplyr)
```

## Credentials

To use the API to Canvas you need an access token. Access tokens are
specific to your user account and Canvas domain. Your Canvas domain,
`CANVAS_DOMAIN`, is the URL of your institution’s Canvas instance,
e.g. <https://oregonstate.instructure.com> or the instance provided by
Instructure <https://canvas.instructure.com/>.

You can request an access token at: `{CANVAS_DOMAIN}/profile/settings`,
under “Approved Integrations:”. Once generated, your token is only
visible once so make sure you copy it.

To verify your token and domain, pass them to the `.token` and
`.api_url` arguments of
[`cnvs_whoami()`](https://cwickham.github.io/cnvs/reference/cnvs_whoami.md):

``` r
cnvs_whoami(
  .token = "your-token-here",
  .api_url = "https://canvas.instructure.com"
)
```

The result should be successful and include your name and login id:

      "name": "Charlotte Wickham",
      "login_id": "cwickham@gmail.com",
      "domain": "https://canvas.instructure.com",
      "token": "yo..."

It is convenient to set environment variables to store your domain and
token. cnvs looks for these in `CANVAS_DOMAIN` and `CANVAS_API_TOKEN`
respectively. The easiest way to set them is to edit your `.Renviron`
file:

``` r
# install.packages("usethis")
usethis::edit_r_environ()
```

Add lines like these substituting in your own domain and token:

    CANVAS_DOMAIN="https://canvas.instructure.com"
    CANVAS_API_TOKEN="your-token-here"

Make sure your `.Renviron` file ends with an empty line.

Restart R and check by running
[`cnvs_whoami()`](https://cwickham.github.io/cnvs/reference/cnvs_whoami.md)
with no arguments:

``` r
cnvs_whoami()
```

``` default
{
  "name": "Charlotte Wickham",
  "login_id": "116595056272912288897",
  "domain": "https://canvas.instructure.com",
  "token": "7~JU...mQac"
}
```

## Finding your courses

The default
[`cnvs()`](https://cwickham.github.io/cnvs/reference/cnvs.md) endpoint
is `/api/v1/courses` which lists all your courses:

``` r
cnvs()
```

It’s easier to work with this data if you extract the course names and
IDs into a tibble:

``` r
cnvs() |> map(\(x) tibble(id = x$id, name = x$name)) |> list_rbind()
```

You can also find your course ID by visiting your course in Canvas and
examining the URL:

    https://canvas.instructure.com/courses/1732420

Your course ID comes right after `/courses/`, e.g. 1732420 in this case.

For the examples below, I’ll use a `course_id` from one of my courses —
you’ll need to substitute your own:

``` r
course_id <- 14337283
```

## Making queries

To make a query to the Canvas LMS API use the
[`cnvs()`](https://cwickham.github.io/cnvs/reference/cnvs.md) function.
The first argument is the API endpoint.
[`cnvs()`](https://cwickham.github.io/cnvs/reference/cnvs.md) is
designed to make it as easy as possible to copy and paste from the
[Canvas API documentation](https://canvas.instructure.com/doc/api/)
(also available at
[developerdocs.instructure.com](https://developerdocs.instructure.com/services/canvas)).

As an example, imagine you want to see the discussion topics in your
course. Your first step is to find this task in the Canvas API docs — it
is listed under the Discussions resource as [List discussion
topics](https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics.index).
There are two endpoints listed there:

> GET /api/v1/courses/:course_id/discussion_topics

> GET /api/v1/groups/:group_id/discussion_topics

The first will list topics in a course and the second in a group — you
want the first. Parts of the endpoint that are prefaced with a colon,
`:`, are parameters, e.g. `:course_id` and `:group_id`. You will need to
provide these parameters to
[`cnvs()`](https://cwickham.github.io/cnvs/reference/cnvs.md) as named
arguments (minus the `:`).

To make the query, copy and paste the endpoint to the first argument of
[`cnvs()`](https://cwickham.github.io/cnvs/reference/cnvs.md), then add
arguments for any parameters in the endpoint:

``` r
discussions <- cnvs(
  "GET /api/v1/courses/:course_id/discussion_topics",
  course_id = course_id
)
```

## Parsing responses

[`cnvs()`](https://cwickham.github.io/cnvs/reference/cnvs.md) returns a
list, but prints this list as JSON. You can access components as you
would elements in a list:

``` r
discussions[[1]]$title
```

Functions for parsing the results are beyond the scope of cnvs, but you
can parse them yourself using iteration functions from purrr. For
example, we could look at all the topic titles:

``` r
discussions |>
  map_chr("title")
```

Or squeeze the entire response into a tibble:

``` r
discussions |>
  map(\(x) {
    x |>
      compact() |> # remove NULLs
      map_if(is.list, list) |> # push nested lists down one level
      as_tibble()
  }) |>
  list_rbind()
```

## Passing parameters to the endpoint

The Canvas API docs also describe parameters that can be passed in the
body of a query to each endpoint in the “Parameters” section. You can
add these as additional named arguments to
[`cnvs()`](https://cwickham.github.io/cnvs/reference/cnvs.md). For
example, for [List discussion
topics](https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics.index)
a possible parameter is `only_announcements`, a boolean, that controls
whether only announcements are returned. You could add this to the call
the [`cnvs()`](https://cwickham.github.io/cnvs/reference/cnvs.md) as
another argument:

``` r
announcements <- cnvs(
  "GET /api/v1/courses/:course_id/discussion_topics",
  course_id = course_id,
  only_announcements = TRUE
)
announcements |>
  map_chr("title")
```

Some parameters expect a more complicated object, for example the
parameters to [create a
module](https://canvas.instructure.com/doc/api/modules.html#method.context_modules_api.create),
include:

> `module[name]` `module[unlock_at]` `module[position]`

This notation, a parameter name followed by another in square brackets,
indicates a hierarchical structure. Canvas is expecting the `module`
parameter to be a JSON object. In
[`cnvs()`](https://cwickham.github.io/cnvs/reference/cnvs.md) this
translates to a named list, e.g.:

``` r
new_module <- cnvs(
  "POST /api/v1/courses/:course_id/modules",
  course_id = course_id,
  module = list(
    name = "First module",
    unlock_at = "2019-09-01T6:59:00Z",
    position = 1
  )
)
```

If the square brackets are empty, Canvas is expecting a JSON array,
which translates to an unnamed list in
[`cnvs()`](https://cwickham.github.io/cnvs/reference/cnvs.md). An
example of this structure is the `quiz_extensions` parameter to [set
quiz
extensions](https://canvas.instructure.com/doc/api/quiz_extensions.html#method.quizzes/quiz_extensions.create),
e.g.

> `quiz_extensions[][user_id]` `quiz_extensions[][extra_attempts]`

``` r
quiz_ext <- cnvs(
  "POST /api/v1/courses/:course_id/quizzes/:quiz_id/extensions",
  course_id = course_id,
  quiz_id = 62851823,
  quiz_extensions = list(
    list(
      user_id = 99999,
      extra_attempts = 1
    ),
    list(
      user_id = 99998,
      extra_attempts = 2
    )
  )
)
```

## Uploading files

To upload files use the
[`cnvs_upload()`](https://cwickham.github.io/cnvs/reference/cnvs_upload.md)
function. You need to locate the endpoint for the required context of
the file. E.g. To [upload a course
file](https://canvas.instructure.com/doc/api/courses.html#method.courses.create_file)
the endpoint is:

    POST /api/v1/courses/:course_id/files

Whereas to [upload a file as a
submission](https://canvas.instructure.com/doc/api/submissions.html#method.submissions_api.create_file)
the endpoint is:

    POST /api/v1/courses/:course_id/assignments/:assignment_id/submissions/:user_id/files

Pass the path to the file you wish to upload to
[`cnvs_upload()`](https://cwickham.github.io/cnvs/reference/cnvs_upload.md):

``` r
uploaded <- cnvs_upload(
  temp_file,
  course_id = course_id,
  parent_folder_path = "handouts/"
)
```

The default endpoint uploads to a course. Like
[`cnvs()`](https://cwickham.github.io/cnvs/reference/cnvs.md) you can
specify endpoint parameters like `course_id`, or request body parameters
like `parent_folder_path`, as additional arguments.
