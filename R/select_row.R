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
#' @export get_footnote
get_footnote <- function(
    filename,
    type = NULL,
    tnumber = NULL,
    pname = NULL,
    oid = NULL) {
  if (is.null(pname) & is.null(tnumber)) stop("Either program name (pname) or TFL number (tnumber) must be provided.\n")

  if (!file.exists(filename)) stop("Input file does not exist! Check the filename and/or pathname and try again. \n", filename)
  hfooter_file <- read_footer(filename)

  if (!is.null(pname)) return(select_with_name(df = hfooter_file, pname = pname, oid = oid))
  else {
    row_list <- select_with_number(df = hfooter_file, tnumber = tnumber)
    return (row_list)
    #return(add_stamp(filename = row_list, tnumber = tnumber)) #"Figure 1.1"))
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
select_row_header <- function(
    filename,
    type = NULL,
    tnumber = NULL,
    pname = NULL,
    oid = NULL) {
  if (is.null(pname) & is.null(tnumber)) stop("Either program name (pname) or TFL number (tnumber) must be provided.\n")

  if (!file.exists(filename)) stop("Input file does not exist! Check the filename and/or pathname and try again. \n", filename)
  hfooter_file <- read_footer(filename)

  if (!is.null(pname)) return(select_with_name(df = hfooter_file, pname = pname, oid = oid))
  else {
    hfooter_list <- select_with_number(df =hfooter_file,  tnumber = tnumber)

    header_list <- hfooter_list %>%
      select(starts_with("TTL"), POPULATION)
    head_list <- Filter(function(x) !is.na(x), header_list)

    return(head_list)
  }
}
