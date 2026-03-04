utils::globalVariables(c("POPULATION", "OID", "SOURCE", "PGMNAMEW", "TTL1", "TYPE"))
#' Extract Titles and Subtitle Metadata
#'
#' Retrieves title-related fields (TTL1, TTL2, etc.) and population from the metadata.
#'
#' @param df A data frame or tibble of title and footnote metadata.
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
    dplyr::select(starts_with("TTL"), POPULATION)
  t_list <- Filter(function(x) !is.na(x), filtered_list)

  return(t_list)
}

#' Extract Footnote Metadata
#'
#' Retrieves footnote fields (FOOT1, FOOT2, etc.) from the metadata.
#'
#' @inheritParams get_title
#' @param add_footr_tstamp If TRUE, add timestamp and source information as the
#'   last line of the footnotes. Default is TRUE.
#'
#' @return A named list of non-missing footnote fields.
#'
#' @export
get_footnote <- function(df = NULL,
                      type = NULL,
                      tnumber = NULL,
                      pname = NULL,
                      oid = NULL,
                      add_footr_tstamp=TRUE) {
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
    dplyr::select(starts_with("FOOT"))

  if (!is.null(add_footr_tstamp) && add_footr_tstamp) {
    src <- footnote_list %>% select(SOURCE)
    pgmname <- footnote_list %>% select(PGMNAME)

    filtered_list$source <- get_footr_tstamp(unlist(pgmname), unlist(src))
  }

  f_list <- Filter(function(x) !is.na(x), filtered_list)

  return(f_list)
}

get_footr_tstamp <- function(pgmname_str, src_str) {
  runtime_stamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  sprintf(
    "Generated from %s on %s Data Source(s): %s",
    pgmname_str,
    runtime_stamp,
    src_str
  )
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
  ulheader <- df %>% dplyr::select(starts_with("UL"))
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
  urheader <- df %>% dplyr::select(starts_with("UR"))
  urheader <- Filter(function(x) !is.na(x), urheader)

  if (by_list) {
    return(urheader)
  } # return a list by default
  else {
    return(paste(urheader, sep = "\n", collapse = " \n"))
  }
}


#' Extract Population Metadata
#'
#' Retrieves population field from the metadata.
#'
#' @inheritParams get_title
#'
#' @return A named list containing the population field.
#'
#' @export
get_pop <- function(df = NULL,
                    type = NULL,
                    tnumber = NULL,
                    pname = NULL,
                    oid = NULL) {
  if (is.null(df)) stop("Input dataframe error! Check the input data and try again. \n")

  if (is.null(pname) & is.null(tnumber)) stop("Need to provide either a program name or TFL number to select row.\n")

  # select either on program nmae of TFL number
  if (!is.null(pname)) {
    pop_list <- select_with_name(df = df, pname = pname, oid = oid)
  } else {
    pop_list <- select_with_number(df = df, tnumber = tnumber)
  }
  # select only population
  filtered_list <- pop_list %>%
    dplyr::select(POPULATION)
  p_list <- Filter(function(x) !is.na(x), filtered_list)

  return(p_list)
}

#' Extract Byline Metadata
#'
#' Retrieves byline fields (BYLINE1, BYLINE2, etc.) from the metadata.
#'
#' @inheritParams get_title
#'
#' @return A named list of non-missing byline fields.
#'
#' @export
get_byline <- function(df = NULL,
                       type = NULL,
                       tnumber = NULL,
                       pname = NULL,
                       oid = NULL) {
  if (is.null(df)) stop("Input dataframe error! Check the input data and try again. \n")

  if (is.null(pname) & is.null(tnumber)) stop("Need to provide either a program name or TFL number to select row.\n")

  # select either on program nmae of TFL number
  if (!is.null(pname)) {
    byline_list <- select_with_name(df = df, pname = pname, oid = oid)
  } else {
    byline_list <- select_with_number(df = df, tnumber = tnumber)
  }
  # select only byline
  filtered_list <- byline_list %>%
    dplyr::select(starts_with("BYLINE"))
  b_list <- Filter(function(x) !is.na(x), filtered_list)

  return(b_list)
}

#' Extract Program Name Metadata
#'
#' Retrieves program name field (PGMNAME) from the metadata.
#'
#' @inheritParams get_title
#'
#' @return A named list containing the program name field.
#'
#' @export
get_pgmname <- function(df = NULL,
                        type = NULL,
                        tnumber = NULL,
                        pname = NULL,
                        oid = NULL) {
  if (is.null(df)) stop("Input dataframe error! Check the input data and try again. \n")

  if (is.null(pname) & is.null(tnumber)) stop("Need to provide either a program name or TFL number to select row.\n")

  # select either on program name or TFL number
  if (!is.null(pname)) {
    pgmname_list <- select_with_name(df = df, pname = pname, oid = oid)
  } else {
    pgmname_list <- select_with_number(df = df, tnumber = tnumber)
  }
  # select only program name
  filtered_list <- pgmname_list %>%
    dplyr::select(PGMNAME)
  p_list <- Filter(function(x) !is.na(x), filtered_list)

  return(p_list)
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
    dplyr::select(starts_with("SOURCE"))
  f_list <- Filter(function(x) !is.na(x), filtered_list)

  return(f_list)
}

