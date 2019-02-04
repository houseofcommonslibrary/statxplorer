### Functions for making and receiving http requests

# Constants -------------------------------------------------------------------

TABLE_URL <- "https://stat-xplore.dwp.gov.uk/webapi/rest/v1/table"

# Functions -------------------------------------------------------------------

request_table <- function(query) {
    api_key <- get_api_key()
    headers <- httr::add_headers(
        "APIKey" = api_key,
        "Content-Type" = "application/json")
    httr::POST(TABLE_URL, headers, body = query, encode = "form")
}

fetch_table <- function(query) {

    # Send the query and get the response
    response <- request_table(query)
    response_text <- httr::content(response, as = "text", encoding = "utf-8")

    # If the server returned an error raise it with the response text
    if (response$status_code != 200) stop(request_error(response_text))

    # Extract the text and return the JSON
    response_text <- httr::content(response, as = "text", encoding = "utf-8")
    jsonlite::fromJSON(response_text, simplifyVector = FALSE)
}
