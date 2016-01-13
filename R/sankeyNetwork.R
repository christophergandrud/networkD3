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
#' @param NodeID character string specifying the node IDs in the \code{Nodes}.
#' data frame. Must be 0-indexed.
#' @param NodeGroup character string specifying the node groups in the
#' \code{Nodes}. Used to color the nodes in the network.
#' @param LinkGroup character string specifying the groups in the
#' \code{Links}. Used to color the links in the network.
#' @param units character string describing physical units (if any) for Value
#' @param colourScale character string specifying the categorical colour
#' scale for the nodes. See
#' \url{https://github.com/mbostock/d3/wiki/Ordinal-Scales}.
#' @param fontSize numeric font size in pixels for the node text labels.
#' @param fontFamily font family for the node text labels.
#' @param nodeWidth numeric width of each node.
#' @param nodePadding numeric essentially influences the width height.
#' @param margin an integer or a named \code{list}/\code{vector} of integers
#' for the plot margins. If using a named \code{list}/\code{vector},
#' the positions \code{top}, \code{right}, \code{bottom}, \code{left}
#' are valid.  If a single integer is provided, then the value will be
#' assigned to the right margin. Set the margin appropriately
#' to accomodate long text labels.
#' @param height numeric height for the network graph's frame area in pixels.
#' @param width numeric width for the network graph's frame area in pixels.
#'
#' @examples
#' \dontrun{
#' # Recreate Bostock Sankey diagram: http://bost.ocks.org/mike/sankey/
#' # Load energy projection data
#' URL <- paste0('https://cdn.rawgit.com/christophergandrud/networkD3/',
#'               'master/JSONdata/energy.json')
#' energy <- jsonlite::fromJSON(URL)
#' # Plot
#' sankeyNetwork(Links = energy$links, Nodes = energy$nodes, Source = 'source',
#'              Target = 'target', Value = 'value', NodeID = 'name',
#'              units = 'TWh', fontSize = 12, nodeWidth = 30)
#'
#' # Colour links
#' energy$links$energy_type <- sub(' .*', '',
#'                                energy$nodes[energy$links$source + 1, 'name'])
#'
#' sankeyNetwork(Links = energy$links, Nodes = energy$nodes, Source = 'source',
#' Target = 'target', Value = 'value', NodeID = 'name',
#' LinkGroup = 'energy_type', NodeGroup = NULL)
#'
#' }
#' @source
#' D3.js was created by Michael Bostock. See \url{http://d3js.org/} and, more
#' specifically for Sankey diagrams \url{http://bost.ocks.org/mike/sankey/}.
#'
#' @seealso \code{\link{JS}}
#'
#' @export

sankeyNetwork <- function(Links, Nodes, Source, Target, Value, 
    NodeID, NodeGroup = NodeID, LinkGroup = NULL, units = "", 
    colourScale = JS("d3.scale.category20()"), fontSize = 7, 
    fontFamily = NULL, nodeWidth = 15, nodePadding = 10, margin = NULL, 
    height = NULL, width = NULL) {
    # Hack for UI consistency. Think of improving.
    colourScale <- as.character(colourScale)
    
    # Subset data frames for network graph
    if (!is.data.frame(Links)) {
        stop("Links must be a data frame class object.")
    }
    if (!is.data.frame(Nodes)) {
        stop("Nodes must be a data frame class object.")
    }
    # if Source or Target are missing assume Source is the first
    # column Target is the second column
    if (missing(Source)) 
        Source = 1
    if (missing(Target)) 
        Target = 2
    
    if (missing(Value)) {
        LinksDF <- data.frame(Links[, Source], Links[, Target])
        names(LinksDF) <- c("source", "target")
    } else if (!missing(Value)) {
        LinksDF <- data.frame(Links[, Source], Links[, Target], 
            Links[, Value])
        names(LinksDF) <- c("source", "target", "value")
    }
    
    # if NodeID is missing assume NodeID is the first column
    if (missing(NodeID)) 
        NodeID = 1
    NodesDF <- data.frame(Nodes[, NodeID])
    names(NodesDF) <- c("name")
    
    # add node group if specified
    if (is.character(NodeGroup)) {
        NodesDF$group <- Nodes[, NodeGroup]
    }
    
    if (is.character(LinkGroup)) {
        LinksDF$group <- Links[, LinkGroup]
    }
    
    margin <- margin_handler(margin)
    
    # create options
    options = list(NodeID = NodeID, NodeGroup = NodeGroup, LinkGroup = LinkGroup, 
        colourScale = colourScale, fontSize = fontSize, fontFamily = fontFamily, 
        nodeWidth = nodeWidth, nodePadding = nodePadding, units = units, 
        margin = margin)
    
    # create widget
    htmlwidgets::createWidget(name = "sankeyNetwork", x = list(links = LinksDF, 
        nodes = NodesDF, options = options), width = width, height = height, 
        htmlwidgets::sizingPolicy(padding = 10, browser.fill = TRUE), 
        package = "networkD3")
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
    if (!quoted) 
        {
            expr <- substitute(expr)
        }  # force quoted
    shinyRenderWidget(expr, sankeyNetworkOutput, env, quoted = TRUE)
}
