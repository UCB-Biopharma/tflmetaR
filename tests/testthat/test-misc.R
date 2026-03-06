
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


test_that("include_footr_tstamp returns a single character string", {
  result <- include_footr_tstamp("t_dm", "ADSL")

  expect_type(result, "character")
  expect_length(result, 1)
})

test_that("include_footr_tstamp contains expected fixed text", {
  result <- tflmetaR:::include_footr_tstamp("t_dm", "ADSL")

  expect_true(grepl("^Generated from t_dm on ", result))
  expect_true(grepl(" Data Source\\(s\\): ADSL$", result))
})

test_that("include_footr_tstamp errors for invalid pgmname_str", {
  expect_error(tflmetaR:::include_footr_tstamp(123, "ADSL"))
  expect_error(tflmetaR:::include_footr_tstamp(c("a", "b"), "ADSL"))
})

test_that("include_footr_tstamp errors for invalid src_str", {
  expect_error(tflmetaR:::include_footr_tstamp("t_dm", 123))
  expect_error(tflmetaR:::include_footr_tstamp("t_dm", c("ADSL", "ADAE")))
})
