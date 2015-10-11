#' Create Reingold-Tilford Tree network diagrams.
#'
#' @param Data A square matrix or data frame whose (n, m) entry represents
#'        the strength of the link from group n to group m
#' @param height height for the network graph's frame area in pixels (if
#'   \code{NULL} then height is automatically determined based on context)
#' @param width numeric width for the network graph's frame area in pixels (if
#'   \code{NULL} then width is automatically determined based on context)
#' @param initialOpacity specify the opacity before the user mouses over 
#'        the link
#' @param colourScale specify the hexadecimal colours in which to display
#'        the different categories. If there are fewer colours than categories,
#'        the last colour is repeated as necessary (if \code{NULL} then defaults
#'        to D3 colour scale)
#' @param padding specify the amount of space between adjacent categories
#'        on the outside of the graph
#' @param fontSize numeric font size in pixels for the node text labels.
#' @param fontFamily font family for the node text labels.
#' @param labels vector containing labels of the categories
#' @param useTicks integer number of ticks on the radial axis.
#'        The default is `0` which means no ticks will be drawn.
#' @param labelDistance integer distance in pixels (px) between
#'        text labels and outer radius.  The default is `30`.
#'
#'
#' @examples
#' \dontrun{
#' #### Data about hair colour preferences, from 
#' ## https://github.com/mbostock/d3/wiki/Chord-Layout
#' 
#' hairColourData <- matrix(c(11975,  1951,  8010, 1013,
#'                             5871, 10048, 16145,  990,
#'                             8916,  2060,  8090,  940,
#'                             2868,  6171,  8045, 6907),
#'                             nrow = 4)
#'                             
#' chordNetwork(Data = hairColourData, 
#'              width = 500, 
#'              height = 500,
#'              colourScale = c("#000000", 
#'                              "#FFDD89", 
#'                              "#957244", 
#'                              "#F26223"),
#'              labels = c("red", "brown", "blond", "gray"))
#' 
#' }
#'
#' @source 
#'
#' Mike Bostock: \url{https://github.com/mbostock/d3/wiki/Chord-Layout}.
#'
#' @export
#'
chordNetwork <- function(Data,
                         height = 500,
                         width = 500,
                         initialOpacity = 0.8,
                         useTicks = 0,
                         colourScale = c("#1f77b4", 
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
                         padding = 0.1,
                         fontSize = 14,
                         fontFamily = "sans-serif",
                         labels = c(),
                         labelDistance = 30)

{ 
  options <- list(
    width = width,
    height = height,
    use_ticks = useTicks,
    initial_opacity = initialOpacity,
    colour_scale = colourScale,
    padding = padding,
    font_size = fontSize,
    font_family = fontFamily,
    labels = labels,
    label_distance = labelDistance
  )
  
  if (!is.matrix(Data) && !is.data.frame(Data))
  {
    stop("Data must be of type matrix or data frame")
  }
  
  if (nrow(Data) != ncol(Data))
  {
    stop(paste("Data must have the same number of rows and columns; given ",
               nrow(Data),
               "rows and",
               ncol(Data),
               "columns",
               sep = " "))
  }
  
  if(length(labels)!=0 && length(labels)!=ncol(Data)){
    stop(paste("Length of labels vector should be the same as the number of rows"))
  }
  
  if (is.data.frame(Data))
  {
    Data = data.matrix(Data)
  }
  
  # create widget
  htmlwidgets::createWidget(
    name = "chordNetwork",
    x = list(matrix = Data, options = options),
    width = width,
    height = height,
    htmlwidgets::sizingPolicy(viewer.suppress = TRUE,
                              browser.fill = TRUE,
                              browser.padding = 75,
                              knitr.figure = FALSE,
                              knitr.defaultWidth = 500,
                              knitr.defaultHeight = 500),
    package = "networkD3")
}

#' @rdname networkD3-shiny
#' @export
chordNetworkOutput <- function(outputId, width = "100%", height = "500px") {
    shinyWidgetOutput(outputId, "chordNetwork", width, height, 
                      package = "networkD3")
}

#' @rdname networkD3-shiny
#' @export
renderchordNetwork <- function(expr, env = parent.frame(), quoted = FALSE) {
    if (!quoted) { expr <- substitute(expr) } # force quoted
    shinyRenderWidget(expr, chordNetworkOutput, env, quoted = TRUE)
}

