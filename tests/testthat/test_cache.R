### Test cache functions
context("Cache functions")

# Constants -------------------------------------------------------------------

DATA_DIR <- "data"

# Tests -----------------------------------------------------------------------

test_that("set_api_key sets an api_key", {
    api_key_exp <- "ABC123"
    set_api_key(api_key_exp)
    api_key_obs <- get(CACHE_API_KEY, envir = cache)
    expect_equal(api_key_obs, api_key_exp)
})

test_that("get_api_key gets an api_key", {
    api_key_exp <- "ABC123"
    set_api_key(api_key_exp)
    api_key_obs <- get_api_key()
    expect_equal(api_key_obs, api_key_exp)
})

test_that("load_api_key loads an api_key", {
    api_key_exp <- "ABC123"
    filename <- file.path(DATA_DIR, "tmp_api_key.txt")
    readr::write_file(api_key_exp, filename)
    api_key_obs <- load_api_key(filename)
    expect_equal(api_key_obs, api_key_exp)
    file.remove(filename)
})
