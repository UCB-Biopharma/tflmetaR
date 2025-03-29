#' Get upper left headers
#'
#' @param filename a full filename including folder path.
#' @param sheetname optional sheetname. Default is "header"
#' @param by_list optional return type. Default is a list.
#'
#' @details
#' Generate a list of upper left header. If by_list = FALSE, the function will return a string vector.
#'
#' @rdname get_ulheader
#'
#' @export get_ulheader
get_ulheader <- function(
    filename,
    sheetname = "header",
    by_list = TRUE) {
  # Read header spreadsheet
  ulheader <- read_header(filename = filename, sheetname = {{sheetname}}) %>%
    select(starts_with("UL"))
  ulheader <- Filter(function(x) !is.na(x), ulheader)

  if (by_list) return(ulheader) # return a list by default
  else {
        return(paste(ulheader, sep = "\n", collapse = " \n"))
  }
}


#' Get upper right headers
#'
#' @param filename a full filename including folder path.
#' @param sheetname optional sheetname. Default is "header"
#' @param by_list optional return type. Default is a list.
#'
#' @details
#' Generate a list of upper right header. If by_list = FALSE, the function will return a string vector.
#'
#' @rdname get_urheader
#'
#' @export get_urheader
get_urheader <- function(
  filename,
  sheetname = "header",
  by_list = TRUE) {
  # Read header spreadsheet
  urheader <- read_header(filename = filename, sheetname = {{sheetname}}) %>%
    select(starts_with("UR"))
  urheader <- Filter(function(x) !is.na(x), urheader)

  if (by_list) return(urheader) # return a list by default
  else {

    return(paste(urheader, sep = "\n", collapse = " \n"))
  }
}
