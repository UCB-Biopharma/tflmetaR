#dummy test
test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

#test non-exist file
test_that("readxl throws an error if the file does not exist", {
  expect_error(TFootr::read_footer("non_existent_file.xls"), "Input header_footer file does not exist! Check the filename and/or pathname and try again. \n")
})

#test incorrect sheetname
test_that("read_footer throws an error if incorrect sheetname given", {
  expect_error(TFootr::read_footer("~/TFootr/inst/extdata/sample_titles.xls", sheetname = "foot"), "Failed to read the sheet. Please check the file and sheet name.")
})
