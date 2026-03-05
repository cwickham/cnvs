#' Upload files to Canvas
#'
#' Upload a local file to a location on Canvas LMS. Read more about possible parameters
#' at \url{https://canvas.instructure.com/doc/api/file.file_uploads.html}.
#'
#' @param path Path to file to upload
#' @param endpoint Character string of the API endpoint for upload. This depends on the required
#' context of file. For example, the default,
#' `"/api/v1/courses/:course_id/files"` uploads a file to a course.
#' Uploading a file as an assignment submission
#' has the endpoint `"/api/v1/courses/:course_id/assignments/:assignment_id/submissions/:user_id/files"`
#' @param ... Other parameters passed along to [cnvs()]. Use these
#' to specify endpoint parameters, e.g. `course_id`, parameters for the file
#' upload, e.g. `parent_folder_path`, or other parameters to [cnvs()]
#' like `.token` or `.api_url`.
#' @export
#' @examples
#' \dontrun{
#' ## Upload a course file, ends up in "unfiled"
#' cnvs_upload("notes.pdf", course_id = "1732420")
#'
#' ## Upload a course file to a specific folder
#' cnvs_upload("notes.pdf",
#'   course_id = "1732420", parent_folder_path = "cnvs_files")
#' }
cnvs_upload <- function(path, endpoint = "/api/v1/courses/:course_id/files", ...) {
  # TODO: Migrate to httr2 - this function is temporarily disabled

  cli::cli_abort(c(
    "cnvs_upload() is not yet available.",
    "i" = "This function needs to be migrated to httr2.",
    "i" = "Use cnvs() directly for now to interact with the Canvas API."
  ))
}
