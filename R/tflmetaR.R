#' Retrieve titles and footnotes from a metadata file
#'
#' Read annotation metadata (titles/footnotes/etc.) from either an Excel file
#' (\code{.xls} / \code{.xlsx}) or a CSV file (\code{.csv}). The function first
#' reads the source file, then filters to a single row using \code{by_column},
#' \code{by_value}, and optional \code{oid}, and finally selects the requested
#' set of columns via \code{select_type}.
#'
#' @param file A file path to the metadata source. Supported extensions are
#'   \code{.xls}, \code{.xlsx}, and \code{.csv}.
#' @param sheet Sheet name to read when \code{file} is an Excel file.
#'   Ignored when \code{file} is a CSV.
#' @param by_column Column name used to filter the appropriate titles and
#'   footnotes. Default is \code{"PGMNAME"}.
#' @param by_value Value in \code{by_column} used to filter the appropriate
#'   titles and footnotes.
#' @param select_type Selection type:
#'   \itemize{
#'     \item \code{NULL}: return the entire selected row (all columns).
#'     \item \code{"TITLE"}: return columns starting with \code{"TTL"} plus \code{POPULATION}.
#'     \item \code{"FOOTR"}: return columns starting with \code{"FOOT"} (and optionally add a timestamp line).
#'     \item Otherwise: a specific column name to return that column.
#'   }
#'   Matching is case-insensitive (internally uppercased).
#' @param add_footr_tstamp If \code{TRUE}, add timestamp/source information as
#'   the last line of the footnotes. Only applied when \code{select_type = "FOOTR"}.
#' @param oid If not \code{NULL}, further filter by \code{OID == oid}.
#'
#' @return A data frame containing the selected row/columns.
#'
#' @details
#' The input file must exist. Unsupported file extensions result in an error.
#' For CSV sources, \code{sheet} is ignored.
#'
#' @examples
#' \dontrun{
#' # Excel:
#' # (1) Get titles
#' tflmetaR("metadata.xlsx", sheet = 1, by_value = "t_dm", select_type = "TITLE")
#'
#' # (2) Get footnotes
#' tflmetaR("metadata.xlsx", sheet = "Sheet1", by_value = "t_dm", select_type = "FOOTR")
#'
#' # (3) Get a specific column sheet, e.g., SOURCE
#' tflmetaR("metadata.xlsx", sheet_name = "Sheet1", by_value = "t_dm", select_type = "SOURCE")
#'
#' # (4) Get the whole row
#' tflmetaR("metadata.xlsx", sheet = "Sheet1", by_value = "t_dm")
#'
#' # CSV:
#' tflmetaR("metadata.csv", by_value = "t_dm", select_type = "TITLE")
#' }
#'
#' @export
tflmetaR <- function(file,
                     sheet = NULL,
                     by_column = "PGMNAME",
                     by_value,
                     select_type = NULL,
                     add_footr_tstamp = TRUE,
                     oid = NULL) {
  if (!file.exists(file)) {
    stop("File does not exist: ", file)
  }

  ext <- tolower(tools::file_ext(file))

  data <- switch(
    ext,
    "xlsx" = readxl::read_excel(file, sheet = sheet),
    "xls"  = readxl::read_excel(file, sheet = sheet),
    "csv"  = utils::read.csv(file, stringsAsFactors = FALSE, check.names = FALSE),
    stop("Unsupported file type. Only .xlsx, .xls, and .csv are allowed.")
  )

  colnames(data) <- toupper(colnames(data))
  required_cols <- c("PGMNAME", "TTL1", "FOOT1", "SOURCE")

  if (!all(required_cols %in% colnames(data)))
    stop("Input file has required column(s) missing.\n")


  data |>
    tflmetaR::select_row(by_column, by_value, oid) %>%
    tflmetaR::select_cols(select_type, add_footr_tstamp)
}


