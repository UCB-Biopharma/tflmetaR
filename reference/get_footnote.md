# Get Footnote Metadata

Retrieves footnote-related fields (columns beginning with `"FOOT"`, such
as `FOOT1` and `FOOT2`) from a TFL metadata frame for a specified
program name or TFL number.

## Usage

``` r
get_footnote(
  df,
  tnumber = NULL,
  pname = NULL,
  oid = NULL,
  add_footr_tstamp = TRUE
)
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

- add_footr_tstamp:

  Logical. If `TRUE`, append timestamp and source information as the
  last footnote line. Defaults to `TRUE`.

## Value

A data frame of the non-missing footnote-related metadata fields.

## See also

[`read_tfile()`](read_tfile.md) to read metadata from Excel or CSV;

[`get_title()`](get_title.md), [`get_source()`](get_source.md),
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

get_footnote(meta, pname = "t_dm", add_footr_tstamp = FALSE)
#>                     FOOT1                   FOOT2
#> 1 All Randomized Subjects Reference: Listing 11.3
get_footnote(meta, tnumber = "Table 14.3.1", add_footr_tstamp = FALSE)
#>               FOOT1                             FOOT2
#> 2 Safety Population Adverse events coded using MedDRA
```
