# Standardize column names in the metadata file

Reads an Excel metadata file, standardizes its column names to the
expected field names using a JSON mapping configuration, and writes the
result to a new Excel file.

## Usage

``` r
change_colname(input_xlsx, output_xlsx, config_path, sheet = NULL)
```

## Arguments

- input_xlsx:

  Path to the input Excel file.

- output_xlsx:

  Path to the output Excel file to create.

- config_path:

  Path to a JSON configuration file containing the column name mapping.

- sheet:

  Sheet index or name passed to
  [`readxl::read_excel`](https://readxl.tidyverse.org/reference/read_excel.html).
  If `NULL` (default), the first worksheet in the Excel file is used.

## Value

Invisibly returns the path to the output Excel file.

## Details

The JSON configuration file must contain an `aliases` field, which is a
named list mapping each canonical field name to a character vector of
acceptable input column name variants. For example:

    {
      "aliases": {
        "TTL1": ["Title 1", "Title_1"],
        "PGMNAME": ["Program Name", "program_name"]
      }
    }

Before matching, input column names and aliases are normalized by
converting to lowercase, trimming whitespace, and replacing underscores
with spaces. Columns that do not match any alias are preserved
unchanged. If multiple input columns map to the same canonical field
name, output names are made unique via
[`base::make.unique()`](https://rdrr.io/r/base/make.unique.html).

## See also

[`read_tfile()`](read_tfile.md) to read the standardized metadata file.

## Examples

``` r
input_file <- tempfile(fileext = ".xlsx")
output_file <- tempfile(fileext = ".xlsx")
config_file <- tempfile(fileext = ".json")

example_df <- data.frame(
  "Title_1" = "Summary of demographics",
  "Program Name" = "t_dm",
  check.names = FALSE
)

writexl::write_xlsx(example_df, input_file)

cfg <- paste0(
  "{",
  '  "aliases": {',
  '    "TTL1": ["Title 1"],',
  '    "PGMNAME": ["Program Name"]',
  "  }",
  "}"
)

writeLines(cfg, config_file)

change_colname(
  input_xlsx = input_file,
  output_xlsx = output_file,
  config_path = config_file
)

readxl::read_excel(output_file)
#> # A tibble: 1 × 2
#>   TTL1                    PGMNAME
#>   <chr>                   <chr>  
#> 1 Summary of demographics t_dm   
```
