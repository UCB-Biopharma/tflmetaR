# test_map_excel_headers.R
# Purpose: Verify header mapping works end-to-end and in-memory.

# ---- Load deps ----
if (!requireNamespace("testthat", quietly = TRUE)) {
  install.packages("testthat")
}
if (!requireNamespace("readxl", quietly = TRUE)) {
  install.packages("readxl")
}
if (!requireNamespace("writexl", quietly = TRUE)) {
  install.packages("writexl")
}
if (!requireNamespace("jsonlite", quietly = TRUE)) {
  install.packages("jsonlite")
}

library(testthat)
library(readxl)
library(writexl)
library(jsonlite)

# ---- Source the macro (adjust the path to where your macro lives) ----
# If running from project root:
#   source("map_excel_headers.R")
# If running inside tests/testthat/:
#   source(testthat::test_path("..", "..", "map_excel_headers.R"))
source("/home/u064039/tfletaR_change_col_name/R/alias_mapping.R")


# ---- Resolve test fixtures ----
# If you're building a package and these files live in inst/extdata, prefer system.file():
# cfg_path <- system.file("extdata", "field_mapping.config.json", package = "yourpackagename")
# in_path  <- system.file("extdata", "test_input_before_mapping.xlsx", package = "yourpackagename")
# exp_path <- system.file("extdata", "test_output_after_mapping.xlsx",  package = "yourpackagename")



cfg_path <- "/home/u064039/tfletaR_change_col_name/inst/extdata/field_mapping.config.json"
in_path  <- "/home/u064039/tfletaR_change_col_name/inst/extdata/test_input_before_mapping.xlsx"
exp_path <- "/home/u064039/tfletaR_change_col_name/inst/extdata/test_output_after_mapping.xlsx" # expected output generated previously
tmp_out  <- "/home/u064039/tfletaR_change_col_name/inst/extdata/test_output_after_mapping_new.xlsx"



# ---- 1) EXPLICIT CALL: map_excel_headers() file -> file ----
testthat::test_that("alias_mapping() maps headers and preserves data", {

  # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  # The explicit call you were looking for:
  map_excel_headers(input_xlsx = in_path,
                              output_xlsx = tmp_out,
                              config_path = cfg_path)
  # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  actual   <- read_excel(tmp_out)
  expected <- read_excel(exp_path)

  # Compare column names
  testthat::expect_identical(names(actual), names(expected))

  # Compare dimensions
  testthat::expect_identical(dim(actual), dim(expected))

  # Compare content as character to avoid Excel type quirks
  to_char <- function(df) {
    data.frame(lapply(df, function(col) as.character(col)),
               check.names = FALSE, stringsAsFactors = FALSE)
  }
  testthat::expect_identical(to_char(actual), to_char(expected))
})

# ---- 2) IN-MEMORY CALL: map_dataframe_headers() ----
testthat::test_that("map_dataframe_headers() maps TTL1 and preserves unmapped", {
  # Minimal in-memory example
  df <- data.frame(
    "Title 1"         = c("A", "B"),
    "Some_New_Header" = c(1, 2),
    check.names = FALSE
  )

  df_map <- map_dataframe_headers(df, cfg_path)

  # DEBUG ONLY: export to global env
  assign("df_dbg", df, envir = .GlobalEnv)
  assign("df_map", df_map, envir = .GlobalEnv)


  testthat::expect_true("TTL1" %in% names(df_map))
  testthat::expect_true("Some_New_Header" %in% names(df_map))
  testthat::expect_identical(df_map$TTL1, c("A", "B"))
  # Numeric -> character after Excel-like handling; ensure values preserved textually
  testthat::expect_identical(as.character(df_map$Some_New_Header), c("1", "2"))
})


# ---- 3) Collision handling (TTL1 & TITLE_1) ----
testthat::test_that("Duplicate canonical collisions become unique", {
  df <- data.frame(
    "Title 1" = c("x", "y"),
    "TITLE_1" = c("p", "q"),
    check.names = FALSE
  )
  df_map <- map_dataframe_headers(df, cfg_path)

  # DEBUG ONLY: export to global env
  assign("df_dbg", df, envir = .GlobalEnv)
  assign("df_map_dbg", df_map, envir = .GlobalEnv)

  testthat::expect_equal(names(df_map)[1], "TTL1")
  testthat::expect_equal(names(df_map)[2], "TTL1.1")
  testthat::expect_identical(df_map$TTL1,   c("x", "y"))
  testthat::expect_identical(df_map$`TTL1.1`, c("p", "q"))
})

# ---- 4) Idempotency (file -> file twice) ----
testthat::test_that("map_excel_headers() is idempotent", {
  tmp1 <- tempfile(fileext = ".xlsx")
  tmp2 <- tempfile(fileext = ".xlsx")

  invisible(map_excel_headers(in_path, tmp1, cfg_path))
  invisible(map_excel_headers(tmp1,  tmp2, cfg_path))

  df1 <- read_excel(tmp1)
  df2 <- read_excel(tmp2)

  expect_identical(names(df1), names(df2))
  expect_identical(
    data.frame(lapply(df1, as.character), check.names = FALSE),
    data.frame(lapply(df2, as.character), check.names = FALSE)
  )
})

# ---- Optional: run this file directly ----
if (sys.nframe() == 0L) {
  message("Running tests in current file...")
  testthat::test_file("test_map_excel_headers.R")
}
