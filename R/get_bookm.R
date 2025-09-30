#' Get Bookmark Value with Abbreviation Shortening
#'
#' @description
#' The `get_bookm()` function extracts or constructs a bookmark string
#' from a data frame row. It first looks for a `"bookm"` column; if not found
#' or if empty, it falls back to `get_title()`. The result is sanitized
#' so that it can be safely used as a filename or PDF bookmark. If the length
#' of the bookmark exceeds 128 characters, phrases are shortened using an
#' external abbreviation lookup table stored in `abbrev.xlsx`.
#'
#' @param df A data frame containing metadata (must have at least one row).
#' @param type Optional character string specifying the object type
#'   (e.g., `"Table"`, `"Listing"`, `"Figure"`). Not used for filtering.
#' @param tnumber A character or numeric value specifying the table or listing number.
#' @param pname A character string specifying the program name.
#'   If not `NULL`, this takes priority over `tnumber`.
#' @param oid Optional character or numeric object identifier (not used for filtering).
#' @param abbrev_file Path to an abbreviation Excel file (default = `"abbrev.xlsx"`).
#'   The file must have two columns: first = phrase, second = abbreviation.
#'
#' @return A character string containing a sanitized (and possibly shortened) bookmark.
#'
#' @examples
#' \dontrun{
#' df <- data.frame(
#'   tnumber = c("1", "2"),
#'   pname   = c("adsl_summary", "ae_list"),
#'   bookm   = c(NA, "Listing_2_Bookmark")
#' )
#'
#' get_bookm(df, pname = "adsl_summary") # fallback to get_title()
#' get_bookm(df, tnumber = "2")          # uses bookm column
#' }
#'
#' @export
get_bookm <- function(df = NULL,
                      type = NULL,
                      tnumber = NULL,
                      pname = NULL,
                      oid = NULL,
                      abbrev_file = "st_abbrev.xlsx") {
  # Input checks
  if (is.null(df)) stop("`df` must be provided.")

  # Filter logic
  if (!is.null(pname)) {
    row <- df[df$pname == pname, , drop = FALSE]
  } else if (!is.null(tnumber)) {
    row <- df[df$tnumber == tnumber, , drop = FALSE]
  } else {
    stop("Either `pname` or `tnumber` must be provided.")
  }

  if (nrow(row) == 0) stop("No matching row found in `df`.")
  if (nrow(row) > 1) warning("Multiple rows found; returning the first match.")

  # Extract bookm
  bookm <- row$bookm[1]

  # Fallback if bookm is missing
  if (is.null(bookm) || is.na(bookm) || bookm == "") {
    titles <- get_title(df = df, pname = pname, tnumber = tnumber, oid = oid)
    bookm <- paste(unlist(titles), collapse = "_")
  }

  # Sanitize invalid characters
  bookm <- gsub('[\\\\/:*?"<>|]', "", bookm)

  # If too long, apply abbreviation table
  if (nchar(bookm) > 128) {
    if (!file.exists(abbrev_file)) {
      warning("Bookmark exceeds 128 characters and abbrev file not found; returning long bookmark.")
    } else {
      #library(readxl)
      abbrev <- readxl::read_excel(abbrev_file, col_names = TRUE)
      colnames(abbrev) <- c("scope", "phrase", "abbr")

      for (i in seq_len(nrow(abbrev))) {
        bookm <- gsub(abbrev$phrase[i], abbrev$abbr[i], bookm, fixed = TRUE)
      }
    }
  }

  # Enforce maximum length
  if (nchar(bookm) > 128) {
    bookm <- substr(bookm, 1, 128)
  }

  return(bookm)
}
