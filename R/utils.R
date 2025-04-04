#' Read Titles and Footnotes Excel File
#'
#'
#' A wrapper function to read title & footnote excel spreadsheet file
#' @details The title and footnotes are to be maintained in the excel spreadsheet. This file should have the following column names in order for the program
#' to pull appropriate header or footnotes:\cr
#' \cr "PGMNAME", "TTL1", "SOURCE", "FOOT1" \cr
#' Filename can be an object returned by file.path() function  \cr
#' @param filename a full filename including folder path.
#' @param sheetname default sheetname for title & footnote is "title_footnote"; default sheetname for header part is "header". If not given, the function will read the first sheet.
#'
#'
#'
#' @rdname read_tfile
#' @seealso [select_row]
#' @examples
#'
#' @export read_tfile
read_tfile <- function(filename = NULL,
                        sheetname = NULL, ...) {
  if (!file.exists(filename)) stop("Input header_footer file does not exist! Check the filename and/or pathname and try again. \n", filename)

  tfile <- tryCatch(
    {
      if (sheetname == "header") {
        readxl::read_excel(filename, sheet = sheetname, n_max = 1, ...)
        } else {
          readxl::read_excel(filename, sheet = sheetname, ...)
        }
    },
    error = function(e) {
      message("An error occurred: ", e$message)
    }
  )
  # check the read result
  if (is.null(tfile)) {
    stop("Failed to read the sheet. Please check the file and sheet name.")
  } else {
    colnames(tfile) <- toupper(colnames(tfile))
    required_cols <- c("PGMNAME", "TTL1", "SOURCE", "FOOT1")
    if (is.null(sheetname) & !all(required_cols %in% colnames(tfile))) {
      stop("Input file misses required column(s).\n")
    }

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
#' @seealso [read_tfile]
#' @examples
#'
#' headers <- read_header("path/to/your/titles.xls")
#'
#' @export read_header
read_header <- function(filename = filename,
                        sheetname = "header") {
  if (!file.exists(filename)) stop("Input file does not exist! Check the filename and/or pathname and try again. \n", filename)
  # if (is.null(sheetname)) sheetname = "header" #set to default
  # tfile <- readxl::read_excel(filename_with_path, sheet=sheetname)
  head_file <- tryCatch(
    {
      readxl::read_excel(filename, sheet = sheetname, n_max = 1)
    },
    error = function(e) {
      message("An error occurred: ", e$message)
    }
  )

  if (is.null(head_file)) {
    stop("Failed to read the sheet. Please check the file and sheet name.")
  } else {
    colnames(head_file) <- toupper(colnames(head_file))
    required_cols <- c("UL1", "UL2", "UL3", "UR1", "UR2", "UR3")
    if (!all(required_cols %in% colnames(head_file))) {
      stop("Input file has required column(s) missing.\n")
    } else {
      head_file <- head_file %>% select(UL1, UL2, UL3, UR1, UR2, UR3)
    }
    # head_file <- head_file[, colSums(is.null(head_file)) != nrow(head_file)]

    return(head_file)
  }
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
add_stamp <- function(fnote_list = footnote_list,
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
  # fnote_list <- fnote_list %>% as.data.frame()
  footer_list <- Filter(function(x) !is.na(x), fnote_list)

  data_src <- footer_list %>%
    select(starts_with("FOOT"), SOURCE)

  current_time <- Sys.time()
  runtime_stamp <- format(current_time, "%Y-%m-%d %H:%M:%S")
  ref_timestamp <- glue("\nGenerated from {basename(rstudioapi::getSourceEditorContext()$path)} on ", runtime_stamp, " Data Source(s): ", unlist(data_src), "\n")
  footer_list <- c(footer_list, ref_timestamp)
  names(footer_list)[length(footer_list)] <- "SRC" # give last part a name in case end user want to refer to it.
  return(footer_list)
}
