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
#' @return Invisibly returns the response from the upload confirmation.
#'   On success, prints the download URL for the uploaded file.
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
  # Step 1: Notify Canvas about the file upload
  file_info <- cnvs(
    endpoint = endpoint,
    .method = "POST",
    name = fs::path_file(path),
    size = fs::file_size(path),
    ...
  )

  # Step 2: Upload the file to the URL provided by Canvas
  req <- httr2::request(file_info$upload_url)
  req <- httr2::req_body_multipart(
    req,
    !!!file_info$upload_params,
    file = curl::form_file(path)
  )
  resp <- httr2::req_perform(req)

  # Step 3: Handle redirect if needed (Canvas may redirect to confirm upload)
  if (httr2::resp_status(resp) %/% 100 == 3) {
    redirect_url <- httr2::resp_header(resp, "location")
    redirect_req <- httr2::request(redirect_url)
    redirect_req <- httr2::req_headers(
      redirect_req,
      Authorization = paste("Bearer", cnvs_token())
    )
    resp <- httr2::req_perform(redirect_req)
  }

  # Step 4: Process the response
  response <- httr2::resp_body_json(resp)

  if (httr2::resp_status(resp) %/% 100 == 2) {
    if (!is.null(response$url)) {
      cli::cli_alert_success("File uploaded: {.url {response$url}}")
    } else {
      cli::cli_alert_success("File uploaded successfully")
    }
  }

  invisible(response)
}
