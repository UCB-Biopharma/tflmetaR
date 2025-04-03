#' Select header and footer based on TFL number
#'
#' This function select titles and footnotes based on TFL number
#' @param df A dataframe or list of  titles and footnotes
#' @param tnumber TFL number, used to select proper titles and footnotes. This can be with or without TFL type.If pname parameter is not given, tnumber must not be NA.
#' @param type optional TFL type
#' @return A list or dataframe with one obs containing titles and footnotes.
#'
#' @details Each TFL (table, listing, or figure) should have a type and TFL number in the header_footer Excel spreadsheet. This information can be in two separate columns (TYPE & TTL1)
#' or combined in TTL1 column. However, if both type and TFL number are already combined in column TTL1, there should be a space to separate them.
#' Additional details...
#'
#' @export select_with_number
select_with_number <- function(df = list(),
                               type = NULL,
                               tnumber = NULL) {
  if (is.null(type) & is.null(tnumber)) stop("Selection paramters can not be NULL.\n")

  # if (!(toupper(type) %in% c("LISTING", "TABLE", "FIGURE", "GRAPH")) & !is.null(type) ) stop("TLF type is invalid.\n")

  ## if type is not NULL, combine type with tfl number
  # if (!is.null(type)) crit <- paste(type, tnumber) %>% gsub("\\b(\\w+)\\s+\\1\\b", "\\1")
  # else crit <- tnumber

  if (is.null(type)) {
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
#' @param df A dataframe or list of overall title and footnote
#' @param pname The program name used to select proper title entry. If this parameter is given (not NA), it has precedence over TFL number for selection.
#' @param oid Optional parameter
#'
#' @details Each TFL (table, listing, or figure) should have a type and TFL number in the header_footer Excel spreadsheet. This information can be in two separate columns (TYPE & TTL1)
#' or combined in TTL1 column. However, if both type and TFL number are already combined in column TTL1, there should be a space to separate them.
#' Additional details...
#'
#' @export select_with_name
select_with_name <- function(df = list(),
                             pname = "",
                             oid = "") {
  # if (is.null(pname) | is.null(oid)) stop("Selection paramters are not valid.\n")
  if (is.null(pname)) stop("Selection paramters are not valid.\n") # allow NA as OID
  ## if type is not NULL, combine type with tfl number
  # if (!is.null(type)) crit <- paste(type, tnumber) %>% gsub("\\b(\\w+)\\s+\\1\\b", "\\1")
  # else crit <- tnumber

  footer_list <- df %>%
    filter(PGMNAME == pname & OID == oid)

  ## make sure only one unique entry is generated
  # if (nrow(footer_list) != 1) stop("No unique entry generated. Check the title and footnote file and try again.\n")
  if (nrow(footer_list) == 0) stop("No entry is generated. Check the title and footnote file and try again.\n")
  if (nrow(footer_list) > 1) stop("Non unique entry generated. Check the title and footnote file and try again.\n")

  return(footer_list)
}
#' Get footnotes based on program name or TFL number
#'
#' @param df A dataframe or list of overall title and footnote
#' @param tnumber TFL number, used to select proper titles and footnotes. This can be with or without TFL type.If pname parameter is not given, tnumber must not be NA.
#' @param type optional TFL type
#' @param pname The program name used to select proper title entry. If this parameter is given (not NA), it has precedence over TFL number for selection.
#' @param oid Optional parameter
#'
#' @details
#' Generate footnotes in a list by calling this function. As a custom, one additional line of program name, run timestamp, and data source(s) is added to the list at the end.
#'
#' @export get_footnotes2
get_footnotes2 <- function(filename,
                         type = NULL,
                         tnumber = NULL,
                         pname = NULL,
                         oid = NULL) {
  if (is.null(pname) & is.null(tnumber)) stop("Either program name (pname) or TFL number (tnumber) must be provided.\n")

  if (!file.exists(filename)) stop("Input file does not exist! Check the filename and/or pathname and try again. \n", filename)
  hfooter_file <- read_footer(filename)

  if (!is.null(pname)) {
    return(select_with_name(df = hfooter_file, pname = pname, oid = oid))
  } else {
    row_list <- select_with_number(df = hfooter_file, tnumber = tnumber)
    row_list <- Filter(function(x) !is.na(x), row_list)
    return(row_list %>% select(starts_with("FOOT"), SOURCE))
    # return(add_stamp(filename = row_list, tnumber = tnumber)) #"Figure 1.1"))
  }
}


#' Select titles and subtitles based on program name or TFL number
#'
#' @param df A dataframe or list of overall title and footnote
#' @param tnumber TFL number, used to select proper titles and footnotes. This can be with or without TFL type.If pname parameter is not given, tnumber must not be NA.
#' @param type optional TFL type
#' @param pname The program name used to select proper title entry. If this parameter is given (not NA), it has precedence over TFL number for selection.
#' @param oid Optional parameter
#'
#' @details
#' Generate a list to contain titles, subtitles and population. The list structure provides flexibility comparing to unlisted string vector as return value.
#'
#' @export select_row_header
select_row_header <- function(filename,
                              type = NULL,
                              tnumber = NULL,
                              pname = NULL,
                              oid = NULL) {
  if (is.null(pname) & is.null(tnumber)) stop("Either program name (pname) or TFL number (tnumber) must be provided.\n")

  if (!file.exists(filename)) stop("Input file does not exist! Check the filename and/or pathname and try again. \n", filename)
  hfooter_file <- read_footer(filename)

  if (!is.null(pname)) {
    return(select_with_name(df = hfooter_file, pname = pname, oid = oid))
  } else {
    hfooter_list <- select_with_number(df = hfooter_file, tnumber = tnumber)

    header_list <- hfooter_list %>%
      select(starts_with("TTL"), POPULATION)
    head_list <- Filter(function(x) !is.na(x), header_list)

    return(head_list)
  }
}
