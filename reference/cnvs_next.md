# Get the next, previous, first or last page of results

Get the next, previous, first or last page of results

## Usage

``` r
cnvs_next(cnvs_response, .token = NULL, .send_headers = NULL)

cnvs_prev(cnvs_response, .token = NULL, .send_headers = NULL)

cnvs_first(cnvs_response, .token = NULL, .send_headers = NULL)

cnvs_last(cnvs_response, .token = NULL, .send_headers = NULL)
```

## Arguments

- cnvs_response:

  An object returned by a
  [`cnvs()`](https://cwickham.github.io/cnvs/reference/cnvs.md) call.

- .token:

  Authentication token. Defaults to
  [`cnvs_token()`](https://cwickham.github.io/cnvs/reference/cnvs_token.md).

- .send_headers:

  Named character vector of header field values (except `Authorization`,
  which is handled via `.token`). This can be used to override or
  augment the default `User-Agent` header:
  `"https://github.com/cwickham/cnvs"`.

## Value

Answer from the API.

## Details

Note that these are not always defined. E.g. if the first page was
queried (the default), then there are no first and previous pages
defined. If there is no next page, then there is no next page defined,
etc.

If the requested page does not exist, an error is thrown.

## See also

The `.limit` argument to
[`cnvs()`](https://cwickham.github.io/cnvs/reference/cnvs.md) supports
fetching more than one page.

## Examples

``` r
if (FALSE) { # \dontrun{
x <- cnvs("/api/v1/courses")
x2 <- cnvs_next(x)
} # }
```
