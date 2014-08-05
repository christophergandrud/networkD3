#' Function for creating simple D3 JavaScript force directed network graphs.
#' 
#' \code{simpleNetwork} creates simple D3 JavaScript force directed network 
#' graphs.
#' 
#' @param data a data frame object with three columns. The first two are the 
#'   names of the linked units. The third records an edge value. (Currently the 
#'   third column doesn't affect the graph.)
#' @param source character string naming the network source variable in the data
#'   frame. If \code{source = NULL} then the first column of the data frame is 
#'   treated as the source.
#' @param target character string naming the network target variable in the data
#'   frame. If \code{target = NULL} then the second column of the data frame is 
#'   treated as the target.
#' @param height height for the network graph's frame area in pixels (if 
#'   \code{NULL} then height is automatically determined based on context)
#' @param width numeric width for the network graph's frame area in pixels (if
#'   \code{NULL} then width is automatically determined based on context)
#' @param linkDistance numeric distance between the links in pixels (actually 
#'   arbitrary relative to the diagram's size).
#' @param charge numeric value indicating either the strength of the node 
#'   repulsion (negative value) or attraction (positive value).
#' @param fontSize numeric font size in pixels for the node text labels.
#' @param linkColour character string specifying the colour you want the link 
#'   lines to be. Multiple formats supported (e.g. hexadecimal).
#' @param nodeColour character string specifying the colour you want the node 
#'   circles to be. Multiple formats supported (e.g. hexadecimal).
#' @param nodeClickColour character string specifying the colour you want the 
#'   node circles to be when they are clicked. Also changes the colour of the 
#'   text. Multiple formats supported (e.g. hexadecimal).
#' @param textColour character string specifying the colour you want the text to
#'   be before they are clicked. Multiple formats supported (e.g. hexadecimal).
#' @param opacity numeric value of the proportion opaque you would like the 
#'   graph elements to be.
#'   
#' @examples
#' # Fake data
#' source <- c("A", "A", "A", "A", "B", "B", "C", "C", "D")
#' target <- c("B", "C", "D", "J", "E", "F", "G", "H", "I")
#' data <- data.frame(source, target)
#' 
#' # Create graph
#' simpleNetwork(data, height = 300, width = 700)
#' 
#' @source D3.js was created by Michael Bostock. See \url{http://d3js.org/} and,
#'   more specifically for directed networks 
#'   \url{https://github.com/mbostock/d3/wiki/Force-Layout}
#'   
#' @export
simpleNetwork <- function(data, 
                          source = NULL, 
                          target = NULL, 
                          height = NULL,
                          width = NULL, 
                          linkDistance = 50, 
                          charge = -200,
                          fontSize = 7, 
                          linkColour = "#666", 
                          nodeColour = "#3182bd", 
                          nodeClickColour = "#E34A33",
                          textColour = "#3182bd", 
                          opacity = 0.6)
{
  # validate input
  if (!is.data.frame(data))
    stop("data must be a data frame class object.")
  
  # convert data to json
  if (is.null(source) && is.null(target))
    links <- data[, 1:2]
  else if (!is.null(source) && !is.null(target))
    links <- data.frame(data[, source], data[, target])
  names(links) <- c("source", "target")
  linksJson <- toJSONarray(links)
    
  # create options
  options = list(
    linkDistance = linkDistance,
    charge = charge,
    fontSize = fontSize,
    linkColour = linkColour,
    nodeColour = nodeColour,
    nodeClickColour = nodeClickColour,
    textColour = textColour,
    opacity = opacity
  )
  
  # create widget
  htmlwidgets::createWidget(
    name = "simpleNetwork",
    x = list(links = linksJson, options = options),
    width = width,
    height = height,
    htmlwidgets::sizingPolicy(padding = 0, browser.fill = TRUE),
    package = "networkD3",
  )
}

#' @export
widget_html.simpleNetwork  <- function(x, id, class, style, width, height) {
  simpleNetworkHTML(id, class, style, width, height)
}

# TODO: can the shiny output binding be made more compact/automatic
# (see gist from ramnath)

#' Shiny bindings for simpleNetwork
#' @export
simpleNetworkOutput <- function(id, width = "100%", height = 400) {
  
  div <- simpleNetworkHTML(
    id,
    class = "simpleNetwork",
    style = sprintf("width:%s;height:%s;", 
                    validateCssUnit(width), 
                    validateCssUnit(height)),
    width,
    height
  )
  
  deps <- htmlwidgets::getDependency("simpleNetwork", package = "networkD3")
  
  htmltools::attachDependencies(div, deps)
}

#' @export
#' @rdname simpleNetworkOutput
renderSimpleNetwork <- htmlwidgets::renderWidget


simpleNetworkHTML <- function(id, class, style, width, height) {
  
  # need to nest the svg element in a div because shiny can't 
  # do an addClass on an svg element
  div(id = id,
      class = class,
      style = style,
      tag('svg', list(width = width, height = height))
  )
}
  





