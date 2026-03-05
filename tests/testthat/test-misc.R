test_that("select_row errors when by_column is not a single string", {
  df <- data.frame(PGMNAME = "t_dm", OID = "T001", stringsAsFactors = FALSE)

  expect_error(select_row(df, by_column = 123, by_value = "t_dm"),
               "`by_column` must be a single character string")

  expect_error(select_row(df, by_column = c("PGMNAME", "OID"), by_value = "t_dm"),
               "`by_column` must be a single character string")
})

test_that("select_row errors when by_column is not found in data", {
  df <- data.frame(PGMNAME = "t_dm", OID = "T001", stringsAsFactors = FALSE)

  expect_error(select_row(df, by_column = "NOPE", by_value = "t_dm"),
               "`by_column` not found in data")
})

test_that("select_row returns exactly one matching row (no oid)", {
  metadata_df <- data.frame(
    PGMNAME = c("ADSL", "AE", "ADVS"),
    OID     = c("T001", "T002", "T003"),
    VALUE   = c("x", "y", "z"),
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
    OID     = c("T001", "T002", "T003"),
    VALUE   = c("a", "b", "c"),
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
    OID     = c("T001", "T002"),
    stringsAsFactors = FALSE
  )

  expect_error(
    select_row(metadata_df, by_column = "PGMNAME", by_value = "NOT_EXIST"),
    regexp = "No row is found"
  )
})

test_that("select_row errors when multiple rows match without oid", {
  metadata_df <- data.frame(
    PGMNAME = c("ADSL", "ADSL"),
    OID     = c("T001", "T002"),
    stringsAsFactors = FALSE
  )

  expect_error(
    select_row(metadata_df, by_column = "PGMNAME", by_value = "ADSL"),
    regexp = "Non unique entry generated"
  )
})

test_that("select_row errors when multiple rows match even with oid (data issue)", {
  metadata_df <- data.frame(
    PGMNAME = c("ADSL", "ADSL", "ADSL"),
    OID     = c("T001", "T001", "T002"),
    stringsAsFactors = FALSE
  )

  expect_error(
    select_row(metadata_df, by_column = "PGMNAME", by_value = "ADSL", oid = "T001"),
    regexp = "Non unique entry generated"
  )
})

test_that("select_row returns exactly one row when both filters match", {
  df <- data.frame(PGMNAME = c("t_dm", "t_dm"),
                   OID = c("T001", "T002"),
                   X = c("1", "2"),
                   stringsAsFactors = FALSE)

  out <- select_row(df, by_column = "PGMNAME", by_value = "t_dm", oid = "T002")
  expect_equal(nrow(out), 1)
  expect_identical(out$OID[[1]], "T002")
  expect_identical(out$X[[1]], "2")
})

test_that("select_cols: NULL select_type returns all columns (and drops NA-only columns)", {
  df <- data.frame(
    TTL1 = "t1",
    FOOT1 = "f1",
    POPULATION = "Safety",
    PGMNAME = "T14-01",
    SOURCE = "src",
    ALLNA = NA,                 # NA-only column to be dropped by Filter()
    stringsAsFactors = FALSE
  )

  out <- select_cols(df, select_type = NULL)

  # Should keep all non-NA-only columns
  testthat::expect_true(is.list(out))
  testthat::expect_setequal(names(out), setdiff(names(df), "ALLNA"))
})

test_that("select_row errors when oid is provided but OID column is missing", {
  df <- data.frame(PGMNAME = c("t_dm", "ae"), stringsAsFactors = FALSE)

  expect_error(
    select_row(df, by_column = "PGMNAME", by_value = "t_dm", oid = "T001"),
    regexp = "Column `OID` not found"
  )
})

# NA in by_column does not create extra matches
test_that("select_row ignores NA values in filtering column", {
  df <- data.frame(
    PGMNAME = c(NA, "f_km"),
    OID     = c(NA, "a"),
    TTL1    = c(NA, "Figure F01"),
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
    OID     = c("T001", "T002", "T003"),
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
    OID     = c("T001", "T002"),
    stringsAsFactors = FALSE
  )

  expect_error(
    select_row(df, by_column = "PGMNAME", by_value = "ADSL", oid = "T999"),
    regexp = "No row is found"
  )
})

# Filtering column exists but values are all NA
test_that("select_row errors when filtering column exists but is all NA", {
  df <- data.frame(
    PGMNAME = c(NA, NA),
    OID     = c("T001", "T002"),
    stringsAsFactors = FALSE
  )

  expect_error(
    select_row(df, by_column = "PGMNAME", by_value = "ADSL"),
    regexp = "No row is found"
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

test_that("select_cols: TITLE selects TTL* and POPULATION", {
  df <- data.frame(
    TTL1 = "t1",
    TTL2 = NA,                  # should be dropped by Filter() because NA-only (all NA)
    FOOT1 = "f1",
    POPULATION = "Safety",
    SOURCE = "src",
    stringsAsFactors = FALSE
  )
  df$TTL2 <- NA  # ensure it's all-NA column (length 1)

  out <- select_cols(df, select_type = "TITLE")

  testthat::expect_setequal(names(out), c("TTL1", "POPULATION"))
  testthat::expect_identical(unlist(out$TTL1), "t1")
  testthat::expect_identical(unlist(out$POPULATION), "Safety")
})

test_that("select_cols: FOOTR selects FOOT* and does NOT add timestamp when add_footr_tstamp is FALSE", {
  df <- data.frame(
    FOOT1 = "f1",
    FOOT2 = NA,          # all-NA column -> dropped
    SOURCE = "src",
    stringsAsFactors = FALSE
  )
  df$FOOT2 <- NA

  out <- select_cols(df, select_type = "FOOTR", add_footr_tstamp = FALSE)

  testthat::expect_setequal(names(out), c("FOOT1"))
  testthat::expect_false("source" %in% names(out))
})

test_that("select_cols: FOOTR adds `source` via get_footr_tstamp() when add_footr_tstamp is TRUE", {
  df <- data.frame(
    FOOTR = "f1",
    SOURCE = "src",
    PGMNAME = "T14-01",
    stringsAsFactors = FALSE
  )

  # Mock get_footr_tstamp in the package namespace so test is deterministic
  testthat::local_mocked_bindings(
    get_footr_tstamp = function(pgmname, src) {
      paste0("TS:", pgmname, ":", src)
    },
    .env = asNamespace("tflmetaR")  # change if your package name differs
  )

  out <- select_cols(df, select_type = "FOOTR", add_footr_tstamp = TRUE)

  testthat::expect_true("source" %in% names(out))
  testthat::expect_identical(unlist(out$source), "TS:T14-01:src")
})

test_that("select_cols: select_type can be a specific column name and is case-insensitive", {
  df <- data.frame(
    PGMNAME = "T14-01",
    TTL1 = "t1",
    stringsAsFactors = FALSE
  )

  out1 <- select_cols(df, select_type = "pgmname")
  out2 <- select_cols(df, select_type = "PGMNAME")

  testthat::expect_setequal(names(out1), "PGMNAME")
  testthat::expect_setequal(names(out2), "PGMNAME")
  testthat::expect_identical(unlist(out1$PGMNAME), "T14-01")
})

test_that("select_cols: select_type = NULL returns all columns (except all-NA columns)", {
  df <- data.frame(
    PGMNAME = c("T14-01", "T14-02"),
    TTL1 = c("t1", "t2"),
    PARTIAL_NA = c(NA, "x"),
    ALL_NA = c(NA, NA),
    stringsAsFactors = FALSE
  )

  out <- select_cols(df, select_type = NULL)

  testthat::expect_true(is.list(out))
  testthat::expect_setequal(names(out), c("PGMNAME", "TTL1", "PARTIAL_NA"))
  testthat::expect_false("ALL_NA" %in% names(out))
})

test_that("select_cols: drops columns that are entirely NA", {
  df <- data.frame(
    TTL1 = c("t1", "t2"),
    TTL2 = c(NA, NA),            # all NA -> should be removed by Filter(!all(is.na(.)))
    POPULATION = c("Safety", "Safety"),
    stringsAsFactors = FALSE
  )

  out <- select_cols(df, select_type = "TITLE")

  testthat::expect_true("TTL1" %in% names(out))
  testthat::expect_true("POPULATION" %in% names(out))
  testthat::expect_false("TTL2" %in% names(out))
})

test_that("select_cols: keeps columns that are partially NA", {
  df <- data.frame(
    TTL1 = c("t1", NA),          # partial NA -> should be kept
    POPULATION = c("Safety", "Safety"),
    stringsAsFactors = FALSE
  )

  out <- select_cols(df, select_type = "TITLE")

  testthat::expect_true("TTL1" %in% names(out))
  testthat::expect_true("POPULATION" %in% names(out))

  # TTL1 should preserve NA (i.e., not dropped)
  testthat::expect_true(any(is.na(unlist(out$TTL1))))
})

test_that("select_cols: FOOTR does not call get_footr_tstamp when add_footr_tstamp is FALSE/NULL", {
  df <- data.frame(FOOT1 = "f1", SOURCE = "src", PGMNAME = "pgm", stringsAsFactors = FALSE)

  # FALSE
  out1 <- select_cols(df, select_type = "FOOTR", add_footr_tstamp = FALSE)
  expect_true("FOOT1" %in% names(out1))
  expect_false("source" %in% names(out1))

  # NULL (your code checks !is.null(add_footr_tstamp) && add_footr_tstamp)
  out2 <- select_cols(df, select_type = "FOOTR", add_footr_tstamp = NULL)
  expect_true("FOOT1" %in% names(out2))
  expect_false("source" %in% names(out2))
})

test_that("select_cols: FOOTR handles missing SOURCE and/or PGMNAME defensively", {
  # Missing SOURCE
  df1 <- data.frame(FOOT1 = "f1", PGMNAME = "pgm", stringsAsFactors = FALSE)

  testthat::local_mocked_bindings(
    get_footr_tstamp = function(pgmname, src) "TS",
    .env = asNamespace("tflmetaR") # change if pkg name differs
  )

  out1 <- select_cols(df1, select_type = "FOOTR", add_footr_tstamp = TRUE)
  expect_true("FOOT1" %in% names(out1))
  expect_true("source" %in% names(out1))  # your function adds it even if src is ""
  expect_identical(unlist(out1$source), "TS")

  # Missing PGMNAME
  df2 <- data.frame(FOOT1 = "f1", SOURCE = "src", stringsAsFactors = FALSE)
  out2 <- select_cols(df2, select_type = "FOOTR", add_footr_tstamp = TRUE)
  expect_true("source" %in% names(out2))
})

test_that("select_cols: selecting a specific column errors if missing", {
  df <- data.frame(PGMNAME = "t_dm", stringsAsFactors = FALSE)

  expect_error(select_cols(df, select_type = "NOPE"))
})
