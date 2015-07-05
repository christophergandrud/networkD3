#' Create a D3 JavaScript Sankey diagram
#'
#' @param Links a data frame object with the links between the nodes. It should
#' have include the \code{Source} and \code{Target} for each link. An optional
#' \code{Value} variable can be included to specify how close the nodes are to
#' one another.
#' @param Nodes a data frame containing the node id and properties of the nodes.
#' If no ID is specified then the nodes must be in the same order as the
#' \code{Source} variable column in the \code{Links} data frame. Currently only
#' grouping variable is allowed.
#' @param Source character string naming the network source variable in the
#' \code{Links} data frame.
#' @param Target character string naming the network target variable in the
#' \code{Links} data frame.
#' @param Value character string naming the variable in the \code{Links} data
#' frame for how far away the nodes are from one another.
#' @param NodeID character string specifying the node IDs in the \code{Nodes}
#' data frame.
#' @param height numeric height for the network graph's frame area in pixels.
#' @param width numeric width for the network graph's frame area in pixels.
#' @param colourScale character string specifying the categorical colour
#' scale for the nodes. See
#' \url{https://github.com/mbostock/d3/wiki/Ordinal-Scales}.
#' @param fontSize numeric font size in pixels for the node text labels.
#' @param fontFamily font family for the node text labels.
#' @param nodeWidth numeric width of each node.
#' @param nodePadding numeric essentially influences the width height.
#'
#' @examples
#' \dontrun{
#' # Recreate Bostock Sankey diagram: http://bost.ocks.org/mike/sankey/
#' # Load energy projection data
#' library(RCurl)
#' # Create URL. paste0 used purely to keep within line width.

#' URL <- paste0("https://raw.githubusercontent.com/christophergandrud/",
#'               "networkD3/master/JSONdata/energy.json")
#' Energy <- getURL(URL, ssl.verifypeer = FALSE)
#'
#' # Convert to data frame
#' EngLinks <- JSONtoDF(jsonStr = Energy, array = "links")
#' EngNodes <- JSONtoDF(jsonStr = Energy, array = "nodes")
#'
#' # Plot
#' sankeyNetwork(Links = EngLinks, Nodes = EngNodes, Source = "source",
#'              Target = "target", Value = "value", NodeID = "name",
#'               fontSize = 12, nodeWidth = 30)
#' }
#' @source
#' D3.js was created by Michael Bostock. See \url{http://d3js.org/} and, more
#' specifically for Sankey diagrams \url{http://bost.ocks.org/mike/sankey/}.
#'
#' @seealso \code{\link{JS}}
#'
#' @export

sankeyNetwork <- function(Links,
                          Nodes,
                          Source,
                          Target,
                          Value,
                          NodeID,
                          height = NULL,
                          width = NULL,
                          colourScale = JS("d3.scale.category20()"),
                          fontSize = 7,
                          fontFamily = "serif",
                          nodeWidth = 15,
                          nodePadding = 10)
{
    # Hack for UI consistency. Think of improving.
    colourScale <- as.character(colourScale)

    # Subset data frames for network graph
    if (!is.data.frame(Links)) {
        stop("Links must be a data frame class object.")
    }
    if (!is.data.frame(Nodes)) {
        stop("Nodes must be a data frame class object.")
    }
    if (missing(Value)) {
        LinksDF <- data.frame(Links[, Source], Links[, Target])
        names(LinksDF) <- c("source", "target")
    }
    else if (!missing(Value)) {
        LinksDF <- data.frame(Links[, Source], Links[, Target], Links[, Value])
        names(LinksDF) <- c("source", "target", "value")
    }
    NodesDF <- data.frame(Nodes[, NodeID])
    names(NodesDF) <- c("name")

    # create options
    options = list(
        NodeID = NodeID,
        colourScale = colourScale,
        fontSize = fontSize,
        fontFamily = fontFamily,
        nodeWidth = nodeWidth,
        nodePadding = nodePadding
    )

    # create widget
    htmlwidgets::createWidget(
        name = "sankeyNetwork",
        x = list(links = LinksDF, nodes = NodesDF, options = options),
        width = width,
        height = height,
        htmlwidgets::sizingPolicy(viewer.suppress = TRUE,
                                  knitr.figure = FALSE,
                                  browser.fill = TRUE,
                                  browser.padding = 75,
                                  knitr.defaultWidth = 800,
                                  knitr.defaultHeight = 500),
        package = "networkD3"
    )
}

#' @rdname networkD3-shiny
#' @export
sankeyNetworkOutput <- function(outputId, width = "100%", height = "500px") {
    shinyWidgetOutput(outputId, "sankeyNetwork", width, height,
                      package = "networkD3")
}

#' @rdname networkD3-shiny
#' @export
renderSankeyNetwork <- function(expr, env = parent.frame(), quoted = FALSE) {
    if (!quoted) { expr <- substitute(expr) } # force quoted
    shinyRenderWidget(expr, sankeyNetworkOutput, env, quoted = TRUE)
}
