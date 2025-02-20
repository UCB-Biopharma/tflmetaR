#' Read header and footer Excel file
#'
#' This function reads headers and footers from a spreadsheet, either an Excel file or csv file.
#'
#'
#'
#' @details Table_layout is based upon the complex_layout. However, unlike complex_layout, the table layout consists of eight rows for headers, titles, plot, notes, and footnotes.
#' The fourth row and sixth row are used to create space above and below the table.\cr
#' The heights of the rows in table_layout with `"free"` scales are 5%, 5%, 5%, 5%, 60%, 5%, 5%, and 10% of the area respectively.\cr
#' In `table_layout` with `"fixed"` scales, row heights are specified in inches for annotations, while the remaining space is dedicated to the plot.
#' This ensures consistent spacing across outputs, with the plot occupying the central area.\cr
#' Please note that as output space is reduced, annotations retain their space which makes the plot appear smaller.
#'
#' For an example, see `vignette("table_example", package = "plotation")`.
#'
#' @rdname read_header
#' @seealso [read_header]
#' @examples
#' table_layout()
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
  required_cols <- c("TYPE", "PGMNAME", "OID", "TTL1", "BYLINE1", "FOOT1")
  if (!all(required_cols %in% colnames(tfile))) stop("Input file has required column(s) missing.\n")
  else tfile <- tfile %>% select(TYPE, PGMNAME, OID, starts_with("TTL"), starts_with("BYLINE"), starts_with("FOOT"))
  #tfile <- tfile[, colSums(is.na(tfile)) != nrow(tfile)]

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
    type = NA,
    tnumber ="" ) {
  if (is.na(type) & is.na(tnumber)) stop("Selection paramters can not be NULL.\n")

  if (!(toupper(type) %in% c("LISTING", "TABLE", "FIGURE", "GRAPH", '', NA)) ) stop("TLF type is invalid.\n")

  ## if type is not NULL, combine type with tfl number
  if (!is.na(type)) crit <- paste(type, tnumber) %>% gsub("\\b(\\w+)\\s+\\1\\b", "\\1")
  else crit <- tnumber

  if (is.na(type))  {
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
#' @export select_with_number
select_with_name <- function(
    df = list(),
    pname = "",
    oid ="" ) {
  if (is.na(pname) | is.na(oid)) stop("Selection paramters are not valid.\n")

  ## if type is not NULL, combine type with tfl number
  # if (!is.na(type)) crit <- paste(type, tnumber) %>% gsub("\\b(\\w+)\\s+\\1\\b", "\\1")
  # else crit <- tnumber

  footer_list <- df %>%
    filter(PGMNAME == pname & OID == oid)

  ## make sure only one unique entry is generated
  if (nrow(footer_list) != 1) stop("No unique entry generated. Check the title and footnote file and try again.\n")

  return(footer_list)
}
