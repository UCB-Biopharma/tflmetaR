# Read metadata from an Excel or CSV file

Reads metadata from an Excel (`.xlsx`, `.xls`) or CSV (`.csv`) file,
standardizes column names to uppercase, and optionally validates that
required metadata columns are present.

## Usage

``` r
read_tfile(filename, sheetname = NULL, validate = TRUE, ...)
```

## Arguments

- filename:

  A character string specifying the path to the metadata file. Supported
  formats are `.xlsx`, `.xls`, and `.csv`.

- sheetname:

  For Excel files, the name or index of the worksheet to read. Ignored
  for CSV files. If `NULL` (default), the first worksheet is used.

- validate:

  Logical. If `TRUE` (default), the function checks that required
  metadata columns are present.

- ...:

  Additional arguments passed to
  [`readxl::read_excel`](https://readxl.tidyverse.org/reference/read_excel.html)
  for Excel files. Ignored for CSV files.

## Value

A data frame containing the imported metadata, with column names
converted to uppercase.

## Details

Column names in the returned data frame are converted to uppercase.

If `validate = TRUE`, the input metadata must contain the following
required columns:

- PGMNAME:

  Program name associated with the output.

- TTL1:

  Primary title text.

- FOOT1:

  Primary footnote text.

- SOURCE:

  Source description for the output.

If any required column is missing, the function stops with an error.

## See also

[`get_title()`](get_title.md), [`get_footnote()`](get_footnote.md),
[`get_source()`](get_source.md), [`get_pop()`](get_pop.md),
[`get_byline()`](get_byline.md), [`get_pgmname()`](get_pgmname.md),
[`get_ulheader()`](get_ulheader.md),
[`get_urheader()`](get_urheader.md), and [`get_bookm()`](get_bookm.md)
for retrieving individual annotation fields;

[`tflmetaR()`](tflmetaR.md) for a single-call alternative.

[`change_colname()`](change_colname.md) to standardize column names in
the metadata file.

## Examples

``` r
# Example 1: read a CSV metadata file
csv_file <- tempfile(fileext = ".csv")
write.csv(
  data.frame(
    pgmname = "t_dm",
    ttl1 = "Table 1. Demographics",
    foot1 = "Source: ADSL",
    foot2 = "*: Baseline record",
    source = "ADSL"
  ),
  csv_file,
  row.names = FALSE
)

read_tfile(csv_file)
#>   PGMNAME                  TTL1        FOOT1              FOOT2 SOURCE
#> 1    t_dm Table 1. Demographics Source: ADSL *: Baseline record   ADSL

# Example 2: read an Excel metadata file
xlsx_file <- tempfile(fileext = ".xlsx")
writexl::write_xlsx(
  data.frame(
    pgmname = "t_ae",
    ttl1 = "Table 2. Adverse Events",
    foot1 = "Source: ADAE",
    source = "ADAE"
  ),
  xlsx_file
)

read_tfile(xlsx_file)
#> # A tibble: 1 × 4
#>   PGMNAME TTL1                    FOOT1        SOURCE
#>   <chr>   <chr>                   <chr>        <chr> 
#> 1 t_ae    Table 2. Adverse Events Source: ADAE ADAE  
```
