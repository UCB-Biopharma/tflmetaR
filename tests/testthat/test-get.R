library(testthat)
library(dplyr)
library(mockery)
library(glue)


test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

test_that("get_title throws error on NULL df", {
  expect_error(get_title(df = NULL),
               regexp = "Input dataframe error")
})

test_that("get_title throws error when neither pname nor tnumber is provided", {
  df <- data.frame(PGMNAME = "A", TTL1 = "Title", POPULATION = "Test")
  expect_error(get_title(df = df),
               regexp = "Need to provide either a program name or TFL number")
})

test_that("get_title uses select_with_name when pname is provided", {
  df <- data.frame(PGMNAME = "A", TTL1 = "Title", POPULATION = "Test")
  mock_select_with_name <- mock(df)
  stub(get_title, "select_with_name", mock_select_with_name)

  result <- get_title(df = df, pname = "A", oid = NULL)
  expect_true(is.data.frame(result))
  expect_named(result, c("TTL1", "POPULATION"))
})

test_that("get_title uses select_with_number when pname is NULL", {
  df <- data.frame(TTL1 = "Title", POPULATION = "Test")
  mock_select_with_number <- mock(df)
  stub(get_title, "select_with_number", mock_select_with_number)

  result <- get_title(df = df, tnumber = "Title")
  expect_true(is.data.frame(result))
  expect_named(result, c("TTL1", "POPULATION"))
})

test_that("get_title filters out NA columns", {
  df <- data.frame(TTL1 = "Title", TTL2 = NA, POPULATION = "Pop")
  mock_select_with_number <- mock(df)
  stub(get_title, "select_with_number", mock_select_with_number)

  result <- get_title(df = df, tnumber = "Title")
  expect_true("TTL1" %in% names(result))
  expect_false("TTL2" %in% names(result))
})

#test get_footnote
test_that("get_footnote throws error on NULL df", {
  expect_error(get_footnote(df = NULL),
               regexp = "Input dataframe error")
})

test_that("get_footnote throws error when neither pname nor tnumber is provided", {
  df <- data.frame(PGMNAME = "A", FOOT1 = "Footnote")
  expect_error(get_footnote(df = df),
               regexp = "Need to provide either a program name or TFL number")
})

test_that("get_footnote uses select_with_name when pname is provided", {
  df <- data.frame(PGMNAME = "A", FOOT1 = "Footnote", FOOT2 = NA)
  mock_select_with_name <- mock(df)
  stub(get_footnote, "select_with_name", mock_select_with_name)

  result <- get_footnote(df = df, pname = "A", oid = NULL)
  expect_true(is.data.frame(result))
  expect_named(result, "FOOT1")
  #expect_equal(result$FOOT1, "Footnote")
})

test_that("get_footnote uses select_with_number when pname is NULL", {
  df <- data.frame(FOOT1 = "Note", FOOT2 = "Another note")
  mock_select_with_number <- mock(df)
  stub(get_footnote, "select_with_number", mock_select_with_number)

  result <- get_footnote(df = df, tnumber = "001")
  expect_true(is.data.frame(result))
  expect_named(result, c("FOOT1", "FOOT2"))
})

test_that("get_footnote filters out NA footnote columns", {
  df <- data.frame(FOOT1 = "Footnote", FOOT2 = NA)
  mock_select_with_number <- mock(df)
  stub(get_footnote, "select_with_number", mock_select_with_number)

  result <- get_footnote(df = df, tnumber = "X")
  expect_true("FOOT1" %in% names(result))
  expect_false("FOOT2" %in% names(result))
})

# test get_ulheader
test_that("get_ulheader returns a data.frame when by_list = TRUE", {
  df <- data.frame(UL1 = "Header1", UL2 = "Header2", OTHER = "Ignore")
  result <- get_ulheader(df, by_list = TRUE)

  expect_true(is.data.frame(result))
  expect_named(result, c("UL1", "UL2"))
})

test_that("get_ulheader returns a string when by_list = FALSE", {
  df <- data.frame(UL1 = "Header1", UL2 = "Header2")
  result <- get_ulheader(df, by_list = FALSE)

  expect_true(is.character(result))
  #expect_true(grepl("Header1", result))
  #expect_true(grepl("Header2", result))
  expect_true(grepl("\n", result))
})

test_that("get_ulheader filters out NA columns", {
  df <- data.frame(UL1 = "Header1", UL2 = NA, UL3 = "Header3")
  result <- get_ulheader(df, by_list = TRUE)

  expect_named(result, c("UL1", "UL3"))
  expect_false("UL2" %in% names(result))
})

test_that("get_ulheader handles no UL columns gracefully", {
  df <- data.frame(A = "X", B = "Y")
  result <- get_ulheader(df, by_list = TRUE)

  expect_equal(ncol(result), 0)
})

# test get_urheader
test_that("get_urheader returns a data.frame when by_list = TRUE", {
  df <- data.frame(UR1 = "Header1", UR2 = "Header2", OTHER = "Ignore")
  result <- get_urheader(df, by_list = TRUE)

  expect_true(is.data.frame(result))
  expect_named(result, c("UR1", "UR2"))
})

test_that("get_urheader returns a string when by_list = FALSE", {
  df <- data.frame(UR1 = "Header1", UR2 = "Header2")
  result <- get_urheader(df, by_list = FALSE)

  expect_true(is.character(result))
  #expect_true(grepl("Header1", result))
  #expect_true(grepl("Header2", result))
  expect_true(grepl("\n", result))
})

test_that("get_urheader filters out NA columns", {
  df <- data.frame(UR1 = "Header1", UR2 = NA, UR3 = "Header3")
  result <- get_urheader(df, by_list = TRUE)

  expect_named(result, c("UR1", "UR3"))
  expect_false("UR2" %in% names(result))
})

test_that("get_urheader handles no UR columns gracefully", {
  df <- data.frame(A = "X", B = "Y")
  result <- get_urheader(df, by_list = TRUE)

  expect_equal(ncol(result), 0)
})

# test get_source
test_that("get_source throws error on NULL df", {
  expect_error(get_source(df = NULL),
               regexp = "Input dataframe error")
})

test_that("get_source throws error when neither pname nor tnumber is provided", {
  df <- data.frame(SOURCE1 = "Internal")
  expect_error(get_source(df = df),
               regexp = "Need to provide either a program name or TFL number")
})

test_that("get_source uses select_with_name when pname is provided", {
  df <- data.frame(SOURCE1 = "Source info", SOURCE2 = NA)
  mock_select_with_name <- mock(df)
  stub(get_source, "select_with_name", mock_select_with_name)

  result <- get_source(df = df, pname = "my_program", oid = NULL)
  expect_true(is.data.frame(result))
  expect_named(result, "SOURCE1")
  #expect_equal(result$SOURCE1, "Source info")
})

test_that("get_source uses select_with_number when pname is NULL", {
  df <- data.frame(SOURCE1 = "Generated data", SOURCE2 = "External")
  mock_select_with_number <- mock(df)
  stub(get_source, "select_with_number", mock_select_with_number)

  result <- get_source(df = df, tnumber = "001")
  expect_true(is.data.frame(result))
  expect_named(result, c("SOURCE1", "SOURCE2"))
})

test_that("get_source filters out NA source columns", {
  df <- data.frame(SOURCE1 = "One", SOURCE2 = NA, SOURCE3 = "Two")
  mock_select_with_number <- mock(df)
  stub(get_source, "select_with_number", mock_select_with_number)

  result <- get_source(df = df, tnumber = "any")
  expect_named(result, c("SOURCE1", "SOURCE3"))
  expect_false("SOURCE2" %in% names(result))
})

# test get_timestamp
test_that("get_timestamp returns a string with correct format", {
  # Mock the RStudio API call
  fake_context <- list(path = "/Users/tester/Documents/script.R")
  mock_get_context <- mock(fake_context)
  #stub(get_timestamp, "rstudioapi::getSourceEditorContext", mock_get_context)
  # Skip this test if not running in RStudio, or if rstudioapi isn't available
  skip_if_not(rstudioapi::isAvailable(), "rstudioapi is not available or not running in RStudio")
  # Run the function
  ts <- get_refstamp()

  # Check output type and contents
  expect_true(is.character(ts))
  #expect_true(grepl("Generated from script\\.R on", ts))
  #expect_true(grepl("\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}", ts))
})


test_that("get_refstamp works correctly", {
  # Test when pname is NULL
  context <- list(path = "path/to/file.R")
  assign("getSourceEditorContext", function() context, envir = .GlobalEnv)
  # Skip this test if not running in RStudio, or if rstudioapi isn't available
  skip_if_not(rstudioapi::isAvailable(), "rstudioapi is not available or not running in RStudio")
  result <- get_refstamp()
  #expect_match(result, "Generated from file.R on ")

  # Test when pname is provided
  pname <- "my_package"
  result <- get_refstamp(pname)
  expect_match(result, "Generated from my_package on ")
})

test_that("get_refstamp returns correct message with pname", {
  # Skip this test if not running in RStudio, or if rstudioapi isn't available
  skip_if_not(rstudioapi::isAvailable(), "rstudioapi is not available or not running in RStudio")
  result <- get_refstamp("my_program.R")
  expect_true(startsWith(result, "Generated from my_program.R on "))
})

test_that("get_refstamp returns message using rstudioapi when pname is NULL", {
  # Skip this test if not running in RStudio, or if rstudioapi isn't available
  skip_if_not(rstudioapi::isAvailable(), "rstudioapi is not available or not running in RStudio")

  result <- get_refstamp()
  expect_true(grepl("^Generated from .* on \\s*$", result))
})
