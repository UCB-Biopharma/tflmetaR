#' Single-call interface for retrieving annotation metadata
#'
#' Reads annotation metadata from an Excel (`.xls`, `.xlsx`) or CSV (`.csv`)
#' file and returns the requested metadata based on `annotation`.
#'
#' @param filename Path to the metadata file. Supported formats are
#'   `.xls`, `.xlsx`, and `.csv`.
#' @param sheetname For Excel files, the worksheet name or index to read.
#'   Ignored for CSV files. If `NULL` (default), the first worksheet is used.
#' @param by_column Name of the column used to identify the desired row.
#'   Matching is case-insensitive. Defaults to `"PGMNAME"` (program name).
#' @param by_value Value of `by_column` used to identify the desired row.
#'   For example, `by_column = "PGMNAME"` and `by_value = "t_dm.R"`
#'   retrieves the row where `PGMNAME == "t_dm.R"`.
#' @param oid Optional object identifier for additional row filtering.
#' @param annotation Type of annotation metadata to return:
#'   \itemize{
#'     \item `NULL` (default): return the full filtered row.
#'     \item `"TITLE"`: return title-related metadata (fields beginning with
#'       `"TTL"`, such as `TTL1`, `TTL2`, and `POPULATION` if available).
#'     \item `"FOOTR"`: return footnote metadata (fields beginning with `"FOOT"`).
#'       If `add_footr_tstamp = TRUE`, a timestamp line may be appended.
#'     \item `"SOURCE"`: return metadata fields beginning with `"SOURCE"`.
#'     \item `"BYLINE"`: return metadata fields beginning with `"BYLINE"`.
#'     \item `"POPULATION"`: return the `POPULATION` field.
#'     \item Any other string: return the matching field(s) by name.
#'   }
#' @param add_footr_tstamp Logical. If `TRUE` (default), appends a
#'   timestamp line to footnote output when `annotation = "FOOTR"`.
#'
#' @details
#' `tflmetaR()` provides a concise single-call interface for retrieving
#' annotation metadata. The metadata file is filtered to a single row by
#' matching `by_value` against `by_column` (default: `"PGMNAME"`). When
#' multiple rows share the same `by_column` value, `oid` can be used for
#' additional filtering. The returned metadata is then reduced to the columns
#' specified by `annotation`.
#'
#' For scripts that annotate multiple fields, the helper-function workflow is
#' recommended to avoid repeated file I/O: read the metadata file once with
#' [read_tfile()], then retrieve individual annotations with [get_title()],
#' [get_footnote()], and related helpers.
#'
#' @return A data frame containing the selected metadata.
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
#'   annotation = "TITLE"
#' )
#'
#' # Return footnote-related columns
#' tflmetaR(
#'   filename = csv_file,
#'   by_value = "t_dm",
#'   annotation = "FOOTR",
#'   add_footr_tstamp = FALSE
#' )
#'
#' # Return a specific column
#' tflmetaR(
#'   filename = csv_file,
#'   by_value = "t_dm",
#'   annotation = "SOURCE"
#' )
#'
#' # Return the full selected row
#' tflmetaR(
#'   filename = csv_file,
#'   by_value = "t_dm"
#' )
#'
#' @seealso
#'   [read_tfile()] to read metadata from Excel or CSV;
#'
#'   [get_title()], [get_footnote()], [get_source()], [get_pop()],
#'   [get_byline()], [get_pgmname()], [get_ulheader()], [get_urheader()],
#'   and [get_bookm()] for retrieving individual annotation fields;
#'
#'   [change_colname()] to standardize column names in the metadata file.
#'
#' @export
tflmetaR <- function(filename,
                     sheetname = NULL,
                     by_column = "PGMNAME",
                     by_value,
                     oid = NULL,
                     annotation = NULL,
                     add_footr_tstamp = TRUE) {
  if (missing(by_value)) {
    stop("`by_value` must be provided.", call. = FALSE)
  }

  read_tfile(filename, sheetname = sheetname) |>
    select_row(by_column, by_value, oid) |>
    select_cols(annotation, add_footr_tstamp)
}
