# headr
Add headers and footers to clinical study TFLs / tlgs

## headr <a href="https://dev.azure.com/ucbalm/Data%20Mining/_git/plotation?version=GBmain"><img src="man/figures/logo.png" align="right" height="138" /></a>


The "Separation of data from code" practice in programming allows for better organization, easier maintenance, and improved security by limiting how data can be accessed and modified within a system. In the pharmaceutical industry, and many other fields, there is often a need to annotate tables and figures with informative headers and footnotes, e.g.,  titles, subtitles, captions, footnotes, and other text elements that provide important context to the reports. However, it is not uncommon to see many R or RMarkdown programs having these embedded within the program code. It is a challenge to update titles or footnotes which are mixed with the program code.

`headr` package can read in a centrally maintained "titles and footnotes" spreadsheet and select the correct entry of titles and footnotes with either the program name, or TFL (table, figure, or listing) type and number. The titles or footnotes are placed in list data structure and integrate seamlessly with your preferred table package (for example, "Flextable") or visualization program, e.g. ggplot2.



## Installation

You can install the released version with:

```         
# git clone 
```



## More Info
