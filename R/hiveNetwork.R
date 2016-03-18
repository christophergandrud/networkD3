#' Create a D3 JavaScript hive plot representation of a network.
#' 
#' @TODO
#' 1. Think about bindings from data.frame to: axis and group
#' 2. Limit to ? axis?
#' 
#' @export
hiveNetwork <- function(nodes,
                        links,
                        source = NULL,
                        target = NULL,
                        linksize = NULL,
                        linkcolour = NULL,
                        nodeID = NULL,
                        x = NULL,
                        y = NULL,
                        nodesize = NULL,
                        nodecolour = NULL,
                        height = NULL,
                        width = NULL)
{
  
  # some checks ----
  if (!is.data.frame(links))
    stop("Links must be a data frame class object.")
  
  if (!is.data.frame(nodes))
    stop("Nodes must be a data frame class object.")
  
  # helper - rescale attributes to play nice with axis
  .rescale <- function(x) (x - min(x))/(max(x) - min(x))
  
  # axis binding
  if (is.null(nodes$x)) {
    indeces <- 1:nrow(nodes) - 1
    indeces <- cbind( indeces %in% links$source & !indeces %in% links$target,
                      indeces %in% links$source &  indeces %in% links$target,
                     !indeces %in% links$source &  indeces %in% links$target)
    nodes$x <- apply(indeces, 1, which)
  }
  
  # radius binding
  nodes$y <- .rescale(nodes$y)
  
  # node size binding
  if (is.null(nodes$nodesize)) {
    nodes$nodesize <- 5
  }

  # node size binding
  if (is.null(nodes$nodecolour)) {
    nodes$nodecolour <- nodes$x
  }
  
  # link size binding
  if (is.null(links$linksize)) {
    links$linksize <- 0.5
  }
  
  # link colour binding
  if (is.null(links$linkcolour)) {
    links$linkcolour <- links$source
  }
  
  # create options ----
  options = list()
  
  # create widget
  htmlwidgets::createWidget(
    name = "hiveNetwork",
    x = list(links = links, nodes = nodes, options = options),
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
