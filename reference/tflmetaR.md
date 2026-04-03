# Single-call interface for retrieving annotation metadata

Reads annotation metadata from an Excel (`.xls`, `.xlsx`) or CSV
(`.csv`) file and returns the requested metadata based on `annotation`.

## Usage

``` r
tflmetaR(
  filename,
  sheetname = NULL,
  by_column = "PGMNAME",
  by_value,
  oid = NULL,
  annotation = NULL,
  add_footr_tstamp = TRUE
)
```

## Arguments

- filename:

  Path to the metadata file. Supported formats are `.xls`, `.xlsx`, and
  `.csv`.

- sheetname:

  For Excel files, the worksheet name or index to read. Ignored for CSV
  files. If `NULL` (default), the first worksheet is used.

- by_column:

  Name of the column used to identify the desired row. Matching is
  case-insensitive. Defaults to `"PGMNAME"` (program name).

- by_value:

  Value of `by_column` used to identify the desired row. For example,
  `by_column = "PGMNAME"` and `by_value = "t_dm.R"` retrieves the row
  where `PGMNAME == "t_dm.R"`.

- oid:

  Optional object identifier for additional row filtering.

- annotation:

  Type of annotation metadata to return:

  - `NULL` (default): return the full filtered row.

  - `"TITLE"`: return title-related metadata (fields beginning with
    `"TTL"`, such as `TTL1`, `TTL2`, and `POPULATION` if available).

  - `"FOOTR"`: return footnote metadata (fields beginning with
    `"FOOT"`). If `add_footr_tstamp = TRUE`, a timestamp line may be
    appended.

  - `"SOURCE"`: return metadata fields beginning with `"SOURCE"`.

  - `"BYLINE"`: return metadata fields beginning with `"BYLINE"`.

  - `"POPULATION"`: return the `POPULATION` field.

  - Any other string: return the matching field(s) by name.

- add_footr_tstamp:

  Logical. If `TRUE` (default), appends a timestamp line to footnote
  output when `annotation = "FOOTR"`.

## Value

A data frame containing the selected metadata.

## Details

`tflmetaR()` provides a concise single-call interface for retrieving
annotation metadata. The metadata file is filtered to a single row by
matching `by_value` against `by_column` (default: `"PGMNAME"`). When
multiple rows share the same `by_column` value, `oid` can be used for
additional filtering. The returned metadata is then reduced to the
columns specified by `annotation`.

For scripts that annotate multiple fields, the helper-function workflow
is recommended to avoid repeated file I/O: read the metadata file once
with
[`read_tfile()`](https://ucb-biopharma.github.io/tflmetaR/reference/read_tfile.md),
then retrieve individual annotations with
[`get_title()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_title.md),
[`get_footnote()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_footnote.md),
and related helpers.

## See also

[`read_tfile()`](https://ucb-biopharma.github.io/tflmetaR/reference/read_tfile.md)
to read metadata from Excel or CSV;

[`get_title()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_title.md),
[`get_footnote()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_footnote.md),
[`get_source()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_source.md),
[`get_pop()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_pop.md),
[`get_byline()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_byline.md),
[`get_pgmname()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_pgmname.md),
[`get_ulheader()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_ulheader.md),
[`get_urheader()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_urheader.md),
and
[`get_bookm()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_bookm.md)
for retrieving individual annotation fields;

[`change_colname()`](https://ucb-biopharma.github.io/tflmetaR/reference/change_colname.md)
to standardize column names in the metadata file.

## Examples

``` r
# Create a small example metadata file
csv_file <- tempfile(fileext = ".csv")
write.csv(
  data.frame(
    PGMNAME = "t_dm",
    TTL1 = "Table 14.1.1",
    TTL2 = "Subject Disposition",
    FOOT1 = "All Randomized Subjects",
    SOURCE = "ADSL"
  ),
  csv_file,
  row.names = FALSE
)

# Return title-related columns
tflmetaR(
  filename = csv_file,
  by_value = "t_dm",
  annotation = "TITLE"
)
#>           TTL1                TTL2
#> 1 Table 14.1.1 Subject Disposition

# Return footnote-related columns
tflmetaR(
  filename = csv_file,
  by_value = "t_dm",
  annotation = "FOOTR",
  add_footr_tstamp = FALSE
)
#>                     FOOT1
#> 1 All Randomized Subjects

# Return a specific column
tflmetaR(
  filename = csv_file,
  by_value = "t_dm",
  annotation = "SOURCE"
)
#>   SOURCE
#> 1   ADSL

# Return the full selected row
tflmetaR(
  filename = csv_file,
  by_value = "t_dm"
)
#>   PGMNAME         TTL1                TTL2                   FOOT1 SOURCE
#> 1    t_dm Table 14.1.1 Subject Disposition All Randomized Subjects   ADSL
```
