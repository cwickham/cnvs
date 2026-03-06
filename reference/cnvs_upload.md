# Upload files to Canvas

Upload a local file to a location on Canvas LMS. Read more about
possible parameters at
<https://canvas.instructure.com/doc/api/file.file_uploads.html>.

## Usage

``` r
cnvs_upload(path, endpoint = "/api/v1/courses/:course_id/files", ...)
```

## Arguments

- path:

  Path to file to upload

- endpoint:

  Character string of the API endpoint for upload. This depends on the
  required context of file. For example, the default,
  `"/api/v1/courses/:course_id/files"` uploads a file to a course.
  Uploading a file as an assignment submission has the endpoint
  `"/api/v1/courses/:course_id/assignments/:assignment_id/submissions/:user_id/files"`

- ...:

  Other parameters passed along to
  [`cnvs()`](https://cwickham.github.io/cnvs/reference/cnvs.md). Use
  these to specify endpoint parameters, e.g. `course_id`, parameters for
  the file upload, e.g. `parent_folder_path`, or other parameters to
  [`cnvs()`](https://cwickham.github.io/cnvs/reference/cnvs.md) like
  `.token` or `.api_url`.

## Value

Invisibly returns the response from the upload confirmation. On success,
prints the download URL for the uploaded file.

## Examples

``` r
if (FALSE) { # \dontrun{
## Upload a course file, ends up in "unfiled"
cnvs_upload("notes.pdf", course_id = "1732420")

## Upload a course file to a specific folder
cnvs_upload("notes.pdf",
  course_id = "1732420", parent_folder_path = "cnvs_files")
} # }
```
