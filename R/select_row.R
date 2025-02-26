#' Select header and footer based on program name or TFL number
#'
#' @param df A dataframe or list of overall title and footnote
#' @param tnumber TFL number, used to select proper titles and footnotes. This can be with or without TFL type.If pname parameter is not given, tnumber must not be NA.
#' @param type optional TFL type
#' @param pname The program name used to select proper title entry. If this parameter is given (not NA), it has precedence over TFL number for selection.
#' @param oid Optional parameter
#'
#' @details
#' Additional details...
#'
#' @export select_title
select_row <- function(
    df,
    type = NA,
    tnumber,
    pname,
    oid) {
  if (is.na(pname) & is.na(tnumber)) stop("Either program name (pname) or TFL number (tnumber) must be provided.\n")
  if (!is.na(pname)) return(select_with_name(df = df, pname = pname, oid = oid))
  else return(select_with_number(df = df, type = type, tnumber = tnumber))
}
