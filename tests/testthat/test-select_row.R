test_that("select_row errors when by_column is not a single string", {
  df <- data.frame(PGMNAME = "t_dm", OID = "T001", stringsAsFactors = FALSE)

  expect_error(
    select_row(df, by_column = 123, by_value = "t_dm"),
    "`by_column` must be a single character string"
  )

  expect_error(
    select_row(df, by_column = c("PGMNAME", "OID"), by_value = "t_dm"),
    "`by_column` must be a single character string"
  )
})

test_that("select_row errors when by_column is not found in data", {
  df <- data.frame(PGMNAME = "t_dm", OID = "T001", stringsAsFactors = FALSE)

  expect_error(select_row(df, by_column = "NOPE", by_value = "t_dm"),
    regexp = "Column `NOPE` is not present"
  )
})

test_that("select_row returns exactly one matching row (no oid)", {
  metadata_df <- data.frame(
    PGMNAME = c("ADSL", "AE", "ADVS"),
    OID = c("T001", "T002", "T003"),
    VALUE = c("x", "y", "z"),
    stringsAsFactors = FALSE
  )

  out <- select_row(metadata_df, by_column = "PGMNAME", by_value = "AE")

  expect_s3_class(out, "data.frame")
  expect_equal(nrow(out), 1)
  expect_equal(out$PGMNAME, "AE")
  expect_equal(out$OID, "T002")
})

test_that("select_row respects oid filter", {
  metadata_df <- data.frame(
    PGMNAME = c("ADSL", "ADSL", "ADSL"),
    OID = c("T001", "T002", "T003"),
    VALUE = c("a", "b", "c"),
    stringsAsFactors = FALSE
  )

  out <- select_row(metadata_df, by_column = "PGMNAME", by_value = "ADSL", oid = "T003")

  expect_equal(nrow(out), 1)
  expect_equal(out$PGMNAME, "ADSL")
  expect_equal(out$OID, "T003")
  expect_equal(out$VALUE, "c")
})

test_that("select_row errors when no rows match", {
  metadata_df <- data.frame(
    PGMNAME = c("ADSL", "AE"),
    OID = c("T001", "T002"),
    stringsAsFactors = FALSE
  )

  expect_error(
    select_row(metadata_df, by_column = "PGMNAME", by_value = "NOT_EXIST"),
    regexp = "No rows match"
  )
})

test_that("select_row errors when multiple rows match without oid", {
  metadata_df <- data.frame(
    PGMNAME = c("ADSL", "ADSL"),
    OID = c("T001", "T002"),
    stringsAsFactors = FALSE
  )

  expect_error(
    select_row(metadata_df, by_column = "PGMNAME", by_value = "ADSL"),
    regexp = "Expected exactly one matching row"
  )
})

test_that("select_row errors when multiple rows match even with oid (data issue)", {
  metadata_df <- data.frame(
    PGMNAME = c("ADSL", "ADSL", "ADSL"),
    OID = c("T001", "T001", "T002"),
    stringsAsFactors = FALSE
  )

  expect_error(
    select_row(metadata_df, by_column = "PGMNAME", by_value = "ADSL", oid = "T001"),
    regexp = "Expected exactly one matching row"
  )
})

test_that("select_row returns exactly one row when both filters match", {
  df <- data.frame(
    PGMNAME = c("t_dm", "t_dm"),
    OID = c("T001", "T002"),
    X = c("1", "2"),
    stringsAsFactors = FALSE
  )

  out <- select_row(df, by_column = "PGMNAME", by_value = "t_dm", oid = "T002")
  expect_equal(nrow(out), 1)
  expect_identical(out$OID[[1]], "T002")
  expect_identical(out$X[[1]], "2")
})

test_that("select_row errors when oid is provided but OID column is missing", {
  df <- data.frame(PGMNAME = c("t_dm", "ae"), stringsAsFactors = FALSE)

  expect_error(
    select_row(df, by_column = "PGMNAME", by_value = "t_dm", oid = "T001"),
    regexp = "`OID` is missing"
  )
})

# NA in by_column does not create extra matches
test_that("select_row ignores NA values in filtering column", {
  df <- data.frame(
    PGMNAME = c(NA, "f_km"),
    OID = c(NA, "a"),
    TTL1 = c(NA, "Figure F01"),
    stringsAsFactors = FALSE
  )

  out <- select_row(df, by_column = "PGMNAME", by_value = "f_km")

  expect_equal(nrow(out), 1)
  expect_identical(out$PGMNAME[[1]], "f_km")
})

# by_value can be a vector (because %in%)
test_that("select_row supports vector by_value via %in%", {
  df <- data.frame(
    PGMNAME = c("ADSL", "AE", "ADVS"),
    OID = c("T001", "T002", "T003"),
    stringsAsFactors = FALSE
  )

  out <- select_row(df, by_column = "PGMNAME", by_value = c("AE", "XX"))

  expect_equal(nrow(out), 1)
  expect_identical(out$PGMNAME[[1]], "AE")
  expect_identical(out$OID[[1]], "T002")
})

# No match after applying oid filter
test_that("select_row errors when by_value matches but oid filter removes all rows", {
  df <- data.frame(
    PGMNAME = c("ADSL", "ADSL"),
    OID = c("T001", "T002"),
    stringsAsFactors = FALSE
  )

  expect_error(
    select_row(df, by_column = "PGMNAME", by_value = "ADSL", oid = "T999"),
    regexp = "No rows match"
  )
})

# Filtering column exists but values are all NA
test_that("select_row errors when filtering column exists but is all NA", {
  df <- data.frame(
    PGMNAME = c(NA, NA),
    OID = c("T001", "T002"),
    stringsAsFactors = FALSE
  )

  expect_error(
    select_row(df, by_column = "PGMNAME", by_value = "ADSL"),
    regexp = "No rows match"
  )
})

# drop = FALSE keeps output as data.frame even with 1-column input
test_that("select_row returns a data.frame even when input has one column", {
  df <- data.frame(PGMNAME = c("A", "B"), stringsAsFactors = FALSE)

  out <- select_row(df, by_column = "PGMNAME", by_value = "B")

  expect_s3_class(out, "data.frame")
  expect_equal(nrow(out), 1)
  expect_equal(ncol(out), 1)
  expect_identical(out$PGMNAME[[1]], "B")
})
