
#test non-exist file
test_that("readxl throws an error if the file does not exist", {
  expect_error(tflmetaR::read_xlfile("non_existent_file.xls", "Sheet1"),
               "`path` does not exist: 'non_existent_file.xls'")
})


