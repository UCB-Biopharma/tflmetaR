
test_that("read_xlfile throws an error if the file does not exist", {
  expect_error(tflmetaR::read_xlfile("non_existent_file.xls", "Sheet1"),
               "`path` does not exist: 'non_existent_file.xls'")
})

test_that("read_xlfile reads the requested sheet and validates required columns", {
  testthat::skip_if_not_installed("writexl")

  # Build a minimal valid sheet (note: lowercase names to test toupper())
  df_ok <- data.frame(
    pgmname = "T14-01",
    ttl1    = "Title line 1",
    foot1   = "Footnote line 1",
    source  = "ADSL",
    stringsAsFactors = FALSE
  )

  # A second sheet to confirm sheetname argument is respected
  df_other <- data.frame(
    pgmname = "OTHER",
    ttl1    = "Other title",
    foot1   = "Other footnote",
    source  = "OTHER_SRC",
    stringsAsFactors = FALSE
  )

  xlsx_path <- tempfile(fileext = ".xlsx")
  writexl::write_xlsx(
    x = list(Sheet1 = df_ok, Sheet2 = df_other),
    path = xlsx_path
  )

  res <- read_xlfile(xlsx_path, "Sheet1")

  # Basic class check
  testthat::expect_true(is.data.frame(res))

  # Names are uppercased
  testthat::expect_true(all(c("PGMNAME", "TTL1", "FOOT1", "SOURCE") %in% names(res)))
  testthat::expect_false(any(c("pgmname", "ttl1", "foot1", "source") %in% names(res)))

  # Content matches the selected sheet (Sheet1, not Sheet2)
  testthat::expect_identical(res$PGMNAME[[1]], "T14-01")
  testthat::expect_identical(res$SOURCE[[1]], "ADSL")
})

test_that("read_xlfile errors when required columns are missing", {
  testthat::skip_if_not_installed("writexl")

  # Missing FOOT1 and SOURCE
  df_bad <- data.frame(
    PGMNAME = "T14-01",
    TTL1    = "Title line 1",
    stringsAsFactors = FALSE
  )

  xlsx_path <- tempfile(fileext = ".xlsx")
  writexl::write_xlsx(list(Sheet1 = df_bad), xlsx_path)

  testthat::expect_error(
    read_xlfile(xlsx_path, "Sheet1"),
    regexp = "required column\\(s\\) missing"
  )
})

test_that("read_xlfile accepts mixed-case column names and still validates", {
  testthat::skip_if_not_installed("writexl")

  df_mixed <- data.frame(
    PgmName = "T14-01",
    ttL1    = "Title line 1",
    Foot1   = "Footnote line 1",
    SoUrCe  = "ADSL",
    stringsAsFactors = FALSE
  )

  xlsx_path <- tempfile(fileext = ".xlsx")
  writexl::write_xlsx(list(Sheet1 = df_mixed), xlsx_path)

  res <- read_xlfile(xlsx_path, "Sheet1")
  testthat::expect_true(all(c("PGMNAME", "TTL1", "FOOT1", "SOURCE") %in% names(res)))
})

test_that("read_xlfile errors for a non-existent sheet", {
  # This error is thrown by readxl
  xlsx_path <- tempfile(fileext = ".xlsx")

  testthat::skip_if_not_installed("writexl")
  writexl::write_xlsx(list(Sheet1 = data.frame(a = 1)), xlsx_path)

  testthat::expect_error(
    read_xlfile(xlsx_path, "NoSuchSheet")
  )
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

