#' Retrieve metadata for a table, listing, or figure
#'
#' Reads annotation metadata from an Excel (`.xls`, `.xlsx`) or CSV (`.csv`)
#' file, filters to a single row using `by_column`, `by_value`, and optional
#' `oid`, and returns the requested metadata based on `annotation`.
#'
#' @param filename Path to the metadata file. Supported extensions are
#'   `.xls`, `.xlsx`, and `.csv`.
#' @param sheetname For Excel files, the worksheet name or index to read.
#'   Ignored for CSV files. If `NULL` (default), the first worksheet is used.
#' @param by_column Name of the metadata field used to filter the desired row.
#'   Matching is case-insensitive. Default is `"PGMNAME"` (program name).
#' @param by_value Value of `by_column` used to identify the desired row.
#'   For example, `by_column = "PGMNAME"` and `by_value = "t_dm.R"`
#'   retrieves the row where `PGMNAME == "t_dm.R"`.
#' @param oid Optional object identifier used for additional filtering.
#' @param annotation Type of metadata to return:
#'   \itemize{
#'     \item `NULL`: return the full filtered row.
#'     \item `"TITLE"`: return title-related metadata (fields beginning with
#'       `"TTL"`, such as `TTL1`, `TTL2`, and `POPULATION` if available).
#'     \item `"FOOTR"`: return footnote metadata (fields beginning with `"FOOT"`).
#'       If `add_footr_tstamp = TRUE`, a timestamp/source line may be appended.
#'     \item `"SOURCE"`: return metadata fields beginning with `"SOURCE"`.
#'     \item `"BYLINE"`: return metadata fields beginning with `"BYLINE"`.
#'     \item `"POPULATION"`: return the `POPULATION` field.
#'     \item Any other value: return the specified field, or matching fields
#'       when applicable.
#'   }
#' @param add_footr_tstamp Logical. If `TRUE`, append timestamp/source
#'   information when `annotation = "FOOTR"`. Ignored otherwise.
#'
#' @details
#' This function provides a simple interface for retrieving titles,
#' footnotes, sources, and other annotation metadata from a structured
#' metadata file.
#'
#' Internally, the metadata file is read using [read_tfile()], then filtered
#' to a single row and reduced to the requested columns.
#'
#' @return A data frame containing the filtered row or selected metadata
#'   columns.
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

