#' @export
read_xlfile <- function(filename, sheetname) {
  df <- readxl::read_excel(filename, sheet = sheetname)

  # TODO awu: use zzz.R and getOption() to get required_cols
  colnames(df) <- toupper(colnames(df))
  required_cols <- c("PGMNAME", "TTL1", "FOOT1", "SOURCE")

  if (!all(required_cols %in% colnames(df)))
    stop("Input file has required column(s) missing.\n")

  df
}


select_row <- function(data, by_column, by_value, oid=NULL) {
  df <- data %>% filter(!!sym(by_column) == by_value)

  if (!is.null(oid))  df <- df %>% filter(OID == oid)

  if (nrow(df) == 0) {
    stop("No row is found. Check the title and footnote file and try again.\n")
  } else if (nrow(df) > 1) {
    stop("Non unique entry generated. Check the title and footnote file and try again.\n")
  }
  df
}

select_cols <- function(data, select_type, add_footr_tstamp=TRUE) {
  type <- toupper(select_type);
  cols <- NULL;

  if (is.null(select_type)) {
    cols <- data
  } else if (type=="TITLE") {
    cols <- data %>% select(starts_with("TTL"), POPULATION)
  } else if (type=="FOOTR") {
    cols <- data %>% select(starts_with("FOOT"))
    col_src <- data %>% select(SOURCE)

    if (!is.null(add_footr_tstamp) && add_footr_tstamp) {
      cols <- add_footr_tstamp(cols, col_src)
    }
  } else {
    cols <- data %>% select(type)
  }

  out <- Filter(function(x) !is.na(x), cols)
  out
}


add_footr_tstamp <- function(data, col_src) {
  runtime_stamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  ref_timestamp <- glue("\nGenerated from {basename(rstudioapi::getSourceEditorContext()$path)} on ",
                        runtime_stamp, " Data Source(s): ", unlist(col_src), "\n")

  out <- c(data, ref_timestamp)
  names(out)[length(out)] <- "SOURCE" #give last part a name in case end user want to refer to it.

  return(as.data.frame(out))
}
