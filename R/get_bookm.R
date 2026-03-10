#' Get bookmark text for a table, listing, or figure
#'
#' Returns bookmark text from metadata for a specified output. The function
#' first identifies the matching row in `df` using `pname` or `tnumber`.
#' If a non-missing `BOOKM` value is available, that value is returned.
#' Otherwise, the function falls back to [get_title()] and combines the
#' returned title components into a single bookmark string.
#'
#' The bookmark text is sanitized by removing characters that are not suitable
#' for bookmark use. If the result exceeds `max_length`, the function attempts
#' to shorten it using abbreviation mappings from `abbrev_file`. If the
#' bookmark is still too long, it is truncated at a word boundary up to
#' `max_length` characters.
#'
#' @param df A data frame containing metadata.
#' @param tnumber An optional character string specifying the TFL number
#'   stored in `TTL1`, such as `"Table 14.1.1"`.
#' @param pname An optional character string specifying the program name
#'   stored in `PGMNAME`.
#'
#'   Exactly one of `tnumber` or `pname` must be supplied.
#' @param oid An optional character string specifying the object identifier.
#' @param abbrev_file Optional path to an Excel file containing abbreviation
#'   mappings. The file should contain three columns corresponding to scope,
#'   phrase, and abbreviation. If `NULL`, no abbreviation table is applied.
#' @param max_length Maximum allowed bookmark length. Default is `180`.
#'
#' @return A character string containing sanitized bookmark text.
#'
#' @examples
#' # Example 1: return BOOKM when it is present
#' df1 <- data.frame(
#'   TTL1 = "Figure 1.1",
#'   PGMNAME = "f_km.R",
#'   BOOKM = "KM_PLOT"
#' )
#'
#' get_bookm(df1, pname = "f_km.R")
#' get_bookm(df1, tnumber = "Figure 1.1")
#'
#' # Example 2: fall back to title text when BOOKM is missing
#' df2 <- data.frame(
#'   TTL1 = "Adverse Events",
#'   TTL2 = "Safety Population",
#'   PGMNAME = "t_ae",
#'   BOOKM = NA
#' )
#'
#' get_bookm(df2, pname = "t_ae")
#'
#' # Example 3: invalid characters are removed
#' df3 <- data.frame(
#'   TTL1 = "Listing 3. Laboratory Results",
#'   PGMNAME = "l_lab",
#'   BOOKM = "Lab: ALT/AST * Overview?"
#' )
#'
#' get_bookm(df3, pname = "l_lab")
#'
#' @export
get_bookm <- function(df,
                      tnumber = NULL,
                      pname = NULL,
                      oid = NULL,
                      abbrev_file = NULL,
                      max_length = 180) {
  annotation <- get_annotation(df, tnumber, pname, oid, annotation = "BOOKM")

  bookm <- annotation$BOOKM[1]

  # Fallback if bookm is missing
  if (is.null(bookm) || is.na(bookm) || bookm == "") {
    titles <- get_title(df = df, pname = pname, tnumber = tnumber, oid = oid)
    bookm <- paste(unlist(titles), collapse = "_")
  }

  # Sanitize invalid characters
  bookm <- gsub('[\\\\/:;()*?"<>|]', "", bookm)

  # If too long, apply abbreviation table
  if (nchar(bookm) > max_length) {
    if (is.null(abbrev_file)) {
      warning(
        sprintf(
          "Bookmark exceeds %s characters and no abbrev file was provided.",
          max_length
        )
      )
    } else if (!file.exists(abbrev_file)) {
      warning(
        sprintf(
          "Bookmark exceeds %s characters and abbrev file not found.",
          max_length
        )
      )
    } else {
      abbrev <- readxl::read_excel(abbrev_file, col_names = TRUE)
      colnames(abbrev) <- c("scope", "phrase", "abbr")

      for (i in seq_len(nrow(abbrev))) {
        bookm <- gsub(abbrev$phrase[i], abbrev$abbr[i], bookm, fixed = TRUE)
      }
    }
  }

  # Enforce maximum length
  if (nchar(bookm) > max_length) {
    words <- strsplit(bookm, " ")[[1]]
    result <- ""
    for (word in words) {
      if (nchar(result) + nchar(word) + 1 <= max_length) {
        result <- paste(result, word, sep = ifelse(nchar(result) == 0, "", " "))
      } else {
        break
      }
    }
    result
  } else {
    bookm
  }
}
