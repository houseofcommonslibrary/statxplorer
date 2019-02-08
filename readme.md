# statxplorer

statxplorer is an R package for downloading data from the Department for Work and Pensions [Stat-Xplore](https://stat-xplore.dwp.gov.uk/webapi/jsf/login.xhtml) API. 

The package makes it easy to send queries to the API and receive a simple list of the results, which includes a dataframe of tidy data ready for analysis. The package supports a workflow of designing queries in the Stat-Xplore web interface (or by hand) and then using them to retrieve the data programatically. Queries can be loaded directly from files in the call to fetch data from the API.

This package has principally been developed to support automation and reproducible research in the House of Commons Library, but may be useful to other researchers who routinely work with DWP data. It is currently a work in progess, but is already functional. More documentation to follow soon.
