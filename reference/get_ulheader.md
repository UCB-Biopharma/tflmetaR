# Get Upper-Left Header Text

Retrieves upper-left header fields (columns beginning with `"UL"`, such
as `UL1` and `UL2`) from metadata.

## Usage

``` r
get_ulheader(df)
```

## Arguments

- df:

  A data frame containing metadata.

## Value

A data frame of the non-missing Upper-Left header metadata fields.

## See also

[`read_tfile()`](https://ucb-biopharma.github.io/tflmetaR/reference/read_tfile.md)
to read metadata from Excel or CSV;

[`get_title()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_title.md),
[`get_footnote()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_footnote.md),
[`get_source()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_source.md),
[`get_pop()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_pop.md),
[`get_byline()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_byline.md),
[`get_pgmname()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_pgmname.md),
[`get_urheader()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_urheader.md),
and
[`get_bookm()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_bookm.md)
for retrieving individual annotation fields;

[`change_colname()`](https://ucb-biopharma.github.io/tflmetaR/reference/change_colname.md)
to standardize column names in the metadata file.

## Examples

``` r
meta <- data.frame(
  UL1 = "Drug X",
  UL2 = "Study 001",
  UR1 = "CONFIDENTIAL",
  UR2 = "VERSION: FINAL"
)

get_ulheader(meta)
#>      UL1       UL2
#> 1 Drug X Study 001
```
