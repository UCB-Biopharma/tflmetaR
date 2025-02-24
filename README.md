
# The `headr` Package <a href="https://github.com/Cassinic/headr/"><img src="man/figure/logo.png" alt="headr logo" style="float:right;height:182.25px" align="right" height="232.25"></a>

<!-- badges: start -->
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/headr)](https://CRAN.R-project.org/package=headr)
[![Total Downloads](http://cranlogs.r-pkg.org/badges/grand-total/headr)](https://CRAN.R-project.org/package=headr)
[![Downloads](http://cranlogs.r-pkg.org/badges/headr)](https://CRAN.R-project.org/package=headr)
[![R-CMD-check](https://github.com/mayoverse/headr/workflows/R-CMD-check/badge.svg)](https://github.com/mayoverse/headr/actions)
<!-- badges: end -->

## Overview


The main object of the `headr` package is to process titles (headers) and footnotes table and to offer an interface with commonly used table packages (e.g., `flextable`) or figure packages (e.g., `ggplot2`) to add headers and footers to clinical study reports (CSR) outputs.


## Introduction

The "Separation of data from code" practice in programming paradigm allows for better organization, easier maintenance, and improved security by limiting how data can be accessed and modified within a system. In the pharmaceutical industry, and many other fields, there is often a need to annotate tables and figures with informative headers and footnotes, e.g.,  titles, subtitles, captions, footnotes, and other text elements that provide important context to the reports. However, it is not uncommon to see many R or RMarkdown programs having these embedded within the program code. It is a challenge to update titles or footnotes which are mixed with the program code.

The `headr` package can read in a separately maintained titles spreadsheet and select the correct entry of titles and footnotes with either the program name, or TFL (table, figure, or listing) type and number. The titles or footnotes are placed in list data structure and integrate seamlessly with your preferred table package (for example, "Flextable") or visualization program, e.g. ggplot2.



## Installation

You can install the development version from Gibhub.

```         
# git clone 
```



## More Info


see also

## Vignettes

vignettess



