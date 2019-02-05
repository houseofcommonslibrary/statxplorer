# Functions for extracting tabular data from the response json

#' Extract the results of a query from the response
#'
#' \code{extract_results} processes the results of the query and extracts the
#' data in a format suitable for analysis.
#'
#' @param json The results of the query as parsed json.
#' @param simplify If TRUE and the result contains only one data cube, return
#'   just that cube. The default value is TRUE.
#' @return A list of the results with one item for each data cube.
#' @export

extract_results <- function(json, simplify = TRUE) {

    # Extract results for each cube into a list
    results <- purrr::map(1:length(json$cubes), ~ extract_cube(json, .))

    # Name each cube with its measure and return
    names(results) <- purrr::map_chr(json$measures,
                                     function(measure) measure$label)

    # Simplify if requested and return
    if (simplify && length(results) == 1) return(results[[1]])
    results
}

#' Extract the results of a query from the response for a given data cube
#'
#' @param json The results of the query as parsed json.
#' @param cube The number of the cube to extract.
#' @return A list of the results for the given cube.
#' @keywords internal

extract_cube <- function(json, cube) {

    # Extract the measure name
    measure <- json$measures[[cube]]$label

    # Extract fieldnames
    fields <- purrr::map_chr(json$fields, function(field) field$label)

    # Extract labels for items
    items <- purrr::map(json$fields, function(field) {
        unlist(lapply(field$items, function(item) item$labels))
    })
    names(items) <- fields

    # Extract uris for items
    uris <- purrr::map(json$fields, function(field) {
        unlist(lapply(field$items, function(item) item$uris))
    })
    names(uris) <- fields

    # Create the results dataframe and add the data
    df <- extract_items_df(items)
    df[[measure]] <- unlist(json$cubes[[cube]][[1]])

    # Return the data for this cube
    list(
        fields = fields,
        items = items,
        uris = uris,
        df = df
    )
}

#' Extract a dataframe of the item combinations represented in a query result
#'
#' @param items The list of items for a query result.
#' @return A dataframe of the item combinations represented in the result.
#' @keywords internal

extract_items_df <- function(items) {

    # Get a list of the items for each field as dataframes
    items <- purrr::imap(items, function(items, field) {
        tibble::tibble(!!field := items)
    })

    # Create a dataframe of the combinations in order
    do.call(tidyr::crossing, items)
}
