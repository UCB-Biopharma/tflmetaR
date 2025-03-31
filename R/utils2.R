#' Return data source
#'
#' This function returns data source(s) for printing at the bottom of TFLs
#'
#'
#' @details Calls other utils functions.
#'
#' @param filename Full filename including folder path and file extension.
#' @param tnumber TFL number, used to select proper titles and footnotes. This can be with or without TFL type.If pname parameter is not given, tnumber must not be NULL.
#' @param type optional TFL type
#' @param pname The program name used to select proper title entry. If this parameter is given (not NULL), it has precedence over TFL number for selection.
#' @param oid Optional parameter
#' @rdname get_source
#'
#'
#' @export get_source
get_source <- function(
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

  data_src <- hfooter_list %>%
    select(SOURCE)

  return(data_src)
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
  ref_timestamp <- glue("Generated from {basename(rstudioapi::getSourceEditorContext()$path)} on ", runtime_stamp)
  return(ref_timestamp)
}
