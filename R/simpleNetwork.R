#' Function for creating simple D3 JavaScript force directed network graphs.
#' 
#' \code{simpleNetwork} creates simple D3 JavaScript force directed network 
#' graphs.
#' 
#' @param data a data frame object with three columns. The first two are the 
#'   names of the linked units. The third records an edge value. (Currently the 
#'   third column doesn't affect the graph.)
#' @param src character string naming the network source variable in the data
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
#' src <- c("A", "A", "A", "A", "B", "B", "C", "C", "D")
#' target <- c("B", "C", "D", "J", "E", "F", "G", "H", "I")
#' data <- data.frame(src, target)
#' 
#' # Create graph
#' simpleNetwork(data)
#' 
#' @source D3.js was created by Michael Bostock. See \url{http://d3js.org/} and,
#'   more specifically for directed networks 
#'   \url{https://github.com/mbostock/d3/wiki/Force-Layout}
#'   
#' @export
simpleNetwork <- function(data, 
                          src = NULL, 
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
  
  # create links data
  if (is.null(src) && is.null(target))
    links <- data[, 1:2]
  else if (!is.null(src) && !is.null(target))
    links <- data.frame(data[, src], data[, target])
  names(links) <- c("source", "target")
    
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
    x = list(links = links, options = options),
    width = width,
    height = height,
    htmlwidgets::sizingPolicy(padding = 0, browser.fill = TRUE),
    package = "networkD3"
  )
}


#' Output bindings for simpleNetwork
#' 
#' Bindings used to generate HTML (statically and within Shiny applications).
#' 
#' @param x Instance data associated with element
#' @param outputId Unique id of output element
#' @param class CSS class for output element
#' @param style Inline CSS styles for output element
#' @param width Output width. Must be a valid CSS unit (like "100%", "400px", 
#'   "auto") or a number, which will be coerced to a string and have "px" 
#'   appended.
#' @param height Output height (same semantics as \code{width}).
#' @param expr An expression that generates a simpleNetwork.
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name simpleNetworkOutputBindings
#' @export
widget_html.simpleNetwork  <- function(x, id, class, style, width, height) {  
  div(id = id,
      class = class,
      style = style)
  )
}

#' @rdname simpleNetworkOutputBindings
#' @export
simpleNetworkOutput <- htmlwidgets::makeShinyOutput("simpleNetwork", "networkD3")

#' @rdname simpleNetworkOutputBindings
#' @export
renderSimpleNetwork <- htmlwidgets::makeShinyRender(simpleNetworkOutput)









