#' Load Session Data
#'
#' @description Loads telemetry and general data from the official F1 data stream via
#' the fastf1 python library. Data is available from 2018 onward.
#'
#' The data loaded can optionally be assigned to a R variable, and then interrogated for
#' session data streams. See the \href{https://docs.fastf1.dev/}{fastf1 documentation}
#' for more details on the data returned by the python API.
#'
#' If you have trouble with errors mentioning 'fastf1' or 'get_fastf1_version()' read the
#' 'Setup FastF1 Connection vignette (run \code{vignette('setup_fastf1', 'f1dataR')}).
#'
#' Cache directory can be set by setting `option(f1dataR.cache = [cache dir])`,
#' default is the current working directory.
#'
#' @param obj_name name assigned to the loaded session to be referenced later.
#' Leave as `'session'` unless otherwise required.
#' @param season number from 2018 to current season. Defaults to current season.
#' @param round number from 1 to 24 (depending on season selected) and defaults
#' to most recent. Also accepts race name.
#' @param session the code for the session to load. Options are `'FP1'`, `'FP2'`, `'FP3'`,
#' `'Q'`, `'S'`, `'SS'`,`'SQ'`, and `'R'`. Default is `'R'`, which refers to Race.
#' @param log_level Detail of logging from fastf1 to be displayed. Choice of:
#' `'DEBUG'`, `'INFO'`, `'WARNING'`, `'ERROR'` and `'CRITICAL.'` See
#' \href{https://docs.fastf1.dev/fastf1.html#configure-logging-verbosity}{fastf1 documentation}.
#' @param race `r lifecycle::badge("deprecated")` `race` is no longer supported, use `round`
#' @import reticulate
#' @return A session object to be used in other functions invisibly.
#' @export
#' @seealso [load_session_laps()] [plot_fastest()]
#' @examples
#' # Load the quali session from 2019 first round
#' if (interactive()) {
#'   session <- load_race_session(season = 2019, round = 1, session = "Q")
#' }
load_race_session <- function(obj_name = "session", season = get_current_season(), round = 1, session = "R",
                              log_level = "WARNING", race = lifecycle::deprecated()) {
  # Deprecation Checks
  if (lifecycle::is_present(race)) {
    lifecycle::deprecate_stop("1.4.0", "load_race_session(race)", "load_race_session(round)")
  }
  check_ff1_version()

  # Function Code
  if (season != "current" && (season < 2018 || season > get_current_season())) {
    cli::cli_abort('{.var season} must be between 2018 and {get_current_season()} (or use "current")')
    # stop(glue::glue('Year must be between 2018 and {current} (or use "current")',
    #                 current = get_current_season()))
  }
  if (!(session %in% c("FP1", "FP2", "FP3", "Q", "R", "S", "SS", "SQ"))) {
    cli::cli_abort('{.var session} must be one of "FP1", "FP2", "FP3", "Q", "SQ", "SS", "S", or "R"')
  }
  if (season == "current") {
    season <- get_current_season()
  }

  log_level <- match.arg(log_level, c("DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"), several.ok = FALSE)

  if (log_level %in% c("DEBUG", "INFO")) {
    cli::cli_alert_info("The first time a session is loaded, some time is required. Please be patient. Subsequent times will be faster.")
  }

  # only cache to tempdir if cache option is set to memory or off (includes filesystem in vector as a fallback error catch)
  if (getOption("f1dataR.cache", default = "memory") %in% c("memory", "off", "filesystem")) {
    f1datar_cache <- normalizePath(tempdir(), winslash = "/")
  } else {
    f1datar_cache <- normalizePath(getOption("f1dataR.cache"), winslash = "/")
  }

  if (!dir.exists(f1datar_cache)) {
    dir.create(f1datar_cache, recursive = TRUE)
  }

  reticulate::py_run_string("import fastf1")
  reticulate::py_run_string(glue::glue("fastf1.set_log_level('{log_level}')", log_level = log_level))
  reticulate::py_run_string(glue::glue("fastf1.Cache.enable_cache('{cache_dir}')", cache_dir = f1datar_cache))

  py_string <- glue::glue("{name} = fastf1.get_session({season}, ", name = obj_name, season = season)
  if (is.numeric(round)) {
    py_string <- glue::glue("{py_string}{round}, '{session}')",
      py_string = py_string, round = round, session = session
    )
  } else {
    # Character race, so need quotes around it
    py_string <- glue::glue("{py_string}'{round}', '{session}')",
      py_string = py_string, round = round, session = session
    )
  }

  # fastf1.get_session([args]) runs even if there's no internet connection,
  # the schedule of sessions is built into the package
  tryCatch(
    session <- reticulate::py_run_string(py_string),
    error = function(e) {
      cli::cli_abort(c("Error loading FastF1 session.",
        "x" = as.character(e)
      ))
    }
  )

  # Check for fastf1 (F1timing/internet) connection
  status <- check_ff1_network_connection(session$session$api_path)
  if (!status) {
    cli::cli_alert_danger("f1dataR: Can't connect to F1 Live Timing for FastF1 data download")
    return(NULL)
  }

  # likewise, without internet the session itself will 'load' but not actually retrieve any data
  reticulate::py_run_string(glue::glue("{name}.load()", name = obj_name))

  # without internet the session check will fail, and retry reload
  check_ff1_session_loaded(session_name = obj_name)

  status <- FALSE
  tryCatch(
    {
      # Only returns a value if session.load() has been successful
      # If it hasn't, internet or fastf1 must be down
      reticulate::py_run_string(glue::glue("{obj_name}.t0_date", obj_name = obj_name))
      status <- TRUE
    },
    error = function(e) {
      cli::cli_alert_danger("f1dataR: Error getting data from FastF1 or F1 Live Timing")
      status <- FALSE
    }
  )

  if (!status) {
    return(NULL)
  }

  invisible(session[obj_name])
}
