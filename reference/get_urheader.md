# Get Upper-Right Header Text

Retrieves upper-right header fields (columns beginning with `"UR"`, such
as `UR1` and `UR2`) from metadata.

## Usage

``` r
get_urheader(df)
```

## Arguments

- df:

  A data frame containing metadata.

## Value

A data frame of the non-missing upper-right header metadata fields.

## See also

[`read_tfile()`](read_tfile.md) to read metadata from Excel or CSV;

[`get_title()`](get_title.md), [`get_footnote()`](get_footnote.md),
[`get_source()`](get_source.md), [`get_pop()`](get_pop.md),
[`get_byline()`](get_byline.md), [`get_pgmname()`](get_pgmname.md),
[`get_ulheader()`](get_ulheader.md), and [`get_bookm()`](get_bookm.md)
for retrieving individual annotation fields;

[`change_colname()`](change_colname.md) to standardize column names in
the metadata file.

## Examples

``` r
meta <- data.frame(
  UL1 = "Drug X",
  UL2 = "Study 001",
  UR1 = "CONFIDENTIAL",
  UR2 = "VERSION: FINAL"
)

get_urheader(meta)
#>            UR1            UR2
#> 1 CONFIDENTIAL VERSION: FINAL
```
