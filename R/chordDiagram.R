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
#' #### Create tree from JSON formatted data
#' ## Download JSON data
#' library(RCurl)
#' # Create URL. paste0 used purely to keep within line width.
#' URL <- paste0("https://raw.githubusercontent.com/christophergandrud/",
#'               "networkD3/master/JSONdata/flare.json")
#' Flare <- getURL(URL)
#'
#' ## Convert to list format
#' Flare <- rjson::fromJSON(Flare)
#'
#' ## Recreate Bostock example from http://bl.ocks.org/mbostock/4063550
#' radialNetwork(List = Flare, fontSize = 10, opacity = 0.9)
#'
#' #### Create a tree dendrogram from an R hclust object
#' hc <- hclust(dist(USArrests), "ave")
#' radialNetwork(as.radialNetwork(hc))
#' radialNetwork(as.radialNetwork(hc), fontFamily = "cursive")
#'
#' #### Create tree from a hierarchical R list
#' For an alternative structure see: http://stackoverflow.com/a/30747323/1705044
#' CanadaPC <- list(name = "Canada", children = list(list(name = "Newfoundland",
#'                     children = list(list(name = "St. John's"))),
#'                list(name = "PEI",
#'                     children = list(list(name = "Charlottetown"))),
#'                list(name = "Nova Scotia",
#'                     children = list(list(name = "Halifax"))),
#'                list(name = "New Brunswick",
#'                     children = list(list(name = "Fredericton"))),
#'                list(name = "Quebec",
#'                     children = list(list(name = "Montreal"),
#'                                     list(name = "Quebec City"))),
#'                list(name = "Ontario",
#'                     children = list(list(name = "Toronto"),
#'                                     list(name = "Ottawa"))),
#'                list(name = "Manitoba",
#'                     children = list(list(name = "Winnipeg"))),
#'                list(name = "Saskatchewan",
#'                     children = list(list(name = "Regina"))),
#'                list(name = "Nunavuet",
#'                     children = list(list(name = "Iqaluit"))),
#'                list(name = "NWT",
#'                     children = list(list(name = "Yellowknife"))),
#'                list(name = "Alberta",
#'                     children = list(list(name = "Edmonton"))),
#'                list(name = "British Columbia",
#'                     children = list(list(name = "Victoria"),
#'                                     list(name = "Vancouver"))),
#'                list(name = "Yukon",
#'                     children = list(list(name = "Whitehorse")))
#' ))
#'
#' radialNetwork(List = CanadaPC, fontSize = 10)
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
                         color_scale = c("#1f77b4", 
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
                         font_size = 7,
                         font_family = "serif")
{ 
  options <- list(
    width = width,
    height = height,
    title = title,
    initial_opacity = initial_opacity,
    color_scale = color_scale,
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
                              knitr.defaultWidth = 800,
                              knitr.defaultHeight = 500),
    package = "networkD3")
}

#' @rdname networkD3-shiny
#' @export
chordDiagramOutput <- function(outputId, width = "100%", height = "500px") {
  shinyWidgetOutput(outputId, "chordDiagram", width, height,
                    package = "networkD3")
}

#' @rdname networkD3-shiny
#' @export
renderChordDiagram <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, chordDiagramOutput, env, quoted = TRUE)
}

