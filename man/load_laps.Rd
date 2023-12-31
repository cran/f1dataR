% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/load_laps.R
\name{load_laps}
\alias{load_laps}
\title{Load Lap by Lap Time Data}
\usage{
load_laps(
  season = get_current_season(),
  round = "last",
  race = lifecycle::deprecated()
)
}
\arguments{
\item{season}{number from 1996 to current season (defaults to current season).}

\item{round}{number from 1 to 23 (depending on season selected) and defaults
to most recent.  Also accepts \code{'last'}.}

\item{race}{\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#deprecated}{\figure{lifecycle-deprecated.svg}{options: alt='[Deprecated]'}}}{\strong{[Deprecated]}} \code{race} is no longer supported, use \code{round}.}
}
\value{
A tibble with columns driver_id (unique and recurring), position
during lap, time (in clock form), lap number, time (in seconds), and season.
}
\description{
Loads basic lap-by-lap time data for all drivers in a given season
and round. Lap time data is available from 1996 onward. Use \code{.load_laps()} for a uncached version.
}
