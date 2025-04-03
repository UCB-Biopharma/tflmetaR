

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
footer_with_stamp <- function(filename,
                              type = NULL,
                              tnumber = NULL,
                              pname = NULL,
                              oid = NULL) {

  # select either on program nmae of TFL number
  if (!is.NULL(pname)) {
    hfooter_list <- select_with_name(df = filename, pname = pname, oid = oid)
  } else {
    hfooter_list <- select_with_number(df = filename, tnumber = tnumber)
  }

  # hfooter_list <- select_row(filename = hfooter_file, type = type, pname = pname, oid = oid)
  # ht_list <- select_with_number(df =header_footer,  tnumber = "Table 2.1")

  footer_list <- hfooter_list %>%
    select(starts_with("FOOT"))

  footer_list <- Filter(function(x) !is.na(x), footer_list)

  data_src <- hfooter_list %>%
    select(SOURCE)

  current_time <- Sys.time()
  runtime_stamp <- format(current_time, "%Y-%m-%d %H:%M:%S")
  ref_timestamp <- glue("\nGenerated from {basename(rstudioapi::getSourceEditorContext()$path)} on ", runtime_stamp, " Data Source(s): ", unlist(data_src), "\n")
  footer_list <- c(footer_list, ref_timestamp)
  names(footer_list)[length(footer_list)] <- "SRC" # give last part a name in case end user want to refer to it.
  return(footer_list)
}
