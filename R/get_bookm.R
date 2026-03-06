#' Get Bookmark Value with Abbreviation Shortening
#'
#' @description
#' The `get_bookm()` function extracts or constructs a bookmark string
#' from a data frame row. It first looks for a `"BOOKM"` column; if not found
#' or if empty, it falls back to `get_title()`. The result is sanitized
#' so that it can be safely used as a filename or PDF bookmark. If the bookmark
#' exceeds `max_length`, phrases are shortened using an external abbreviation
#' lookup table stored in `abbrev.xlsx`.
#'
#' @param df A data frame containing metadata (must have at least one row).
#' @param tnumber A character string specifying the table or listing number.
#' @param pname A character string specifying the program name.
#'   If not `NULL`, this takes priority over `tnumber`.
#' @param oid An optional character string object identifier.
#' @param abbrev_file Path to an abbreviation Excel file (default = `"st_abbrev.xlsx"`).
#'   The file must contain two columns: the first for phrases and the second for
#'   their corresponding abbreviations.
#' @param max_length Maximum allowed bookmark length. Default is `180`.
#'
#' @return A character string containing a sanitized (and possibly shortened) bookmark.
#'
#' @examples
#' df <- data.frame(
#'   TTL1    = c("1", "2"),
#'   PGMNAME = c("adsl_summary", "ae_list"),
#'   BOOKM   = c(NA, "Listing_2_Bookmark")
#' )
#'
#' get_bookm(df, pname = "ae_list")
#' get_bookm(df, tnumber = "2")
#'
#' # BOOKM is NA, so the function falls back to get_title()
#' get_bookm(df, pname = "adsl_summary")
#'
#' \donttest{
#'   # Example using an external abbreviation file
#'   get_bookm(df, pname = "adsl_summary", abbrev_file = "st_abbrev.xlsx")
#' }
#'
#' @export
get_bookm <- function(df,
                      tnumber = NULL,
                      pname = NULL,
                      oid = NULL,
                      abbrev_file = "st_abbrev.xlsx",
                      max_length = 180) {
  validate_input(df, pname, tnumber)

  if (!is.null(pname)) {
    row <- select_row(df, by_column = "PGMNAME", by_value = pname, oid = oid)
  } else {
    row <- select_row(df, by_column = "TTL1", by_value = tnumber)
  }

  # Extract bookm
  bookm <- if ("BOOKM" %in% names(row)) row$BOOKM[1] else NA_character_

  # Fallback if bookm is missing
  if (is.null(bookm) || is.na(bookm) || bookm == "") {
    titles <- get_title(df = df, pname = pname, tnumber = tnumber, oid = oid)
    bookm <- paste(unlist(titles), collapse = "_")
  }

  # Sanitize invalid characters
  bookm <- gsub('[\\\\/:;()*?"<>|]', "", bookm)

  # If too long, apply abbreviation table
  if (nchar(bookm) > max_length) {
    if (!file.exists(abbrev_file)) {
      warning(
        sprintf(
          "Bookmark exceeds %s characters and abbrev file not found; returning long bookmark.",
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
