% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/key-aggregates.R
\name{key_aggregates}
\alias{key_aggregates}
\title{get score for key sentences as per Lexrank}
\usage{
key_aggregates(.data, aggregate_on, summ_method)
}
\arguments{
\item{.data}{character vector of words}

\item{aggregate_on}{vector to aggregate .data over; ideally, sentence_id}

\item{summ_method}{method to use for summarisation: textrank or
lexrank. Doesn't do anything yet}
}
\value{
lexrank scores of aggregates
}
\description{
get score for key sentences as per Lexrank
}
