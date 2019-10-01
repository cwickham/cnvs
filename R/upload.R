#' Upload files to Canvas
#'
#' Upload a local file to a location on Canvas LMS. Read more about possible parameters
#' at \url{https://canvas.instructure.com/doc/api/file.file_uploads.html}.
#'
#' @param endpoint Character string of the API endpoint for upload.  This depends on the required
#' context of file. For example, uploading a file to a course uses the endpoint
#' \code{"/api/v1/courses/:course_id/files"}.  Uploading a file as an assignment submission
#' has the endpoint \code{"/api/v1/courses/:course_id/assignments/:assignment_id/submissions/:user_id/files"}
#' @param path Path to file to upload
#' @param ... Other parameters passed along to \code{\link{cnvs}()}.  Use these
#' to specify endpoint parameters, e.g. \code{course_id}, parameters for the file
#' upload, e.g. \code{parent_folder_path}, or other parameters to \code{\link{cnvs}()}
#' like \code{.token} or \code{.api_endpoint}.
#' @export
#' @examples
#' \dontrun{
#' ## Upload a course file, ends up in "unfiled"
#' cnvs_upload("/api/v1/courses/:course_id/files",
#'   path = "notes.pdf", course_id = "1732420")
#'
#' ## Upload a course file to a specific folder
#' cnvs_upload("POST /api/v1/courses/:course_id/files",
#'   path = "notes.pdf", course_id = "1732420", parent_folder_path = "cnvs_files/")
#' }
cnvs_upload <- function(endpoint, path, ...){
  file <- cnvs(endpoint = endpoint, .method = "POST",
    name = fs::path_file(path),
    size = fs::file_size(path),
    ...)

  form <- httr::upload_file(path)
  names(form) <- c("file", "type")

  req <- httr::POST(
    file$upload_url,
    body = c(file$upload_params, form)
  )

  if((status_code(req) %/% 100 == 3)){
    # Redirect to finish upload process
    redirect_req <- gh_build_request(httr::headers(req)$location, method = "GET")
    req <- gh_make_request(redirect_req)
  }

  gh_process_response(req)
}
