library(testthat)
library(dplyr)

# test select_with_number
test_that("select_with_number handles missing parameters", {
  df <- data.frame(TYPE = c("A", "B"), TTL1 = c(1, 2))

  expect_error(select_with_number(df),
               regexp = "Selection paramters can not be NULL.")
})

test_that("select_with_number filters correctly with type and tnumber", {
  df <- data.frame(TYPE = c("A", "B", "A"), TTL1 = c(1, 2, 3))

  result <- select_with_number(df, type = "A", tnumber = 1)
  expect_true(nrow(result) == 1)
  #expect_equal(result$TYPE, "A")
  expect_equal(result$TTL1, 1)
})

test_that("select_with_number filters correctly with only tnumber", {
  df <- data.frame(TYPE = c("A", "B", "C"), TTL1 = c(1, 2, 1))

  result <- select_with_number(df, tnumber = 2)
  expect_true(nrow(result) == 1)
  expect_equal(result$TTL1, 2)
})

test_that("select_with_number returns error for no match", {
  df <- data.frame(TYPE = c("A", "B"), TTL1 = c(1, 2))

  expect_error(select_with_number(df, type = "C", tnumber = 1),
               regexp = "No entry is generated")
})

test_that("select_with_number returns error for non-unique match", {
  df <- data.frame(TYPE = c("A", "A"), TTL1 = c(1, 1))

  expect_error(select_with_number(df, type = "A", tnumber = 1),
               regexp = "Non unique entry generated")
})

# test select_with_name
test_that("select_with_name throws error when pname is NULL", {
  df <- data.frame(PGMNAME = "A", OID = "001")
  expect_error(select_with_name(df, pname = NULL, oid = "001"),
               regexp = "'pname' is NULL")
})

test_that("select_with_name throws error when no matching entry is found", {
  df <- data.frame(PGMNAME = "A", OID = "001")
  expect_error(select_with_name(df, pname = "B", oid = "001"),
               regexp = "No matching entry")
})

test_that("select_with_name throws error when multiple matching entries are found", {
  df <- data.frame(PGMNAME = c("A", "A"), OID = c("001", "001"))
  expect_error(select_with_name(df, pname = "A", oid = "001"),
               regexp = "Non unique entry generated")
})

test_that("select_with_name returns correct row when exactly one match is found", {
  df <- data.frame(PGMNAME = c("A", "B"), OID = c("001", "002"), VALUE = c("X", "Y"))
  result <- select_with_name(df, pname = "A", oid = "001")

  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 1)
  #expect_equal(result$VALUE, "X")
})
