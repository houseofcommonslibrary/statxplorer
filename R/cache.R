### Package cache

# Cache -----------------------------------------------------------------------

cache <- new.env(parent = emptyenv())

# Constants -------------------------------------------------------------------

CACHE_API_KEY = "api_key"

# Cache access ----------------------------------------------------------------

get_api_key <- function() {
    if (! exists(CACHE_API_KEY, envir = cache)) {
        stop("No API key provided: use set_api_key to provide your key")
    }
    get(CACHE_API_KEY, envir = cache)
}

set_api_key <- function(api_key) {
    assign(CACHE_API_KEY, api_key, envir = cache)
}
