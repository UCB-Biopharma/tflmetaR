test_that("read_tfile() errors on invalid filename inputs", {
  expect_error(
    read_tfile(filename = 123),
    "`filename` must be a non-empty character string",
    fixed = TRUE
  )

  expect_error(
    read_tfile(filename = c("a.csv", "b.csv")),
    "`filename` must be a non-empty character string",
    fixed = TRUE
  )

  expect_error(
    read_tfile(filename = NA_character_),
    "`filename` must be a non-empty character string",
    fixed = TRUE
  )

  expect_error(
    read_tfile(filename = ""),
    "`filename` must be a non-empty character string",
    fixed = TRUE
  )
})

test_that("read_tfile() errors when file does not exist", {
  fake <- file.path(tempdir(), "no_such_file.csv")
  expect_false(file.exists(fake))

  expect_error(
    read_tfile(fake),
    "File does not exist:",
    fixed = TRUE
  )
})

test_that("read_tfile() errors on unsupported file extension", {
  f <- tempfile(fileext = ".txt")
  writeLines("dummy", f)

  expect_error(
    read_tfile(f),
    "Unsupported file type. Only .xlsx, .xls, and .csv are allowed.",
    fixed = TRUE
  )
})

test_that("read_tfile() reads CSV, uppercases names, validates required cols", {
  f <- tempfile(fileext = ".csv")
  df_in <- data.frame(
    pgmname = "t_dm",
    ttl1 = "Title 1",
    foot1 = "Foot 1",
    source = "SRC",
    stringsAsFactors = FALSE
  )
  utils::write.csv(df_in, f, row.names = FALSE)

  df_out <- read_tfile(f, validate = TRUE)

  expect_true(is.data.frame(df_out))
  expect_equal(names(df_out), toupper(names(df_in)))
})

test_that("read_tfile() validate=FALSE skips required column checks", {
  f <- tempfile(fileext = ".csv")
  df_in <- data.frame(
    pgmname = "t_dm",
    stringsAsFactors = FALSE
  )
  utils::write.csv(df_in, f, row.names = FALSE)

  # should NOT error even though required cols are missing
  df_out <- read_tfile(f, validate = FALSE)
  expect_equal(names(df_out), toupper(names(df_in)))
})

test_that("read_tfile() errors when required columns are missing (validate=TRUE)", {
  f <- tempfile(fileext = ".csv")
  df_in <- data.frame(
    pgmname = "t_dm",
    ttl1 = "Title 1",
    stringsAsFactors = FALSE
  )
  utils::write.csv(df_in, f, row.names = FALSE)

  expect_error(
    read_tfile(f, validate = TRUE),
    "missing required column",
    ignore.case = TRUE
  )
})

test_that("read_tfile() reads XLS from extdata (covers xls branch)", {
  skip_if_not_installed("readxl")

  xls_path <- system.file("extdata", "st_titles.xls", package = "tflmetaR")
  expect_true(nzchar(xls_path))
  expect_true(file.exists(xls_path))

  df <- read_tfile(xls_path, sheetname = 1, validate = FALSE)

  expect_true(is.data.frame(df))
  # read_tfile uppercases names unconditionally
  expect_equal(names(df), toupper(names(df)))
})

test_that("read_tfile() reads XLSX (covers xlsx branch)", {
  skip_if_not_installed("readxl")
  skip_if_not_installed("writexl")

  xlsx <- tempfile(fileext = ".xlsx")
  df_in <- data.frame(
    PGMNAME = "t_dm",
    TTL1 = "Title 1",
    FOOT1 = "Foot 1",
    SOURCE = "SRC",
    stringsAsFactors = FALSE
  )
  writexl::write_xlsx(df_in, xlsx)

  df_out <- read_tfile(xlsx, sheetname = 1, validate = TRUE)

  expect_true(is.data.frame(df_out))
  expect_equal(names(df_out), toupper(names(df_out)))
  expect_true(all(c("PGMNAME", "TTL1", "FOOT1", "SOURCE") %in% names(df_out)))
})

test_that("internal read_tfile_csv() errors when file does not exist", {
  fake <- file.path(tempdir(), "no_such_file.csv")
  expect_false(file.exists(fake))

  expect_error(
    tflmetaR:::read_tfile_csv(fake),
    "File does not exist:",
    fixed = TRUE
  )
})

test_that("check_required_cols() errors when input has no column names", {
  x <- data.frame()
  names(x) <- NULL

  expect_error(
    tflmetaR:::check_required_cols(x, c("PGMNAME")),
    "Input metadata must have column names.",
    fixed = TRUE
  )
})

test_that("check_required_cols() returns invisibly TRUE when required columns exist (case-insensitive)", {
  df <- data.frame(
    pgmname = "t_dm",
    ttl1 = "Title 1",
    foot1 = "Foot 1",
    source = "SRC",
    stringsAsFactors = FALSE
  )

  res <- tflmetaR:::check_required_cols(df, c("PGMNAME", "TTL1", "FOOT1", "SOURCE"))
  expect_true(isTRUE(res))
})
