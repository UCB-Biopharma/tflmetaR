#' Retrieve metadata for a table, listing, or figure
#'
#' Reads annotation metadata from an Excel (`.xls`, `.xlsx`) or CSV (`.csv`)
#' file, filters to a single row using `by_column`, `by_value`, and optional
#' `oid`, and returns the requested columns based on `select_type`.
#'
#' @param filename Path to the metadata file. Supported extensions are
#'   `.xls`, `.xlsx`, and `.csv`.
#' @param sheetname For Excel files, the worksheet name or index to read.
#'   Ignored for CSV files. If `NULL` (default), the first worksheet is used.
#' @param by_column Column name used to filter the desired metadata row.
#'   The column name is matched case-insensitively against the metadata.
#'   Default is `"PGMNAME"` (program name).
#' @param by_value Value in `by_column` used to select the desired row.
#' @param oid Optional object identifier used for additional filtering.
#' @param select_type Type of metadata to return:
#'   \itemize{
#'     \item `NULL`: return the full selected row.
#'     \item `"TITLE"`: return title columns (for example, columns beginning
#'       with `"TTL"`) and related title metadata.
#'     \item `"FOOTR"`: return footnote columns (for example, columns beginning
#'       with `"FOOT"`). If `add_footr_tstamp = TRUE`, a timestamp/source line
#'       may be appended.
#'     \item otherwise: return the specified column or set of matching columns.
#'   }
#' @param add_footr_tstamp Logical. If `TRUE`, append timestamp/source
#'   information when `select_type = "FOOTR"`. Ignored otherwise.
#'
#' @details
#' This function provides a simple interface for retrieving titles,
#' footnotes, or other annotation metadata from a structured metadata file.
#'
#' Internally, the metadata file is read using [read_tfile()], after which
#' the appropriate row and columns are extracted based on the supplied
#' filtering and selection arguments.
#'
#' @return A data frame containing the selected row or columns.
#'
#' @examples
#' # Create a small example metadata file
#' csv_file <- tempfile(fileext = ".csv")
#' write.csv(
#'   data.frame(
#'     PGMNAME = "t_dm",
#'     TTL1 = "Table 14.1.1",
#'     TTL2 = "Subject Disposition",
#'     FOOT1 = "All Randomized Subjects",
#'     SOURCE = "ADSL"
#'   ),
#'   csv_file,
#'   row.names = FALSE
#' )
#'
#' # Return title-related columns
#' tflmetaR(
#'   filename = csv_file,
#'   by_value = "t_dm",
#'   select_type = "TITLE"
#' )
#'
#' # Return footnote-related columns
#' tflmetaR(
#'   filename = csv_file,
#'   by_value = "t_dm",
#'   select_type = "FOOTR",
#'   add_footr_tstamp = FALSE
#' )
#'
#' # Return a specific column
#' tflmetaR(
#'   filename = csv_file,
#'   by_value = "t_dm",
#'   select_type = "SOURCE"
#' )
#'
#' # Return the full selected row
#' tflmetaR(
#'   filename = csv_file,
#'   by_value = "t_dm"
#' )
#'
#' @export
tflmetaR <- function(filename,
                     sheetname = NULL,
                     by_column = "PGMNAME",
                     by_value,
                     oid = NULL,
                     select_type = NULL,
                     add_footr_tstamp = TRUE) {

  if (missing(by_value)) {
    stop("`by_value` must be provided.", call. = FALSE)
  }

  read_tfile(filename, sheetname = sheetname) |>
    select_row(by_column, by_value, oid) |>
    select_cols(select_type, add_footr_tstamp)
}

