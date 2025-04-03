#' Get title, subtitles and population
#'
#' When annotating table/listing/figure, use this function to get title(s) as a list
#' Each element of the list can be individually processed, e.g., assign fontsize, fontface, etc.
#' or the whole list can be unlisted into a string separated by, for example, '\n" for proper wrapping.
#'
#' @return a list
#'
#' @details Titles & footnotes are centrally managed in an Excel spreadhsheet. The title and subtitles are placed in columns
#'   TTL1 to TTL(n).
#'
#' @param df A dataframe which is returned from calling read_excel() or other to read title & footnote file.
#' @param tnumber TFL number, used to select proper titles and footnotes. This can be with or without TFL type.If pname parameter is not given, tnumber must not be NULL.
#' @param type optional TFL type
#' @param pname The program name used to select proper title entry. If this parameter is given (not NULL), it has precedence over TFL number for selection.
#' @param oid Optional parameter
#' @rdname get_title
#'
#'
#' @export get_title
get_title <- function(df = NULL,
                      type = NULL,
                      tnumber = NULL,
                      pname = NULL,
                      oid = NULL) {
  if (is.null(df)) stop("Input dataframe error! Check the input data and try again. \n")

  if (is.null(pname) & is.null(tnumber)) stop("Need to provide either a program name or TFL number to select row.\n")

  # select either on program nmae of TFL number
  if (!is.null(pname)) {
    title_list <- select_with_name(df = df, pname = pname, oid = oid)
  } else {
    title_list <- select_with_number(df = df, tnumber = tnumber)
  }
  # select only title, subtitle(s) and population.
  filtered_list <- title_list %>%
    select(starts_with("TTL"), POPULATION)
  t_list <- Filter(function(x) !is.na(x), filtered_list)

  return(t_list)
}

#' Get footnotes
#'
#' When annotating table/listing/figure, use this function to get footnotes as a list
#' Each element of the list can be individually processed, e.g., assign fontsize, fontface, etc.
#' or the whole list can be unlisted into a string separated by, for example, '\n" for proper wrapping.
#'
#' @return a list
#'
#' @details Titles & footnotes are centrally managed in an Excel spreadhsheet. The footnotes are placed in columns
#'   FOOT1 to Foot(n).
#'
#' @param df A dataframe which is returned from calling read_excel() or other to read title & footnote file.
#' @param tnumber TFL number, used to select proper titles and footnotes. This can be with or without TFL type.If pname parameter is not given, tnumber must not be NULL.
#' @param type optional TFL type
#' @param pname The program name used to select proper title entry. If this parameter is given (not NULL), it has precedence over TFL number for selection.
#' @param oid Optional parameter
#' @rdname get_footnote
#'
#'
#' @export get_footnote
get_footnote <- function(df = NULL,
                      type = NULL,
                      tnumber = NULL,
                      pname = NULL,
                      oid = NULL) {
  if (is.null(df)) stop("Input dataframe error! Check the input data and try again. \n")

  if (is.null(pname) & is.null(tnumber)) stop("Need to provide either a program name or TFL number to select row.\n")

  # select either on program nmae of TFL number
  if (!is.null(pname)) {
    footnote_list <- select_with_name(df = df, pname = pname, oid = oid)
  } else {
    footnote_list <- select_with_number(df = df, tnumber = tnumber)
  }
  # select only footnotes
  filtered_list <- footnote_list %>%
    select(starts_with("FOOT"))
  f_list <- Filter(function(x) !is.na(x), filtered_list)

  return(f_list)
}

#' Get upper left headers
#'
#' @param df a full filename including folder path.
#' @param sheetname optional sheetname. Default is "header"
#' @param by_list optional return type. Default is a list.
#'
#' @details
#' Generate a list of upper left header. If by_list = FALSE, the function will return a string vector.
#'
#' @rdname get_ulheader
#'
#' @export get_ulheader
get_ulheader <- function(df,
                         by_list = TRUE) {
  # Read header spreadsheet
  ulheader <- df %>% select(starts_with("UL"))
  ulheader <- Filter(function(x) !is.na(x), ulheader)

  if (by_list) {
    return(ulheader)
  } # return a list by default
  else {
    return(paste(ulheader, sep = "\n", collapse = " \n"))
  }
}


#' Get upper right headers
#'
#' @param df a full filename including folder path.
#' @param sheetname optional sheetname. Default is "header"
#' @param by_list optional return type. Default is a list.
#'
#' @details
#' Generate a list of upper right header. If by_list = FALSE, the function will return a string vector.
#'
#' @rdname get_urheader
#'
#' @export get_urheader
get_urheader <- function(df,
                         by_list = TRUE) {
  # Read header spreadsheet
  urheader <- df %>% select(starts_with("UR"))
  urheader <- Filter(function(x) !is.na(x), urheader)

  if (by_list) {
    return(urheader)
  } # return a list by default
  else {
    return(paste(urheader, sep = "\n", collapse = " \n"))
  }
}


#' Return data source(s)
#'
#' This function assumes that the data source(s) along with the titles and footnotes are stored in a spreadsheet
#'
#'
#' @details Calls other utils functions.
#'
#' @param df Full filename including folder path and file extension.
#' @param tnumber TFL number, used to select proper titles and footnotes. This can be with or without TFL type.If pname parameter is not given, tnumber must not be NULL.
#' @param type optional TFL type
#' @param pname The program name used to select proper title entry. If this parameter is given (not NULL), it has precedence over TFL number for selection.
#' @param oid Optional parameter
#' @rdname get_source
#'
#'
#' @export get_source
get_source <- function(df = NULL,
                       type = NULL,
                       tnumber = NULL,
                       pname = NULL,
                       oid = NULL) {
  if (is.null(df)) stop("Input dataframe error! Check the input data and try again. \n")

  if (is.null(pname) & is.null(tnumber)) stop("Need to provide either a program name or TFL number to select row.\n")

  # select either on program nmae of TFL number
  if (!is.null(pname)) {
    source_list <- select_with_name(df = df, pname = pname, oid = oid)
  } else {
    source_list <- select_with_number(df = df, tnumber = tnumber)
  }
  # select only footnotes
  filtered_list <- source_list %>%
    select(starts_with("SOURCE"))
  f_list <- Filter(function(x) !is.na(x), filtered_list)

  return(f_list)
}


#' This function returns program name and timestamp for printing at the bottom of TFLs
#'
#'
#' @details Calls other utils functions.
#' @rdname get_timestamp
#'
#'
#' @export get_timestamp
get_timestamp <- function(pname = NULL) {
  current_time <- Sys.time()
  runtime_stamp <- format(current_time, "%Y-%m-%d %H:%M:%S")
  ref_timestamp <- glue("Generated from {basename(rstudioapi::getSourceEditorContext()$path)} on ", runtime_stamp, "\n")
  return(ref_timestamp)
}
