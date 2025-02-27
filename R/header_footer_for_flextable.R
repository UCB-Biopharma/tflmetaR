#' Generate headers - titles and population
#'
#' This function reads headers for tables and listings which will be generated using {flextable} package.
#'
#'
#'
#' @details Calls other utils functions. The header should be unlisted.
#'
#' @param filename Full filename including folder path and file extension.
#' @param tnumber TFL number, used to select proper titles and footnotes. This can be with or without TFL type.If pname parameter is not given, tnumber must not be NULL.
#' @param type optional TFL type
#' @param pname The program name used to select proper title entry. If this parameter is given (not NULL), it has precedence over TFL number for selection.
#' @param oid Optional parameter
#'
#'
#' @export header_for_flextable
header_for_flextable <- function(
    filename,
    type = NA,
    tnumber = NA,
    pname = NA,
    oid = NA) {
  if (!file.exists(filename)) stop("Input file does not exist! Check the filename and/or pathname and try again. \n", filename)
  hfooter_file <- read_footer(filename)

  # select either on program nmae of TFL number
  if (!is.na(pname)) hfooter_list <- select_with_name(df =hfooter_file, pname = pname, oid = oid)
  else hfooter_list <- select_with_number(df =hfooter_file,  tnumber = tnumber)

  #hfooter_list <- select_row(hfooter_file, type = type, pname = pname, oid = oid)
  #ht_list <- select_with_number(df =header_footer,  tnumber = "Table 2.1")

  header_list <- hfooter_list %>%
    select(starts_with("TTL"), POPULATION)
  head_list <- Filter(function(x) !is.na(x), header_list)

  return(head_list)
  #foot_list <- ht_list %>% select(starts_with("FOOT"))
}


#' Generate footnotes - including program name, timestamp, and data source attached.
#'
#' This function prepares footnotes for tables and listings using {flextable} package.
#'
#'
#'
#' @details Calls other utils functions.
#'
#' @param filename Full filename including folder path and file extension.
#' @param tnumber TFL number, used to select proper titles and footnotes. This can be with or without TFL type.If pname parameter is not given, tnumber must not be NULL.
#' @param type optional TFL type
#' @param pname The program name used to select proper title entry. If this parameter is given (not NULL), it has precedence over TFL number for selection.
#' @param oid Optional parameter
#'
#'
#' @export footer_for_flextable
footer_for_flextable <- function(
    filename,
    type = NA,
    tnumber = NA,
    pname = NA,
    oid = NA) {
  if (!file.exists(filename)) stop("Input file does not exist! Check the filename and/or pathname and try again. \n", filename)
  hfooter_file <- read_footer(filename)

  # select either on program nmae of TFL number
  if (!is.na(pname)) hfooter_list <- select_with_name(df =hfooter_file, pname = pname, oid = oid)
  else hfooter_list <- select_with_number(df =hfooter_file,  tnumber = tnumber)

  #hfooter_list <- select_row(filename = hfooter_file, type = type, pname = pname, oid = oid)
  #ht_list <- select_with_number(df =header_footer,  tnumber = "Table 2.1")

  footer_list <- hfooter_list %>%
    select(starts_with("FOOT"))

  footer_list <- Filter(function(x) !is.na(x), footer_list)

  data_src <- hfooter_list %>%
    select(SOURCE)

  current_time <- Sys.time()
  runtime_stamp <- format(current_time, "%Y-%m-%d %H:%M:%S")
  ref_timestamp <- glue("\nGenerated from {basename(rstudioapi::getSourceEditorContext()$path)} on ", runtime_stamp, " Data Source(s): ", unlist(data_src), "\n")
  footer_list <- c(footer_list, ref_timestamp)
  return(footer_list)
  #foot_list <- ht_list %>% select(starts_with("FOOT"))
}

#' Generate footnotes - including program name, timestamp, and data source attached.
#'
#' This function prepares footnotes for tables and listings, or figures.
#'
#'
#'
#' @details Generate a list of footnotes with an additional line of program name, run timestamp, and data source(s) added to the end.
#'
#' @param df A dataframe or list of titles and footnotes.
#' @param tnumber TFL number, used to select proper titles and footnotes. This can be with or without TFL type.If pname parameter is not given, tnumber must not be NULL.
#' @param type optional TFL type
#' @param pname The program name used to select proper title entry. If this parameter is given (not NULL), it has precedence over TFL number for selection.
#' @param oid Optional parameter
#'
#'
#' @export footer_with_stamp
footer_with_stamp <- function(
    filename,
    type = NA,
    tnumber = NA,
    pname = NA,
    oid = NA) {

  # select either on program nmae of TFL number
  if (!is.na(pname)) hfooter_list <- select_with_name(df =filename, pname = pname, oid = oid)
  else hfooter_list <- select_with_number(df =filename,  tnumber = tnumber)

  #hfooter_list <- select_row(filename = hfooter_file, type = type, pname = pname, oid = oid)
  #ht_list <- select_with_number(df =header_footer,  tnumber = "Table 2.1")

  footer_list <- hfooter_list %>%
    select(starts_with("FOOT"))

  footer_list <- Filter(function(x) !is.na(x), footer_list)

  data_src <- hfooter_list %>%
    select(SOURCE)

  current_time <- Sys.time()
  runtime_stamp <- format(current_time, "%Y-%m-%d %H:%M:%S")
  ref_timestamp <- glue("\nGenerated from {basename(rstudioapi::getSourceEditorContext()$path)} on ", runtime_stamp, " Data Source(s): ", unlist(data_src), "\n")
  footer_list <- c(footer_list, ref_timestamp)
  return(footer_list)
  #foot_list <- ht_list %>% select(starts_with("FOOT"))
}
