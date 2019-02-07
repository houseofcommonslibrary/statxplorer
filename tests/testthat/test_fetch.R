### Test fetch functions
context("Fetch functions")

# Imports ---------------------------------------------------------------------

source("validate.R")

# Setup -----------------------------------------------------------------------

# Load test data
example_a_query <- read_query(file.path("example_a_query"))
example_a_http_response <- read_data("example_a_http_response")
example_a_json_response <- read_data("example_a_json_response")

# Tests -----------------------------------------------------------------------

test_that("request_table process the response from example a", {
    with_mock(
        "statxplorer::get_api_key" = function() {""},
        "httr::POST" = function(url, headers, body = NULL, encode = NULL) {example_a_http_response}, {

        response <- request_table(example_a_query)
        expect_identical(response, example_a_json_response)
    })
})
