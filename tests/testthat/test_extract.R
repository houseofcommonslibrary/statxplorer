### Test fetch functions
context("Extract functions")

# Imports ---------------------------------------------------------------------

source("validate.R")

# Setup -----------------------------------------------------------------------

# Load test data for example_a_query
example_a_json_response <- read_data("example_a_json_response")
example_a_results <- read_data("example_a_results")
example_a_results_us <- read_data("example_a_results_us")

# Load test data for example_b_query
example_b_json_response <- read_data("example_b_json_response")
example_b_results <- read_data("example_b_results")
example_b_results_us <- read_data("example_b_results_us")

# Tests -----------------------------------------------------------------------

test_that("extract_results processes the response from example_a_query", {
    results <- extract_results(example_a_json_response)
    expect_identical(results, example_a_results)
})

test_that("extract_results processes example_a_query unsimplified", {
    results_us <- extract_results(example_a_json_response, simplify = FALSE)
    expect_identical(results_us, example_a_results_us)
})


