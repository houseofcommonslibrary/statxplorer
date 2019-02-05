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

    # Extract and label categories
    categories <- purrr::map(json$fields, function(field) {
        unlist(lapply(field$items, function(item) item$labels))
    })
    names(categories) <- fields

    # Create the results dataframe and add the data
    df <- extract_categories_df(categories)
    df$Value <- unlist(json$cubes[[cube]][[1]])

    # Return the data for this cube
    list(
        fields = fields,
        categories = categories,
        df = df
    )
}

extract_categories_df <- function(categories) {

    # Get a list of the categories for each field as dataframes
    categories <- purrr::imap(categories, function(categories, fieldname) {
        tibble::tibble(!!fieldname := categories)
    })

    # Create a dataframe of the combinations in order
    do.call(tidyr::crossing, categories)
}
