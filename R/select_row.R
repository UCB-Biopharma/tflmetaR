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
  if (is.null(type) & is.null(tnumber)) stop("Selection paramters can not be NULL.\n")

  if (is.null(type)) {
    footer_list <- df %>% dplyr::filter(TTL1 == tnumber)
  } else {
    footer_list <- df %>% dplyr::filter(TYPE == type & TTL1 == tnumber)
  }

  ## make sure only one unique entry is generated
  if (nrow(footer_list) == 0) stop("No entry is generated. Check the title and footnote file and try again.\n")
  if (nrow(footer_list) > 1) stop("Non unique entry generated. Check the title and footnote file and try again.\n")

  return(footer_list)
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

  if (is.null(pname)) stop("Selection paramters are not valid.\n") # allow NA as OID

  footer_list <- df %>%
    dplyr::filter(PGMNAME == pname & OID == oid)

  ## make sure only one unique entry is generated
  if (nrow(footer_list) == 0) stop("No entry is generated. Check the title and footnote file and try again.\n")
  if (nrow(footer_list) > 1) stop("Non unique entry generated. Check the title and footnote file and try again.\n")

  return(footer_list)
}


