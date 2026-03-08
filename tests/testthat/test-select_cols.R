
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

  out <- select_cols(df, annotation = "TITLE")

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

  out <- select_cols(df, annotation = "FOOTR", add_footr_tstamp = FALSE)

  testthat::expect_setequal(names(out), c("FOOT1"))
  testthat::expect_false("source" %in% names(out))
})

test_that("select_cols: FOOTR adds `source` via include_footr_tstamp() when add_footr_tstamp is TRUE", {
  df <- data.frame(
    FOOTR = "f1",
    SOURCE = "src",
    PGMNAME = "T14-01",
    stringsAsFactors = FALSE
  )

  # Mock include_footr_tstamp in the package namespace so test is deterministic
  testthat::local_mocked_bindings(
    include_footr_tstamp = function(pgmname, src) {
      paste0("TS:", pgmname, ":", src)
    },
    .env = asNamespace("tflmetaR")  # change if your package name differs
  )

  out <- select_cols(df, annotation = "FOOTR", add_footr_tstamp = TRUE)

  testthat::expect_true("source" %in% names(out))
  testthat::expect_identical(unlist(out$source), "TS:T14-01:src")
})

test_that("select_cols: annotation can be a specific column name and is case-insensitive", {
  df <- data.frame(
    PGMNAME = "T14-01",
    TTL1 = "t1",
    stringsAsFactors = FALSE
  )

  out1 <- select_cols(df, annotation = "pgmname")
  out2 <- select_cols(df, annotation = "PGMNAME")

  testthat::expect_setequal(names(out1), "PGMNAME")
  testthat::expect_setequal(names(out2), "PGMNAME")
  testthat::expect_identical(unlist(out1$PGMNAME), "T14-01")
})

test_that("select_cols: annotation = NULL returns all columns (except all-NA columns)", {
  df <- data.frame(
    PGMNAME = c("T14-01", "T14-02"),
    TTL1 = c("t1", "t2"),
    PARTIAL_NA = c(NA, "x"),
    ALL_NA = c(NA, NA),
    stringsAsFactors = FALSE
  )

  out <- select_cols(df, annotation = NULL)

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

  out <- select_cols(df, annotation = "TITLE")

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

  out <- select_cols(df, annotation = "TITLE")

  testthat::expect_true("TTL1" %in% names(out))
  testthat::expect_true("POPULATION" %in% names(out))

  # TTL1 should preserve NA (i.e., not dropped)
  testthat::expect_true(any(is.na(unlist(out$TTL1))))
})

test_that("select_cols: FOOTR does not call add_footr_tstamp when add_footr_tstamp is FALSE/NULL", {
  df <- data.frame(FOOT1 = "f1", SOURCE = "src", PGMNAME = "pgm", stringsAsFactors = FALSE)

  # FALSE
  out1 <- select_cols(df, annotation = "FOOTR", add_footr_tstamp = FALSE)
  expect_true("FOOT1" %in% names(out1))
  expect_false("source" %in% names(out1))

  # NULL (your code checks !is.null(add_footr_tstamp) && add_footr_tstamp)
  out2 <- select_cols(df, annotation = "FOOTR", add_footr_tstamp = NULL)
  expect_true("FOOT1" %in% names(out2))
  expect_false("source" %in% names(out2))
})

test_that("select_cols: FOOTR handles missing SOURCE and/or PGMNAME defensively", {
  # Missing SOURCE
  df1 <- data.frame(FOOT1 = "f1", PGMNAME = "pgm", stringsAsFactors = FALSE)

  testthat::local_mocked_bindings(
    include_footr_tstamp = function(pgmname, src) "TS",
    .env = asNamespace("tflmetaR") # change if pkg name differs
  )

  out1 <- select_cols(df1, annotation = "FOOTR", add_footr_tstamp = TRUE)
  expect_true("FOOT1" %in% names(out1))
  expect_true("source" %in% names(out1))  # your function adds it even if src is ""
  expect_identical(unlist(out1$source), "TS")

  # Missing PGMNAME
  df2 <- data.frame(FOOT1 = "f1", SOURCE = "src", stringsAsFactors = FALSE)
  out2 <- select_cols(df2, annotation = "FOOTR", add_footr_tstamp = TRUE)
  expect_true("source" %in% names(out2))
})

test_that("select_cols: selecting a non-existing column returns empty data frame", {
  df <- data.frame(PGMNAME = "t_dm", stringsAsFactors = FALSE)
  result <- select_cols(df, annotation = "NOPE")
  expect_true(is.data.frame(result))
  expect_equal(ncol(result), 0)
})

test_that("select_cols: NULL annotation returns all columns (and drops NA-only columns)", {
  df <- data.frame(
    TTL1 = "t1",
    FOOT1 = "f1",
    POPULATION = "Safety",
    PGMNAME = "T14-01",
    SOURCE = "src",
    ALLNA = NA,                 # NA-only column to be dropped by Filter()
    stringsAsFactors = FALSE
  )

  out <- select_cols(df, annotation = NULL)

  # Should keep all non-NA-only columns
  testthat::expect_true(is.list(out))
  testthat::expect_setequal(names(out), setdiff(names(df), "ALLNA"))
})
