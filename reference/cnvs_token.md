# Return the local user's Canvas token and domain

`cnvs_token()` returns the Canvas API token from the `CANVAS_API_TOKEN`
environment variable. Most Canvas API requests require a token to prove
the request is authorized by a specific Canvas user.

`cnvs_domain()` returns the Canvas domain URL from the `CANVAS_DOMAIN`
environment variable. This is your institution's Canvas URL, e.g.
`https://canvas.instructure.com` or `https://myuni.instructure.com`.

You can generate a token from your Canvas profile settings page at
`{CANVAS_DOMAIN}/profile/settings` under "Approved Integrations".

See
[`cnvs_whoami()`](https://cwickham.github.io/cnvs/reference/cnvs_whoami.md)
for more details on setting up your credentials.

## Usage

``` r
cnvs_token()

cnvs_token_exists()

cnvs_domain()
```

## Value

A string. For `cnvs_token()`, the return value has an S3 class to ensure
that simple printing strategies don't reveal the entire token. Both
functions error if the corresponding environment variable is not set.

## Examples

``` r
if (FALSE) { # \dontrun{
cnvs_token()
cnvs_domain()

format(cnvs_token())
} # }
```
