#' Read Title and Footnote Metadata from an Excel File
#'
#' Reads and validates an Excel file containing header and footer information for
#' clinical tables, figures, or listings (TFLs). The function supports reading from
#' a specific sheet (e.g., "header") or the default sheet.
#'
#' @param filename A character string specifying the path to the Excel file.
#' @param sheetname Optional. A character string specifying the sheet name to read.
#' If `"header"`, only the first row is read (`n_max = 1`). If `NULL`, the default sheet is read.
#' @param ... Additional arguments passed to [readxl::read_excel()].
#'
#' @return A data frame with column names converted to uppercase. If `sheetname` is `NULL`,
#' the returned data frame is validated to ensure it contains the required columns:
#' `"PGMNAME"`, `"TTL1"`, `"SOURCE"`, and `"FOOT1"`.
#'
#' @details
#' The function performs the following steps:
#' - Validates the file path
#' - Reads the Excel sheet using `readxl::read_excel()`
#' - Converts all column names to uppercase
#' - If reading the full sheet (not just header), validates that required columns are present
#'
#' @examples
#' \dontrun{
#' # Read from the 'header' sheet
#' df_header <- read_tfile("titles_and_footnotes.xlsx", sheetname = "header")
#'
#' # Read the default sheet
#' df_all <- read_tfile("titles_and_footnotes.xlsx")
#' }
#'
#' @importFrom readxl read_excel
#' @export
read_tfile <- function(filename = NULL,
                        sheetname = NULL, ...) {
  if (!file.exists(filename)) stop("Input header_footer file does not exist! Check the filename and/or pathname and try again. \n", filename)

  tfile <- tryCatch(
    {
      if (sheetname == "header") {
        readxl::read_excel(filename, sheet = sheetname, n_max = 1, ...)
        } else {
          readxl::read_excel(filename, sheet = sheetname, ...)
        }
    },
    error = function(e) {
      message("An error occurred: ", e$message)
    }
  )
  # check the read result
  if (is.null(tfile)) {
    stop("Failed to read the sheet. Please check the file and sheet name.")
  } else {
    colnames(tfile) <- toupper(colnames(tfile))
    required_cols <- c("PGMNAME", "TTL1", "SOURCE", "FOOT1")
    if (is.null(sheetname) & !all(required_cols %in% colnames(tfile))) {
      stop("Input file misses required column(s).\n")
    }

  return(tfile)
  }
}

#' Read Title and Footnote Metadata from a CSV File
#'
#' Reads and validates a CSV file containing titles and footnotes for tables or figures,
#' and returns a data frame with standardized column names.
#'
#' The function is typically used in reporting workflows to load external metadata
#' (titles, subtitles, footnotes, source notes, etc.) into the analysis environment.
#'
#' @param filename A character string specifying the path to the CSV file.
#'
#' @return A data frame with column names converted to uppercase. The data frame should
#' contain at least the following required columns: `"PGMNAME"`, `"TTL1"`, `"SOURCE"`, and `"FOOT1"`.
#'
#' @details
#' This function performs the following steps:
#' - Checks whether the file exists
#' - Reads the CSV using `readr::read_csv()`
#' - Converts all column names to uppercase
#'
#' If the file does not exist or cannot be read, the function will stop with an informative error.
#'
#' @examples
#' \dontrun{
#' # Read a metadata file
#' df <- read_tfile_csv("data/titles_footnotes.csv")
#' head(df)
#' }
#'
#' @importFrom readr read_csv
#' @export
read_tfile_csv <- function(filename = NULL) {
  if (!file.exists(filename)) stop("Input header_footer file does not exist! Check the filename and/or pathname and try again. \n", filename)

  tfile <- tryCatch(
    {
      tfile <- read_csv(filename)
    },
    error = function(e) {
      message("An error occurred: ", e$message)
    }
  )
  # check the read result
  if (is.null(tfile)) {
    stop("Failed to read the sheet. Please check the file and sheet name.")
  } else {
    colnames(tfile) <- toupper(colnames(tfile))
    required_cols <- c("PGMNAME", "TTL1", "SOURCE", "FOOT1")
    return(tfile)
  }
}


