#' statxplorer: A package for downloading data from the Stat-Xplore API
#'
#' The statxplorer package provides a suite of functions for downloading data
#' from the Department for Work and Pensions Stat-Xplore API.
#'
#' @docType package
#' @name statxplorer
#' @importFrom magrittr %>%
#' @importFrom rlang .data
NULL

# Tell R CMD check about new operators
if(getRversion() >= "2.15.1") {
    utils::globalVariables(c(".", ":="))
}
