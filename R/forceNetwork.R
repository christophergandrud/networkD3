#' Create a D3 JavaScript force directed network graph.
#'
#' @param Links a data frame object with the links between the nodes. It should
#' include the \code{Source} and \code{Target} for each link. These should be
#' numbered starting from 0. An optional \code{Value} variable can be included
#' to specify how close the nodes are to one another.
#' @param Nodes a data frame containing the node id and properties of the nodes.
#' If no ID is specified then the nodes must be in the same order as the Source
#' variable column in the \code{Links} data frame. Currently only a grouping
#' variable is allowed.
#' @param Source character string naming the network source variable in the
#' \code{Links} data frame.
#' @param Target character string naming the network target variable in the
#' \code{Links} data frame.
#' @param Value character string naming the variable in the \code{Links} data
#' frame for how wide the links are.
#' @param NodeID character string specifying the node IDs in the \code{Nodes}
#' data frame.
#' @param Group character string specifying the group of each node in the
#' \code{Nodes} data frame.
#' @param height numeric height for the network graph's frame area in pixels.
#' @param width numeric width for the network graph's frame area in pixels.
#' @param fontsize numeric font size in pixels for the node text labels.
#' @param linkDistance numeric or character string. Either numberic fixed
#' distance between the links in pixels (actually arbitrary relative to the
#' diagram's size). Or a JavaScript function, possibly to weight by
#' \code{Value}. For example:
#' \code{linkDistance = "function(d){return d.value * 10}"}.
#' @param linkWidth numeric or character string. Can be a numeric fixed width in
#' pixels (arbitrary relative to the diagram's size). Or a JavaScript function,
#' possibly to weight by \code{Value}. The default is
#' \code{linkWidth = "function(d) { return Math.sqrt(d.value); }"}.
#' @param charge numeric value indicating either the strength of the node
#' repulsion (negative value) or attraction (positive value).
#' @param linkColour character string specifying the colour you want the link
#' lines to be. Multiple formats supported (e.g. hexadecimal).
#' @param opacity numeric value of the proportion opaque you would like the
#' graph elements to be.
#' @param zoom logical, whether or not to enable the ability to use the mouse
#' scroll-wheel to zoom in and out of the graph.
#'
#' @examples
#' \dontrun{
#' #### Tabular data example.
#' # Load data
#' data(MisLinks)
#' data(MisNodes)
#'
#' # Create graph
#' forceNetwork(Links = MisLinks, Nodes = MisNodes, Source = "source",
#'              Target = "target", Value = "value", NodeID = "name",
#'              Group = "group", opacity = 0.4)
#'
#' #### JSON Data Example
#' # Load data JSON formated data into two R data frames
#' library(RCurl)
#' MisJson <- getURL("http://bit.ly/1cc3anB")
#' MisLinks <- JSONtoDF(jsonStr = MisJson, array = "links")
#' MisNodes <- JSONtoDF(jsonStr = MisJson, array = "nodes")
#'
#' # Create graph
#' forceNetwork(Links = MisLinks, Nodes = MisNodes, Source = "source",
#'              Target = "target", Value = "value", NodeID = "name",
#'              Group = "group", opacity = 0.4)
#' }
#' 
#' @source
#' D3.js was created by Michael Bostock. See \url{http://d3js.org/} and, more
#' specifically for force directed networks
#' \url{https://github.com/mbostock/d3/wiki/Force-Layout}.
#'
#' @export
forceNetwork <- function(Links, Nodes, Source, Target, Value = NULL, NodeID,
	Group, height = NULL, width = NULL, fontsize = 7, linkDistance = 50,
	linkWidth = "function(d) { return Math.sqrt(d.value); }", charge = -120,
	linkColour = "#666",opacity = 0.6, zoom = FALSE)
{
	# Subset data frames for network graph
	if (class(Links) != "data.frame"){
		stop("Links must be a data frame class object.")
	}
	if (class(Nodes) != "data.frame"){
		stop("Nodes must be a data frame class object.")
	}
	if (is.null(Value)){
		LinksDF <- data.frame(Links[, Source], Links[, Target])
		names(LinksDF) <- c("source", "target")
	}
	else if (!is.null(Value)){
		LinksDF <- data.frame(Links[, Source], Links[, Target], Links[, Value])
		names(LinksDF) <- c("source", "target", "value")
	}
	NodesDF <- data.frame(Nodes[, NodeID], Nodes[, Group])
	names(NodesDF) <- c("name", "group")

	# derive click text size
	clickTextSize <- fontsize * 2.5
	
	# create options
	options = list(
	  NodeID = NodeID,
	  Group = Group,
	  fontsize = fontsize,
    clickTextSize = fontsize * 2.5,
	  linkDistance = linkDistance,
	  linkWidth = linkWidth,
    charge = charge,
    linkColour = linkColour,
	  opacity = opacity,
    zoom = zoom
	)
	
	# create widget
	htmlwidgets::createWidget(
	  name = "forceNetwork",
	  x = list(links = LinksDF, nodes = NodesDF, options = options),
	  width = width,
	  height = height,
	  htmlwidgets::sizingPolicy(padding = 0, 
                              browser.fill = TRUE),
	  package = "networkD3"
	)
}


#' @rdname networkD3-shiny
#' @export
forceNetworkOutput <- htmlwidgets::makeShinyOutput("forceNetwork", "networkD3")

#' @rdname networkD3-shiny
#' @export
renderForceNetwork <- htmlwidgets::makeShinyRender(forceNetworkOutput)




