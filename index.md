# cnvs

Minimalistic client to access the [Canvas LMS
API](https://canvas.instructure.com/doc/api/index.html). Heavily
borrowing from the infrastructure of [gh](https://github.com/r-lib/gh)

## Philosophy

cnvs is intentionally minimalist. To use it, you will need to become
familiar with the [Canvas API
documentation](https://canvas.instructure.com/doc/api/index.html). cnvs
does no checking on the endpoints you provide, nor the objects you pass.
This has the advantage that cnvs is not dependent on the specifics of
the Canvas API. cnvs also does no parsing of response content, you will
need to extract the desired information from the returned lists
yourself.

While cnvs does facilitate the automation of repetitive tasks in Canvas
from R, it still requires a fair bit of expertise from the user. The
hope is to use it as a foundation for a higher level api package, that
is more user-friendly.

## Installation

Install the package from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("cwickham/cnvs")
```

## Usage

``` r
library(cnvs)
```

Use the [`cnvs()`](https://cwickham.github.io/cnvs/reference/cnvs.md)
function to access all API endpoints. The endpoints are listed in the
[documentation](https://canvas.instructure.com/doc/api/index.html).

The first argument of
[`cnvs()`](https://cwickham.github.io/cnvs/reference/cnvs.md) is the
endpoint. Note that the leading `/api/v1/` must be included as well, but
this facilitates copy and pasting directly from the documentation.
Parameters can be passed as extra arguments. E.g.

``` r
my_courses <- cnvs("/api/v1/courses", enrollment_type = "teacher")
vapply(my_courses, "[[", "", "name")
```

``` R
[1] "Test Course"
```

The JSON result sent by the API is converted to an R object.

If the end point itself has parameters, these can also be passed as
extra arguments:

``` r
test_modules <- cnvs("/api/v1/courses/:course_id/modules",
  course_id = 14337283)
vapply(test_modules, "[[", "", "name")
```

``` R
[1] "First module" "First module" "First module" "First module" "First module"
```

### POST, PATCH, PUT and DELETE requests

POST, PUT, and DELETE requests can be sent by including the HTTP verb
before the endpoint, in the first argument. For example, to create a
module:

``` r
new_module <- cnvs("POST /api/v1/courses/:course_id/modules",
  course_id = 14337283,  # set a parameter in the endpoint `:course_id`
  module = list(        # a parameter sent in the body
    name = "First module",
    position = 1
  )
)
```

``` r
test_modules <- cnvs("/api/v1/courses/:course_id/modules",
  course_id = 14337283)
vapply(test_modules, "[[", "", "name")
```

``` R
[1] "First module" "First module" "First module" "First module" "First module"
[6] "First module"
```

Then update the name of the module:

``` r
update_module <- cnvs("PUT /api/v1/courses/:course_id/modules/:id",
  course_id = 14337283,
  id = new_module$id,
  module = list(
    name = "Module 1"
  )
)
```

``` r
test_modules <- cnvs("/api/v1/courses/:course_id/modules",
  course_id = 14337283)
vapply(test_modules, "[[", "", "name")
```

``` R
[1] "Module 1"     "First module" "First module" "First module" "First module"
[6] "First module"
```

Then, finally, delete the module:

``` r
cnvs("DELETE /api/v1/courses/:course_id/modules/:id",
  course_id = 14337283,
  id = new_module$id
)
```

``` R
{
  "id": 22583369,
  "position": 1,
  "name": "Module 1",
  "unlock_at": {},
  "require_sequential_progress": false,
  "requirement_type": "all",
  "publish_final_grade": false,
  "prerequisite_module_ids": [],
  "published": false,
  "items_count": 0,
  "items_url": "https://canvas.instructure.com/api/v1/courses/14337283/modules/22583369/items"
} 
```

``` r
test_modules <- cnvs("/api/v1/courses/:course_id/modules",
  course_id = 14337283)
vapply(test_modules, "[[", "", "name")
```

``` R
[1] "First module" "First module" "First module" "First module" "First module"
```

### Pagination

Supply the `page` parameter to get subsequent pages:

``` r
my_courses2 <- cnvs("/api/v1/courses", enrollment_type = "teacher",
  page = 2)
vapply(my_courses2, "[[", "", "name")
```

## License

cnvs: MIT © Charlotte Wickham

The code is mostly minor edits to the [gh](https://github.com/r-lib/gh)
package:

gh: MIT © Gábor Csárdi, Jennifer Bryan, Hadley Wickham
