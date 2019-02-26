# statxplorer

statxplorer is an R package for downloading tabular data from the Department for Work and Pensions [Stat-Xplore](https://stat-xplore.dwp.gov.uk/webapi/jsf/login.xhtml) API. 

This package lets you send queries to the Stat-XPlore API and receive the results in a simple and manageable data structure, which includes dataframes of tidy data ready for analysis. The package supports a workflow of designing queries in the Stat-Xplore web interface (or by hand) and then using them to retrieve the data programatically from the API's [Table](https://stat-xplore.dwp.gov.uk/webapi/online-help/Open-Data-API-Table.html) endpoint. Queries can be loaded directly from files when you send a request for the data. Please note that this package does not currently support custom aggregate variables (see below).

This package has principally been developed to support automation and reproducible research in the House of Commons Library, but may be useful to other researchers who routinely work with DWP data. Let me know if you have any feedback or find any bugs.

## Installation

Install from GitHub using devtools.

```r
install.packages("devtools")
devtools::install_github("olihawkins/statxplorer")
```

## Setting an API key

To use Stat-Xplore you need an API key, which you can download after you [register](https://stat-xplore.dwp.gov.uk/webapi/jsf/user/register.xhtml) for an account. To use this package you will need to set the API key once for each session. You can do this either by providing the key directly using `set_api_key`, or loading the key from a file with `load_api_key`.

```r
library(statxplorer)

# Set API key with a string
set_api_key("APIKEYSTRING")

# Set API key from a file
load_api_key("api_key.txt")

```

## Sending queries

Stat-Xplore queries can be verbose. You can generate them yourself according to the [JSON schema](https://stat-xplore.dwp.gov.uk/webapi/online-help/Open-Data-API-Table.html), but it is easiest to start by designing a query in Stat-Xplore's web interface and downloading it as a JSON file (choose "Open Data API Query" as the download option in the web interface).

Suppose you have this query stored in a file called **uc-households.json**, which requests the number of households claiming Universal Credit in August 2018 broken down by family type.

```json
{
  "database" : "str:database:UC_Households",
  "measures" : [ "str:count:UC_Households:V_F_UC_HOUSEHOLDS" ],
  "recodes" : {
    "str:field:UC_Households:V_F_UC_HOUSEHOLDS:HNFAMILY_TYPE" : {
      "map" : [
          [ "str:value:UC_Households:V_F_UC_HOUSEHOLDS:HNFAMILY_TYPE:C_UC_FAMILY_TYPE:1" ],
          [ "str:value:UC_Households:V_F_UC_HOUSEHOLDS:HNFAMILY_TYPE:C_UC_FAMILY_TYPE:2" ],
          [ "str:value:UC_Households:V_F_UC_HOUSEHOLDS:HNFAMILY_TYPE:C_UC_FAMILY_TYPE:3" ],
          [ "str:value:UC_Households:V_F_UC_HOUSEHOLDS:HNFAMILY_TYPE:C_UC_FAMILY_TYPE:4" ],
          [ "str:value:UC_Households:V_F_UC_HOUSEHOLDS:HNFAMILY_TYPE:C_UC_FAMILY_TYPE:99" ] ],
      "total" : true
    },
    "str:field:UC_Households:F_UC_DATE:DATE_NAME" : {
      "map" : [ [ "str:value:UC_Households:F_UC_DATE:DATE_NAME:C_UC_DATE:201808" ] ],
      "total" : false
    }
  },
  "dimensions" : [
      [ "str:field:UC_Households:F_UC_DATE:DATE_NAME" ],
      [ "str:field:UC_Households:V_F_UC_HOUSEHOLDS:HNFAMILY_TYPE" ] ]
}
```

You can download the data for this query using `fetch_table`, either by passing the query as a string to the `fetch_table` function, or by loading it from a file with the `filename` argument.

```r
# Pass the query directly
library(readr)
query <- read_file("uc-households.json")
results <- fetch_table(query)

# Load the query from a file
results <- fetch_table(filename = "uc-households.json")
```

## Working with the results

The results of the query are returned as a list with the following elements:

- **measures** - the names of the measures for each dataset (*character*)
- **fields** - the names of categorical variables included in the data (*character*)
- **items** - the names of the categories or levels within each field (*list*)
- **uris** - the uris of the categories or levels within each field (*list*)
- **dfs** - a dataframe for each measure with the data in long form (*list*)

The results of the query shown above look like this:

```r
$measures
[1] "Households on Universal Credit"

$fields
[1] "Month"       "Family Type"

$items
$items$`Month`
[1] "August 2018"

$items$`Family Type`
[1] "Single, no child dependant"      "Single, with child dependant(s)"
[3] "Couple, no child dependant"      "Couple, with child dependant(s)"
[5] "Unknown or missing family type"  "Total"                          

$uris
$uris$`Month`
[1] "str:value:UC_Households:F_UC_DATE:DATE_NAME:C_UC_DATE:201808"

$uris$`Family Type`
[1] "str:value:UC_Households:V_F_UC_HOUSEHOLDS:HNFAMILY_TYPE:C_UC_FAMILY_TYPE:1" 
[2] "str:value:UC_Households:V_F_UC_HOUSEHOLDS:HNFAMILY_TYPE:C_UC_FAMILY_TYPE:2" 
[3] "str:value:UC_Households:V_F_UC_HOUSEHOLDS:HNFAMILY_TYPE:C_UC_FAMILY_TYPE:3" 
[4] "str:value:UC_Households:V_F_UC_HOUSEHOLDS:HNFAMILY_TYPE:C_UC_FAMILY_TYPE:4" 
[5] "str:value:UC_Households:V_F_UC_HOUSEHOLDS:HNFAMILY_TYPE:C_UC_FAMILY_TYPE:99"

$dfs
$dfs$`Households on Universal Credit`
# A tibble: 6 x 3
  Month       `Family Type`                         `Households on Universal Credit`
  <chr>       <chr>                                                            <dbl>
1 August 2018 Single, no child dependant                                      625010
2 August 2018 Single, with child dependant(s)                                 251797
3 August 2018 Couple, no child dependant                                       35651
4 August 2018 Couple, with child dependant(s)                                  91236
5 August 2018 Unknown or missing family type                                       0
6 August 2018 Total                                                          1003697
```

The results are provided as tidy datasets in `results$dfs`. The `dfs` list contains one dataframe for each measure that was requested in the query.

## Adding codes

Stat-Xplore provides ids for each variable in the URI strings. These URIs sometimes include codes that are externally recognised identifiers as the final token in the string. For example, URIs for geographical areas contain the ids that the Office for National Statistics uses for those areas at the end of the URI. These ids can be helpful for linking the data to other datasets.

To make it easier to extract and use these ids, the package has a function called `add_codes_for_field`. This will attempt to create a new column in each of the results dataframes containing the codes for a given field. To add a set of codes to the dataframes in the results, call `add_codes_for_field` with the results you want to modify, the name of the field for which you want to add codes, and the name of the column that will contain the codes.

```r
results <- add_codes_for_field(results, field = "Family Type", colname = "Family Type Codes")
```

If the given field does not exist, or the given column name already exists, the function will throw an error. 

## Custom aggregate variables

This package does not yet support queries that request custom aggregate variables in the results: `fetch_table` will throw an error if your query contains a custom aggergate variable. This is becuase the results from the Stat-Xplore API do not indicate that a custom aggegate has been used and instead list all of the individual items that have been aggregated to produce it, so the number of items and the number of values in the results do not match. I am working on a solution for this.

## API Issues

Every now and again the Stat-Xplore API fails to respond to a request that it normally returns correctly. This results in a timeout with the error message `Error in curl::curl_fetch_memory(url, handle = handle)`. This appears to be an issue with the server itself: waiting and trying again later normally resolves this issue. I have reported the problem to the Stat-Xplore team. 
