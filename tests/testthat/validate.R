### Manage test data for validation

# About -----------------------------------------------------------------------

# The functions in this folder are used to record the output of the api and
# functions that process that data in order to produce mocks and check if the
# expected behaviour of the functions has changed. The file paths are set so
# that you can source this file from the package route during development to
# generate the test data, and source it from within the tests to use it. You
# must set an api key before using the functions in this file to generate data.

# Constants -------------------------------------------------------------------

READ_TEST_DATA_DIR <- file.path("data")
WRITE_TEST_DATA_DIR <- file.path("tests", "testthat", "data")
READ_QUERY_DIR <- file.path("tests", "testthat", "queries")

# Read and write data ---------------------------------------------------------

#' Read a file from the data directory
#'
#' @keywords internal

read_data <- function(filename) {
    readRDS(file.path(READ_TEST_DATA_DIR,
                      stringr::str_glue("{filename}.RData")))
}

#' Write a tibble to the data directory
#'
#' @keywords internal

write_data <- function(df, filename) {
    saveRDS(df, file.path(WRITE_TEST_DATA_DIR,
                          stringr::str_glue("{filename}.RData")))
}

#' Read a query from the queries directory
#'
#' @keywords internal

read_query <- function(example_name) {
    readr::read_file(file.path(READ_QUERY_DIR,
                               stringr::str_glue(
                                   "{example_name}_query.json")))
}

#' Send a query to the api and get the text of the http response body
#'
#' @keywords internal

send_query <- function(query) {
    api_key <- get_api_key()
    headers <- httr::add_headers(
        "APIKey" = api_key,
        "Content-Type" = "application/json")
    response <- httr::POST(URL_TABLE, headers, body = query, encode = "form")
    httr::content(response, as = "text", encoding = "utf-8")
}

# Fetch test data -------------------------------------------------------------

#' Fetch data for unit tests for a given example query
#'
#' @keywords internal

fetch_example_data <- function(example_name) {

    query <- read_query(example_name)
    http_response <- send_query(query)
    json_response <- request_table(query)
    results <- extract_results(json_response)

    write_data(http_response, "{example_name}_http_response")
    write_data(json_response, "{example_name}_json_response")
    write_data(results, "{example_name}_results")
}

fetch_test_data <- function() {
    fetch_example_data("example_1")
}

