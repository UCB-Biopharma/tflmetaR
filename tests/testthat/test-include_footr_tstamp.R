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
