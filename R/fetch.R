### Functions for making and receiving http requests

# Constants -------------------------------------------------------------------

URL_INFO <- "https://stat-xplore.dwp.gov.uk/webapi/rest/v1/info"
URL_TABLE <- "https://stat-xplore.dwp.gov.uk/webapi/rest/v1/table"

# Functions -------------------------------------------------------------------

#' Send an http request with a query and return the response
#'
#' \code{request_table} sends a query to the table endpoint, checks the
#' response, parses the response text as json, and returns the parsed data. If
#' the query syntax is not valid or the request fails for any other reason an
#' error is raised with the response text.
#'
#' @param query A valid Stat-Xplore query as a string.
#' @return A list of the query results as parsed json.
#' @export

request_table <- function(query) {

    # Get api key from cache
    api_key <- get_api_key()

    # Set headers
    headers <- httr::add_headers(
        "APIKey" = api_key,
        "Content-Type" = "application/json")

    # POST and retuen
    response <- httr::POST(URL_TABLE, headers, body = query, encode = "form")

    # If the server returned an error raise it with the response text
    if (response$status_code != 200) stop(request_error(response_text))

    # Extract the text, process as JSON, and extract the data
    response_text <- httr::content(response, as = "text", encoding = "utf-8")
    response_json <- jsonlite::fromJSON(response_text, simplifyVector = FALSE)
}

#' Send a table query and return the results
#'
#' \code{fetch_table} sends a query to the table endpoint and returns the
#' response as a list containing the results. The results include a dataframe
#' of tidy data for each measure requested by the query.
#'
#' A query can be provided as a string or can be loaded from a file using the
#' \code{filename} argument. This is sometimes convenient as Stat-Xplore
#' queries can be large and are most easily produced using the table builder
#' tool on the website, which exports queries as json text files.
#'
#' Stat-Xplore returns one set of results for each measure included in a query.
#' Each set of results includes data for different measures on the same set of
#' observations.
#'
#' The list of results has the following structure:
#'
#' measure / measures - the names of the measures for each dataset (str / list)
#' fields - the names of categorical variables represented in the data (list)
#' items - the names of the categories or levels within each field (list)
#' uris - the uris of the categories or levels within each field (list)
#' df / dfs - a dataframe for each measure in long form (list / tibble)
#'
#' If a query requests data on only one measure and \code{simplify} is
#' set to \code{TRUE}, then \code{relusts$measure} is a string containg the
#' measure name and \code{results$df} if a dataframe containing the results.
#'
#' If a query requests data on more than one measure, or \code{simplify} is set
#' to \code{FALSE}, the measure names are stored as a list in
#' \code{results$measures} and the dataframes for each measure are stored as a
#' list in \code{results$dfs}.
#'
#' \code{simplify} is \code{TRUE} by default.
#'
#' @param query Stat-Xplore query as a string.
#' @param filename The path to a text file containing a Stat-Xplore query.
#'   This argument is not required but has priority: if a \code{filename} is
#'   provided, the \code{query} argument is ignored.
#' @param simplify If TRUE and the results contain only one measure, don't nest
#'   the measure and results data within unecessary lists.
#' @return A list containing the results of the query, with one item per cube.
#' @export

fetch_table <- function(query, filename, simplify = TRUE) {

    # Read the query from a file if given
    if (! is.null(filename)) query <- readr::read_file(filename)

    # Send the query and get the response
    response_json <- request_table(query)

    # Extract results
    extract_results(response_json, simplify)
}

#' Check if R can reach the api and return a boolean
#'
#' @keywords internal

check_api <- function() {

    # Get api key from cache
    api_key <- get_api_key()

    # Set headers
    headers <- httr::add_headers(
        "APIKey" = api_key,
        "Content-Type" = "application/json")

    # Send request to the info endpoint
    tryCatch({
        response <- httr::GET(URL_INFO, headers)
        response$status_code == 200
    }, error = function(e) {
        FALSE
    })
}
