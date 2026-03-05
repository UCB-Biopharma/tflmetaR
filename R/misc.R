#' Select a Single Row from a Data Frame Based on Column Value(s)
#'
#' Filters a data frame to return a single matching row based on a specified column-value pair,
#' with an optional filter on `OID`. Ensures the result is unique and non-empty.
#'
#' @param data A data frame to be filtered.
#' @param by_column A string. The name of the column to filter on.
#' @param by_value The value to match in the specified column.
#' @param oid Optional. A specific `OID` value to further filter the result (default is `NULL`).
#'
#' @return A data frame containing exactly one row that matches the filtering criteria.
#' Throws an error if no row is found or if multiple rows match the criteria.
#'
#' @details
#' This function is typically used to extract a specific metadata entry, such as
#' a title or footnote definition, from a table. It ensures that the result is unique
#' and meets the expected structure for further processing.
#'
#' @examples
#' \dontrun{
#' select_row(metadata_df, by_column = "PGMNAME", by_value = "t_dm", oid = "T001")
#' }
#'
#' @export
select_row <- function(data, by_column, by_value, oid=NULL) {
  if (!is.character(by_column) || length(by_column) != 1) {
    stop("`by_column` must be a single character string.", call. = FALSE)
  }
  if (!by_column %in% names(data)) {
    stop("`by_column` not found in data: ", by_column, call. = FALSE)
  }

  df <- data[data[[by_column]] %in% by_value, , drop = FALSE]

  if (!is.null(oid)) {
    if (!"OID" %in% names(df)) {
      stop("Column `OID` not found in data but `oid` was provided.", call. = FALSE)
    }
    df <- df[df[["OID"]] == oid, , drop = FALSE]
  }

  if (nrow(df) == 0) {
    stop("No row is found. Check the title and footnote file and try again.\n")
  } else if (nrow(df) > 1) {
    stop("Non unique entry generated. Check the title and footnote file and try again.\n")
  }
  df
}

#' Select Metadata Columns from a Data Frame
#'
#' Selects specific columns from a metadata data frame based on the type of content desired
#' (e.g., titles, footnotes, or a named column). Optionally appends a timestamp to footnotes.
#'
#' @param data A data frame containing metadata (e.g., titles, footnotes, sources).
#' @param select_type A string indicating the type of columns to select. Can be `"TITLE"`,
#' `"FOOTR"`, or a specific column name. If `NULL`, all columns are returned.
#' @param add_footr_tstamp Logical or a function. If `TRUE`, a function named `add_footr_tstamp()`
#' is called to append timestamps to footnotes. Defaults to `TRUE`.
#'
#' @return A list of selected columns from the input data, with `NA` values removed.
#'
#' @details
#' - If `select_type` is `"TITLE"`, selects all columns starting with `"TTL"` and the `POPULATION` column.
#' - If `"FOOTR"`, selects columns starting with `"FOOT"` and optionally appends timestamp from `SOURCE`.
#' - If a specific column name is provided, attempts to select it directly.
#' - If `select_type` is `NULL`, returns all columns.
#'
#' @examples
#' \dontrun{
#' select_cols(metadata_df, select_type = "TITLE")
#' select_cols(metadata_df, select_type = "FOOTR", add_footr_tstamp = TRUE)
#' select_cols(metadata_df, select_type = "PGMNAME")
#' }
#'
#' @importFrom dplyr select starts_with all_of
#' @export
select_cols <- function(data, select_type, add_footr_tstamp=TRUE) {
  type <- toupper(select_type);
  cols <- NULL;

  if (is.null(select_type)) {
    cols <- data
  } else if (type=="TITLE") {
    cols <- data |> select(starts_with("TTL"), POPULATION)
  } else if (type=="FOOTR") {
    cols <- data |> select(starts_with("FOOT"))

    if (!is.null(add_footr_tstamp) && add_footr_tstamp) {
      src <- ""
      if ("SOURCE" %in% names(data)) src <- data |> select(SOURCE)

      pgmname <- ""
      if ("PGMNAME" %in% names(data)) pgmname <- data |> select(PGMNAME)

      cols$source <- get_footr_tstamp(unlist(pgmname), unlist(src))
    }
  } else {
    cols <- data |> dplyr::select(all_of(type))
  }

  out <- Filter(function(x) !all(is.na(x)), cols)
  out
}



