### Test fetch functions
context("Extract functions")

# Imports ---------------------------------------------------------------------

source("validate.R")

# Setup -----------------------------------------------------------------------

# Load test data for example_a_query
example_a_json_response <- read_data("example_a_json_response")
example_a_results <- read_data("example_a_results")
example_a_results_codes <- read_data("example_a_results_codes")

# Load test data for example_b_query
example_b_json_response <- read_data("example_b_json_response")
example_b_results <- read_data("example_b_results")
example_b_results_codes <- read_data("example_b_results_codes")

# Test extract_results --------------------------------------------------------

test_that("extract_results processes the response from example_a_query", {
    results <- extract_results(example_a_json_response)
    expect_identical(results, example_a_results)
})

test_that("extract_results processes the response from example_b_query", {
    results <- extract_results(example_b_json_response)
    expect_identical(results, example_b_results)
})

# Test add_codes_for_field ----------------------------------------------------

test_that("add_codes_for_field throws an error if results have wrong names", {
    results <- example_a_results
    names(results) <- letters[1:5]
    expect_error(
        add_codes_for_field(
            results, "National - Regional - LA - OAs", "Codes"),
        "These results do not have the expected names")
})

test_that("add_codes_for_field throws an error if results have wrong types", {
    results <- example_a_results
    results$measures <- NA
    expect_error(
        add_codes_for_field(
            results, "National - Regional - LA - OAs", "Codes"),
        "These results do not have the expected types")
})

test_that("add_codes_for_field throws an error if the field is missing", {
    expect_error(
        add_codes_for_field(
            example_a_results, "Non-existent field", "Codes"),
        "These results do not contain a field called \"Non-existent field\"")
})

test_that("add_codes_for_field throws an error if the column name exists", {
    expect_error(
        add_codes_for_field(
            example_a_results, "National - Regional - LA - OAs", "Month"),
        "These results already contain a column called \"Month\"")
})

test_that("add_codes_for_field correctly adds columns to one dataframe", {
    obs <- add_codes_for_field(
        example_a_results, "National - Regional - LA - OAs", "Codes")
    expect_identical(obs, example_a_results_codes)
})

test_that("add_codes_for_field correctly adds columns to many dataframes", {
    obs <- add_codes_for_field(
        example_b_results, "National - Regional - LA - OAs", "Codes")
    expect_identical(obs, example_b_results_codes)
})
