# tests/testthat/test-get_bookm.R

library(testthat)

test_that("get_bookm() returns bookm when present", {
  df <- data.frame(
    tnumber = c("1"),
    pname   = c("prog1"),
    bookm   = c("MyBookmark"),
    stringsAsFactors = FALSE
  )

  result <- get_bookm(df = df, pname = "prog1")
  expect_equal(result, "MyBookmark")
})

test_that("get_bookm() falls back to get_title() when bookm is missing", {
  df <- data.frame(
    tnumber = c("1"),
    pname   = c("prog1"),
    bookm   = NA,
    stringsAsFactors = FALSE
  )

  # Mock get_title() to return known output
  mock_get_title <- function(...) list("Title A", "Title B")
  assignInNamespace("get_title", mock_get_title, ns = "tflmetaR")

  result <- get_bookm(df = df, pname = "prog1")
  expect_equal(result, "Title A_Title B")
})

test_that("get_bookm() sanitizes invalid characters", {
  df <- data.frame(
    tnumber = c("1"),
    pname   = c("prog1"),
    bookm   = "My/Invalid:Bookmark*?",
    stringsAsFactors = FALSE
  )

  result <- get_bookm(df = df, pname = "prog1")
  expect_false(grepl("[\\\\/:*?\"<>|]", result))
})

test_that("get_bookm() applies abbreviation lookup if >128 chars", {
  long_text <- paste(rep("ThisIsAVeryLongPhrase", 10), collapse = "_")

  df <- data.frame(
    tnumber = c("1"),
    pname   = c("prog1"),
    bookm   = long_text,
    stringsAsFactors = FALSE
  )

  # Create temporary abbrev file
  abbrev_file <- tempfile(fileext = ".xlsx")
  writexl::write_xlsx(
    data.frame(scope = "bookmark", phrase = "ThisIsAVeryLongPhrase", abbr = "Short", stringsAsFactors = FALSE),
    abbrev_file
  )

  result <- get_bookm(df = df, pname = "prog1", abbrev_file = abbrev_file)
  expect_true(nchar(result) < nchar(long_text))
  expect_true(grepl("Short", result))
})

test_that("get_bookm() errors when df is NULL", {
  expect_error(get_bookm(df = NULL, pname = "prog1"))
})

test_that("get_bookm() errors when pname and tnumber are both NULL", {
  df <- data.frame(
    tnumber = c("1"),
    pname   = c("prog1"),
    bookm   = "Bookmark",
    stringsAsFactors = FALSE
  )

  expect_error(get_bookm(df = df))
})

test_that("get_bookm() warns when multiple rows match", {
  df <- data.frame(
    tnumber = c("1", "1"),
    pname   = c("prog1", "prog1"),
    bookm   = c("Bookmark1", "Bookmark2"),
    stringsAsFactors = FALSE
  )

  expect_warning(get_bookm(df = df, tnumber = "1"))
})

test_that("get_bookm() truncates to 128 chars if still too long", {
  long_text <- paste(rep("SuperLongPhrase", 20), collapse = "_") # very long string

  df <- data.frame(
    tnumber = c("1"),
    pname   = c("prog1"),
    bookm   = long_text,
    stringsAsFactors = FALSE
  )

  result <- get_bookm(df = df, pname = "prog1")

  expect_true(nchar(result) <= 128)
  expect_equal(nchar(result), 128)
})
