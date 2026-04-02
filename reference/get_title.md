# Get Title Metadata

Retrieves title-related fields (columns beginning with `"TTL"`, such as
`TTL1`, `TTL2`, and `POPULATION` if available) from a TFL metadata data
frame for a specified program name or table number.

## Usage

``` r
get_title(df, tnumber = NULL, pname = NULL, oid = NULL)
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

A data frame of the non-missing title-related metadata fields

## See also

[`read_tfile()`](read_tfile.md) to read metadata from Excel or CSV;

[`get_footnote()`](get_footnote.md), [`get_source()`](get_source.md),
[`get_pop()`](get_pop.md), [`get_byline()`](get_byline.md),
[`get_pgmname()`](get_pgmname.md), [`get_ulheader()`](get_ulheader.md),
[`get_urheader()`](get_urheader.md), and [`get_bookm()`](get_bookm.md)
for retrieving individual annotation fields;

[`tflmetaR()`](tflmetaR.md) for a single-call alternative.

## Examples

``` r
meta <- data.frame(
  PGMNAME = c("t_dm", "t_ae"),
  TTL1 = c("Table 14.1.1", "Table 14.3.1"),
  TTL2 = c("Subject Disposition", "Adverse Events"),
  SOURCE = c("ADSL", "ADAE"),
  FOOT1 = c(
    "All Randomized Subjects",
    "Safety Population"
  ),
  FOOT2 = c(
    "Reference: Listing 11.3",
    "Adverse events coded using MedDRA"
  )
)

get_title(meta, pname = "t_dm")
#>           TTL1                TTL2
#> 1 Table 14.1.1 Subject Disposition
get_title(meta, tnumber = "Table 14.3.1")
#>           TTL1           TTL2
#> 2 Table 14.3.1 Adverse Events
```
