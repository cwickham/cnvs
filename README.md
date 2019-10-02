
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cnvs

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![{Travis build
status}](https://travis-ci.org/cwickham/cnvs.svg?branch=master)](https://travis-ci.org/cwickham/cnvs)
<!-- badges: end -->

> Canvas LMS API

Minimalistic client to access the [Canvas LMS
API](https://canvas.instructure.com/doc/api/index.html).

Heavily borrowing from the infrastructure of
[gh](https://github.com/r-lib/gh)

## Installation

Install the package from GitHub as usual:

``` r
# install.packages("remotes")
remotes::install_github("cwickham/cnvs")
```

## Usage

``` r
library(cnvs)
```

Use the `cnvs()` function to access all API endpoints. The endpoints are
listed in the
[documentation](https://canvas.instructure.com/doc/api/index.html).

The first argument of `cnvs()` is the endpoint. Note that the leading
`/api/v1/` must be included as well, but this facilitates copy and
pasting directly from the documentation. Parameters can be passed as
extra arguments. E.g.

``` r
my_courses <- cnvs("/api/v1/courses", enrollment_type = "teacher")
vapply(my_courses, "[[", "", "name")
#> [1] "ST499/599 Topics in Data Visualization"
#> [2] "ST505 for ST511"                       
#> [3] "ST511 Summer 2017"                     
#> [4] "Stat 499/599, Data Programming in R"   
#> [5] "Testing for cnvs"
```

The JSON result sent by the API is converted to an R object.

If the end point itself has parameters, these can also be passed as
extra arguments:

``` r
test_modules <- cnvs("/api/v1/courses/:course_id/modules", 
  course_id = 1732420)
vapply(test_modules, "[[", "", "name")
#> [1] "First module" "First module" "First module" "Test module" 
#> [5] "First module"
```

### POST, PATCH, PUT and DELETE requests

POST, PUT, and DELETE requests can be sent by including the HTTP verb
before the endpoint, in the first argument. For example, to create a
module:

``` r
new_module <- cnvs("POST /api/v1/courses/:course_id/modules",
  course_id = 1732420,  # set a parameter in the endpoint `:course_id`
  module = list(        # a parameter sent in the body
    name = "First module",
    position = 1
  )
)
```

``` r
test_modules <- cnvs("/api/v1/courses/:course_id/modules", 
  course_id = 1732420)
vapply(test_modules, "[[", "", "name")
#> [1] "First module" "First module" "First module" "First module"
#> [5] "Test module"  "First module"
```

Then update the name of the module:

``` r
update_module <- cnvs("PUT /api/v1/courses/:course_id/modules/:id",
  course_id = 1732420,
  id = new_module$id,
  module = list(
    name = "Module 1"
  )
)
```

``` r
test_modules <- cnvs("/api/v1/courses/:course_id/modules", 
  course_id = 1732420)
vapply(test_modules, "[[", "", "name")
#> [1] "Module 1"     "First module" "First module" "First module"
#> [5] "Test module"  "First module"
```

Then, finally, delete the module:

``` r
cnvs("DELETE /api/v1/courses/:course_id/modules/:id",
  course_id = 1732420,
  id = new_module$id
)
#> {
#>   "id": 3539256,
#>   "position": 1,
#>   "name": "Module 1",
#>   "unlock_at": {},
#>   "require_sequential_progress": false,
#>   "publish_final_grade": false,
#>   "prerequisite_module_ids": [],
#>   "published": false,
#>   "items_count": 0,
#>   "items_url": "https://canvas.instructure.com/api/v1/courses/1732420/modules/3539256/items"
#> }
```

``` r
test_modules <- cnvs("/api/v1/courses/:course_id/modules", 
  course_id = 1732420)
vapply(test_modules, "[[", "", "name")
#> [1] "First module" "First module" "First module" "Test module" 
#> [5] "First module"
```

### Uploading files

To upload files use the `cnvs_upload()` function. You need to locate the
endpoint for the required context of the file. E.g. To [upload a course
file](https://canvas.instructure.com/doc/api/courses.html#method.courses.create_file)
the endpoint is:

    POST /api/v1/courses/:course_id/files 

Whereas to [upload a file as an
submission](https://canvas.instructure.com/doc/api/submissions.html#method.submissions_api.create_file)
the endpoint
    is:

    POST /api/v1/courses/:course_id/assignments/:assignment_id/submissions/:user_id/files

Pass this endpoint to `cnvs_upload()` along with path to the file you
wish to upload:

``` r
cnvs_upload("/api/v1/courses/:course_id/files",
  path = "notes.pdf", course_id = "1732420", parent_folder_path = "handouts/")
```

Like `cnvs()` you can specify parameters in the endpoint, like
`course_id`, or parameters in the body of the request like
`parent_folder_path` as additional arguments.

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
