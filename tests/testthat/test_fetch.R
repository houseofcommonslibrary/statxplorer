### Test fetch functions
context("Fetch functions")

# Imports ---------------------------------------------------------------------

source("validate.R")

# Setup -----------------------------------------------------------------------

# Load test data
example_a_query <- read_query(file.path("example_a_query"))
example_a_http_response <- read_data("example_a_http_response")
example_a_json_response <- read_data("example_a_json_response")
example_a_results <- read_data("example_a_results")

# Mocks -----------------------------------------------------------------------

get_mock_post <- function(response) {
    function(url, headers, body = NULL, encode = NULL) {response}
}

get_mock_request_table <- function(response) {
    function(query) {response}
}

# Tests -----------------------------------------------------------------------

test_that("request_table processes the response from example_a_query", {
    with_mock(
        "statxplorer::get_api_key" = function() {},
        "httr::POST" = get_mock_post(example_a_http_response), {

        response <- request_table(example_a_query)
        expect_identical(response, example_a_json_response)
    })
})

test_that("fetch_table processes the response from example_a_query", {
    with_mock(
        "statxplorer::request_table" =
            get_mock_request_table(example_a_json_response), {

        results <- fetch_table(example_a_query)
        expect_identical(results, example_a_results)
    })
})

test_that("fetch_table loads and processes example_a_query from a file", {
    with_mock(
        "statxplorer::request_table" =
            get_mock_request_table(example_a_json_response), {

        results <- fetch_table(
            filename = file.path(READ_TEST_DIR, "example_a_query.json"))
        expect_identical(results, example_a_results)
    })
})
