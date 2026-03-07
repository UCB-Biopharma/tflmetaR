#' Read metadata from an Excel or CSV file
#'
#' Reads metadata from an Excel (`.xlsx`, `.xls`) or CSV (`.csv`) file,
#' standardizes column names to uppercase, and optionally validates that
#' required metadata columns are present.
#'
#' @param filename A character string specifying the path to the metadata file.
#'   Supported formats are `.xlsx`, `.xls`, and `.csv`.
#' @param sheetname For Excel files, the name or index of the worksheet to read.
#'   Ignored for CSV files. If `NULL` (default), the first worksheet is used.
#' @param validate Logical. If `TRUE` (default), the function checks that
#'   required metadata columns are present.
#' @param ... Additional arguments passed to
#'   \code{\link[readxl:read_excel]{readxl::read_excel}} for Excel files.
#'   Ignored for CSV files.
#'
#' @details
#' Column names in the returned data frame are converted to uppercase.
#'
#' If `validate = TRUE`, the input metadata must contain the following
#' required columns:
#' \describe{
#'   \item{PGMNAME}{Program name associated with the output.}
#'   \item{TTL1}{Primary title text.}
#'   \item{FOOT1}{Primary footnote text.}
#'   \item{SOURCE}{Source description for the output.}
#' }
#'
#' If any required column is missing, the function stops with an error.
#'
#' @return A data frame containing the imported metadata, with column names
#'   converted to uppercase.
#'
#' @examples
#' # Example 1: read a CSV metadata file
#' csv_file <- tempfile(fileext = ".csv")
#' write.csv(
#'   data.frame(
#'     pgmname = "t_dm",
#'     ttl1 = "Table 1. Demographics",
#'     foot1 = "Source: ADSL",
#'     foot2 = "*: Baseline record",
#'     source = "ADSL"
#'   ),
#'   csv_file,
#'   row.names = FALSE
#' )
#'
#' read_tfile(csv_file)
#'
#' # Example 2: read an Excel metadata file
#' xlsx_file <- tempfile(fileext = ".xlsx")
#' writexl::write_xlsx(
#'   data.frame(
#'     pgmname = "t_ae",
#'     ttl1 = "Table 2. Adverse Events",
#'     foot1 = "Source: ADAE",
#'     source = "ADAE"
#'   ),
#'   xlsx_file
#' )
#'
#' read_tfile(xlsx_file)
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


#' read CSV metadata file
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

