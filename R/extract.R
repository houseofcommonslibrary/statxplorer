# Functions for extracting tabular data from the response JSON

# Functions -------------------------------------------------------------------

extract_results <- function(json) {

    # Extract results for each cube into a list
    results <- purrr::map(1:length(json$cubes), ~ extract_cube(json, .))

    # Name each cube with its measure and return
    names(results) <- purrr::map_chr(json$measures,
                                     function(measure) measure$label)
    results
}

extract_cube <- function(json, cube = 1) {

    # Extract fieldnames
    fields <- purrr::map_chr(json$fields, function(field) field$label)

    # Extract label for items
    items <- purrr::map(json$fields, function(field) {
        unlist(lapply(field$items, function(item) item$labels))
    })
    names(items) <- fields

    # Extract and uris for items
    uris <- purrr::map(json$fields, function(field) {
        unlist(lapply(field$items, function(item) item$uris))
    })
    names(uris) <- fields

    # Create the results dataframe and add the data
    df <- extract_items_df(items)
    df$Value <- unlist(json$cubes[[cube]][[1]])

    # Return the data for this cube
    list(
        fields = fields,
        items = items,
        uris = uris,
        df = df
    )
}

extract_items_df <- function(items) {

    # Get a list of the items for each field as dataframes
    items <- purrr::imap(items, function(items, field) {
        tibble::tibble(!!field := items)
    })

    # Create a dataframe of the combinations in order
    do.call(tidyr::crossing, items)
}
