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
#' @export
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


# ---- Optional: convenience wrapper that returns a data.frame ----
map_dataframe_headers <- function(df, config_path) {
  cfg <- jsonlite::fromJSON(config_path, simplifyVector = TRUE)
  apply_header_mapping(df, cfg)
}


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
