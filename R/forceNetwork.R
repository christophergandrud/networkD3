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
#' @param Nodesize character string specifying the a column in the \code{Nodes}
#' data frame with some value to vary the node radius's with. See also
#' \code{radiusCalculation}.
#' @param Group character string specifying the group of each node in the
#' \code{Nodes} data frame.
#' @param height numeric height for the network graph's frame area in pixels.
#' @param width numeric width for the network graph's frame area in pixels.
#' @param colourScale character string specifying the categorical colour
#' scale for the nodes. See
#' \url{https://github.com/mbostock/d3/wiki/Ordinal-Scales}.
#' @param fontSize numeric font size in pixels for the node text labels.
#' @param fontFamily font family for the node text labels.
#' @param linkDistance numeric or character string. Either numberic fixed
#' distance between the links in pixels (actually arbitrary relative to the
#' diagram's size). Or a JavaScript function, possibly to weight by
#' \code{Value}. For example:
#' \code{linkDistance = JS("function(d){return d.value * 10}")}.
#' @param linkWidth numeric or character string. Can be a numeric fixed width in
#' pixels (arbitrary relative to the diagram's size). Or a JavaScript function,
#' possibly to weight by \code{Value}. The default is
#' \code{linkWidth = JS("function(d) { return Math.sqrt(d.value); }")}.
#' @param radiusCalculation character string. A javascript mathematical
#' expression, to weight the radius by \code{Nodesize}. The default value is
#' \code{radiusCalculation = JS("Math.sqrt(d.nodesize)+6")}.
#' @param charge numeric value indicating either the strength of the node
#' repulsion (negative value) or attraction (positive value).
#' @param linkColour character vector specifying the colour(s) you want the link
#' lines to be. Multiple formats supported (e.g. hexadecimal).
#' @param opacity numeric value of the proportion opaque you would like the
#' graph elements to be.
#' @param zoom logical value to enable (\code{TRUE}) or disable (\code{FALSE})
#' zooming.
#' @param legend logical value to enable node colour legends.
#' @param bounded logical value to enable (\code{TRUE}) or disable
#' (\code{FALSE}) the bounding box limiting the graph's extent. See
#' \url{http://bl.ocks.org/mbostock/1129492}.
#' @param opacityNoHover numeric value of the opacity proportion for node labels
#' text when the mouse is not hovering over them.
#' @param clickAction character string with a JavaScript expression to evaluate
#' when a node is clicked.
#'
#' @examples
#' # Load data
#' data(MisLinks)
#' data(MisNodes)
#' # Create graph
#' forceNetwork(Links = MisLinks, Nodes = MisNodes, Source = "source",
#'              Target = "target", Value = "value", NodeID = "name",
#'              Group = "group", opacity = 0.4, zoom = TRUE)
#'
#' # Create graph with legend and varying node radius
#' forceNetwork(Links = MisLinks, Nodes = MisNodes, Source = "source",
#'              Target = "target", Value = "value", NodeID = "name",
#'              Nodesize = "size",
#'              radiusCalculation = "Math.sqrt(d.nodesize)+6",
#'              Group = "group", opacity = 0.4, legend = TRUE)
#'
#' \dontrun{
#' #### JSON Data Example
#' # Load data JSON formated data into two R data frames
#' # Create URL. paste0 used purely to keep within line width.
#' URL <- paste0("https://cdn.rawgit.com/christophergandrud/networkD3/",
#'               "master/JSONdata/miserables.json")
#'
#' MisJson <- jsonlite::fromJSON(URL)
#'
#' # Create graph
#' forceNetwork(Links = MisJson$links, Nodes = MisJson$nodes, Source = "source",
#'              Target = "target", Value = "value", NodeID = "name",
#'              Group = "group", opacity = 0.4)
#'
#' # Create graph with zooming
#' forceNetwork(Links = MisJson$links, Nodes = MisJson$nodes, Source = "source",
#'              Target = "target", Value = "value", NodeID = "name",
#'              Group = "group", opacity = 0.4, zoom = TRUE)
#'
#'
#' # Create a bounded graph
#' forceNetwork(Links = MisJson$links, Nodes = MisJson$nodes, Source = "source",
#'              Target = "target", Value = "value", NodeID = "name",
#'              Group = "group", opacity = 0.4, bounded = TRUE)
#'
#' # Create graph with node text faintly visible when no hovering
#' forceNetwork(Links = MisJson$links, Nodes = MisJson$nodes, Source = "source",
#'              Target = "target", Value = "value", NodeID = "name",
#'              Group = "group", opacity = 0.4, bounded = TRUE,
#'              opacityNoHover = TRUE)
#'
#' ## Specify colours for specific edges
#' # Find links to Valjean (11)
#' which(MisNodes == "Valjean", arr = TRUE)[1] - 1
#' ValjeanInds = which(MisLinks == 11, arr = TRUE)[, 1]
#'
#' # Create a colour vector
#' ValjeanCols = ifelse(1:nrow(MisLinks) %in% ValjeanInds, "#bf3eff", "#666")
#'
#' forceNetwork(Links = MisLinks, Nodes = MisNodes, Source = "source",
#'              Target = "target", Value = "value", NodeID = "name",
#'              Group = "group", opacity = 0.8, linkColour = ValjeanCols)
#'
#'
#' ## Create graph with alert pop-up when a node is clicked.  You're
#' # unlikely to want to do exactly this, but you might use
#' # Shiny.onInputChange() to allocate d.XXX to an element of input
#' # for use in a Shiny app.
#'
#' MyClickScript <- 'alert("You clicked " + d.name + " which is in row " +
#'        (d.index + 1) +  " of your original R data frame");'
#'
#' forceNetwork(Links = MisLinks, Nodes = MisNodes, Source = "source",
#'              Target = "target", Value = "value", NodeID = "name",
#'              Group = "group", opacity = 1, zoom = FALSE,
#'              bounded = TRUE, clickAction = MyClickScript)
#' }
#'

#' @source
#' D3.js was created by Michael Bostock. See \url{http://d3js.org/} and, more
#' specifically for force directed networks
#' \url{https://github.com/mbostock/d3/wiki/Force-Layout}.
#' @seealso \code{\link{JS}}.
#'
#' @export
forceNetwork <- function(Links,
                         Nodes,
                         Source,
                         Target,
                         Value,
                         NodeID,
                         Nodesize,
                         Group,
                         height = NULL,
                         width = NULL,
                         colourScale = JS("d3.scale.category20()"),
                         fontSize = 7,
                         fontFamily = "serif",
                         linkDistance = 50,
                         linkWidth = JS("function(d) { return Math.sqrt(d.value); }"),
                         radiusCalculation = JS(" Math.sqrt(d.nodesize)+6"),
                         charge = -120,
                         linkColour = "#666",
                         opacity = 0.6,
                         zoom = FALSE,
                         legend = FALSE,
                         bounded = FALSE,
                         opacityNoHover = 0,
                         clickAction = NULL)
{
        # Hack for UI consistency. Think of improving.
        colourScale <- as.character(colourScale)
        linkWidth <- as.character(linkWidth)
        radiusCalculation <- as.character(radiusCalculation)

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
        if (!missing(Nodesize)){
                NodesDF <- data.frame(Nodes[, NodeID], Nodes[, Group], Nodes[, Nodesize])
                names(NodesDF) <- c("name", "group", "nodesize")
                nodesize = TRUE
        }else{
                NodesDF <- data.frame(Nodes[, NodeID], Nodes[, Group])
                names(NodesDF) <- c("name", "group")
                nodesize = FALSE
        }
        LinksDF <- data.frame(LinksDF, colour=linkColour)
        LinksDF$colour = as.character(LinksDF$colour)

        # create options
        options = list(
                NodeID = NodeID,
                Group = Group,
                colourScale = colourScale,
                fontSize = fontSize,
                fontFamily = fontFamily,
                clickTextSize = fontSize * 2.5,
                linkDistance = linkDistance,
                linkWidth = linkWidth,
                charge = charge,
                # linkColour = linkColour,
                opacity = opacity,
                zoom = zoom,
                legend = legend,
                nodesize = nodesize,
                radiusCalculation = radiusCalculation,
                bounded = bounded,
                opacityNoHover = opacityNoHover,
                clickAction = clickAction
        )

        # create widget
        htmlwidgets::createWidget(
                name = "forceNetwork",
                x = list(links = LinksDF, nodes = NodesDF, options = options),
                width = width,
                height = height,
                htmlwidgets::sizingPolicy(padding = 10, browser.fill = TRUE),
                package = "networkD3"
        )
}

#' @rdname networkD3-shiny
#' @export
forceNetworkOutput <- function(outputId, width = "100%", height = "500px") {
        shinyWidgetOutput(outputId, "forceNetwork", width, height,
                          package = "networkD3")
}

#' @rdname networkD3-shiny
#' @export
renderForceNetwork <- function(expr, env = parent.frame(), quoted = FALSE) {
        if (!quoted) { expr <- substitute(expr) } # force quoted
        shinyRenderWidget(expr, forceNetworkOutput, env, quoted = TRUE)
}
