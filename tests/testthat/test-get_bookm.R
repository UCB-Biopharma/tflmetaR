
test_that("get_bookm() returns bookm when present", {
  df <- data.frame(
    TTL1 = c("1"),
    PGMNAME   = c("prog1"),
    BOOKM   = c("MyBookmark"),
    stringsAsFactors = FALSE
  )

  result <- get_bookm(df = df, pname = "prog1")
  expect_equal(result, "MyBookmark")
})

test_that("get_bookm() falls back to get_title() when bookm is missing", {
  df <- data.frame(
    TTL1 = c("1"),
    PGMNAME   = c("prog1"),
    BOOKM   = NA,
    stringsAsFactors = FALSE
  )
  local_mocked_bindings(
    get_title = function(...) list("Title A", "Title B")
  )
  result <- get_bookm(df = df, pname = "prog1")
  expect_equal(result, "Title A_Title B")
})

test_that("get_bookm() sanitizes invalid characters", {
  df <- data.frame(
    TTL1 = c("1"),
    PGMNAME   = c("prog1"),
    BOOKM   = "My/Invalid:Bookmark*?",
    stringsAsFactors = FALSE
  )

  result <- get_bookm(df = df, pname = "prog1")
  expect_false(grepl("[\\\\/:*?\"<>|]", result))
})

test_that("get_bookm() applies abbreviation lookup if >128 chars", {
  long_text <- paste(rep("ThisIsAVeryLongPhrase", 10), collapse = "_")

  df <- data.frame(
    TTL1 = c("1"),
    PGMNAME   = c("prog1"),
    BOOKM   = long_text,
    stringsAsFactors = FALSE
  )

  # Create temporary abbrev file
  abbrev_file <- tempfile(fileext = ".xlsx")
  writexl::write_xlsx(
    data.frame(scope = "bookmark", phrase = "ThisIsAVeryLongPhrase", abbr = "Short", stringsAsFactors = FALSE),
    abbrev_file
  )

  result <- get_bookm(df = df, pname = "prog1", abbrev_file = abbrev_file)
  expect_true(nchar(result) < nchar(long_text))
  expect_true(grepl("Short", result))
})

test_that("get_bookm() errors when df is NULL", {
  expect_error(get_bookm(df = NULL, pname = "prog1"))
})

test_that("get_bookm() errors when pname and tnumber are both NULL", {
  df <- data.frame(
    TTL1 = c("1"),
    PGMNAME   = c("prog1"),
    BOOKM   = "Bookmark",
    stringsAsFactors = FALSE
  )

  expect_error(get_bookm(df = df))
})

test_that("get_bookm() errors when multiple rows match", {
  df <- data.frame(
    TTL1 = c("1", "1"),
    PGMNAME   = c("prog1", "prog1"),
    BOOKM   = c("Bookmark1", "Bookmark2"),
    stringsAsFactors = FALSE
  )

  expect_error(get_bookm(df = df, tnumber = "1"))
})

test_that("get_bookm() truncates to 180 chars or less if still too long", {
  long_text <- paste(rep("SuperLongPhrase", 20), collapse = "_") # very long string

  df <- data.frame(
    TTL1 = c("1"),
    PGMNAME   = c("prog1"),
    BOOKM   = long_text,
    stringsAsFactors = FALSE
  )

  expect_warning(get_bookm(df = df, pname = "prog1"))
})

test_that("get_bookm() falls back to get_title() when BOOKM column is absent", {
  df <- data.frame(
    TTL1 = "1",
    PGMNAME = "prog1",
    stringsAsFactors = FALSE
  )

  local_mocked_bindings(
    get_title =   function(...) list("Title A", "Title B")
  )

  result <- get_bookm(df = df, pname = "prog1")
  expect_equal(result, "Title A_Title B")
})

test_that("get_bookm() falls back to get_title() when BOOKM is empty string", {
  df <- data.frame(
    TTL1 = "1",
    PGMNAME = "prog1",
    BOOKM = "",
    stringsAsFactors = FALSE
  )

  local_mocked_bindings(
    get_title =   function(...) list("Title A", "Title B")
  )

  result <- get_bookm(df = df, pname = "prog1")
  expect_equal(result, "Title A_Title B")
})

test_that("get_bookm() can select row by tnumber", {
  df <- data.frame(
    TTL1 = c("1", "2"),
    PGMNAME = c("prog1", "prog2"),
    BOOKM = c("Bookmark1", "Bookmark2"),
    stringsAsFactors = FALSE
  )

  result <- get_bookm(df = df, tnumber = "2")
  expect_equal(result, "Bookmark2")
})

test_that("get_bookm() warns when bookmark exceeds max_length and abbrev file is missing", {
  long_text <- paste(rep("LongBookmarkText", 20), collapse = " ")

  df <- data.frame(
    TTL1 = "1",
    PGMNAME = "prog1",
    BOOKM = long_text,
    stringsAsFactors = FALSE
  )

  expect_warning(
    result <- get_bookm(
      df = df,
      pname = "prog1",
      abbrev_file = "file_does_not_exist.xlsx",
      max_length = 50
    ),
    "Bookmark exceeds 50 characters and abbrev file not found"
  )

  expect_true(is.character(result))
  expect_length(result, 1)
})

test_that("get_bookm() truncates bookmark to max_length or less when still too long after abbreviation", {
  long_text <- paste(rep("VeryLongPhrase", 30), collapse = " ")

  df <- data.frame(
    TTL1 = "1",
    PGMNAME = "prog1",
    BOOKM = long_text,
    stringsAsFactors = FALSE
  )

  abbrev_file <- tempfile(fileext = ".xlsx")
  writexl::write_xlsx(
    data.frame(
      scope = "bookmark",
      phrase = "VeryLongPhrase",
      abbr = "LongWordStillTooBig",
      stringsAsFactors = FALSE
    ),
    abbrev_file
  )

  result <- get_bookm(
    df = df,
    pname = "prog1",
    abbrev_file = abbrev_file,
    max_length = 50
  )

  expect_true(nchar(result) <= 50)
})
