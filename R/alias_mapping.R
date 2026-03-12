#' Standardize column names in the metadata file
#'
#' Reads an Excel metadata file, standardizes its column names to the expected
#' field names using a JSON mapping configuration, and writes the result to a
#' new Excel file.
#'
#' @param input_xlsx Path to the input Excel file.
#' @param output_xlsx Path to the output Excel file to create.
#' @param config_path Path to a JSON configuration file containing the
#'   column name mapping.
#' @param sheet Sheet index or name passed to
#'   \code{\link[readxl:read_excel]{readxl::read_excel}}.
#'   If \code{NULL} (default), the first worksheet in the Excel file is used.
#'
#' @details
#' The JSON configuration file must contain an `aliases` field, which is a named
#' list mapping each canonical field name to a character vector of acceptable
#' input column name variants. For example:
#'
#' ```json
#' {
#'   "aliases": {
#'     "TTL1": ["Title 1", "Title_1"],
#'     "PGMNAME": ["Program Name", "program_name"]
#'   }
#' }
#' ```
#'
#' Before matching, input column names and aliases are normalized by converting
#' to lowercase, trimming whitespace, and replacing underscores with spaces.
#' Columns that do not match any alias are preserved unchanged. If multiple
#' input columns map to the same canonical field name, output names are made
#' unique via [base::make.unique()].
#'
#' @return Invisibly returns the path to the output Excel file.
#'
#' @examples
#' input_file <- tempfile(fileext = ".xlsx")
#' output_file <- tempfile(fileext = ".xlsx")
#' config_file <- tempfile(fileext = ".json")
#'
#' example_df <- data.frame(
#'   "Title_1" = "Summary of demographics",
#'   "Program Name" = "t_dm",
#'   check.names = FALSE
#' )
#'
#' writexl::write_xlsx(example_df, input_file)
#'
#' cfg <- paste0(
#'   "{",
#'   '  "aliases": {',
#'   '    "TTL1": ["Title 1"],',
#'   '    "PGMNAME": ["Program Name"]',
#'   "  }",
#'   "}"
#' )
#'
#' writeLines(cfg, config_file)
#'
#' change_colname(
#'   input_xlsx = input_file,
#'   output_xlsx = output_file,
#'   config_path = config_file
#' )
#'
#' readxl::read_excel(output_file)
#'
#' @seealso
#'   [read_tfile()] to read the standardized metadata file.
#'
#' @export
change_colname <- function(input_xlsx,
                           output_xlsx,
                           config_path,
                           sheet = NULL) {
  cfg <- jsonlite::fromJSON(config_path, simplifyVector = TRUE)
  df <- readxl::read_excel(input_xlsx, sheet = sheet)
  df_mapped <- apply_header_mapping(df, cfg)
  writexl::write_xlsx(df_mapped, output_xlsx)
  invisible(output_xlsx)
}


#' Convenience wrapper that returns a data.frame
#' @noRd
map_dataframe_headers <- function(df, config_path) {
  cfg <- jsonlite::fromJSON(config_path, simplifyVector = TRUE)
  apply_header_mapping(df, cfg)
}


#' @noRd
normalize_header <- function(x) {
  # Apply the same normalization rules as config:
  # - case-insensitive (lowercase)
  # - trim whitespace
  # - remove underscores
  x2 <- tolower(trimws(x))
  x2 <- gsub("_", " ", x2, fixed = TRUE)
  x2
}

#' @noRd
build_alias_lookup <- function(cfg) {
  # cfg$aliases is a named list: canonical -> vector of aliases
  # Return a named character vector mapping normalized alias -> canonical
  out <- c()
  for (canon in names(cfg$aliases)) {
    aliases <- cfg$aliases[[canon]]
    # Also ensure canonical is included as a self-alias
    aliases <- unique(c(aliases, canon))
    nms <- vapply(aliases, normalize_header, character(1))
    # If duplicates occur across canonicals, the last one wins—this should not happen if config is clean.
    tmp <- structure(rep(canon, length(nms)), names = nms)
    out <- c(out, tmp)
  }
  out
}

#' @noRd
apply_header_mapping <- function(df, cfg) {
  alias_lookup <- build_alias_lookup(cfg)
  # Map each incoming name: normalize, then lookup -> canonical, else keep original
  mapped <- vapply(names(df), function(nm) {
    nn <- normalize_header(nm)
    if (!is.na(alias_lookup[nn])) alias_lookup[nn] else nm
  }, character(1))

  # Make duplicate names unique (e.g., TTL1, TTL1 -> TTL1, TTL1.1)
  mapped <- make.unique(mapped, sep = ".")
  names(df) <- mapped
  df
}
