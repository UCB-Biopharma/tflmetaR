---
title: TFootr / README.md
---
# The TFootr Package <a href="https://github.com/Cassinic/TFootr/"><img src="man/figure/logo.png" alt="TFootr logo" style="float:right;height:182.25px" align="right" height="232.25"></a>

<!-- badges: start -->
# [![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/TFootr)](https://CRAN.R-project.org/package=TFootr)
# [![Total Downloads](http://cranlogs.r-pkg.org/badges/grand-total/TFootr)](https://CRAN.R-project.org/package=TFootr)
# [![Downloads](http://cranlogs.r-pkg.org/badges/TFootr)](https://CRAN.R-project.org/package=TFootr)
# [![R-CMD-check](https://github.com/mayoverse/TFootr/workflows/R-CMD-check/badge.svg)](https://github.com/mayoverse/TFootr/actions)
<!-- badges: end -->

## Purpose


The main object of the `TFootr` package is to process titles (headers) and footnotes file and to offer an interface with commonly used table packages (e.g., `flextable`) or figure packages (e.g., `ggplot2`) to add titles and footers to clinical study reports (CSR) deliverables.


## Introduction

The "Separation of data from code" practice in programming paradigm allows for better organization, easier maintenance, and improved security by limiting how data can be accessed and modified within a system. In the pharmaceutical industry, and many other fields, there is often a need to annotate tables and figures with informative headers and footnotes, e.g.,  titles, subtitles, captions, footnotes, and other text elements that provide important context to the reports. However, it is not uncommon to see many R or RMarkdown programs having these embedded within the program code. It is a challenge to update titles or footnotes which are mixed with the program code, at the least.

The `TFootr` package can read in a separately maintained titles & footnotes spreadsheet and select the desired entry of titles and footnotes with either the program name, or TFL (table, figure, or listing) type and number. The titles or footnotes are placed in a list data structure and integrate seamlessly with the end user preferred table package (for example, "Flextable") or visualization program, e.g. ggplot2.



## Installation

You can install the development version from ...

```         
# git clone 
```



## More Info


Additional information...

## Vignettes

For more detailed examples and usage, check out the vignettes.



