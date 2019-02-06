# Functions for extracting tabular data from query results

#' Extract the results of a query from the response json
#'
#' \code{extract_results} processes the results of the query and extracts the
#' data in a format suitable for analysis.
#'
#' @param json The results of the query as parsed json.
#' @param simplify If TRUE and the result contains only one data cube, return
#'   just the measure and datatframe for that cube, otherwise return the
#'   measures and dataframes in lists. The default value is TRUE.
#' @return A list of the results for the given cube.
#' @export

extract_results <- function(json, simplify = TRUE) {

    # Extract measure labels
    measures <- purrr::map_chr(json$measures, function(measure) measure$label)

    # Extract field labels
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

    # Extract dataframes for measures
    dfs <- purrr::imap(measures, function(measure, i) {
        df <- extract_items_df(items)
        df[[measure]] <- unlist(json$cubes[[i]][[1]])
        df
    })
    names(dfs) <- measures

    # Simplify if requested and return
    if (simplify && length(measures) == 1) {
        list(
            measure = measures[[1]],
            fields = fields,
            items = items,
            uris = uris,
            df = dfs[[1]])
    } else {
        list(
            measures = measures,
            fields = fields,
            items = items,
            uris = uris,
            dfs = dfs)
    }
}

#' Extract a dataframe of the item combinations represented in query results
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
