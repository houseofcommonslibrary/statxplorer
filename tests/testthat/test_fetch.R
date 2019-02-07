### Test fetch functions
context("Fetch functions")

# Imports ---------------------------------------------------------------------

source("validate.R")

# Setup -----------------------------------------------------------------------

# Load queries
example_1_query <- readr::read_file(file.path(
    READ_TEST_DATA_DIR, "example_1_query.json"))

# Load responses
example_1_response <- readRDS(file.path(
    READ_TEST_DATA_DIR, "example_1_response.RData"))

# Tests -----------------------------------------------------------------------

test_that("request_table sends and receives a query", {

    if (!api_available) skip("skipped as api could not be reached")

    response <- request_table(example_1_query)
    expect_identical(response, example_1_response)
})
