% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/load_session_laps.R
\name{load_session_laps}
\alias{load_session_laps}
\title{Load Lapwise Data}
\usage{
load_session_laps(
  season = get_current_season(),
  round = 1,
  session = "R",
  log_level = "WARNING",
  add_weather = FALSE,
  race = lifecycle::deprecated()
)
}
\arguments{
\item{season}{number from 2018 to current season. Defaults to current season.}

\item{round}{number from 1 to 24 (depending on season selected) and defaults
to most recent. Also accepts race name.}

\item{session}{the code for the session to load. Options are \code{'FP1'}, \code{'FP2'}, \code{'FP3'},
\code{'Q'}, \code{'S'}, \code{'SS'},\code{'SQ'}, and \code{'R'}. Default is \code{'R'}, which refers to Race.}

\item{log_level}{Detail of logging from fastf1 to be displayed. Choice of:
\code{'DEBUG'}, \code{'INFO'}, \code{'WARNING'}, \code{'ERROR'} and \code{'CRITICAL.'} See
\href{https://docs.fastf1.dev/fastf1.html#configure-logging-verbosity}{fastf1 documentation}.}

\item{add_weather}{Whether to add weather information to the laps. See
\href{https://docs.fastf1.dev/core.html#fastf1.core.Laps.get_weather_data}{fastf1 documentation} for info on weather.}

\item{race}{\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#deprecated}{\figure{lifecycle-deprecated.svg}{options: alt='[Deprecated]'}}}{\strong{[Deprecated]}} \code{race} is no longer supported, use \code{round}}
}
\value{
A tibble. Note time information is in seconds, see \href{https://docs.fastf1.dev/time_explanation.html}{fastf1 documentation} for more information on timing.
}
\description{
Loads lapwise data for a race session.

Includes each driver's each lap's laptime, pit in/out time, tyre information, track status, and (optionally) weather information.
The resulting data frame contains a column for the session type. Note that quali sessions are labelled Q1, Q2 & Q3.

Cache directory can be set by setting \verb{option(f1dataR.cache = [cache dir])},
default is the current working directory.

If you have trouble with errors mentioning 'fastf1' or 'get_fastf1_version()' read the
'Setup FastF1 Connection vignette (run \code{vignette('setup_fastf1', 'f1dataR')}).
}
