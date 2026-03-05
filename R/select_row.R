#' Select a Metadata Entry by Type and TFL Number
#'
#' Filters the metadata for a unique match based on type and TFL number.
#'
#' @param df A data frame containing the metadata.
#' @param type Optional. A character string specifying the type (e.g., "table", "figure").
#' @param tnumber A character or numeric TFL number.
#'
#' @return A single-row data frame (list) with matching metadata.
#'
#' @import magrittr
#' @export
select_with_number <- function(df = list(),
                               type = NULL,
                               tnumber = NULL) {
  select_row(df, by_column = "TTL1", by_value = tnumber)
}

utils::globalVariables("PGMNAME")
#' Select a Metadata Entry by Program Name and Optional OID
#'
#' Filters the metadata for a unique match based on program name and optional object ID (OID).
#'
#' @param df A data frame containing the metadata.
#' @param pname A character string specifying the program name.
#' @param oid Optional. A character string specifying the object ID.
#'
#' @return A single-row data frame (list) with matching metadata.
#'
#' @export
select_with_name <- function(df = list(),
                             pname = "",
                             oid = "") {

  select_row(df, by_column = "PGMNAME", by_value = pname, oid = oid)
}


