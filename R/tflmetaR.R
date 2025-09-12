#' Get title and footnotes from an Excel file
#'
#' @param xlfile Filename including folder path and file extension (xls/xlsx).
#' @param sheet_name Sheet to read.
#' @param by_column Column name that is used to filter proper titles and
#'   footnotes. Default is "PGMNAME".
#' @param by_value Column value that is used to filter proper titles and
#'   footnotes.
#' @param select_type Either NULL to return the entire selected row, "title" to
#'   return columns starting with "TTL", "footr" to return columns starting with
#'   "FOOT", or a specific column name to return that particular column. The
#'   default is NULL.
#' @param add_footr_tstamp If TRUE, add timestamp and source information as the
#'   last line of the footnotes. It is only applied when select_type = "footr"
#' @param oid If not NULL, oid is used to filter the appropriate titles and
#'   footnotes. The default value is NULL.
#'
#' @return Returns a data frame
#' @export
#'
#' @examples
#' \dontrun{
#' (1) To get titles:  tflmetaR(filename, "Sheet1", by_value="t_dm", select_type="title")
#' (2) To get footers: tflmetaR(filename, "Sheet1", by_value="t_dm", select_type="footr")
#' (3) To get a specific cell value, i.e., SOURCE:
#'       tflmetaR(filename, "Sheet1", by_value="t_dm", select_type="source")
#' (4) To get the whole row: tflmetaR(filename, "Sheet1", by_value="t_dm")
#' }
tflmetaR <- function(xlfile,
                   sheet_name,
                   by_column="PGMNAME",
                   by_value,
                   select_type=NULL,
                   add_footr_tstamp=TRUE,
                   oid=NULL) {
  read_xlfile(xlfile, sheet_name) %>%
    select_row(by_column, by_value, oid) %>%
    select_cols(select_type, add_footr_tstamp)
}


