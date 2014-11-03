#' Create Reingold-Tilford Tree network graphs and linear dendrograms.
#'
#'
#' @param List a hierarchical list object with a root node and children.

#' @param height height for the network graph's frame area in pixels (if
#'   \code{NULL} then height is automatically determined based on context)
#' @param width numeric width for the network graph's frame area in pixels (if
#'   \code{NULL} then width is automatically determined based on context)
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
#' @param type either "dendrogram" for a traditional cluster dendrogram
#' or "radial" for a radial Reingold-Tilford network graph. Abbreviation is
#' allowed (argument matching is used).
#'
#' 
#' @examples
#' ## dontrun
#' ## Create a dendrogram from an R hclust object
#'  hc <- hclust(dist(USArrests), "ave")
#'  d3Tree(as.d3Tree(hc), type="dendrogram")
#'
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
#' d3Tree(List = CanadaPC, fontSize = 10)
#' 
#' ## Create tree from JSON formatted data
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
  height = NULL,
  width = NULL,
  fontSize = 10,
  linkColour = "#ccc",
  nodeColour = "#fff",
  nodeStroke = "steelblue",
  textColour = "#111",
  opacity = 0.9,
  margin = 120,
  type = c("radial","dendrogram"))
{
    # validate input
    if (!is.list(List))
      stop("List must be a list object.")
    root <- toJSON(List)
    type <- match.arg(type)

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
        opacity = opacity,
        type = type
    )

    # create widget
    if(type=="radial")
    {
      htmlwidgets::createWidget(
        name = "rttree",
        x = list(root = root, options = options),
        width = width,
        height = height,
        htmlwidgets::sizingPolicy(padding = 0, browser.fill = TRUE),
        package = "networkD3")
    } else {
      htmlwidgets::createWidget(
        name = "tree",
        x = list(root = root, options = options),
        width = width,
        height = height,
        htmlwidgets::sizingPolicy(padding = 0, browser.fill = TRUE),
        package = "networkD3")
    }

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
