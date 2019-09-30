
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

### Domain and Access Tokens

By default the canvas domain and token are looked for in the environment
variables `CANVAS_DOMAIN` and `CANVAS_API_TOKEN`. You can read about
setting these in `?cnvas_whoami`. Alternatively, one can set the
`.token` and `.api_endpoint` arguments of `cnvs()`.

## Usage

``` r
library(cnvs)
```

Use the `cnvs()` function to access all API endpoints. The endpoints are
listed in the
[documentation](https://canvas.instructure.com/doc/api/index.html).

The first argument of `cnvs()` is the endpoint. Note that the leading
`/api/v1/` must be included as well, but this facilitates copy and
pasting direct from the documentation. Parameters can be passed as extra
arguments. E.g.

``` r
my_courses <- cnvs("/api/v1/courses", enrollment_type = "teacher")
vapply(my_courses, "[[", "", "name")
#>  [1] "DATA VISUALIZATION (ST_537_400_S2017)"           
#>  [2] "DATA VISUALIZATION (ST_537_400_S2018)"           
#>  [3] "DATA VISUALIZATION (ST_537_400_S2019)"           
#>  [4] "DATA VISUALIZATION (ST_537_400_S2020)"           
#>  [5] "FOUNDATIONS OF DATA ANALYTICS (ST_516_400_F2016)"
#>  [6] "FOUNDATIONS OF DATA ANALYTICS (ST_516_400_F2017)"
#>  [7] "FOUNDATIONS OF DATA ANALYTICS (ST_516_400_F2018)"
#>  [8] "FOUNDATIONS OF DATA ANALYTICS (ST_516_400_F2019)"
#>  [9] "INTERNSHIP (ST_410_001_W2015)"                   
#> [10] "INTERNSHIP (ST_410_001_W2016)"
```

The JSON result sent by the API is converted to an R object.

If the end point itself has parameters, these can also be passed as
extra arguments:

``` r
vis_modules <- cnvs("/api/v1/courses/:course_id/modules", 
  course_id = 1724191)
vapply(vis_modules, "[[", "", "name")
#>  [1] "Start Here - Introduction"                                  
#>  [2] "Week 1 - The good and bad of graphics & Describing graphics"
#>  [3] "Week 2 - Deconstructing and constructing graphics"          
#>  [4] "Week 3 - Perception"                                        
#>  [5] "Week 4 - Color and Scales"                                  
#>  [6] "Week 5 - Principles of tidy data"                           
#>  [7] "Week 6 - Data manipulation"                                 
#>  [8] "Week 7 - Exploration"                                       
#>  [9] "Module 8: Special topics"                                   
#> [10] "Module 9: Interactive and dynamic visualization"
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
