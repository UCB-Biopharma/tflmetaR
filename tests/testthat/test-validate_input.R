test_that("validate_input errors when df is NULL", {
  expect_error(
    validate_input(df = NULL, pname = "t_dm", tnumber = NULL),
    "`df` must be provided."
  )
})

test_that("validate_input errors when both pname and tnumber are NULL", {
  df <- data.frame(PGMNAME = "t_dm", TTL1 = "T14.1", stringsAsFactors = FALSE)
  expect_error(
    validate_input(df = df, pname = NULL, tnumber = NULL),
    "Either `pname` or `tnumber` must be provided."
  )
})

test_that("validate_input errors when both pname and tnumber are provided", {
  df <- data.frame(PGMNAME = "t_dm", TTL1 = "T14.1", stringsAsFactors = FALSE)
  expect_error(
    validate_input(df = df, pname = "t_dm", tnumber = "T14.1"),
    "Only one of `pname` or `tnumber` should be supplied."
  )
})

test_that("validate_input succeeds when pname is provided", {
  df <- data.frame(PGMNAME = "t_dm", TTL1 = "T14.1", stringsAsFactors = FALSE)
  expect_no_error(
    validate_input(df = df, pname = "t_dm", tnumber = NULL)
  )
})

test_that("validate_input succeeds when tnumber is provided", {
  df <- data.frame(PGMNAME = "t_dm", TTL1 = "T14.1", stringsAsFactors = FALSE)
  expect_no_error(
    validate_input(df = df, pname = NULL, tnumber = "T14.1")
  )
})
