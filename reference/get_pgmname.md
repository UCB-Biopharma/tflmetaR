# Get Program Name Metadata

Retrieves the program name field (`PGMNAME`) from metadata for a
specified program name or TFL number.

## Usage

``` r
get_pgmname(df, tnumber = NULL, pname = NULL, oid = NULL)
```

## Arguments

- df:

  A data frame containing TFL metadata.

- tnumber:

  An optional character string specifying the TFL number stored in
  `TTL1`, such as `"Table 14.1.1"`.

- pname:

  An optional character string specifying the program name stored in
  `PGMNAME`.

  Exactly one of `tnumber` or `pname` must be supplied.

- oid:

  An optional character string specifying the object ID stored in `OID`.
  Use this when multiple rows match the program name.

## Value

A data frame of the non-missing program name field.

## See also

[`read_tfile()`](https://ucb-biopharma.github.io/tflmetaR/reference/read_tfile.md)
to read metadata from Excel or CSV;

[`get_title()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_title.md),
[`get_footnote()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_footnote.md),
[`get_source()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_source.md),
[`get_pop()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_pop.md),
[`get_byline()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_byline.md),
[`get_ulheader()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_ulheader.md),
[`get_urheader()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_urheader.md),
and
[`get_bookm()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_bookm.md)
for retrieving individual annotation fields;

[`change_colname()`](https://ucb-biopharma.github.io/tflmetaR/reference/change_colname.md)
to standardize column names in the metadata file.

## Examples

``` r
meta <- data.frame(
  PGMNAME = c("t_dm", "t_ae"),
  TTL1 = c("Table 14.1.1", "Table 14.3.1"),
  SOURCE = c("ADSL", "ADAE"),
  FOOT1 = c("ITT Population", "Safety Population")
)

get_pgmname(meta, pname = "t_dm")
#>   PGMNAME
#> 1    t_dm
get_pgmname(meta, tnumber = "Table 14.3.1")
#>   PGMNAME
#> 2    t_ae
```
