test_that("utility functions work", {
  # Set testing specific parameters - this disposes after the test finishes
  if (dir.exists(file.path(tempdir(), "tst_utils"))) {
    unlink(file.path(tempdir(), "tst_utils"), recursive = TRUE, force = TRUE)
  }
  withr::local_file(file.path(tempdir(), "tst_utils"))
  dir.create(file.path(tempdir(), "tst_utils"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_utils"))

  # current season function - also naturally tested in some load_x functions
  expect_true(is.numeric(get_current_season()))
  expect_gte(get_current_season(), 2022)

  # get_ergast_content() is inherently tested in load_x functions too

  if (require(httptest)) {
    # Test internet failures for get_current_season
    httptest::without_internet({
      expect_gte(get_current_season(), 2022)
    })
  }

  # Test time format changes
  expect_equal(time_to_sec("12.345"), 12.345)
  expect_equal(time_to_sec("1:23.456"), 83.456)
  expect_equal(time_to_sec("12:34:56.789"), 45296.789)
  expect_equal(time_to_sec("12.3456"), 12.3456)
  expect_equal(time_to_sec(12.345), 12.345)

  expect_equal(
    time_to_sec(c("12.345", "1:23.456", "12:34:56.789", "12.3456")),
    c(12.345, 83.456, 45296.789, 12.3456)
  )
})

test_that("setup-fastf1 works", {
  skip_if_no_py()
  skip_if_no_ff1()

  # Set testing specific parameters - this disposes after the test finishes
  # Note: The test suite can't delete the old fastf1_http_cache.sqlite file
  # because python's process has it locked.
  withr::local_file(file.path(tempdir(), "tst_setup"))
  if (dir.exists(file.path(tempdir(), "tst_setup"))) {
    unlink(file.path(tempdir(), "tst_setup"), recursive = TRUE, force = TRUE)
  }
  dir.create(file.path(tempdir(), "tst_setup"), recursive = TRUE)
  withr::local_options(f1dataR.cache = file.path(tempdir(), "tst_setup"))
  withr::local_envvar(.new = list(
    "WORKON_HOME" = file.path(tempdir(), "tst_setup"),
    "RETICULATE_PYTHON" = NA
  ))
  withr::defer(reticulate::virtualenv_remove(file.path(tempdir(), "tst_setup", "setup_venv"), confirm = FALSE))

  expect_false("setup_venv" %in% reticulate::virtualenv_list())

  # Different testing environments may or may not have preexisting selected/activated python venv or condaenv.
  # This try(suppressWarnings()) set makes sure that the code is run, and we'll test for that which we care about
  # (namely the creation of the venv) afterwards
  try(suppressWarnings(setup_fastf1(file.path(tempdir(), "tst_setup", "setup_venv"), conda = FALSE)))

  expect_true("setup_venv" %in% reticulate::virtualenv_list())

  if (reticulate:::conda_installed()) {
    # Workflow runners or CRAN tests might not have conda

    withr::defer(reticulate::conda_remove("setup_conda"))

    expect_error(
      setup_fastf1("setup_venv", conda = TRUE),
      "* found in list of virtualenv environments. Did you mean to use that?"
    )
    expect_false("setup_conda" %in% reticulate::conda_list()$name)

    # Because we set the venv earlier, reticulate won't let you set a second active env without restarting R.
    # Alternatively, we can wrap this in 'try' also.
    expect_error(setup_fastf1("setup_conda", conda = TRUE), "*failed to initialize requested version of Python")
    expect_true("setup_conda" %in% reticulate::conda_list()$name)

    expect_error(
      setup_fastf1("setup_conda", conda = FALSE),
      "* found in list of conda environments. Did you mean to use that?"
    )
  }
})