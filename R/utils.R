#' Read the Excel file of header and footer
#'
#' This function reads headers and footers from an excel spreadsheet.
#'
#'
#'
#' @details The title and footnotes are to be maintained and managed in the excel spreadsheet. This file should have the following column names in order for the program
#' to pull appropriate header or footnotes:\cr
#' \tab "TYPE", "PGMNAME", "OID", "TTL1", "SOURCE", "BYLINE1", "FOOT1" \cr
#' Filename should have the complete folder path and correct file extension. \cr
#'
#' For an example, see `vignette("Use_Flextable", package = "headr")`.
#'
#' @rdname read_header
#' @seealso [read_header]
#' @examples
#'
#'
#' # (to use |> version 4.1.0 of R is required, for lower versions we recommend %>% from magrittr)
#' library(magrittr)
#'
#' library(flextable)
#'
#'
#'
#' @export read_footer
read_footer <- function(
    filename = filename
    ) {
  if (!file.exists(filename)) stop("Input header_footer file does not exist! Check the filename and/or pathname and try again. \n", filename)
  tfile <- readxl::read_excel(filename)
  colnames(tfile) <- toupper(colnames(tfile))
  required_cols <- c("TYPE", "PGMNAME", "OID", "TTL1", "SOURCE", "BYLINE1", "FOOT1")
  if (!all(required_cols %in% colnames(tfile))) stop("Input file has required column(s) missing.\n")
  else tfile <- tfile %>% select(TYPE, PGMNAME, SOURCE, OID, POPULATION, starts_with("TTL"), starts_with("BYLINE"), starts_with("FOOT"))
  #tfile <- tfile[, colSums(is.null(tfile)) != nrow(tfile)]

  return(tfile)
}



#' Select header and footer based on TFL number
#'
#' This function select titles and footnotes based on TFL number
#'
#'
#' @details Each TFL (table, listing, or figure) should have a type and TFL number in the header_footer Excel spreadsheet. This information can be in two separate columns (TYPE & TTL1)
#' or combined in TTL1 column. However, if both type and TFL number are already combined in column TTL1, there should be a space to separate them.
#' Additional details...
#'
#' @export select_with_number
select_with_number <- function(
    df = list(),
    type = NULL,
    tnumber = NULL ) {
  if (is.null(type) & is.null(tnumber)) stop("Selection paramters can not be NULL.\n")

  #if (!(toupper(type) %in% c("LISTING", "TABLE", "FIGURE", "GRAPH")) & !is.null(type) ) stop("TLF type is invalid.\n")

  ## if type is not NULL, combine type with tfl number
  # if (!is.null(type)) crit <- paste(type, tnumber) %>% gsub("\\b(\\w+)\\s+\\1\\b", "\\1")
  # else crit <- tnumber

  if (is.null(type))  {
    footer_list <- df %>% filter(TTL1 == tnumber)
  } else {
    footer_list <- df %>% filter(TYPE == type & TTL1 == tnumber)
  }

  ## make sure only one unique entry is generated
  if (nrow(footer_list) == 0) stop("No entry is generated. Check the title and footnote file and try again.\n")
  if (nrow(footer_list) > 1) stop("Non unique entry generated. Check the title and footnote file and try again.\n")

  return(footer_list)
}


#' Select header and footer based on program name and oid
#'
#' This function select titles and footnotes based on TFL number
#'
#'
#' @details Each TFL (table, listing, or figure) should have a type and TFL number in the header_footer Excel spreadsheet. This information can be in two separate columns (TYPE & TTL1)
#' or combined in TTL1 column. However, if both type and TFL number are already combined in column TTL1, there should be a space to separate them.
#' Additional details...
#'
#' @export select_with_name
select_with_name <- function(
    df = list(),
    pname = "",
    oid ="" ) {
  #if (is.null(pname) | is.null(oid)) stop("Selection paramters are not valid.\n")
  if (is.null(pname)) stop("Selection paramters are not valid.\n") #allow NA as OID
  ## if type is not NULL, combine type with tfl number
  # if (!is.null(type)) crit <- paste(type, tnumber) %>% gsub("\\b(\\w+)\\s+\\1\\b", "\\1")
  # else crit <- tnumber

  footer_list <- df %>%
    filter(PGMNAME == pname & OID == oid)

  ## make sure only one unique entry is generated
  #if (nrow(footer_list) != 1) stop("No unique entry generated. Check the title and footnote file and try again.\n")
  if (nrow(footer_list) == 0) stop("No entry is generated. Check the title and footnote file and try again.\n")
  if (nrow(footer_list) > 1) stop("Non unique entry generated. Check the title and footnote file and try again.\n")

  return(footer_list)
}
