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
#' @param nodeWidth numeric width of each node.
#' @param nodePadding numeric essentially influences the width height.
#' @param parentElement character string specifying the parent element for the
#' resulting svg network graph. This effectively allows the user to specify
#' where on the html page the graph will be placed. By default the parent
#' element is \code{body}.
#' @param standAlone logical, whether or not to return a complete HTML document
#' (with head and foot) or just the script.
#' @param file a character string of the file name to save the resulting graph.
#' If a file name is given a standalone webpage is created, i.e. with a header
#' and footer. If \code{file = NULL} then result is returned to the console.
#' @param iframe logical. If \code{iframe = TRUE} then the graph is saved to an
#' external file in the working directory and an HTML \code{iframe} linking to
#' the file is printed to the console. This is useful if you are using Slidify
#' and many other HTML slideshow framworks and want to include the graph in the
#' resulting page. If you set the knitr code chunk \code{results='asis'} then
#' the graph will be rendered in the output. Usually, you can use
#' \code{iframe = FALSE} if you are creating simple knitr Markdown or HTML
#' pages. Note: you do not need to specify the file name if
#' \code{iframe = TRUE}, however if you do, do not include the file path.
#' @param d3Script a character string that allows you to specify the location of
#' the d3.js script you would like to use. The default is
#' \url{http://d3js.org/d3.v3.min.js}.
#'
#' @examples
#' \dontrun{
#' # Recreate Bostock Sankey diagram: http://bost.ocks.org/mike/sankey/
#' # Load energy projection data
#' library(RCurl)
#' URL <- "https://raw.githubusercontent.com/christophergandrud/d3Network/sankey/JSONdata/energy.json"
#' Energy <- getURL(URL, ssl.verifypeer = FALSE)
#' # Convert to data frame
#' EngLinks <- JSONtoDF(jsonStr = Energy, array = "links")
#' EngNodes <- JSONtoDF(jsonStr = Energy, array = "nodes")
#'
#' # Plot
#' sankeyNetwork(Links = EngLinks, Nodes = EngNodes, Source = "source",
#'              Target = "target", Value = "value", NodeID = "name",
#               fontsize = 12, nodeWidth = 30)
#' }
#' @source
#' D3.js was created by Michael Bostock. See \url{http://d3js.org/} and, more specifically for Sankey diagrams \url{http://bost.ocks.org/mike/sankey/}.
#'
#' @export

sankeyNetwork <- function(Links, Nodes, Source, Target, Value, NodeID,
    height = 600, width = 900, fontsize = 7, nodeWidth = 15, nodePadding = 10)
{
    # Create iframe dimensions larger than graph dimensions
    FrameHeight <- height + height * 0.07
    FrameWidth <- width + width * 0.03

    # Subset data frames for network graph
    if (class(Links) != "data.frame"){
        stop("Links must be a data frame class object.")
    }
    if (class(Nodes) != "data.frame"){
        stop("Nodes must be a data frame class object.")
    }
    if (missing(Value)){
        LinksDF <- data.frame(Links[, Source], Links[, Target])
        names(LinksDF) <- c("source", "target")
    }
    else if (!missing(Value)){
        LinksDF <- data.frame(Links[, Source], Links[, Target], Links[, Value])
        names(LinksDF) <- c("source", "target", "value")
    }
    NodesDF <- data.frame(Nodes[, NodeID])
    names(NodesDF) <- c("name")

    # create options
    options = list(
        NodeID = NodeID,
        fontsize = fontsize,
        nodeWidth = nodeWidth,
        nodePadding = nodePadding
    )

    # create widget
    htmlwidgets::createWidget(
        name = "sankeyNetwork",
        x = list(links = LinksDF, nodes = NodesDF, options = options),
        width = width,
        height = height,
        htmlwidgets::sizingPolicy(padding = 0, browser.fill = TRUE),
        package = "networkD3"
    )

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
}
