testthat::test_that("tflmetaR() dispatches and selects correctly for CSV and Excel", {

  # ---- Create a minimal metadata table ----
  meta <- data.frame(
    PGMNAME     = c("t_dm", "t_ae"),
    OID         = c("A", "A"),
    TTL1        = c("Demographics", "Adverse Events"),
    TTL2        = c("Safety Set", "Safety Set"),
    POPULATION  = c("SAF", "SAF"),
    FOOT1       = c("*: baseline record.", "All AEs included."),
    FOOT2       = c("Source: dummy", "Source: dummy"),
    SOURCE      = c("ADSL", "ADAE"),
    stringsAsFactors = FALSE
  )

  tmpdir <- tempdir()

  # ---- Write CSV fixture ----
  csv_path <- file.path(tmpdir, "metadata.csv")
  utils::write.csv(meta, csv_path, row.names = FALSE)

  # ---- CSV: (5) Get footnotes ----
  res_csv_foot <- tflmetaR(
    file = csv_path,
    by_value = "t_dm",
    annotation = "FOOTR",
    add_footr_tstamp = FALSE
  )

  testthat::expect_s3_class(res_csv_foot, "data.frame")
  testthat::expect_true(all(grepl("^FOOT", names(res_csv_foot))))
  testthat::expect_true(nrow(res_csv_foot) == 1)

  testthat::skip_if_not_installed("writexl")
  xlsx_path <- file.path(tmpdir, "metadata.xlsx")
  writexl::write_xlsx(list(Sheet1 = meta), path = xlsx_path)

  # (1) Excel: Get titles
  res_xls_title <- tflmetaR(
    file = xlsx_path,
    sheet = "Sheet1",
    by_value = "t_dm",
    annotation = "TITLE",
    add_footr_tstamp = FALSE
  )

  testthat::expect_s3_class(res_xls_title, "data.frame")
  testthat::expect_true(nrow(res_xls_title) == 1)
  # TITLE selection should include TTL* and POPULATION (per your select_cols())
  testthat::expect_true(all(grepl("^TTL", names(res_xls_title)) | names(res_xls_title) == "POPULATION"))

  # (2) Excel: Get footnotes
  res_xls_foot <- tflmetaR(
    file = xlsx_path,
    sheet = "Sheet1",
    by_value = "t_dm",
    annotation = "FOOTR",
    add_footr_tstamp = TRUE
  )

  testthat::expect_s3_class(res_xls_foot, "data.frame")
  testthat::expect_true(nrow(res_xls_foot) == 1)
  # FOOTR selection should include FOOT* and SOURCE (if add_footr_tstamp = TRUE)
  testthat::expect_true(all(grepl("^FOOT", names(res_xls_foot)) | names(res_xls_foot) == "source"))


  # (3) Excel: Get a specific column value, e.g., SOURCE
  res_xls_source <- tflmetaR(
    file = xlsx_path,
    sheet = "Sheet1",
    by_value = "t_dm",
    annotation = "SOURCE"
  )

  testthat::expect_s3_class(res_xls_source, "data.frame")
  testthat::expect_true(nrow(res_xls_source) == 1)
  testthat::expect_true(identical(names(res_xls_source), "SOURCE"))
  testthat::expect_identical(res_xls_source$SOURCE, "ADSL")

  # (4) Excel: Get the whole row
  res_xls_all <- tflmetaR(
    file = xlsx_path,
    sheet = "Sheet1",
    by_value = "t_dm"
  )

  testthat::expect_s3_class(res_xls_all, "data.frame")
  testthat::expect_true(nrow(res_xls_all) == 1)
  # Whole row should contain at least these columns
  testthat::expect_true(all(c("PGMNAME", "TTL1", "FOOT1", "SOURCE") %in% names(res_xls_all)))
})

testthat::test_that("tflmetaR() errors clearly for missing files and unsupported extensions", {

  # missing file
  testthat::expect_error(
    tflmetaR(file = file.path(tempdir(), "no_such_file.xlsx"), by_value = "t_dm"),
    "does not exist|not exist",
    ignore.case = TRUE
  )

  # unsupported extension: create a temp file with .txt extension so file.exists() passes
  txt_path <- tempfile(fileext = ".txt")
  writeLines("dummy", txt_path)

  testthat::expect_error(
    tflmetaR(file = txt_path, by_value = "t_dm"),
    "Unsupported file type",
    ignore.case = TRUE
  )
})

test_that("tflmetaR errors when required columns are missing", {
  p <- tempfile(fileext = ".csv")

  # Missing SOURCE
  df <- data.frame(
    PGMNAME = "t_dm",
    TTL1 = "Demographics",
    FOOT1 = "f1",
    stringsAsFactors = FALSE
  )
  utils::write.csv(df, p, row.names = FALSE)

  expect_error(
    tflmetaR(file = p, by_value = "t_dm"),
    "required column\\(s\\) missing",
    ignore.case = TRUE
  )
})

test_that("tflmetaR reads metadata from CSV in extdata", {

  csv_path <- system.file(
    "extdata",
    "sample_titles.csv",
    package = "tflmetaR"
  )

  # Ensure the file exists
  expect_true(file.exists(csv_path))

  # ---- Test: get titles ----
  res_title <- tflmetaR(
    file = csv_path,
    by_value = "t_dm",
    annotation = "TITLE"
  )

  expect_s3_class(res_title, "data.frame")
  expect_true(nrow(res_title) == 1)
  expect_true(any(grepl("^TTL", names(res_title))))

  # ---- Test: get footnotes ----
  res_foot <- tflmetaR(
    file = csv_path,
    by_value = "t_dm",
    annotation = "FOOTR"
  )

  expect_s3_class(res_foot, "data.frame")
  expect_true(nrow(res_foot) == 1)
  expect_true(any(grepl("^FOOT", names(res_foot))))

  # ---- Test: get a specific column ----
  res_source <- tflmetaR(
    file = csv_path,
    by_value = "t_dm",
    annotation = "SOURCE"
  )

  expect_s3_class(res_source, "data.frame")
  expect_identical(names(res_source), "SOURCE")

  # ---- Test: get whole row ----
  res_all <- tflmetaR(
    file = csv_path,
    by_value = "t_dm"
  )

  expect_s3_class(res_all, "data.frame")
  expect_true(nrow(res_all) == 1)
})

test_that("tflmetaR errors when by_value is missing", {

  df <- data.frame(
    PGMNAME = "t_dm",
    TTL1 = "Title",
    FOOT1 = "Footnote",
    SOURCE = "ADSL",
    stringsAsFactors = FALSE
  )

  file <- tempfile(fileext = ".csv")
  write.csv(df, file, row.names = FALSE)

  expect_error(
    tflmetaR(file),
    "`by_value` must be provided."
  )

})

test_that("tflmetaR treats FOOTR annotation case-insensitively", {
  csv_file <- tempfile(fileext = ".csv")

  write.csv(
    data.frame(
      PGMNAME = "t_dm",
      OID = "T001",
      TTL1 = "Table 1. Demographics",
      TTL2 = "Safety Population",
      FOOT1 = "Source: ADSL",
      FOOT2 = "*: Baseline record",
      SOURCE = "ADSL"
    ),
    csv_file,
    row.names = FALSE
  )

  result_upper <- tflmetaR(
    filename = csv_file,
    by_value = "t_dm",
    annotation = "FOOTR",
    add_footr_tstamp = FALSE
  )

  result_mixed <- tflmetaR(
    filename = csv_file,
    by_value = "t_dm",
    annotation = "footr",
    add_footr_tstamp = FALSE
  )

  expect_equal(result_mixed, result_upper)
})
