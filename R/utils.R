#' Read Titles and Footnotes Excel File
#'
#'
#' This function reads headers and footers from an excel spreadsheet.
#'
#' @param filename a full filename including folder path.
#' @param sheetname optional sheetname
#' @details The title and footnotes are to be maintained and managed in the excel spreadsheet. This file should have the following column names in order for the program
#' to pull appropriate header or footnotes:\cr
#' \cr "TYPE", "PGMNAME", "OID", "TTL1", "SOURCE", "BYLINE1", "FOOT1" \cr
#' Filename should have the complete folder path and correct file extension. \cr
#'
#' For an example, see `vignette("use_flextable", package = "TFootr")`.
#'
#' @rdname read_footer
#' @seealso [get_footnote], [select_row_header]
#' @examples
#'
#' titles_footnotes <- read_footer("path/to/your/titles.xls")
#'
#'
#' @export read_footer
read_footer <- function(
    filename = filename,
    sheetname = NULL
    ) {
  if (!file.exists(filename)) stop("Input header_footer file does not exist! Check the filename and/or pathname and try again. \n", filename)
  #tfile <- readxl::read_excel(filename_with_path, sheet=sheetname)
  tfile <- tryCatch({
    readxl::read_excel(filename, sheet = sheetname)
  }, error = function(e) {
    message("An error occurred: ", e$message)
  })

  if (is.null(tfile)) {
    stop("Failed to read the sheet. Please check the file and sheet name.")
  }
  else {
  colnames(tfile) <- toupper(colnames(tfile))
  required_cols <- c("TYPE", "PGMNAME", "OID", "TTL1", "SOURCE", "BYLINE1", "FOOT1")
  if (!all(required_cols %in% colnames(tfile))) stop("Input file has required column(s) missing.\n")
  else tfile <- tfile %>% select(TYPE, PGMNAME, SOURCE, OID, POPULATION, starts_with("TTL"), starts_with("BYLINE"), starts_with("FOOT"))
  #tfile <- tfile[, colSums(is.null(tfile)) != nrow(tfile)]

  return(tfile)
  }
}

#' Read headers from Excel File
#'
#'
#' This function reads headers from an excel spreadsheet.
#' The headers are retrieved from the same excel file but in "header" sheet.
#' If the sheetname is not standard, the name should be provided.
#'
#' @param filename a full filename including folder path.
#' @param sheetname optional sheetname
#' @details Both left and right headers are in a separate sheet of the same file as the title and footnotes.\cr
#'  This file should have the following column names in order for the program
#' to pull appropriate headers:\cr
#' \cr "UL1", "UL2", "UL3", "UR1", "UR2", "UR3", even though two are needed for each side. \cr
#' All other columns will be discarded.Only the first row will be read.
#' Filename should have the complete folder path and correct file extension. \cr
#'
#' For an example, see `vignette("use_flextable", package = "TFootr")`.
#'
#' @rdname read_header
#' @seealso [read_footer]
#' @examples
#'
#' headers <- read_header("path/to/your/titles.xls")
#'
#'
#' @export read_header
read_header <- function(
  filename = filename,
  sheetname = "header"
) {
  if (!file.exists(filename)) stop("Input file does not exist! Check the filename and/or pathname and try again. \n", filename)
  #if (is.null(sheetname)) sheetname = "header" #set to default
  #tfile <- readxl::read_excel(filename_with_path, sheet=sheetname)
  head_file <- tryCatch({
    readxl::read_excel(filename, sheet = sheetname, n_max = 1)
  }, error = function(e) {
    message("An error occurred: ", e$message)
  })

  if (is.null(head_file)) {
    stop("Failed to read the sheet. Please check the file and sheet name.")
  } else {

    colnames(head_file) <- toupper(colnames(head_file))
    required_cols <- c("UL1", "UL2", "UL3", "UR1", "UR2", "UR3")
    if (!all(required_cols %in% colnames(head_file))) stop("Input file has required column(s) missing.\n")
    else head_file <- head_file %>% select(UL1, UL2, UL3, UR1, UR2, UR3)
    #head_file <- head_file[, colSums(is.null(head_file)) != nrow(head_file)]

    return(head_file)
  }
}

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
#' @param df A dataframe or list of overall title and footnote
#' @param pname The program name used to select proper title entry. If this parameter is given (not NA), it has precedence over TFL number for selection.
#' @param oid Optional parameter
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
#' @export add_stamp
add_stamp <- function(
  fnote_list = footnote_list,
  ...) {

  # select either on program nmae of TFL number
  # if (!is.na(pname)) hfooter_list <- select_with_name(df =filename, pname = pname, oid = oid)
  # else hfooter_list <- select_with_number(df =filename,  tnumber = tnumber)
  #
  # #hfooter_list <- select_row(filename = hfooter_file, type = type, pname = pname, oid = oid)
  # #ht_list <- select_with_number(df =header_footer,  tnumber = "Table 2.1")
  #
  # footer_list <- hfooter_list %>%
  #   select(starts_with("FOOT"))
  #fnote_list <- fnote_list %>% as.data.frame()
  footer_list <- Filter(function(x) !is.na(x), fnote_list)

  data_src <- footer_list %>%
    select(starts_with("FOOT"),SOURCE)

  current_time <- Sys.time()
  runtime_stamp <- format(current_time, "%Y-%m-%d %H:%M:%S")
  ref_timestamp <- glue("\nGenerated from {basename(rstudioapi::getSourceEditorContext()$path)} on ", runtime_stamp, " Data Source(s): ", unlist(data_src), "\n")
  footer_list <- c(footer_list, ref_timestamp)
  names(footer_list)[length(footer_list)] <- "SRC" #give last part a name in case end user want to refer to it.
  return(footer_list)
}

