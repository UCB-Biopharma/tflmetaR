# dummy test
test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

# test non-exist file
test_that("readxl throws an error if the file does not exist", {
  expect_error(TFootr::read_tfile("non_existent_file.xls"), "Input header_footer file does not exist! Check the filename and/or pathname and try again. \n")
})

# test incorrect sheetname
test_that("read_footer throws an error if incorrect sheetname given", {
  file_name <- file.path("../../inst/extdata", "sample_titles.xls")
  expect_error(TFootr::read_tfile(file_name, sheetname = "foot"), "Failed to read the sheet. Please check the file and sheet name.")
})

test_that("read_tfile handles missing file correctly", {
  expect_error(read_tfile("nonexistent.xlsx"),
               regexp = "Input header_footer file does not exist!")
})

test_that("read_tfile reads an existing file correctly", {
  # Create a temporary Excel file
  temp_file <- tempfile(fileext = ".xlsx")
  df <- data.frame(PGMNAME = "Test", TTL1 = "Title", SOURCE = "Src", FOOT1 = "Footer")
  writexl::write_xlsx(list(header = df, sheet1 = df), temp_file)

  # Test reading a valid sheet
  result <- read_tfile(temp_file, sheetname = "header")
  expect_true(is.data.frame(result))
  expect_true(all(c("PGMNAME", "TTL1", "SOURCE", "FOOT1") %in% colnames(result)))

  # Clean up
  unlink(temp_file)
})

test_that("read_tfile returns an error for missing required columns", {
  temp_file <- tempfile(fileext = ".xlsx")
  df <- data.frame(OtherColumn = "Test")  # Missing required columns
  writexl::write_xlsx(list(sheet1 = df), temp_file)

  expect_error(read_tfile(temp_file, sheetname = "sheet2"),
               regexp = "Failed to read the sheet. Please check the file and sheet name.")

  unlink(temp_file)
})

test_that("read_tfile returns an error for missing sheet", {
  temp_file <- tempfile(fileext = ".xlsx")
  df <- data.frame(PGMNAME = "Test", TTL1 = "Title", SOURCE = "Src", FOOT1 = "Footer")
  writexl::write_xlsx(list(sheet1 = df), temp_file)

  expect_error(read_tfile(temp_file, sheetname = "nonexistent"),
                 regexp = "Failed to read the sheet. Please check the file and sheet name.")

  unlink(temp_file)
})
