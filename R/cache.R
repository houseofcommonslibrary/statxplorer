### Package cache

# Cache -----------------------------------------------------------------------

#' Package cache environment
#'
#' @keywords internal

cache <- new.env(parent = emptyenv())

# Constants -------------------------------------------------------------------

#' API key cacge variable name
#'
#' @keywords internal

CACHE_API_KEY = "api_key"

# Cache access: api key -------------------------------------------------------

#' Set the api key
#'
#' \code{set_api_key} sets the api key that the package uses for communiciation
#' with the server.
#'
#' @param api_key A valid Stat-Xplore api key.
#' @return NULL
#' @export

set_api_key <- function(api_key) {
    assign(CACHE_API_KEY, api_key, envir = cache)
}

#' Load the api key from a file
#'
#' \code{load_api_key} is a convenience method that loads the api key from the
#' given file and sets it for the session.
#'
#' @param filename The path to a text file containing the api key.
#' @return NULL
#' @export

load_api_key <- function(filename) {
    api_key = stringr::str_trim(readr::read_file(filename))
    set_api_key(api_key)
}

#' Get the api key
#'
#' \code{get_api_key} gets the api key that the package uses for communciation
#' with the server from the package cache.
#'
#' @return The api key as a string
#' @keywords internal

get_api_key <- function() {
    if (! exists(CACHE_API_KEY, envir = cache)) {
        stop(stringr::str_c(
            "No API key provided: use statxplorer::set_api_key() or ",
            "statxplorer::load_api_key() to provide your key"))
    }
    get(CACHE_API_KEY, envir = cache)
}

#' Check an api key has been set
#'
#' \code{has_api_key} checks that an api key for communicating with the server
#' has been set in the package cache.
#'
#' @return A boolean indicating whether the cache contains an api_key
#' @export

has_api_key <- function() {
    exists(CACHE_API_KEY, envir = cache)
}
