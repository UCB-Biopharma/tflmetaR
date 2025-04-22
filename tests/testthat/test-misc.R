#dummy test
test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

#test non-exist file
test_that("readxl throws an error if the file does not exist", {
 expect_error(tfootr::read_xlfile("non_existent_file.xls", "Sheet1"),
  "`path` does not exist: 'non_existent_file.xls'")
})

#test incorrect sheetname
# test_that("read_xlfile throws an error if incorrect sheetname given", {
#   file_name <- file.path("../../inst/extdata", "sample_titles.xls")
#   expect_error(tfootr::read_xlfile(file_name, sheetname = "SheetN"),
#                "Sheet 'SheetN' not found")
# })
