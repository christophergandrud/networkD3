#' Function for creating simple D3 JavaScript force directed network graphs.
#' 
#' \code{d3SimpleNetwork} creates simple D3 JavaScript force directed network 
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
#' d3SimpleNetwork(data, height = 300, width = 700)
#' 
#' @source D3.js was created by Michael Bostock. See \url{http://d3js.org/} and,
#'   more specifically for directed networks 
#'   \url{https://github.com/mbostock/d3/wiki/Force-Layout}
#'   
#' @export
d3SimpleNetwork <- function(data, 
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
    
  # define widget params
  params = list(
    links = linksJson, 
    options = list(height = height,
                   width = width,
                   linkDistance = linkDistance,
                   charge = charge,
                   fontSize = fontSize,
                   linkColour = linkColour,
                   nodeColour = nodeColour,
                   nodeClickColour = nodeClickColour,
                   textColour = textColour,
                   opacity = opacity),
    width = width,
    height = height,
    sizePolicy = htmlwidgets::sizePolicy(
      viewer.fill = TRUE, 
      knitr.figure = TRUE)
  )
  
  # return as a widget 
  asWidget(params, "d3SimpleNetwork")
}

#' @export
widget_html.d3SimpleNetwork  <- function(x, id, class, style, width, height) {
  
  # read and render widget css 
  linkColour <- x$options$linkColour
  opacity <- x$options$opacity
  fontSize <- x$options$fontSize
  css <-  readLines(system.file("www/widgets/d3SimpleNetwork/styles.css", 
                                package = "d3networks"))
  css <- whisker.render(css)
  
  # return style for head and svg tag for body
  htmltools::tagList(
    htmltools::singleton(tags$head(tags$style(css))),
    htmltools::tag('svg',
                   list(id = id,
                        class = class,
                        width = width, 
                        height = height))
  )
}


