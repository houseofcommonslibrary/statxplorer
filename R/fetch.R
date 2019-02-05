### Functions for making and receiving http requests

# Constants -------------------------------------------------------------------

TABLE_URL <- "https://stat-xplore.dwp.gov.uk/webapi/rest/v1/table"

# Functions -------------------------------------------------------------------

request_table <- function(query) {

    # Get API key from cache
    api_key <- get_api_key()

    # Set headers
    headers <- httr::add_headers(
        "APIKey" = api_key,
        "Content-Type" = "application/json")

    # POST and retuen
    httr::POST(TABLE_URL, headers, body = query, encode = "form")
}

fetch_table <- function(query, queryfile = NULL) {

    # Read the query from a file if given
    if (! is.null(queryfile)) query <- readr::read_file(queryfile)

    # Send the query and get the response
    response <- request_table(query)

    # If the server returned an error raise it with the response text
    if (response$status_code != 200) stop(request_error(response_text))

    # Extract the text, process as JSON, and extract the data
    response_text <- httr::content(response, as = "text", encoding = "utf-8")
    response_json <- jsonlite::fromJSON(response_text, simplifyVector = FALSE)
    extract_results(response_json)
}
