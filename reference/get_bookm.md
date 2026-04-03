# Get bookmark text for a table, listing, or figure

Returns bookmark text from metadata for a specified output. The function
first identifies the matching row in `df` using `pname` or `tnumber`. If
a non-missing `BOOKM` value is available, that value is returned.
Otherwise, the function falls back to
[`get_title()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_title.md)
and combines the returned title components into a single bookmark
string.

## Usage

``` r
get_bookm(
  df,
  tnumber = NULL,
  pname = NULL,
  oid = NULL,
  abbrev_file = NULL,
  max_length = 180
)
```

## Arguments

- df:

  A data frame containing metadata.

- tnumber:

  An optional character string specifying the TFL number stored in
  `TTL1`, such as `"Table 14.1.1"`.

- pname:

  An optional character string specifying the program name stored in
  `PGMNAME`.

  Exactly one of `tnumber` or `pname` must be supplied.

- oid:

  An optional character string specifying the object identifier.

- abbrev_file:

  Optional path to an Excel file containing abbreviation mappings. The
  file should contain three columns corresponding to scope, phrase, and
  abbreviation. If `NULL`, no abbreviation table is applied.

- max_length:

  Maximum allowed bookmark length. Default is `180`.

## Value

A character string containing sanitized bookmark text.

## Details

The bookmark text is sanitized by removing characters that are not
suitable for bookmark use. If the result exceeds `max_length`, the
function attempts to shorten it using abbreviation mappings from
`abbrev_file`. If the bookmark is still too long, it is truncated at a
word boundary up to `max_length` characters.

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
and
[`get_urheader()`](https://ucb-biopharma.github.io/tflmetaR/reference/get_urheader.md)
for retrieving individual annotation fields;

[`change_colname()`](https://ucb-biopharma.github.io/tflmetaR/reference/change_colname.md)
to standardize column names in the metadata file.

## Examples

``` r
# Example 1: return BOOKM when it is present
df1 <- data.frame(
  TTL1 = "Figure 1.1",
  PGMNAME = "f_km.R",
  BOOKM = "KM_PLOT"
)

get_bookm(df1, pname = "f_km.R")
#> [1] "KM_PLOT"
get_bookm(df1, tnumber = "Figure 1.1")
#> [1] "KM_PLOT"

# Example 2: fall back to title text when BOOKM is missing
df2 <- data.frame(
  TTL1 = "Adverse Events",
  TTL2 = "Safety Population",
  PGMNAME = "t_ae",
  BOOKM = NA
)

get_bookm(df2, pname = "t_ae")
#> [1] "Adverse Events_Safety Population"

# Example 3: invalid characters are removed
df3 <- data.frame(
  TTL1 = "Listing 3. Laboratory Results",
  PGMNAME = "l_lab",
  BOOKM = "Lab: ALT/AST * Overview?"
)

get_bookm(df3, pname = "l_lab")
#> [1] "Lab ALTAST  Overview"
```
