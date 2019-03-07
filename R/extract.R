# Functions for extracting tabular data from query results

#' Extract the results of a query from the response json
#'
#' \code{extract_results} processes the results of the query and extracts the
#' data in a format suitable for analysis.
#'
#' @param json The results of the query as parsed json.
#' @param custom A named list of character vectors. Each name/value pair
#'   indicates the item labels to use for the field with the given name when
#'   constructing the results dataframes. It is necessary to specify item
#'   labels explicitly using this argument when your query uses custom
#'   aggregate variables, as the number of variables in the results will not
#'   agree with the number of variables shown in the metadata.
#' @return A list of the results for the given cube.
#' @export

extract_results <- function(json, custom = NULL) {

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

    # If custom varaiable labels are specified, update the metadata
    if (!is.null(custom)) {
        for (nm in names(custom)){
            items[[nm]] <- custom[[nm]]
        }
    }

    # Extract dataframes for measures
    dfs <- purrr::imap(measures, function(measure, i) {

        df <- extract_items_df(items)
        values <- unlist(json$cubes[[i]][[1]])

        num_rows <- nrow(df)
        num_values <- length(values)

        if (num_rows != num_values) {
            stop(stringr::str_c(
                "Could not process query results. ",
                stringr::str_glue("There are {num_rows} item combinations "),
                stringr::str_glue("but {num_values} values. ") ,
                "Have you provided the correct metadata for custom aggregate ",
                "variables? See: https://github.com/olihawkins/statxplorer",
                "#custom-aggregate-variables"))
        }

        df[[measure]] <- values
        df
    })
    names(dfs) <- measures

    # Return the results
    list(
        measures = measures,
        fields = fields,
        items = items,
        uris = uris,
        dfs = dfs)
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

#' Extract the codes for a given field and add them to the given dataframe
#'
#' \code{add_codes_for_field} adds a column containing the codes for a given
#' field to the dataframes contained in the given results. The codes are
#' derived from the uris: specifically they are the last item in uri string
#' delimited with a colon. Where fields contain items for totals their uris do
#' not contain a corresponding uri for the total. This function handles that
#' case by creating a dummy code for the total (called "Total").
#'
#' @param results The results list.
#' @param field The name of the field for which to extract codes.
#' @param colname The name of the new column which will contain the codes.
#' @return A copy of the results with a code column added to each dataframe.
#' @export

add_codes_for_field <- function(results, field, colname) {

    # Check the results list has the expected names
    expected_names <- c("measures", "fields", "items", "uris", "dfs")
    if (! all(expected_names %in% names(results))) {
        stop("These results do not have the expected names")
    }

    # Check the results list has the expected types
    expected_types <- c("character", "character", "list", "list", "list" )

    types_match <- purrr::imap_lgl(expected_names, function(name, i) {
        class(results[[name]]) == expected_types[i]
    })

    if (! all(types_match)) {
        stop("These results do not have the expected types")
    }

    # Check the requested field exists
    if (! field %in% results$fields) {
        stop(stringr::str_glue(
            "These results do not contain a field called \"{field}\""))
    }

    # Check the new column name doesn't exist in the results dataframes
    if (any(purrr::map_lgl(results$dfs, ~ colname %in% colnames(.)))) {
        stop(stringr::str_glue(
            "These results already contain a column called \"{colname}\""))
    }

    # Extract the codes from the uris
    uri_components <- stringr::str_split(results$uris[[field]], ":")
    codes <- purrr::map_chr(uri_components, ~ .[length(.)])

    # Add pseudo code for the "Total" row if necessary
    if (length(codes) != length(results$items[[field]])) {
        if (length(codes) == length(results$items[[field]]) - 1) {
            codes <- c(codes, "Total")
        } else {
            stop("Unable to add codes: cannot match items with uris")
        }
    }

    # Create lookup
    lookup <- tibble::tibble(
        labels = results$items[[field]],
        !!colname := codes)

    # Add the codes to each dataframe in the results list
    results$dfs <- purrr::map(results$dfs, function(df) {
        dplyr::left_join(df, lookup, by = stats::setNames(c("labels"), field))
    })

    # Return the results
    results
}

