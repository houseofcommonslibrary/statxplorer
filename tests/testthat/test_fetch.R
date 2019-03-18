### Test fetch functions
context("Fetch functions")

# Imports ---------------------------------------------------------------------

source("validate.R")

# Setup -----------------------------------------------------------------------

# Load test data for example_a_query
example_a_query <- read_query(file.path("example_a_query"))
example_a_http_response <- read_data("example_a_http_response")
example_a_json_response <- read_data("example_a_json_response")
example_a_results <- read_data("example_a_results")

# Load test data for example_b_query
example_b_query <- read_query(file.path("example_b_query"))
example_b_http_response <- read_data("example_b_http_response")
example_b_json_response <- read_data("example_b_json_response")
example_b_results <- read_data("example_b_results")

# Load test data for example_c_query
example_c_query <- read_query(file.path("example_c_query"))
example_c_http_response <- read_data("example_c_http_response")
example_c_json_response <- read_data("example_c_json_response")
example_c_results <- read_data("example_c_results")

# Mocks -----------------------------------------------------------------------

get_mock_post <- function(response) {
    function(url, headers, body = NULL, encode = NULL, timeout = 0) {response}
}

get_mock_request_table <- function(response) {
    function(query) {response}
}

# Test request_table ----------------------------------------------------------

test_that("request_table processes the response from example_a_query", {
    with_mock(
        "statxplorer::get_api_key" = function() {},
        "httr::POST" = get_mock_post(example_a_http_response), {

        response <- request_table(example_a_query)
        expect_identical(response, example_a_json_response)
    })
})

test_that("request_table processes the response from example_b_query", {
    with_mock(
        "statxplorer::get_api_key" = function() {},
        "httr::POST" = get_mock_post(example_b_http_response), {

            response <- request_table(example_b_query)
            expect_identical(response, example_b_json_response)
        })
})

test_that("request_table processes the response from example_c_query", {
    with_mock(
        "statxplorer::get_api_key" = function() {},
        "httr::POST" = get_mock_post(example_c_http_response), {

            response <- request_table(example_c_query)
            expect_identical(response, example_c_json_response)
        })
})

# Test fetch_table ----------------------------------------------------------

test_that("fetch_table throws an error if metadata and data don't match", {
    with_mock(
        "statxplorer::request_table" =
            get_mock_request_table(example_c_json_response), {

        expect_error(
            fetch_table(example_c_query),
            stringr::str_c(
                "Could not process query results. There are 6350 item ",
                "combinations but 1905 values. Have you provided the correct ",
                "metadata for custom aggregate variables? See: ",
                "https://github.com/olihawkins/statxplorer",
                "#custom-aggregate-variables"),
            fixed = TRUE)
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

test_that("fetch_table processes the response from example_b_query", {
    with_mock(
        "statxplorer::request_table" =
            get_mock_request_table(example_b_json_response), {

        results <- fetch_table(example_b_query)
        expect_identical(results, example_b_results)
    })
})

test_that("fetch_table loads and processes example_b_query from a file", {
    with_mock(
        "statxplorer::request_table" =
            get_mock_request_table(example_b_json_response), {

        results <- fetch_table(
            filename = file.path(READ_TEST_DIR, "example_b_query.json"))
        expect_identical(results, example_b_results)
    })
})

test_that("fetch_table processes the response from example_c_query", {
    with_mock(
        "statxplorer::request_table" =
            get_mock_request_table(example_c_json_response), {

        results <- fetch_table(example_c_query, custom = list(
            "Age of Claimant (bands only)" = c("16-64", "65+", "Total")))
        expect_identical(results, example_c_results)
    })
})

test_that("fetch_table loads and processes example_c_query from a file", {
    with_mock(
        "statxplorer::request_table" =
            get_mock_request_table(example_c_json_response), {

        results <- fetch_table(example_c_query, custom = list(
            "Age of Claimant (bands only)" = c("16-64", "65+", "Total")))
        expect_identical(results, example_c_results)
    })
})
