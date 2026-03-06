
#' Extract Title Metadata
#'
#' Retrieves title-related fields (`TTL1`, `TTL2`, etc.) and population
#' information from metadata for a specified program name or TFL number.
#'
#' @param df A data frame or tibble containing title and footnote metadata.
#' @param tnumber Optional TFL number.
#' @param pname Optional program name.
#' @param oid Optional object ID.
#'
#' @return A named list of non-missing title-related fields.
#'
#' @export
get_title <- function(df,
                      tnumber = NULL,
                      pname = NULL,
                      oid = NULL) {
  validate_input(df, pname, tnumber)

  if (!is.null(pname)) {
    title_list <- select_row(df, by_column = "PGMNAME", by_value = pname, oid = oid)
  } else {
    title_list <- select_row(df, by_column = "TTL1", by_value = tnumber)
  }
  select_cols(title_list, select_type = "TITLE")
}

#' Extract Footnote Metadata
#'
#' Retrieves footnote fields (FOOT1, FOOT2, etc.) from metadata for a specified
#' program name or TFL number.
#'
#' @inheritParams get_title
#' @param add_footr_tstamp Logical. If `TRUE`, append timestamp and source
#'   information as the last footnote line. Defaults to `TRUE`.
#'
#' @return A named list of non-missing footnote fields.
#'
#' @export
get_footnote <- function(df,
                      tnumber = NULL,
                      pname = NULL,
                      oid = NULL,
                      add_footr_tstamp = TRUE) {
  validate_input(df, pname, tnumber)

  if (!is.null(pname)) {
    footnote_list <- select_row(df, by_column = "PGMNAME", by_value = pname, oid = oid)
  } else {
    footnote_list <- select_row(df, by_column = "TTL1", by_value = tnumber)
  }
  select_cols(footnote_list, select_type = "FOOTR", add_footr_tstamp = add_footr_tstamp)
}


#' Extract Upper-Left Header Text
#'
#' Retrieves upper-left (`UL*`) header fields from metadata.
#'
#' @param df A data frame of metadata.
#' @param by_list Logical. If `TRUE`, returns a list of non-missing values.
#'   If `FALSE`, returns a collapsed string.
#'
#' @return A list or a character string depending on `by_list`.
#' @export
get_ulheader <- function(df, by_list = TRUE) {
  get_header_by_prefix(df, "UL", by_list = by_list)
}


#' Extract Upper-Right Header Text
#'
#' Retrieves upper-right (UR*) header fields from metadata.
#'
#' @inheritParams get_ulheader
#'
#' @return A list if `by_list = TRUE`, otherwise a single character string.
#'
#' @export
get_urheader <- function(df, by_list = TRUE) {
  get_header_by_prefix(df, "UR", by_list = by_list)
}

#' Helper
#' @noRd
get_header_by_prefix <- function(df, prefix, by_list = TRUE) {
  x <- select_starts_with(df, prefix)
  x <- Filter(function(y) !is.na(y), x)

  if (by_list) {
    x
  } else {
    paste(unlist(x, use.names = FALSE), collapse = "\n")
  }
}


#' Extract Population Metadata
#'
#' Retrieves population field from metadata for a specified program name or TFL number.
#'
#' @inheritParams get_title
#'
#' @return A named list of non-missing population field.
#'
#' @export
get_pop <- function(df,
                    tnumber = NULL,
                    pname = NULL,
                    oid = NULL) {
  validate_input(df, pname, tnumber)

  if (!is.null(pname)) {
    pop_list <- select_row(df, by_column = "PGMNAME", by_value = pname, oid = oid)
  } else {
    pop_list <- select_row(df, by_column = "TTL1", by_value = tnumber)
  }
  select_cols(pop_list, select_type = "POPULATION")
}

#' Extract Byline Metadata
#'
#' Retrieves byline fields (BYLINE1, BYLINE2, etc.) from metadata for a
#' specified program name or TFL number.
#'
#' @inheritParams get_title
#'
#' @return A named list of non-missing byline fields.
#'
#' @export
get_byline <- function(df,
                       tnumber = NULL,
                       pname = NULL,
                       oid = NULL) {
  validate_input(df, pname, tnumber)

  if (!is.null(pname)) {
    byline_list <- select_row(df, by_column = "PGMNAME", by_value = pname, oid = oid)
  } else {
    byline_list <- select_row(df, by_column = "TTL1", by_value = tnumber)
  }
  select_cols(byline_list, select_type = "BYLINE")
}

#' Extract Program Name Metadata
#'
#' Retrieves program name field (PGMNAME) from metadata for a specified
#' program name or TFL number.
#'
#' @inheritParams get_title
#'
#' @return A named list of non-missing program name field.
#'
#' @export
get_pgmname <- function(df,
                        tnumber = NULL,
                        pname = NULL,
                        oid = NULL) {
  validate_input(df, pname, tnumber)

  if (!is.null(pname)) {
    pgmname_list <- select_row(df, by_column = "PGMNAME", by_value = pname, oid = oid)
  } else {
    pgmname_list <- select_row(df, by_column = "TTL1", by_value = tnumber)
  }
  select_cols(pgmname_list, select_type = "PGMNAME")
}

#' Extract Source Metadata
#'
#' Retrieves source fields (e.g., SOURCE1) from metadata for a specified
#' program name or TFL number.
#'
#' @inheritParams get_title
#'
#' @return A named list of non-missing source fields.
#'
#' @export
get_source <- function(df,
                       tnumber = NULL,
                       pname = NULL,
                       oid = NULL) {
  validate_input(df, pname, tnumber)

  if (!is.null(pname)) {
    source_list <- select_row(df, by_column = "PGMNAME", by_value = pname, oid = oid)
  } else {
    source_list <- select_row(df, by_column = "TTL1", by_value = tnumber)
  }
  select_cols(source_list, select_type = "SOURCE")
}



