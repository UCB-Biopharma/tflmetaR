# Get Source Metadata

Retrieves source-related fields (for example, `SOURCE`) from metadata
for a specified program name or TFL number.

## Usage

``` r
get_source(df, tnumber = NULL, pname = NULL, oid = NULL)
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

A data frame of the non-missing source fields.

## See also

[`read_tfile()`](https://ucb-biopharma.github.io/tflmetaR/reference/read_tfile.md)
to read metadata from Excel or CSV;

[`get_title()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_title.md),
[`get_footnote()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_footnote.md),
[`get_pop()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_pop.md),
[`get_byline()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_byline.md),
[`get_pgmname()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_pgmname.md),
[`get_ulheader()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_ulheader.md),
[`get_urheader()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_urheader.md),
and
[`get_bookm()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_bookm.md)
for retrieving individual annotation fields;

[`tflmetaR()`](https://ucb-biopharma.github.io/tflmetaR/reference/tflmetaR.md)
for a single-call alternative.

## Examples

``` r
meta <- data.frame(
  PGMNAME = c("t_dm", "t_ae"),
  TTL1 = c("Table 14.1.1", "Table 14.3.1"),
  SOURCE = c("ADSL", "ADAE"),
  FOOT1 = c("ITT Population", "Safety Population")
)

get_source(meta, pname = "t_dm")
#>   SOURCE
#> 1   ADSL
get_source(meta, tnumber = "Table 14.3.1")
#>   SOURCE
#> 2   ADAE
```
