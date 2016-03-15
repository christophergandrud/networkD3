#' Create a D3 JavaScript hive plot representation of a network.
#' 
#' @TODO
#' 1. Think about bindings from data.frame to: axis and group
#' 2. Limit to ? axis?
#' 
#' @export
hiveNetwork <- function(Links,
                        Nodes,
                        Source = NULL,
                        Target = NULL,
                        NodeID = NULL,
                        Nodeaxis = NULL,
                        Nodesize = NULL,
                        Nodecolour = NULL,
                        Linksize = NULL,
                        Linkcolour = NULL,
                        height = NULL,
                        width = NULL)
{
  
  # some checks ----
  if (!is.data.frame(Links))
    stop("Links must be a data frame class object.")
  
  if (!is.data.frame(Nodes))
    stop("Nodes must be a data frame class object.")
  
  # if (missing(Value)) {
  #   LinksDF <- data.frame("source" = Links[, Source],
  #                         "target" = Links[, Target])
  # }
  # else if (!missing(Value)) {
  #   LinksDF <- data.frame("source" = Links[, Source], 
  #                         "target" = Links[, Target], 
  #                         "value" = Links[, Value])
  # }
  # 
  # if (!missing(Nodesize)) {
  #   NodesDF <- data.frame("name" = Nodes[, NodeID],
  #                         "group" = Nodes[, Group], 
  #                         "nodesize" = Nodes[, Nodesize])
  #   nodesize = TRUE
  # }else {
  #   NodesDF <- data.frame("name" = Nodes[, NodeID], 
  #                         "group" = Nodes[, Group])
  #   nodesize = FALSE
  # }
  
  NodesDF <- data.frame(Nodes, stringsAsFactors = F)
  LinksDF <- data.frame(Links, stringsAsFactors = F)

  # create options ----
  options = list(nlinks = nrow(LinksDF))
  
  # create widget
  htmlwidgets::createWidget(
    name = "hiveNetwork",
    x = list(links = LinksDF, nodes = NodesDF, options = options),
    width = width,
    height = height,
    htmlwidgets::sizingPolicy(padding = 10, browser.fill = TRUE),
    package = "networkD3"
  )
}

#' @rdname networkD3-shiny
#' @export
hiveNetworkOutput <- function(outputId, width = "100%", height = "500px") {
  shinyWidgetOutput(outputId, "hiveNetwork", width, height,
                    package = "networkD3")
}

#' @rdname networkD3-shiny
#' @export
renderHiveNetwork <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, forceNetworkOutput, env, quoted = TRUE)
}
