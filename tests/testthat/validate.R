### Manage test data for validation

# About -----------------------------------------------------------------------

# The functions in this folder are used to record the output of the api and the
# functions that process that data in order to produce mocks, and to check if
# the expected behaviour of the functions has changed. The file paths are set
# so that you can source this file from within the package during development
# to generate the test data, and source it from within the tests to use it for
# testing. You must set an api key before using the functions in this file in
# order to generate the data.

# Constants -------------------------------------------------------------------

READ_TEST_DIR <- file.path("data")
WRITE_TEST_DIR <- file.path("tests", "testthat", "data")

# Read and write data ---------------------------------------------------------

# Read a file from the data directory
read_data <- function(filename) {
    readRDS(file.path(READ_TEST_DIR,
                      stringr::str_glue("{filename}.RData")))
}

# Write a tibble to the data directory
write_data <- function(df, filename) {
    saveRDS(df, file.path(WRITE_TEST_DIR,
                          stringr::str_glue("{filename}.RData")))
}

# Read a query from the queries directory
read_query <- function(example_name) {
    readr::read_file(file.path(READ_TEST_DIR,
                               stringr::str_glue(
                                   "{example_name}.json")))
}

# Send a query to the api and get the text of the http response body
send_query <- function(query) {
    api_key <- get_api_key()
    headers <- httr::add_headers(
        "APIKey" = api_key,
        "Content-Type" = "application/json")
    httr::POST(URL_TABLE, headers, body = query, encode = "form")
}

# Fetch test data -------------------------------------------------------------

# Fetch data for unit tests for a given example query
fetch_example_data <- function(example, custom = NULL) {

    query <- readr::read_file(file.path(
        WRITE_TEST_DIR,
        stringr::str_glue("{example}_query.json")))

    http_response <- send_query(query)
    json_response <- request_table(query)
    results <- extract_results(json_response, custom)
    results_codes <- add_codes_for_field(results, results$fields[[1]], "Codes")

    write_data(http_response, stringr::str_glue("{example}_http_response"))
    write_data(json_response, stringr::str_glue("{example}_json_response"))
    write_data(results, stringr::str_glue("{example}_results"))
    write_data(results_codes, stringr::str_glue("{example}_results_codes"))
}

# Fetch all data for unit tests for a given example query
fetch_test_data <- function() {
    fetch_example_data("example_a")
    fetch_example_data("example_b")
    fetch_example_data("example_c", custom = list(
        "Age of Claimant (bands only)" = c("16-64", "65+", "Total")))
}

