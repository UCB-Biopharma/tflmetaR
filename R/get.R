#' Get Title Metadata
#'
#' Retrieves title-related fields (columns beginning with `"TTL"`, such as
#' `TTL1`, `TTL2`, and `POPULATION` if available) from a TFL metadata data
#' frame for a specified program name or table number.
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
  get_annotation(df, tnumber, pname, oid, annotation = "TITLE")
}

#' Get Footnote Metadata
#'
#' Retrieves footnote-related fields (columns beginning with `"FOOT"`,
#' such as `FOOT1` and `FOOT2`) from a TFL metadata frame for a
#' specified program name or TFL number.
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
  get_annotation(df, tnumber, pname, oid,
    annotation = "FOOTR",
    add_footr_tstamp = add_footr_tstamp
  )
}


#' Get Upper-Left Header Text
#'
#' Retrieves upper-left header fields (columns beginning with `"UL"`,
#' such as `UL1` and `UL2`) from metadata.
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
#' Retrieves upper-right header fields (columns beginning with `"UR"`,
#' such as `UR1` and `UR2`) from metadata.
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
#' Retrieves the population field `POPULATION` from a TFL metadata data frame
#' for a specified program name or TFL number.
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
  get_annotation(df, tnumber, pname, oid, annotation = "POPULATION")
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
  get_annotation(df, tnumber, pname, oid, annotation = "BYLINE")
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
  get_annotation(df, tnumber, pname, oid, annotation = "PGMNAME")
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
  get_annotation(df, tnumber, pname, oid, annotation = "SOURCE")
}


#' @noRd
get_annotation <- function(df, tnumber, pname, oid, annotation, ...) {
  validate_input(df, pname, tnumber)

  by_column <- if (!is.null(pname)) "PGMNAME" else "TTL1"
  by_value <- if (!is.null(pname)) pname else tnumber

  select_row(df, by_column = by_column, by_value = by_value, oid = oid) |>
    select_cols(annotation = annotation, ...)
}


#' @noRd
validate_input <- function(df, pname, tnumber) {
  if (is.null(df)) {
    stop("`df` must be provided.", call. = FALSE)
  }
  if (is.null(pname) && is.null(tnumber)) {
    stop("Either `pname` or `tnumber` must be provided.", call. = FALSE)
  }
  if (!is.null(pname) && !is.null(tnumber)) {
    stop("Only one of `pname` or `tnumber` should be supplied.", call. = FALSE)
  }
  invisible(TRUE)
}
