
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tflmetaR <img src="man/figure/logo.png" alt="tflmetaR logo" align="right" height="auto" width="200" />

## Overview

`tflmetaR` provides a simple interface for retrieving titles, headers,
and footnotes for tables, listings, and figures (TFLs) in clinical study
reports (CSRs) from a metadata file.

Best practices in programming recommend separating code from metadata to
improve readability, maintainability, and scalability. However, many R
scripts used for clinical reporting still hardcode TFL annotations
directly in the programs, making codebases difficult to manage and
extend.

`tflmetaR` bridges this gap. Although independent and self-contained, it
is compatible with the
[`{gridify}`](https://CRAN.R-project.org/package=gridify) and integrates
with the [Pharmaverse](https://pharmaverse.org/) ecosystem for
generating submission-ready statistical deliverables.

`tflmetaR` supports two workflows: a concise single-function interface
and a more flexible helper-function workflow.

## Installation

You can install the newest release version from CRAN:

``` r
install.packages("tflmetaR")
```

## Metadata File

The metadata file can be an Excel file (`.xlsx`, `.xls`) or a CSV file
(`.csv`), with standardized column names. Required columns are `PGMNAME`
(program name), `TTL1` (primary title), `FOOT1` (first footnote), and
`SOURCE` (data source). Additional columns for subtitles (`TTL2`,
`TTL3`, …), further footnotes (`FOOT2`, `FOOT3`, …), population
definitions, book mark and bylines are also supported. If your file uses
different column names, use `change_colname()` to remap them to the
expected names before passing the file to any `tflmetaR` function.

## Basic Workflow

The typical workflow is to retrieve annotation metadata from a metadata
file and apply it to a TFL object created with a package such as
[`{gt}`](https://gt.rstudio.com/),
[`{flextable}`](https://ardata-fr.github.io/flextable-book/), or
[`{ggplot2}`](https://ggplot2.tidyverse.org/). Metadata can be retrieved
in two ways.

**Option 1: Single-function interface**

Use `tflmetaR()` to retrieve the required metadata in a single call:

``` r
path    <- system.file("extdata", "sample_titles.xlsx", package = "tflmetaR")
pgmname <- "t_dm"

title_info <- tflmetaR(
  path,
  by_value         = pgmname,
  annotation       = "TITLE",
  add_footr_tstamp = FALSE
)

footnotes  <- tflmetaR(
  path,
  by_value         = pgmname,
  annotation       = "FOOTR",
  add_footr_tstamp = FALSE
)
```

**Option 2: Helper-function workflow (recommended)**

Read the metadata file once with `read_tfile()`, then retrieve the
required metadata with the `get_*()` helper functions. This avoids
repeated I/O operations when annotating multiple fields:

``` r
meta       <- read_tfile(filename = path)
title_info <- get_title(meta, pname = pgmname)
footnotes  <- get_footnote(meta, pname = pgmname, add_footr_tstamp = FALSE)
```

## Example

The following example creates a table using `{gt}` and annotates it with
titles and footnotes retrieved from a metadata file using `{tflmetaR}`.

``` r
library(tflmetaR)
library(gt)

# Locate example metadata file
path <- system.file("extdata", "sample_titles.xlsx", package = "tflmetaR")
pgmname <- "t_dm"

# Retrieve annotation metadata (Option 2: helper-function workflow)
meta <- read_tfile(filename = path)
title_info <- get_title(meta, pname = pgmname)
footnotes <- get_footnote(meta, pname = pgmname, add_footr_tstamp = FALSE)

# Create the annotated gt table
tbl <- mtcars |>
  head(5) |>
  gt::gt() |>
  gt::tab_header(
    title = title_info$TTL1[[1]],
    subtitle = gt::html(title_info$TTL2[[1]])
  ) |>
  gt::tab_footnote(footnote = footnotes$FOOT1[[1]]) |>
  gt::tab_footnote(footnote = footnotes$FOOT2[[1]])

tbl
```

<div id="iqwdpzgxqt" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#iqwdpzgxqt table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#iqwdpzgxqt thead, #iqwdpzgxqt tbody, #iqwdpzgxqt tfoot, #iqwdpzgxqt tr, #iqwdpzgxqt td, #iqwdpzgxqt th {
  border-style: none;
}
&#10;#iqwdpzgxqt p {
  margin: 0;
  padding: 0;
}
&#10;#iqwdpzgxqt .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#iqwdpzgxqt .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#iqwdpzgxqt .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}
&#10;#iqwdpzgxqt .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}
&#10;#iqwdpzgxqt .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#iqwdpzgxqt .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#iqwdpzgxqt .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#iqwdpzgxqt .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}
&#10;#iqwdpzgxqt .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}
&#10;#iqwdpzgxqt .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#iqwdpzgxqt .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#iqwdpzgxqt .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}
&#10;#iqwdpzgxqt .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#iqwdpzgxqt .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}
&#10;#iqwdpzgxqt .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}
&#10;#iqwdpzgxqt .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#iqwdpzgxqt .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#iqwdpzgxqt .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}
&#10;#iqwdpzgxqt .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#iqwdpzgxqt .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}
&#10;#iqwdpzgxqt .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#iqwdpzgxqt .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#iqwdpzgxqt .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#iqwdpzgxqt .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#iqwdpzgxqt .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#iqwdpzgxqt .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#iqwdpzgxqt .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#iqwdpzgxqt .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#iqwdpzgxqt .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#iqwdpzgxqt .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#iqwdpzgxqt .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#iqwdpzgxqt .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#iqwdpzgxqt .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#iqwdpzgxqt .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#iqwdpzgxqt .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#iqwdpzgxqt .gt_left {
  text-align: left;
}
&#10;#iqwdpzgxqt .gt_center {
  text-align: center;
}
&#10;#iqwdpzgxqt .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#iqwdpzgxqt .gt_font_normal {
  font-weight: normal;
}
&#10;#iqwdpzgxqt .gt_font_bold {
  font-weight: bold;
}
&#10;#iqwdpzgxqt .gt_font_italic {
  font-style: italic;
}
&#10;#iqwdpzgxqt .gt_super {
  font-size: 65%;
}
&#10;#iqwdpzgxqt .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#iqwdpzgxqt .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#iqwdpzgxqt .gt_indent_1 {
  text-indent: 5px;
}
&#10;#iqwdpzgxqt .gt_indent_2 {
  text-indent: 10px;
}
&#10;#iqwdpzgxqt .gt_indent_3 {
  text-indent: 15px;
}
&#10;#iqwdpzgxqt .gt_indent_4 {
  text-indent: 20px;
}
&#10;#iqwdpzgxqt .gt_indent_5 {
  text-indent: 25px;
}
&#10;#iqwdpzgxqt .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#iqwdpzgxqt div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_heading">
      <td colspan="11" class="gt_heading gt_title gt_font_normal" style>Table 2.1</td>
    </tr>
    <tr class="gt_heading">
      <td colspan="11" class="gt_heading gt_subtitle gt_font_normal gt_bottom_border" style>Sample Table Using mtcars Data</td>
    </tr>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="mpg">mpg</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="cyl">cyl</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="disp">disp</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="hp">hp</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="drat">drat</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="wt">wt</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="qsec">qsec</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="vs">vs</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="am">am</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="gear">gear</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="carb">carb</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="mpg" class="gt_row gt_right">21.0</td>
<td headers="cyl" class="gt_row gt_right">6</td>
<td headers="disp" class="gt_row gt_right">160</td>
<td headers="hp" class="gt_row gt_right">110</td>
<td headers="drat" class="gt_row gt_right">3.90</td>
<td headers="wt" class="gt_row gt_right">2.620</td>
<td headers="qsec" class="gt_row gt_right">16.46</td>
<td headers="vs" class="gt_row gt_right">0</td>
<td headers="am" class="gt_row gt_right">1</td>
<td headers="gear" class="gt_row gt_right">4</td>
<td headers="carb" class="gt_row gt_right">4</td></tr>
    <tr><td headers="mpg" class="gt_row gt_right">21.0</td>
<td headers="cyl" class="gt_row gt_right">6</td>
<td headers="disp" class="gt_row gt_right">160</td>
<td headers="hp" class="gt_row gt_right">110</td>
<td headers="drat" class="gt_row gt_right">3.90</td>
<td headers="wt" class="gt_row gt_right">2.875</td>
<td headers="qsec" class="gt_row gt_right">17.02</td>
<td headers="vs" class="gt_row gt_right">0</td>
<td headers="am" class="gt_row gt_right">1</td>
<td headers="gear" class="gt_row gt_right">4</td>
<td headers="carb" class="gt_row gt_right">4</td></tr>
    <tr><td headers="mpg" class="gt_row gt_right">22.8</td>
<td headers="cyl" class="gt_row gt_right">4</td>
<td headers="disp" class="gt_row gt_right">108</td>
<td headers="hp" class="gt_row gt_right">93</td>
<td headers="drat" class="gt_row gt_right">3.85</td>
<td headers="wt" class="gt_row gt_right">2.320</td>
<td headers="qsec" class="gt_row gt_right">18.61</td>
<td headers="vs" class="gt_row gt_right">1</td>
<td headers="am" class="gt_row gt_right">1</td>
<td headers="gear" class="gt_row gt_right">4</td>
<td headers="carb" class="gt_row gt_right">1</td></tr>
    <tr><td headers="mpg" class="gt_row gt_right">21.4</td>
<td headers="cyl" class="gt_row gt_right">6</td>
<td headers="disp" class="gt_row gt_right">258</td>
<td headers="hp" class="gt_row gt_right">110</td>
<td headers="drat" class="gt_row gt_right">3.08</td>
<td headers="wt" class="gt_row gt_right">3.215</td>
<td headers="qsec" class="gt_row gt_right">19.44</td>
<td headers="vs" class="gt_row gt_right">1</td>
<td headers="am" class="gt_row gt_right">0</td>
<td headers="gear" class="gt_row gt_right">3</td>
<td headers="carb" class="gt_row gt_right">1</td></tr>
    <tr><td headers="mpg" class="gt_row gt_right">18.7</td>
<td headers="cyl" class="gt_row gt_right">8</td>
<td headers="disp" class="gt_row gt_right">360</td>
<td headers="hp" class="gt_row gt_right">175</td>
<td headers="drat" class="gt_row gt_right">3.15</td>
<td headers="wt" class="gt_row gt_right">3.440</td>
<td headers="qsec" class="gt_row gt_right">17.02</td>
<td headers="vs" class="gt_row gt_right">0</td>
<td headers="am" class="gt_row gt_right">0</td>
<td headers="gear" class="gt_row gt_right">3</td>
<td headers="carb" class="gt_row gt_right">2</td></tr>
  </tbody>
  <tfoot>
    <tr class="gt_footnotes">
      <td class="gt_footnote" colspan="11"> ES = Enrolled Set</td>
    </tr>
    <tr class="gt_footnotes">
      <td class="gt_footnote" colspan="11"> Reference: Listing 2.1</td>
    </tr>
  </tfoot>
</table>
</div>

## Functions

- `tflmetaR()` — Retrieve metadata for a table, listing, or figure
- `read_tfile()` — Read metadata from Excel or CSV
- `get_title()` — Retrieve titles and subtitles
- `get_footnote()` — Retrieve footnotes
- `get_source()` — Retrieve data source
- `get_pop()` — Retrieve population
- `get_byline()` — Retrieve bylines
- `get_pgmname()` — Retrieve program name
- `get_ulheader()` — Retrieve upper-left header content
- `get_urheader()` — Retrieve upper-right header content
- `get_bookm()` — Retrieve bookmark
- `change_colname()` — Standardize column names in the metadata file
  using a JSON mapping configuration

## Related Packages

`tflmetaR` is designed to work alongside:

- [`{gridify}`](https://CRAN.R-project.org/package=gridify) — for
  composing and rendering annotated TFLs
- [Pharmaverse](https://pharmaverse.org/) — a curated collection of R
  packages for clinical reporting

## Getting Help

For usage questions, please refer to the package vignettes:

``` r
browseVignettes("tflmetaR")
```

## Acknowledgments

Along with the authors and contributors, thanks to the following people
for their support:

Alberto Montironi, Maciej Nasinski
