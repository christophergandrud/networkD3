% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/as_treenetdf.R
\name{as_treenetdf.list}
\alias{as_treenetdf.list}
\title{Convert a nested list to \code{treenetdf}}
\usage{
\method{as_treenetdf}{list}(data, children_name = "children", node_name = "name", ...)
}
\arguments{
\item{data}{a tree network description in one of numerous forms (see
details).}

\item{children_name}{character specifying the name used for the list element
that contains the childeren elements.}

\item{node_name}{character specifying the name used for the list element that
contains the name of the node}

\item{...}{arguments to pass to methods.}
}
\description{
Convert a nested list to \code{treenetdf}
}
