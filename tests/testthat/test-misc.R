#dummy test
test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

#test non-exist file
test_that("readxl throws an error if the file does not exist", {
  expect_error(tflmetaR::read_xlfile("non_existent_file.xls", "Sheet1"),
               "`path` does not exist: 'non_existent_file.xls'")
})

# tests/testthat/test-change_colname.R
#library(testthat)

test_that("title, footnote, and byline columns are renamed sequentially", {
  df <- data.frame(TitleA = 1, TitleB = 2, FootnoteA = 3, BylineX = 4)

  out <- change_colname(
    df,
    title_name   = c("TitleA", "TitleB"),
    ftnote_name  = "FootnoteA",
    byline_name  = "BylineX"
  )

  expect_named(out, c("TTL1", "TTL2", "FOOT1", "BYLINE1"))
})

test_that("page, oid, bookm, population, type, source are renamed with fixed names", {
  df <- data.frame(pg = 1, oid = 2, bm = 3, pop = 4, typ = 5, src = 6)

  out <- change_colname(
    df,
    pg_name      = "pg",
    oid_name     = "oid",
    bookm_name   = "bm",
    pop_name     = "pop",
    type_name    = "typ",
    source_name  = "src"
  )

  expect_named(out, c("Pgmname", "OID", "BOOKM", "Population", "Type", "Source"))
})

test_that("custom mappings (...) are renamed sequentially", {
  df <- data.frame(A = 1, B = 2, C = 3)

  out <- change_colname(df, MYCOL = c("A", "B"), EXTRA = "C")

  expect_named(out, c("MYCOL1", "MYCOL2", "EXTRA1"))
})

test_that("columns not specified remain unchanged", {
  df <- data.frame(TitleA = 1, Data = 2)

  out <- change_colname(df, title_name = "TitleA")

  expect_named(out, c("TTL1", "Data"))
})

test_that("nonexistent column names are ignored gracefully", {
  df <- data.frame(X = 1, Y = 2)

  out <- change_colname(df, title_name = "Z", pg_name = "W")

  # original names preserved
  expect_named(out, c("X", "Y"))
})

test_that("works with empty data frames", {
  df <- data.frame()

  out <- change_colname(df)

  expect_named(out, character(0))
})

