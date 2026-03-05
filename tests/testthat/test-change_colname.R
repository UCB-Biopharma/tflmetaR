
# ---- 1) EXPLICIT CALL: map_excel_headers() file -> file ----
test_that("alias_mapping() maps headers and preserves data", {
  input_xlsx <- system.file(
    "extdata",
    "test_input_before_mapping.xlsx",
    package = "tflmetaR"
  )

  output_xlsx <- tempfile(fileext = ".xlsx")

  config_path <- system.file(
    "extdata",
    "field_mapping.config.json",
    package = "tflmetaR"
  )

  exp_path <- system.file(
    "extdata",
    "test_output_after_mapping.xlsx",
    package = "tflmetaR"
  )

  change_colname(input_xlsx, output_xlsx, config_path)

  actual   <- read_excel(output_xlsx)
  expected <- read_excel(exp_path)

  # Compare column names
  expect_identical(names(actual), names(expected))

  # Compare dimensions
  expect_identical(dim(actual), dim(expected))

  # Compare content as character to avoid Excel type quirks
  to_char <- function(df) {
    data.frame(lapply(df, function(col) as.character(col)),
               check.names = FALSE, stringsAsFactors = FALSE)
  }
  expect_identical(to_char(actual), to_char(expected))
})

# ---- 2) IN-MEMORY CALL: map_dataframe_headers() ----
test_that("map_dataframe_headers() maps TTL1 and preserves unmapped", {
  # Minimal in-memory example
  df <- data.frame(
    "Title 1"         = c("A", "B"),
    "Some_New_Header" = c(1, 2),
    check.names = FALSE
  )
  config_path <- system.file(
    "extdata",
    "field_mapping.config.json",
    package = "tflmetaR"
  )
  df_map <- map_dataframe_headers(df, config_path)

  expect_true("TTL1" %in% names(df_map))
  expect_true("Some_New_Header" %in% names(df_map))
  expect_identical(df_map$TTL1, c("A", "B"))
  # Numeric -> character after Excel-like handling; ensure values preserved textually
  expect_identical(as.character(df_map$Some_New_Header), c("1", "2"))
})


# ---- 3) Collision handling (TTL1 & TITLE_1) ----
test_that("Duplicate canonical collisions become unique", {
  df <- data.frame(
    "Title 1" = c("x", "y"),
    "TITLE_1" = c("p", "q"),
    check.names = FALSE
  )
  config_path <- system.file(
    "extdata",
    "field_mapping.config.json",
    package = "tflmetaR"
  )
  df_map <- map_dataframe_headers(df, config_path)

  expect_equal(names(df_map)[1], "TTL1")
  expect_equal(names(df_map)[2], "TTL1.1")
  expect_identical(df_map$TTL1,   c("x", "y"))
  expect_identical(df_map$`TTL1.1`, c("p", "q"))
})

# ---- 4) Idempotency (file -> file twice) ----
test_that("map_excel_headers() is idempotent", {
  tmp1 <- tempfile(fileext = ".xlsx")
  tmp2 <- tempfile(fileext = ".xlsx")

  input_xlsx <- system.file(
    "extdata",
    "test_input_before_mapping.xlsx",
    package = "tflmetaR"
  )

  config_path <- system.file(
    "extdata",
    "field_mapping.config.json",
    package = "tflmetaR"
  )

  invisible(change_colname(input_xlsx, tmp1, config_path))
  invisible(change_colname(tmp1, tmp2, config_path))

  df1 <- read_excel(tmp1)
  df2 <- read_excel(tmp2)

  expect_identical(names(df1), names(df2))
  expect_identical(
    data.frame(lapply(df1, as.character), check.names = FALSE),
    data.frame(lapply(df2, as.character), check.names = FALSE)
  )
})
