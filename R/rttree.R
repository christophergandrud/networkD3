#' Creates a D3 JavaScript Reingold-Tilford Tree network graph.
#'
#'
#' @param List a hierarchical list object with a root node and children.

#' @param height numeric height for the network graph's frame area in pixels.
#' @param width numeric width for the network graph's frame area in pixels.
#' @param fontSize numeric font size in pixels for the node text labels.
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
#' @param margin integer value of the radial plot margin
#'
#' 
#' @examples
#' ## Create tree from R list
#' # Create hierarchical list
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
#' # Create tree
#' d3Tree(List = CanadaPC, fontSize = 10, width=600, height=600)
#' 
#' ## Create tree from JSON formatted data
#' ## dontrun
#' ## Download JSON data
#' # library(RCurl)
#' # URL <- "https://raw.github.com/christophergandrud/d3Network/master/JSONdata/flare.json"
#' # Flare <- getURL(URL)
#' 
#' ## Convert to list format
#' # Flare <- rjson::fromJSON(Flare)
#' 
#' ## Recreate Bostock example from http://bl.ocks.org/mbostock/4063550
#' # d3Tree(List = Flare, file = "Flare.html", 
#' #        fontSize = 10, opacity = 0.9)
#' 
#' @source Reingold. E. M., and Tilford, J. S. (1981). Tidier Drawings of Trees. 
#' IEEE Transactions on Software Engineering, SE-7(2), 223-228.
#' 
#' Mike Bostock: \url{http://bl.ocks.org/mbostock/4063550}.
#' 
#' @importFrom rjson toJSON
#' @export
#' 
d3Tree <- function(
  List,
  height = 800,
  width = 800,
  fontSize = 10,
  linkColour = "#ccc",
  nodeColour = "#fff",
  nodeStroke = "steelblue",
  textColour = "#111",
  opacity = 0.9,
  margin = 120)
{
    # validate input
    if (!is.list(List))
      stop("List must be a list object.")
    root <- toJSON(List)

    # create options
    options = list(
        height = height,
        width = width,
        fontSize = fontSize,
        linkColour = linkColour,
        nodeColour = nodeColour,
        nodeStroke = nodeStroke,
        textColour = textColour,
        margin = margin,
        opacity = opacity
    )

    # create widget
    htmlwidgets::createWidget(
        name = "rttree",
        x = list(root = root, options = options),
        width = width,
        height = height,
        htmlwidgets::sizingPolicy(padding = 0, browser.fill = TRUE),
        package = "networkD3"
    )

}

#' @rdname networkD3-shiny
#' @export
d3TreeOutput <- function(outputId, width = "100%", height = "500px") {
    shinyWidgetOutput(outputId, "d3Tree", width, height,
                        package = "networkD3")
}

#' @rdname networkD3-shiny
#' @export
renderD3Tree <- function(expr, env = parent.frame(), quoted = FALSE) {
    if (!quoted) { expr <- substitute(expr) } # force quoted
    shinyRenderWidget(expr, d3TreeOutput, env, quoted = TRUE)
}
