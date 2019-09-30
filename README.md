
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cnvs

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
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

### Getting started

``` r
library(cnvs)
```

To use the the API to Canvas you need an access token. Access tokens are
specific to your user account and Canvas domain. Your Canvas domain,
`CANVAS_DOMAIN`, is the URL of your institution’s Canvas instance,
e.g. <https://oregonstate.instructure.com> or, the instance provided by
Instructure <https://canvas.instructure.com/>.

You can request an access token at: `{CANVAS_DOMAIN}/profile/settings`,
under “Approved Integrations:”. Once generated, your token is only
visible once so make sure you copy it.

To verify your token and domain, pass them to the `.token()` and
`.api_endpoint` arguments of
`cnvs_whoami()`:

``` r
cnvs_whoami(.token = "mvvGbKyGK9n5T57qhEu8K1sNMt85OLoNGTepqd3v5NEcWMuxArSz5aaXppPjodr5eU",
           .api_url = "https://canvas.instructure.com")
```

The result should be successful and include your name and login id:

``` r
  "name": "Charlotte Wickham",
  "login_id": "cwickham@gmail.com",
  "domain": "https://canvas.instructure.com",
  "token": "mv..."
```

It is convenient to set environment variables to store your domain and
token. cnvs looks for these in `CANVAS_DOMAIN` and `CANVAS_API_TOKEN`
respectively. The easiest way to set them is to edit your `.Renviron`
file:

``` r
# install.pacakges("usethis")
usethis::edit_r_environ()
```

Add lines like these substituting in your own domain and token:

    CANVAS_DOMAIN="https://canvas.instructure.com"
    CANVAS_API_TOKEN= "mvvGbKyGK9n5T57qhEu8K1sNMt85OLoNGTepqd3v5NEcWMuxArSz5aaXppPjodr5eU"

Restart R and check by running `cnvs_whoami()` with no arguments:

``` r
cnvs_whoami()
```

``` r
  "name": "Charlotte Wickham",
  "login_id": "cwickham@gmail.com",
  "domain": "https://canvas.instructure.com",
  "token": "mv..."
```

## Usage

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
```

The JSON result sent by the API is converted to an R object.

If the end point itself has parameters, these can also be passed as
extra arguments:

``` r
vis_modules <- cnvs("/api/v1/courses/:course_id/modules", 
  course_id = 946353)
vapply(vis_modules, "[[", "", "name")
#> [1] "Start Here - Introduction"                        
#> [2] "Week 1 - Bad graphics & Describing graphics"      
#> [3] "Week 2 - Deconstructing and constructing graphics"
#> [4] "Week 3 - Perception"                              
#> [5] "Week 4 - Color and Scales"                        
#> [6] "Week 5 - Practice"                                
#> [7] "Week 6"
```

### POST, PATCH, PUT and DELETE requests

**Not yet tested**

POST, PATCH, PUT, and DELETE requests can be sent by including the HTTP
verb before the endpoint, in the first argument. E.g. to create a
repository:

``` r
new_repo <- gh("POST /user/repos", name = "my-new-repo-for-gh-testing")
```

and then delete it:

``` r
gh("DELETE /repos/:owner/:repo", owner = "gaborcsardi",
   repo = "my-new-repo-for-gh-testing")
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
