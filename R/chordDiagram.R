#' Create Reingold-Tilford Tree network diagrams.
#'
#' @param Data A square matrix or data frame whose (n, m) entry represents
#'        the strength of the link from group n to group m
#' @param height height for the network graph's frame area in pixels (if
#'   \code{NULL} then height is automatically determined based on context)
#' @param width numeric width for the network graph's frame area in pixels (if
#'   \code{NULL} then width is automatically determined based on context)
#' @param initial_opacity specify the opacity before the user mouses over 
#'        the link
#' @param color_scale specify the hexadecimal colors in which to display
#'        the different categories. If there are fewer colors than categories,
#'        the last color is repeated as necessary (if \code{NULL} then defaults
#'        to D3 color scale)
#' @param padding specify the amount of space between adjacent categories
#'        on the outside of the graph
#' @param fontSize numeric font size in pixels for the node text labels.
#' @param fontFamily font family for the node text labels.
#'
#'
#' @examples
#' \dontrun{
#' #### Data about hair color preferences, from 
#' ## https://github.com/mbostock/d3/wiki/Chord-Layout
#' 
#' hairColourData <- matrix(c(11975,  1951,  8010, 1013,
#'                             5871, 10048, 16145,  990,
#'                             8916,  2060,  8090,  940,
#'                             2868,  6171,  8045, 6907),
#'                             nrow = 4)
#'                             
#' chordDiagram(data = hairColourData, 
#'              width = 500, 
#'              height = 500,
#'              color_scale = c("#000000", 
#'                              "#FFDD89", 
#'                              "#957244", 
#'                              "#F26223"))
#' 
#' }
#'
#' @source 
#'
#' Mike Bostock: \url{https://github.com/mbostock/d3/wiki/Chord-Layout}.
#'
#' @export
#'
chordDiagram <- function(data,
                         height = 1000,
                         width = 1000,
                         initial_opacity = 0.8,
                         colour_scale = c("#1f77b4", 
                                         "#aec7e8", 
                                         "#ff7f0e", 
                                         "#ffbb78", 
                                         "#2ca02c", 
                                         "#98df8a", 
                                         "#d62728", 
                                         "#ff9896", 
                                         "#9467bd", 
                                         "#c5b0d5", 
                                         "#8c564b", 
                                         "#c49c94", 
                                         "#e377c2", 
                                         "#f7b6d2", 
                                         "#7f7f7f", 
                                         "#c7c7c7", 
                                         "#bcbd22", 
                                         "#dbdb8d", 
                                         "#17becf", 
                                         "#9edae5"),
                         padding = 0.05,
                         font_size = 15,
                         font_family = "serif")
{ 
  options <- list(
    width = width,
    height = height,
    title = title,
    initial_opacity = initial_opacity,
    colour_scale = colour_scale,
    padding = padding,
    font_size = font_size,
    font_family = font_family
  )
  
  if (!is.matrix(data) && !is.data.frame(data))
  {
    stop("Data must be of type matrix or data frame")
  }
  
  if (nrow(data) != ncol(data))
  {
    stop(paste("Data must have the same number of rows and columns; given ",
               nrow(data),
               "rows and",
               ncol(data),
               "columns",
               sep = " "))
  }
  
  if (is.data.frame(data))
  {
    data = data.matrix(data)
  }
  
  # create widget
  htmlwidgets::createWidget(
    name = "chordDiagram",
    x = list(matrix = data, options = options),
    width = width,
    height = height,
    htmlwidgets::sizingPolicy(viewer.suppress = TRUE,
                              browser.fill = TRUE,
                              browser.padding = 75,
                              knitr.figure = FALSE,
                              knitr.defaultWidth = 500,
                              knitr.defaultHeight = 800),
    package = "networkD3")
}

#' @rdname networkD3-shiny
#' @export
chordDiagramOutput <- function(outputId, width = "100%", height = "500px") {
  shinyWidgetOutput(outputId, "chordDiagram", width, height, package = "networkD3")
}

#' @rdname networkD3-shiny
#' @export
renderChordDiagram <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, chordDiagramOutput, env, quoted = TRUE)
}

