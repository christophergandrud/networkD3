#' Create Reingold-Tilford Tree network diagrams.
#'
#' @param List a hierarchical list object with a root node and children.
#' @param height height for the network graph's frame area in pixels (if
#'   \code{NULL} then height is automatically determined based on context)
#' @param width numeric width for the network graph's frame area in pixels (if
#'   \code{NULL} then width is automatically determined based on context)
#' @param fontSize numeric font size in pixels for the node text labels.
#' @param fontFamily font family for the node text labels.
#' @param linkColour character string specifying the colour you want the link
#' lines to be. Multiple formats supported (e.g. hexadecimal).
#' @param nodeColour character string specifying the colour you want the node
#' circles to be. Multiple formats supported (e.g. hexadecimal).
#' @param nodeStroke character string specifying the colour you want the node
#' perimeter to be. Multiple formats supported (e.g. hexadecimal).
#' @param textColour character string specifying the colour you want the text to
#' be before they are clicked. Multiple formats supported (e.g. hexadecimal).
#' @param opacity numeric value of the proportion opaque you would like the
#' graph elements to be.
#' @param margin integer value of the plot margin. Set the margin
#' appropriately to accomodate long text labels.
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
#' @source Reingold. E. M., and Tilford, J. S. (1981). Tidier Drawings of Trees.
#' IEEE Transactions on Software Engineering, SE-7(2), 223-228.
#'
#' Mike Bostock: \url{http://bl.ocks.org/mbostock/4063550}.
#'
#' @importFrom rjson toJSON
#' @export
#'
chordDiagram <- function(matrix,
                         width = 1000,
                         height = 1000,
                         title = "Chord Diagram",
                         initial_opacity = 0.8,
                         color_scale = c("#111", "#222", "#333", "#444", "#555"),
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
  
  if (!is.matrix(matrix) && !is.data.frame(matrix))
  {
    stop("Data must be of type matrix or data frame")
  }
  
  if (nrow(matrix) != ncol(matrix))
  {
    stop(paste("Data must have the same number of rows and columns; given ",
               nrow(matrix),
               "rows and",
               ncol(matrix),
               "columns",
               sep = " "))
  }
  
  if (is.data.frame(matrix))
  {
    matrix = data.matrix(matrix)
  }
  
  # create widget
  htmlwidgets::createWidget(
    name = "chordDiagram",
    x = list(matrix = matrix, options = options),
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
