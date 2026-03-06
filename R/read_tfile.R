#' Reads metadata from an Excel (`.xlsx`, `.xls`) or CSV (`.csv`) file and
#' standardizes column names to uppercase. The function also validates that
#' required metadata columns are present in the input file.
#'
#' @param filename A character string specifying the path to the metadata file.
#'   Supported formats are `.xlsx`, `.xls`, and `.csv`.
#' @param sheetname For Excel files, the name or index of the worksheet to read.
#'   Ignored when reading CSV files. Default is `NULL`, which uses the first
#'   sheet.
#' @param validate Logical. If `TRUE` (default), the function checks that required
#'   metadata columns are present.
#' @param ... Additional arguments passed to [readxl::read_excel()].
#'   For CSV files, ... is ignored.
#'
#' @return A data frame containing the metadata with column names converted
#'   to uppercase.
#'
#'
#' @details
#' The input metadata file must contain the following required columns:
#' \describe{
#'   \item{PGMNAME}{Program name associated with the TFL output.}
#'   \item{TTL1}{Primary title text.}
#'   \item{FOOT1}{Primary footnote text.}
#'   \item{SOURCE}{Source description for the output.}
#' }
#'
#' If `validate = TRUE` and any required column is missing, the function
#' stops with an error.
#'
#' @examples
#' \dontrun{
#' filename <- system.file(
#'    "extdata",
#'    "st_titles.xls",
#'    package = "tflmetaR"
#'  )
#' # Read from the 'header' sheet
#' data <- read_tfile(filename, sheetname = "header")
#' }
#'
#'
#' @export
read_tfile <- function(filename, sheetname = NULL, validate = TRUE, ...) {
  if (!is.character(filename) || length(filename) != 1L || is.na(filename) || filename == "") {
    stop("`filename` must be a non-empty character string.", call. = FALSE)
  }

  if (!file.exists(filename)) {
    stop("File does not exist: ", filename, call. = FALSE)
  }

  ext <- tolower(tools::file_ext(filename))
  required_cols <- c("PGMNAME", "TTL1", "FOOT1", "SOURCE")

  data <- switch(
    ext,
    "xlsx" = readxl::read_excel(filename, sheet = sheetname, ...),
    "xls"  = readxl::read_excel(filename, sheet = sheetname, ...),
    "csv"  = read_tfile_csv(filename),
    stop("Unsupported file type. Only .xlsx, .xls, and .csv are allowed.", call. = FALSE)
  )

  # Standardize column names to uppercase
  names(data) <- toupper(names(data))

  if (isTRUE(validate)) {
    check_required_cols(data, required_cols)
  }

  data
}


#' Internal helper: read CSV metadata file
#' @noRd
read_tfile_csv <- function(filename) {
  if (!file.exists(filename)) {
    stop("File does not exist: ", filename, call. = FALSE)
  }
  utils::read.csv(filename, stringsAsFactors = FALSE, check.names = FALSE)
}


#' @noRd
check_required_cols <- function(data, required_cols) {
  if (is.null(names(data))) {
    stop("Input metadata must have column names.", call. = FALSE)
  }

  data_cols <- toupper(names(data))
  required_cols <- toupper(required_cols)

  missing_cols <- setdiff(required_cols, data_cols)

  if (length(missing_cols) > 0) {
    stop(
      "Input metadata file has required column(s) missing: ",
      paste(missing_cols, collapse = ", "),
      call. = FALSE
    )
  }
  invisible(TRUE)
}

