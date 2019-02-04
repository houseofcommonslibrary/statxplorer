### Package errors

#' Report an error with an http request
#'
#' @param response The text of the server reponse.
#' @keywords internal

request_error <- function(response) {
    stringr::str_glue(
        "The server responded with the following message: {response}")
}
