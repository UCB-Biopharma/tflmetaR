---
title: README.md

---

# tfootr <a href="https://github.com/Cassinic/tfootr/"><img src="man/figure/logo.png" alt="tfootr logo" align="right" height="140"></a>

<!-- badges: start -->
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/tfootr)](https://CRAN.R-project.org/package=tfootr)
[![Total Downloads](http://cranlogs.r-pkg.org/badges/grand-total/tfootr)](https://CRAN.R-project.org/package=tfootr)
[![Monthly Downloads](http://cranlogs.r-pkg.org/badges/tfootr)](https://CRAN.R-project.org/package=tfootr)
[![R-CMD-check](https://github.com/Cassinic/tfootr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Cassinic/tfootr/actions)
<!-- badges: end -->

## 📌 Overview

`tfootr` is an R package designed to simplify the management and application of titles, subtitles, and footnotes in clinical study report (CSR) deliverables. It provides a structured interface for separating content metadata (like table headers and footers) from the code that generates the actual tables or figures.

This approach aligns with best practices in software design by supporting **separation of data and code**, improving maintainability, reusability, and reducing the risk of hard-coded text in analysis scripts.

---

## ✨ Features

- Read and validate title/footnote metadata from Excel or CSV files
- Select entries by program name or TFL number
- Return metadata as lists for integration with table packages (e.g., `flextable`) and plotting tools (e.g., `ggplot2`)
- Supports upper-left (UL) and upper-right (UR) headers, titles, subtitles, populations, footnotes, and data sources

---

## 🔧 Installation

You can install the development version of `tfootr` from GitHub:

```r
# Install devtools if you don't have it
install.packages("devtools")

# Install tfootr from GitHub
devtools::install_github("..../tfootr")
```

---

## 📚 Getting Started

```r
library(tfootr)

# Read metadata from a CSV file
meta <- read_tfile_csv("metadata/titles_footnotes.csv")
or
meta <- read_tfile("metadata/titles_footnotes.xls")

# Extract title and footnote for a specific table
title <- get_title(meta, tnumber = "Table 1.1")
footnotes <- get_footnote(meta, tnumber = "Table 1.1")

# Use with flextable (example)
library(flextable)
flextable(iris) %>%
  set_caption(title$TTL1) %>%
  add_footer_lines(values = footnotes)
```

---

## 🧪 Vignettes

Check out the vignettes for detailed usage and advanced features:

```r
browseVignettes("tfootr")
```

---

## 💡 Why `tfootr`?

In many industries — especially pharmaceutical clinical reporting — table titles and footnotes are often buried inside code files. This makes updates tedious and error-prone. `tfootr` addresses this by:

- Centralizing and externalizing metadata
- Enabling quick updates without touching source code
- Supporting audit-friendly workflows

---

## 📄 License

This package is licensed under the MIT License. See [LICENSE](LICENSE) for more information.

---

## 🤝 Contributing

Contributions are welcome! If you’d like to report a bug, request a feature, or submit a pull request, please visit the [GitHub issues page](https://github.com/Cassinic/tfootr/issues).

---

## 🔗 Related Packages

- [`flextable`](https://davidgohel.github.io/flextable/)
- [`ggplot2`](https://ggplot2.tidyverse.org/)
- [`readxl`](https://readxl.tidyverse.org/)
- [`readr`](https://readr.tidyverse.org/)

---

## 📬 Contact

For questions, suggestions, or collaboration ideas, feel free to reach out via GitHub or open an issue.

```

---



