# Info on current Canvas user, domain and token

Reports name and Canvas login ID for the current authenticated user, the
Canvas domain and the first bit of the token.

## Usage

``` r
cnvs_whoami(.token = NULL, .api_url = NULL, .send_headers = NULL)
```

## Arguments

- .token:

  Authentication token. Defaults to
  [`cnvs_token()`](https://cwickham.github.io/cnvs/reference/cnvs_token.md).

- .api_url:

  Canvas domain URL. Used if `endpoint` just contains a path. Defaults
  to `CANVAS_DOMAIN` environment variable if set.

- .send_headers:

  Named character vector of header field values (except `Authorization`,
  which is handled via `.token`). This can be used to override or
  augment the default `User-Agent` header:
  `"https://github.com/cwickham/cnvs"`.

## Value

A `cnvs_response` object, which is also a `list`.

## Details

Your Canvas domain is the address of your organization's Canvas site,
e.g. `https://oregonstate.instructure.com/`. Set this via the
`CANVAS_DOMAIN` environment variable or pass it to `.api_url`.

Get a personal access token for your Canvas domain from
`{CANVAS_DOMAIN}/profile/settings`. The token itself is a string of
letters and digits. You can store it any way you like and provide
explicitly via the `.token` argument to
[`cnvs()`](https://cwickham.github.io/cnvs/reference/cnvs.md).

However, many prefer to define environment variables `CANVAS_API_TOKEN`
and `CANVAS_DOMAIN` with these values in their `.Renviron` file. Add
lines that look like these, substituting your domain and token:

    CANVAS_DOMAIN="https://canvas.instructure.com"
    CANVAS_API_TOKEN="your_token_here"

Put a line break at the end! If you're using an editor that shows line
numbers, there should be (at least) three lines, where the third one is
empty. Restart R for this to take effect. Call `cnvs_whoami()` to
confirm success.

To get complete information on the authenticated user, call
`cnvs("/api/v1/users/self")`.

## Examples

``` r
if (FALSE) { # \dontrun{
cnvs_whoami()

## explicit token + domain
cnvs_whoami(
  .token = "your_token_here",
  .api_url = "https://canvas.instructure.com"
)
} # }
```
