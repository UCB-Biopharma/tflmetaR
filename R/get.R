#' Get Title Metadata
#'
#' Retrieves title-related fields (for example, `TTL1`, `TTL2`) from a TFL
#' metadata data frame for a specified program name or table number.
#'
#' @param df A data frame containing TFL metadata.
#' @param tnumber An optional character string specifying the TFL number
#'   stored in `TTL1`, such as `"Table 14.1.1"`.
#' @param pname An optional character string specifying the program name
#'   stored in `PGMNAME`.
#'
#'   Exactly one of `tnumber` or `pname` must be supplied.
#' @param oid An optional character string specifying the object ID stored
#'   in `OID`. Use this when multiple rows match the program name.
#'
#' @return A named list containing non-missing title-related metadata fields.
#'
#' @examples
#' meta <- data.frame(
#'   PGMNAME = c("t_dm", "t_ae"),
#'   TTL1 = c("Table 14.1.1", "Table 14.3.1"),
#'   TTL2 = c("Subject Disposition", "Adverse Events"),
#'   SOURCE = c("ADSL", "ADAE"),
#'   FOOT1 = c(
#'     "All Randomized Subjects",
#'     "Safety Population"
#'   ),
#'   FOOT2 = c(
#'     "Reference: Listing 11.3",
#'     "Adverse events coded using MedDRA"
#'   )
#' )
#'
#' get_title(meta, pname = "t_dm")
#' get_title(meta, tnumber = "Table 14.3.1")
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
  select_cols(title_list, annotation = "TITLE")
}

#' Get Footnote Metadata
#'
#' Retrieves footnote-related fields (for example, `FOOT1`, `FOOT2`) from a TFL
#' metadata data frame for a specified program name or TFL number.
#'
#' @inheritParams get_title
#' @param add_footr_tstamp Logical. If `TRUE`, append timestamp and source
#'   information as the last footnote line. Defaults to `TRUE`.
#'
#' @return A named list of non-missing footnote-related metadata fields.
#'
#' @examples
#' meta <- data.frame(
#'   PGMNAME = c("t_dm", "t_ae"),
#'   TTL1 = c("Table 14.1.1", "Table 14.3.1"),
#'   TTL2 = c("Subject Disposition", "Adverse Events"),
#'   SOURCE = c("ADSL", "ADAE"),
#'   FOOT1 = c(
#'     "All Randomized Subjects",
#'     "Safety Population"
#'   ),
#'   FOOT2 = c(
#'     "Reference: Listing 11.3",
#'     "Adverse events coded using MedDRA"
#'   )
#' )
#'
#' get_footnote(meta, pname = "t_dm", add_footr_tstamp = FALSE)
#' get_footnote(meta, tnumber = "Table 14.3.1", add_footr_tstamp = FALSE)
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
  select_cols(footnote_list, annotation = "FOOTR", add_footr_tstamp = add_footr_tstamp)
}


#' Get Upper-Left Header Text
#'
#' Retrieves upper-left header fields (for example, `UL1`, `UL2`) from metadata.
#'
#' @param df A data frame containing metadata.
#'
#' @return A named list of non-missing Upper-Left header metadata fields.
#'
#' @examples
#' meta <- data.frame(
#'   UL1 = "Drug X",
#'   UL2 = "Study 001",
#'   UR1 = "CONFIDENTIAL",
#'   UR2 = "VERSION: FINAL"
#' )
#'
#' get_ulheader(meta)
#'
#' @export
get_ulheader <- function(df) {
  select_cols(df, annotation = "UL")
}


#' Get Upper-Right Header Text
#'
#' Retrieves upper-right header fields (for example, `UR1`, `UR2`) from metadata.
#'
#' @inheritParams get_ulheader
#'
#' @return A named list of non-missing upper-right header metadata fields.
#'
#' @examples
#' meta <- data.frame(
#'   UL1 = "Drug X",
#'   UL2 = "Study 001",
#'   UR1 = "CONFIDENTIAL",
#'   UR2 = "VERSION: FINAL"
#' )
#'
#' get_urheader(meta)
#'
#' @export
get_urheader <- function(df) {
  select_cols(df, annotation = "UR")
}


#' Get Population Metadata
#'
#' Retrieves the population field from a TFL metadata data frame for a specified
#' program name or TFL number.
#'
#' @inheritParams get_title
#'
#' @return A named list containing the non-missing population field.
#'
#' @examples
#' meta <- data.frame(
#'   PGMNAME = c("t_dm", "t_ae"),
#'   TTL1 = c("Table 14.1.1", "Table 14.3.1"),
#'   SOURCE = c("ADSL", "ADAE"),
#'   POPULATION = c("ITT Population", "Safety Population"),
#'   FOOT1 = c(
#'     "Reference: Listing 11.3",
#'     "Adverse events coded using MedDRA"
#'   )
#' )
#'
#' get_pop(meta, pname = "t_dm")
#' get_pop(meta, tnumber = "Table 14.3.1")
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
  select_cols(pop_list, annotation = "POPULATION")
}

#' Get Byline Metadata
#'
#' Retrieves byline fields (BYLINE1, BYLINE2, etc.) from metadata for a
#' specified program name or TFL number.
#'
#' @inheritParams get_title
#'
#' @return A named list containing the non-missing byline fields.
#'
#' @examples
#' meta <- data.frame(
#'   PGMNAME = c("t_dm", "t_ae"),
#'   TTL1 = c("Table 14.1.1", "Table 14.3.1"),
#'   SOURCE = c("ADSL", "ADAE"),
#'   BYLINE1 = c("Treatment Group", "System Organ Class"),
#'   BYLINE2 = c("N (%)", "Preferred Term"),
#'   FOOT1 = c("ITT Population", "Safety Population")
#' )
#'
#' get_byline(meta, pname = "t_dm")
#' get_byline(meta, tnumber = "Table 14.3.1")
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
  select_cols(byline_list, annotation = "BYLINE")
}

#' Get Program Name Metadata
#'
#' Retrieves the program name field (`PGMNAME`) from metadata for a specified
#' program name or TFL number.
#'
#' @inheritParams get_title
#'
#' @return A named list containing the non-missing program name field.
#'
#' @examples
#' meta <- data.frame(
#'   PGMNAME = c("t_dm", "t_ae"),
#'   TTL1 = c("Table 14.1.1", "Table 14.3.1"),
#'   SOURCE = c("ADSL", "ADAE"),
#'   FOOT1 = c("ITT Population", "Safety Population")
#' )
#'
#' get_pgmname(meta, pname = "t_dm")
#' get_pgmname(meta, tnumber = "Table 14.3.1")
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
  select_cols(pgmname_list, annotation = "PGMNAME")
}

#' Get Source Metadata
#'
#' Retrieves source-related fields (for example, `SOURCE`) from metadata for a
#' specified program name or TFL number.
#'
#' @inheritParams get_title
#'
#' @return A named list containing the non-missing source fields.
#'
#' @examples
#' meta <- data.frame(
#'   PGMNAME = c("t_dm", "t_ae"),
#'   TTL1 = c("Table 14.1.1", "Table 14.3.1"),
#'   SOURCE = c("ADSL", "ADAE"),
#'   FOOT1 = c("ITT Population", "Safety Population")
#' )
#'
#' get_source(meta, pname = "t_dm")
#' get_source(meta, tnumber = "Table 14.3.1")
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
  select_cols(source_list, annotation = "SOURCE")
}



