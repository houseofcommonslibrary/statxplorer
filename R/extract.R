# Functions for extracting tabular data from a request

# Functions -------------------------------------------------------------------

extract_cube <- function(response, cube = 1) {

    fields <- response$fields
    cubes <- response$cubes

    variables <- list(
        rows = fields[[1]]$label,
        columns = fields[[2]]$label,
        wafers = fields[[3]]$label
    )

    labels <- list(
        rows = unlist(lapply(fields[[1]]$items, function(x) x$labels)),
        columns = unlist(lapply(fields[[2]]$items, function(x) x$labels)),
        wafers = unlist(lapply(fields[[3]]$items, function(x) x$labels))
    )

    dimensions <- list(
        rows = length(cubes[[cube]][[1]]),
        columns = length(cubes[[cube]][[1]][[1]]),
        wafers = length(cubes[[cube]][[1]][[1]][[1]])
    )

    wafers <- purrr::map(1:dimensions$wafers,
                         ~ extract_wafer(response, cube, .))

    list(
        variables = variables,
        labels = labels,
        dimensions = dimensions,
        wafers = wafers
    )
}

extract_wafer <- function(response, cube, wafer) {

    data <- response$cubes[[cube]][[1]]
    column_count <- length(data[[1]])

    fields <- response$fields
    row_labels <- unlist(lapply(fields[[1]]$items, function(x) x$labels))
    col_labels <- unlist(lapply(fields[[2]]$items, function(x) x$labels))
    row_labels_col_label <- fields[[1]]$label

    df <- purrr::map_dfc(1:column_count,
                         ~ extract_column(response, cube, ., wafer))

    colnames(df) <- col_labels
    row_labels_list <- list()
    row_labels_list[[row_labels_col_label]] <- row_labels
    dplyr::bind_cols(row_labels_list, df)
}

extract_column <- function(response, cube, column, wafer) {
    data <- response$cubes[[cube]][[1]]
    row_count <- length(data)
    purrr::map_dbl(1:row_count, ~ data[[.]][[column]][[wafer]])
}
