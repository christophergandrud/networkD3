% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dendroNetwork.R
\name{dendroNetwork}
\alias{dendroNetwork}
\title{Create hierarchical cluster network diagrams.}
\source{
Mike Bostock: \url{https://bl.ocks.org/mbostock/4063570}.

Fabio Nelli: https://www.meccanismocomplesso.org/en/dendrogramma-d3-parte1/
}
\usage{
dendroNetwork(
  hc,
  height = 500,
  width = 800,
  fontSize = 10,
  linkColour = "#ccc",
  nodeColour = "#fff",
  nodeStroke = "steelblue",
  textColour = "#111",
  textOpacity = 0.9,
  textRotate = NULL,
  opacity = 0.9,
  margins = NULL,
  linkType = c("elbow", "diagonal"),
  treeOrientation = c("horizontal", "vertical"),
  zoom = FALSE
)
}
\arguments{
\item{hc}{a hierarchical (\code{hclust}) cluster object.}

\item{height}{height for the network graph's frame area in pixels}

\item{width}{numeric width for the network graph's frame area in pixels}

\item{fontSize}{numeric font size in pixels for the node text labels.}

\item{linkColour}{character string specifying the colour you want the link
lines to be. Multiple formats supported (e.g. hexadecimal).}

\item{nodeColour}{character string specifying the colour you want the node
circles to be. Multiple formats supported (e.g. hexadecimal).}

\item{nodeStroke}{character string specifying the colour you want the node
perimeter to be. Multiple formats supported (e.g. hexadecimal).}

\item{textColour}{character vector or scalar specifying the colour you want
the text to be before they are clicked. Order should match the order of
\code{hclust$labels}. Multiple formats supported (e.g. hexadecimal).}

\item{textOpacity}{numeric vector or scalar of the proportion opaque you
would like the text to be before they are clicked. rder should match the
order of \code{hclust$labels}.}

\item{textRotate}{numeric degress to rotate text for node text. Default
is 0 for horizontal and 65 degrees for vertical.}

\item{opacity}{numeric value of the proportion opaque you would like the
graph elements to be.}

\item{margins}{numeric value or named list of plot margins
(top, right, bottom, left). Set the margin appropriately to accomodate
long text labels.}

\item{linkType}{character specifying the link type between points. Options
are 'elbow' and 'diagonal'.}

\item{treeOrientation}{character specifying the tree orientation, Options
are 'vertical' and 'horizontal'.}

\item{zoom}{logical enabling plot zoom and pan}
}
\description{
Create hierarchical cluster network diagrams.
}
\examples{
\dontrun{
hc <- hclust(dist(USArrests), "ave")

dendroNetwork(hc, height = 600)
dendroNetwork(hc, treeOrientation = "vertical")

dendroNetwork(hc, height = 600, linkType = "diagonal")
dendroNetwork(hc, treeOrientation = "vertical", linkType = "diagonal")

dendroNetwork(hc, textColour = c("red", "green", "orange")[cutree(hc, 3)],
               height = 600)
dendroNetwork(hc, textColour = c("red", "green", "orange")[cutree(hc, 3)],
               treeOrientation = "vertical")
}

}
