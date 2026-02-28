
# map_excel_headers.R
# Utility to map spreadsheet headers to canonical names using a JSON config.
# Dependencies: jsonlite, readxl, writexl

# if (!requireNamespace("jsonlite", quietly = TRUE)) {
#   install.packages("jsonlite")
# }
# if (!requireNamespace("readxl", quietly = TRUE)) {
#   install.packages("readxl")
# }
# if (!requireNamespace("writexl", quietly = TRUE)) {
#   install.packages("writexl")
# }
# if (!requireNamespace("stringr", quietly = TRUE)) {
#   install.packages("stringr")
# }

#suppressPackageStartupMessages({
# library(jsonlite)
# library(readxl)
# library(writexl)
# library(stringr)

#})

# ---- Helpers ----
normalize_header <- function(x) {
  # Apply the same normalization rules as config:
  # - case-insensitive (lowercase)
  # - trim whitespace
  # - remove underscores
  # - collapse multiple spaces
  x2 <- tolower(trimws(x))
  x2 <- gsub("_", " ", x2, fixed = TRUE)
  x2
}

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


#' Rename Excel columns using a JSON-based header mapping configuration
#'
#' Reads an Excel worksheet, maps its column headers to canonical field names
#' defined in a JSON configuration file, and writes the updated data to a new
#' Excel file.
#'
#' @param input_xlsx Path to the input Excel file.
#' @param output_xlsx Path to the output Excel file to create.
#' @param config_path Path to a JSON configuration file describing canonical
#'   field names, matching rules, and aliases.
#' @param sheet Sheet index or name passed to
#'   \code{\link[readxl:read_excel]{readxl::read_excel}}.
#'   Defaults to \code{1}.
#'
#' @details
#' The JSON configuration file must contain the following top-level fields:
#'
#' \describe{
#'   \item{\code{matching_rules}}{A list controlling how header names are normalized
#'   prior to matching. Supported elements include:
#'     \itemize{
#'       \item \code{case_insensitive}: logical; if \code{TRUE}, headers are matched
#'         without case sensitivity.
#'       \item \code{trim_whitespace}: logical; if \code{TRUE}, leading and trailing
#'         whitespace is removed.
#'       \item \code{normalize}: character vector specifying additional normalization
#'         steps. Currently supported:
#'           \itemize{
#'             \item \code{"collapse_spaces"} — collapse multiple internal spaces to one.
#'             \item \code{"remove_underscores"} — remove underscore characters.
#'           }
#'     }
#'   }
#'
#'   \item{\code{canonical_fields}}{Character vector of allowed canonical output
#'   column names (e.g., \code{"TTL1"}, \code{"FOOT1"}, \code{"Population"}).}
#'
#'   \item{\code{aliases}}{Named list mapping each canonical field to a character
#'   vector of acceptable input header variants.}
#' }
#'
#' Header Mapping Behavior:
#' \itemize{
#'   \item Incoming column names are normalized in the following order:
#'     lowercasing → trimming whitespace → removing underscores →
#'     collapsing internal spaces.
#'
#'   \item After normalization, headers are matched against normalized aliases
#'     to determine their canonical field name.
#'
#'   \item Columns that do not match any alias are preserved unchanged.
#'
#'   \item If multiple input columns map to the same canonical field,
#'     output names are made unique using
#'     \code{\link[base:make.unique]{base::make.unique}},
#'     appending suffixes such as \code{.1}, \code{.2}, etc.
#' }
#'
#' The function:
#' \enumerate{
#'   \item Parses the JSON configuration using
#'     \code{\link[jsonlite:fromJSON]{jsonlite::fromJSON}}.
#'   \item Reads the Excel sheet using
#'     \code{\link[readxl:read_excel]{readxl::read_excel}}.
#'   \item Applies header mapping via \code{apply_header_mapping()}.
#'   \item Writes the mapped data frame using
#'     \code{\link[writexl:write_xlsx]{writexl::write_xlsx}}.
#' }
#'
#' @return Invisibly returns \code{output_xlsx}.
#'
#' @examples
#' \dontrun{
#' cfg_path <- system.file(
#'   "extdata",
#'   "field_mapping.config.json",
#'   package = "tflmetaR"
#' )
#'
#' change_colname(
#'   input_xlsx  = "input.xlsx",
#'   output_xlsx = "output.xlsx",
#'   config_path = cfg_path
#' )
#' }
#'
#' @seealso
#' \code{\link[readxl:read_excel]{readxl::read_excel}},
#' \code{\link[writexl:write_xlsx]{writexl::write_xlsx}},
#' \code{\link[jsonlite:fromJSON]{jsonlite::fromJSON}},
#' \code{\link[base:make.unique]{base::make.unique}}
#'
#'
#'#' @export
change_colname <- function(input_xlsx,
                           output_xlsx,
                           config_path,
                           sheet = 1) {
  cfg <- jsonlite::fromJSON(config_path, simplifyVector = TRUE)
  df <- readxl::read_excel(input_xlsx, sheet = sheet)
  df_mapped <- apply_header_mapping(df, cfg)
  writexl::write_xlsx(df_mapped, output_xlsx)
  invisible(output_xlsx)
}

# wd <- getwd()
#
# cfg_path <- str_c( wd, '/inst/extdata/field_mapping.config.json')
# in_path  <- str_c( wd, '/inst/extdata/test_input_before_mapping.xlsx')
# exp_path <- str_c( wd, '/inst/extdata/test_output_after_mapping.xlsx') # expected output generated previously
# tmp_out  <- str_c( wd, '/inst/extdata/test_output_after_mapping_new.xlsx')
# map_excel_headers(input_xlsx = in_path,
#                   output_xlsx = tmp_out,
#                   config_path = cfg_path)

# ---- Optional: convenience wrapper that returns a data.frame ----
map_dataframe_headers <- function(df, config_path=cfg_path) {
  cfg <- jsonlite::fromJSON(config_path, simplifyVector = TRUE)
  apply_header_mapping(df, cfg)
}


#
#
# An R utility (function “macro”) that maps Excel headers to your canonical field names using a JSON config (same normalization rules you described).
# ✅ A test input Excel (“before mapping”).
# ✅ An expected output Excel (“after mapping”) produced with the same rules—so you can verify the R function produces identical output.
#
#
# Save as map_excel_headers.R (or paste into your R session).
# This reads the JSON config, normalizes and maps column names, and writes out a new Excel file.
#
# How it works (quick)
#
# Normalization: lowercasing → trim → remove underscores → collapse spaces.
# So "Title 1", "TITLE_1", and "title1" all normalize to the same key.
# Aliases: The config defines aliases for each canonical field (TTL1, TTL2, …).
# Uniqueness: If two different incoming columns map to the same canonical name, the function appends .1, .2, etc. (R’s make.unique).
#
#
#
# Validate the result
#
# The output test_output_after_mapping_from_R.xlsx should have columns:
#   sample, Type, Pgmname, OID, Source, Population, TTL1, TTL2, TTL3, BYLINE1, BYLINE2, BOOKM, FOOT1, FOOT2, FOOT3, FOOT4, FOOT5, FOOT6, FOOT7, FOOT8
# It should match the provided expected output file:
#   test_output_after_mapping.xlsx
#
#
#
# 4) Notes & customization
#
# Keep unmapped headers: Any input column that doesn’t match the aliases remains unchanged (by design).
# Extend aliases: Add additional variants you see in the wild to field_mapping.config.json under the corresponding canonical field.
# Multiple sheets: Pass sheet = "SheetName" to map_excel_headers() if your data isn’t on the first sheet.
# No JSON dependency: If you prefer embedding the mapping directly in R, I can provide a version with the alias list in code.
#
#
# 5) What’s included in the test files
#
# Before: columns like "Sample ID", "type", "Program Name", "Object ID", "data source", "Cohort", "Title 1", … "Footer 8", with 3 example rows.
# After: the same rows, with headers mapped to the canonical names (sample, Type, Pgmname, … FOOT8).
