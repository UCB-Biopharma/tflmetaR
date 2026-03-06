test_that("select_starts_with selects columns with given prefix", {
  df <- data.frame(
    BYLINE1 = "A",
    BYLINE2 = "B",
    TITLE   = "T",
    stringsAsFactors = FALSE
  )

  result <- select_starts_with(df, "BYLINE")

  expect_equal(names(result), c("BYLINE1", "BYLINE2"))
})


test_that("select_starts_with keeps additional specified columns", {
  df <- data.frame(
    BYLINE1 = "A",
    BYLINE2 = "B",
    TITLE   = "T",
    OID     = "T001",
    stringsAsFactors = FALSE
  )

  result <- select_starts_with(df, "BYLINE", keep_cols = "OID")

  expect_equal(names(result), c("BYLINE1", "BYLINE2", "OID"))
})


test_that("select_starts_with ignores keep_cols not in data", {
  df <- data.frame(
    BYLINE1 = "A",
    BYLINE2 = "B",
    stringsAsFactors = FALSE
  )

  result <- select_starts_with(df, "BYLINE", keep_cols = "OID")

  expect_equal(names(result), c("BYLINE1", "BYLINE2"))
})


test_that("select_starts_with returns empty data frame if no columns match", {
  df <- data.frame(
    TITLE = "T",
    OID   = "T001",
    stringsAsFactors = FALSE
  )

  result <- select_starts_with(df, "BYLINE")

  expect_equal(ncol(result), 0)
})


test_that("select_starts_with handles overlapping prefix and keep_cols", {
  df <- data.frame(
    BYLINE1 = "A",
    BYLINE2 = "B",
    OID     = "T001",
    stringsAsFactors = FALSE
  )

  result <- select_starts_with(df, "BYLINE", keep_cols = c("BYLINE1", "OID"))

  expect_true(all(c("BYLINE1", "BYLINE2", "OID") %in% names(result)))
})


test_that("select_starts_with errors when data is not a data.frame", {
  expect_error(
    select_starts_with(1:10, "BYLINE")
  )
})


test_that("select_starts_with errors when prefix is not a single string", {
  df <- data.frame(BYLINE1 = "A")

  expect_error(
    select_starts_with(df, c("BYLINE", "TITLE"))
  )

  expect_error(
    select_starts_with(df, 123)
  )
})
