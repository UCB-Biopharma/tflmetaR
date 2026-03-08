
test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

test_that("get_title throws error on NULL df", {
  expect_error(get_title(df = NULL),
               regexp = "`df` must be provided")
})

test_that("get_title throws error when neither pname nor tnumber is provided", {
  df <- data.frame(PGMNAME = "A", TTL1 = "Title", POPULATION = "Test")
  expect_error(get_title(df = df),
               regexp = "Either `pname` or `tnumber` must be provided")
})

test_that("get_title uses select_row when pname is provided", {
  df <- data.frame(PGMNAME = "A", TTL1 = "Title", POPULATION = "Test")
  mock_select_row <- mockery::mock(df)
  mockery::stub(get_title, "select_row", mock_select_row)

  result <- get_title(df = df, pname = "A", oid = NULL)
  expect_true(is.data.frame(result))
  expect_named(result, c("TTL1", "POPULATION"))
})

test_that("get_title uses select_row when pname is NULL", {
  df <- data.frame(TTL1 = "Title", POPULATION = "Test")
  mock_select_row <- mockery::mock(df)
  mockery::stub(get_title, "select_row", mock_select_row)

  result <- get_title(df = df, tnumber = "Title")
  expect_true(is.data.frame(result))
  expect_named(result, c("TTL1", "POPULATION"))
})

test_that("get_title filters out NA columns", {
  df <- data.frame(TTL1 = "Title", TTL2 = NA, POPULATION = "Pop")
  mock_select_row <- mockery::mock(df)
  mockery::stub(get_title, "select_row", mock_select_row)

  result <- get_title(df = df, tnumber = "Title")
  expect_true("TTL1" %in% names(result))
  expect_false("TTL2" %in% names(result))
})

#test get_footnote
test_that("get_footnote throws error on NULL df", {
  expect_error(get_footnote(df = NULL),
               regexp = "`df` must be provided")
})

test_that("get_footnote throws error when neither pname nor tnumber is provided", {
  df <- data.frame(PGMNAME = "A", FOOT1 = "Footnote")
  expect_error(get_footnote(df = df),
               regexp = "Either `pname` or `tnumber` must be provided")
})

test_that("get_footnote uses select_row when pname is provided", {
  df <- data.frame(PGMNAME = "A", FOOT1 = "Footnote", FOOT2 = NA)
  mock_select_row <- mockery::mock(df)
  mockery::stub(get_footnote, "select_row", mock_select_row)

  result <- get_footnote(df = df, pname = "A", oid = NULL, add_footr_tstamp=FALSE)
  expect_true(is.data.frame(result))
  expect_named(result, "FOOT1")
  #expect_equal(result$FOOT1, "Footnote")
})

test_that("get_footnote uses select_row when pname is NULL", {
  df <- data.frame(FOOT1 = "Note", FOOT2 = "Another note")
  mock_select_row <- mockery::mock(df)
  mockery::stub(get_footnote, "select_row", mock_select_row)

  result <- get_footnote(df = df, tnumber = "001", add_footr_tstamp=FALSE)
  expect_true(is.data.frame(result))
  expect_named(result, c("FOOT1", "FOOT2"))
})

test_that("get_footnote filters out NA footnote columns", {
  df <- data.frame(FOOT1 = "Footnote", FOOT2 = NA)
  mock_select_row <- mockery::mock(df)
  mockery::stub(get_footnote, "select_row", mock_select_row)

  result <- get_footnote(df = df, tnumber = "X", add_footr_tstamp=FALSE)
  expect_true("FOOT1" %in% names(result))
  expect_false("FOOT2" %in% names(result))
})

# test get_ulheader
test_that("get_ulheader filters out NA columns", {
  df <- data.frame(UL1 = "Header1", UL2 = NA, UL3 = "Header3")
  result <- get_ulheader(df)

  expect_named(result, c("UL1", "UL3"))
  expect_false("UL2" %in% names(result))
})

test_that("get_ulheader handles no UL columns gracefully", {
  df <- data.frame(A = "X", B = "Y")
  result <- get_ulheader(df)

  expect_equal(ncol(result), 0)
})

test_that("get_urheader filters out NA columns", {
  df <- data.frame(UR1 = "Header1", UR2 = NA, UR3 = "Header3")
  result <- get_urheader(df)

  expect_named(result, c("UR1", "UR3"))
  expect_false("UR2" %in% names(result))
})

test_that("get_urheader handles no UR columns gracefully", {
  df <- data.frame(A = "X", B = "Y")
  result <- get_urheader(df)

  expect_equal(ncol(result), 0)
})

# test get_pop
test_that("get_pop throws error on NULL df", {
  expect_error(get_pop(df = NULL),
               regexp = "`df` must be provided")
})

test_that("get_pop throws error when neither pname nor tnumber is provided", {
  df <- data.frame(PGMNAME = "A", POPULATION = "Test Population")
  expect_error(get_pop(df = df),
               regexp = "Either `pname` or `tnumber` must be provided")
})

test_that("get_pop uses select_row when pname is provided", {
  df <- data.frame(PGMNAME = "A", POPULATION = "Test Population", TTL1 = "Title")
  mock_select_row <- mockery::mock(df)
  mockery::stub(get_pop, "select_row", mock_select_row)

  result <- get_pop(df = df, pname = "A", oid = NULL)
  expect_true(is.data.frame(result))
  expect_named(result, "POPULATION")
})

test_that("get_pop uses select_row when pname is NULL", {
  df <- data.frame(TTL1 = "Title", POPULATION = "Test Population")
  mock_select_row <- mockery::mock(df)
  mockery::stub(get_pop, "select_row", mock_select_row)

  result <- get_pop(df = df, tnumber = "Title")
  expect_true(is.data.frame(result))
  expect_named(result, "POPULATION")
})

test_that("get_pop returns only POPULATION column", {
  df <- data.frame(TTL1 = "Title", TTL2 = "Subtitle", POPULATION = "ITT Population", FOOT1 = "Note")
  mock_select_row <- mockery::mock(df)
  mockery::stub(get_pop, "select_row", mock_select_row)

  result <- get_pop(df = df, tnumber = "Title")
  expect_true("POPULATION" %in% names(result))
  expect_false("TTL1" %in% names(result))
  expect_false("TTL2" %in% names(result))
  expect_false("FOOT1" %in% names(result))
})

test_that("get_pop filters out NA population", {
  df <- data.frame(TTL1 = "Title", POPULATION = NA)
  mock_select_row <- mockery::mock(df)
  mockery::stub(get_pop, "select_row", mock_select_row)

  result <- get_pop(df = df, tnumber = "Title")
  expect_equal(ncol(result), 0)
})

# test get_byline
test_that("get_byline throws error on NULL df", {
  expect_error(get_byline(df = NULL),
               regexp = "`df` must be provided")
})

test_that("get_byline throws error when neither pname nor tnumber is provided", {
  df <- data.frame(PGMNAME = "A", BYLINE1 = "Author Name")
  expect_error(get_byline(df = df),
               regexp = "Either `pname` or `tnumber` must be provide")
})

test_that("get_byline uses select_row when pname is provided", {
  df <- data.frame(PGMNAME = "A", BYLINE1 = "Author", BYLINE2 = NA)
  mock_select_row <- mockery::mock(df)
  mockery::stub(get_byline, "select_row", mock_select_row)

  result <- get_byline(df = df, pname = "A", oid = NULL)
  expect_true(is.data.frame(result))
  expect_named(result, "BYLINE1")
})

test_that("get_byline uses select_row when pname is NULL", {
  df <- data.frame(BYLINE1 = "Author", BYLINE2 = "Institution")
  mock_select_row <- mockery::mock(df)
  mockery::stub(get_byline, "select_row", mock_select_row)

  result <- get_byline(df = df, tnumber = "001")
  expect_true(is.data.frame(result))
  expect_named(result, c("BYLINE1", "BYLINE2"))
})

test_that("get_byline filters out NA byline columns", {
  df <- data.frame(BYLINE1 = "Author", BYLINE2 = NA, BYLINE3 = "Institution")
  mock_select_row <- mockery::mock(df)
  mockery::stub(get_byline, "select_row", mock_select_row)

  result <- get_byline(df = df, tnumber = "any")
  expect_named(result, c("BYLINE1", "BYLINE3"))
  expect_false("BYLINE2" %in% names(result))
})

test_that("get_byline returns only BYLINE* columns", {
  df <- data.frame(TTL1 = "Title", BYLINE1 = "Author", POPULATION = "ITT", FOOT1 = "Note")
  mock_select_row <- mockery::mock(df)
  mockery::stub(get_byline, "select_row", mock_select_row)

  result <- get_byline(df = df, tnumber = "Title")
  expect_true("BYLINE1" %in% names(result))
  expect_false("TTL1" %in% names(result))
  expect_false("POPULATION" %in% names(result))
  expect_false("FOOT1" %in% names(result))
})

test_that("get_byline handles no BYLINE columns gracefully", {
  df <- data.frame(TTL1 = "Title", POPULATION = "ITT")
  mock_select_row <- mockery::mock(df)
  mockery::stub(get_byline, "select_row", mock_select_row)

  result <- get_byline(df = df, tnumber = "Title")
  expect_equal(ncol(result), 0)
})

# test get_pgmname
test_that("get_pgmname throws error on NULL df", {
  expect_error(get_pgmname(df = NULL),
               regexp = "`df` must be provided")
})

test_that("get_pgmname throws error when neither pname nor tnumber is provided", {
  df <- data.frame(PGMNAME = "t_dm", TTL1 = "Title")
  expect_error(get_pgmname(df = df),
               regexp = "Either `pname` or `tnumber` must be provide")
})

test_that("get_pgmname uses select_row when pname is provided", {
  df <- data.frame(PGMNAME = "t_dm", TTL1 = "Title", POPULATION = "ITT")
  mock_select_row <- mockery::mock(df)
  mockery::stub(get_pgmname, "select_row", mock_select_row)

  result <- get_pgmname(df = df, pname = "t_dm", oid = NULL)
  expect_true(is.data.frame(result))
  expect_named(result, "PGMNAME")
})

test_that("get_pgmname uses select_row when pname is NULL", {
  df <- data.frame(PGMNAME = "t_dm", TTL1 = "Title")
  mock_select_row <- mockery::mock(df)
  mockery::stub(get_pgmname, "select_row", mock_select_row)

  result <- get_pgmname(df = df, tnumber = "Table 1.1")
  expect_true(is.data.frame(result))
  expect_named(result, "PGMNAME")
})

test_that("get_pgmname returns only PGMNAME column", {
  df <- data.frame(TTL1 = "Title", PGMNAME = "t_dm", POPULATION = "ITT", FOOT1 = "Note")
  mock_select_row <- mockery::mock(df)
  mockery::stub(get_pgmname, "select_row", mock_select_row)

  result <- get_pgmname(df = df, tnumber = "Table 1.1")
  expect_true("PGMNAME" %in% names(result))
  expect_false("TTL1" %in% names(result))
  expect_false("POPULATION" %in% names(result))
  expect_false("FOOT1" %in% names(result))
})

test_that("get_pgmname filters out NA program names", {
  df <- data.frame(TTL1 = "Title", PGMNAME = NA)
  mock_select_row <- mockery::mock(df)
  mockery::stub(get_pgmname, "select_row", mock_select_row)

  result <- get_pgmname(df = df, tnumber = "Title")
  expect_equal(ncol(result), 0)
})

# test get_source
test_that("get_source throws error on NULL df", {
  expect_error(get_source(df = NULL),
               regexp = "`df` must be provided")
})

test_that("get_source throws error when neither pname nor tnumber is provided", {
  df <- data.frame(SOURCE1 = "Internal")
  expect_error(get_source(df = df),
               regexp = "Either `pname` or `tnumber` must be provide")
})

test_that("get_source uses select_row when pname is provided", {
  df <- data.frame(SOURCE1 = "Source info", SOURCE2 = NA)
  mock_select_row <- mockery::mock(df)
  mockery::stub(get_source, "select_row", mock_select_row)

  result <- get_source(df = df, pname = "my_program", oid = NULL)
  expect_true(is.data.frame(result))
  expect_named(result, "SOURCE1")
  #expect_equal(result$SOURCE1, "Source info")
})

test_that("get_source uses select_row when pname is NULL", {
  df <- data.frame(SOURCE1 = "Generated data", SOURCE2 = "External")
  mock_select_row <- mockery::mock(df)
  mockery::stub(get_source, "select_row", mock_select_row)

  result <- get_source(df = df, tnumber = "001")
  expect_true(is.data.frame(result))
  expect_named(result, c("SOURCE1", "SOURCE2"))
})

test_that("get_source filters out NA source columns", {
  df <- data.frame(SOURCE1 = "One", SOURCE2 = NA, SOURCE3 = "Two")
  mock_select_row <- mockery::mock(df)
  mockery::stub(get_source, "select_row", mock_select_row)

  result <- get_source(df = df, tnumber = "any")
  expect_named(result, c("SOURCE1", "SOURCE3"))
  expect_false("SOURCE2" %in% names(result))
})


