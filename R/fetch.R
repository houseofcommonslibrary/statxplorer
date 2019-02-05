### Functions for making and receiving http requests

# Constants -------------------------------------------------------------------

TABLE_URL <- "https://stat-xplore.dwp.gov.uk/webapi/rest/v1/table"

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
    response <- httr::POST(TABLE_URL, headers, body = query, encode = "form")

    # If the server returned an error raise it with the response text
    if (response$status_code != 200) stop(request_error(response_text))

    # Extract the text, process as JSON, and extract the data
    response_text <- httr::content(response, as = "text", encoding = "utf-8")
    response_json <- jsonlite::fromJSON(response_text, simplifyVector = FALSE)
}

#' Send a table query and return the results
#'
#' \code{fetch_table} sends a query to the table endpoint and returns the
#' response as a list of data cubes, each containing a list of data items for
#' each cube.
#'
#' A query may be provided as a string or can be loaded from a file using the
#' \code{queryfile} argument. In most cases this is more convenient as
#' Stat-Xplore queries can be large and are most easily produced using the
#' table builder tool on the website.
#'
#' Stat-Xplore returns one data cube for each measure included in the query
#' as a wafer. In plain english, cubes that are produced from the same query
#' will have different results for different measures but within the same table
#' structure. In the lilst of results cubes are named according to the name of
#' the measure they represent.
#'
#' For each cube a list of the following data is provided:
#'
#' fields - the names categorical variables represented in the data (list)
#' items - the names of the categories or levels within each field (list)
#' uris - the uris of the categories or levels within each field (list)
#' df - a dataframe of the categories and values in long form (tibble)
#'
#' @param query Stat-Xplore query as a string.
#' @param filename The path to a text file containing a Stat-Xplore query.
#'   This argument is not required but has priority: if a \code{filename} is
#'   provided, the \code{query} argument is ignored.
#' @param simplify If TRUE and the result contains only one data cube, return
#'   just that cube. The default value is TRUE.
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
