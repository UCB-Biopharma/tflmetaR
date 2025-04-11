#' Extract Titles and Subtitle Metadata
#'
#' Retrieves title-related fields (TTL1, TTL2, etc.) and population from the metadata.
#'
#' @param df A data frame of title and footnote metadata.
#' @param type Optional. A character string indicating the TFL type.
#' @param tnumber Optional. TFL number.
#' @param pname Optional. Program name.
#' @param oid Optional. Object ID.
#'
#' @return A named list of non-missing title fields.
#'
#' @export
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

#' Extract Footnote Metadata
#'
#' Retrieves footnote fields (FOOT1, FOOT2, etc.) from the metadata.
#'
#' @inheritParams get_title
#'
#' @return A named list of non-missing footnote fields.
#'
#' @export
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

#' Extract Upper-Left Header Text
#'
#' Retrieves upper-left (UL*) header fields from the metadata.
#'
#' @param df A data frame of metadata.
#' @param by_list Logical. If `TRUE`, returns a list of non-missing values.
#' If `FALSE`, returns a collapsed string.
#'
#' @return A character vector or a list depending on `by_list`.
#'
#' @export
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


#' Extract Upper-Right Header Text
#'
#' Retrieves upper-right (UR*) header fields from the metadata.
#'
#' @inheritParams get_ulheader
#'
#' @return A character vector or a list depending on `by_list`.
#'
#' @export
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


#' Extract Source Metadata
#'
#' Retrieves source fields (e.g., SOURCE1) from the metadata.
#'
#' @inheritParams get_title
#'
#' @return A named list of non-missing source fields.
#'
#' @export
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


#' Generate Runtime Timestamp Reference
#'
#' Generates a string indicating the time and source file from which the report was generated.
#'
#' @param pname Optional. A program name to include in the timestamp message.
#'
#' @return A character string with the timestamp and source filename.
#'
#' @importFrom rstudioapi getSourceEditorContext
#' @importFrom glue glue
#' @export
get_timestamp <- function(pname = NULL) {
  current_time <- Sys.time()
  runtime_stamp <- format(current_time, "%Y-%m-%d %H:%M:%S")
  ref_timestamp <- glue("Generated from {basename(rstudioapi::getSourceEditorContext()$path)} on ", "\n")
  return(ref_timestamp)
}
