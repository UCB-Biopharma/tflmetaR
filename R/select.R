#' Internal Helper to Select a Single Row Based on Filtering Criteria
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
#' select_row(data, by_column = "PGMNAME", by_value = "t_dm")
#' }
#'
#' @noRd
select_row <- function(data, by_column, by_value, oid=NULL) {
  if (!is.character(by_column) || length(by_column) != 1) {
    stop("`by_column` must be a single character string", call. = FALSE)
  }

  by_column <- toupper(by_column)

  if (!by_column %in% names(data)) {
    stop("Column `", by_column, "` is not present in `data`", call. = FALSE)
  }

  df <- data[data[[by_column]] %in% by_value, , drop = FALSE]

  if (!is.null(oid)) {
    if (!"OID" %in% names(df)) {
      stop("`oid` was supplied but column `OID` is missing from `data`", call. = FALSE)
    }
    df <- df[df[["OID"]] == oid, , drop = FALSE]
  }

  if (nrow(df) == 0) {
    stop("No rows match the specified criteria", call. = FALSE)
  } else if (nrow(df) > 1) {
    stop("Expected exactly one matching row, but found ", nrow(df), call. = FALSE)
  }
  df
}

#' Internal Helper to Select Metadata Columns Based on Filtering Criteria
#'
#' Selects specific columns from a metadata data frame based on the type of content desired
#' (e.g., titles, footnotes, or a named column). Optionally appends a timestamp to footnotes.
#'
#' @param data A data frame containing metadata (e.g., titles, footnotes, sources).
#' @param select_type A character string indicating which columns to return.
#'   If `NULL`, all columns are returned.
#'   If `"TITLE"`, columns starting with `"TTL"` and `"POPULATION"` are returned.
#'   If `"FOOTR"`, columns starting with `"FOOT"` are returned.
#'   If `select_type` matches a column name exactly, that column is returned.
#'   Otherwise, columns whose names start with `select_type` are returned.
#' @param add_footr_tstamp Logical or a function. If `TRUE`, a function named `add_footr_tstamp()`
#' is called to append timestamps to footnotes. Defaults to `FALSE`.
#'
#' @return A list of selected columns from the input data, with `NA` values removed.
#'
#' @examples
#' \dontrun{
#' select_cols(data, select_type = "TITLE")
#' select_cols(data, select_type = "FOOTR")
#' select_cols(data, select_type = "PGMNAME")
#' }
#'
#' @noRd
select_cols <- function(data, select_type, add_footr_tstamp = FALSE) {
  stopifnot(is.data.frame(data))
  cols <- NULL

  if (is.null(select_type)) {
    cols <- data

  } else {
    type <- toupper(select_type)

    if (type == "TITLE") {
      cols <- select_starts_with(data, "TTL", keep_cols = "POPULATION")

    } else if (type == "FOOTR") {
      cols <- select_starts_with(data, "FOOT")

      if (isTRUE(add_footr_tstamp)) {
        src <- if ("SOURCE" %in% names(data)) data[["SOURCE"]][1] else ""
        pgmname <- if ("PGMNAME" %in% names(data)) data[["PGMNAME"]][1] else ""

        cols$source <- include_footr_tstamp(pgmname, src)
      }

    } else if (type %in% names(data)) {
      cols <- data[type]

    } else {
      cols <- select_starts_with(data, type)
    }
  }

  cols[!vapply(cols, function(x) all(is.na(x)), logical(1))]
}


#' @noRd
include_footr_tstamp <- function(pgmname_str, src_str) {
  stopifnot(is.character(pgmname_str), length(pgmname_str) == 1)
  stopifnot(is.character(src_str), length(src_str) == 1)

  runtime_stamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  sprintf(
    "Generated from %s on %s Data Source(s): %s",
    pgmname_str,
    runtime_stamp,
    src_str
  )
}

#' Return columns whose names start with a prefix, optionally keeping other columns
#'
#' @examples
#' \dontrun{
#' select_starts_with(data, "TTL", keep_cols = "POPULATION")
#' }
#' @noRd
select_starts_with <- function(data, prefix, keep_cols = NULL) {
  stopifnot(is.data.frame(data))
  stopifnot(is.character(prefix), length(prefix) == 1)

  prefix_cols <- names(data)[startsWith(names(data), prefix)]
  cols <- unique(c(prefix_cols, keep_cols))
  cols <- cols[cols %in% names(data)]

  data[, cols, drop = FALSE]
}


#' @noRd
validate_input <- function(df, pname, tnumber) {
  if (is.null(df)) {
    stop("`df` must be provided.", call. = FALSE)
  }
  if (is.null(pname) && is.null(tnumber)) {
    stop("Either `pname` or `tnumber` must be provided.", call. = FALSE)
  }
  if (!is.null(pname) && !is.null(tnumber)) {
    stop("Only one of `pname` or `tnumber` should be supplied.", call. = FALSE)
  }
  invisible(TRUE)
}
