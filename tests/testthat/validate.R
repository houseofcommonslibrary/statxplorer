### Manage test data for validation

# Constants -------------------------------------------------------------------

READ_TEST_DATA_DIR <- file.path("data")
WRITE_TEST_DATA_DIR <- file.path("tests", "testthat", "data")

# Read and write data ---------------------------------------------------------

#' Fetch mocks data for unit tests
#'
#' You must set the api key before calling this function.
#'
#' @keywords internal

fetch_example_data <- function(example_name) {

    filename <- file.path(WRITE_TEST_DATA_DIR,
                          stringr::str_glue("{example_name}_query.json"))
    example_query <- readr::read_file(filename)

    example_response <- request_table(example_query)
    saveRDS(example_response,
            file.path(WRITE_TEST_DATA_DIR,
                      stringr::str_glue("{example_name}_response.RData")))

            example_results <- extract_results(example_response)
    saveRDS(example_results,
            file.path(WRITE_TEST_DATA_DIR,
                      stringr::str_glue("{example_name}_results.RData")))
}

fetch_mocks_data <- function() {

    fetch_example_data("example_1")
}

