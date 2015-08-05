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
radialNetwork <- function(
                          List,
                          height = NULL,
                          width = NULL,
                          fontSize = 10,
                          fontFamily = "serif",
                          linkColour = "#ccc",
                          nodeColour = "#fff",
                          nodeStroke = "steelblue",
                          textColour = "#111",
                          opacity = 0.9,
                          margin = 0)
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
        fontFamily = fontFamily,
        linkColour = linkColour,
        nodeColour = nodeColour,
        nodeStroke = nodeStroke,
        textColour = textColour,
        margin = margin,
        opacity = opacity
    )

    # create widget
    htmlwidgets::createWidget(
      name = "radialNetwork",
      x = list(root = root, options = options),
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
radialNetworkOutput <- function(outputId, width = "100%", height = "800px") {
    shinyWidgetOutput(outputId, "radialNetwork", width, height,
                        package = "networkD3")
}

#' @rdname networkD3-shiny
#' @export
renderRadialNetwork <- function(expr, env = parent.frame(), quoted = FALSE) {
    if (!quoted) { expr <- substitute(expr) } # force quoted
    shinyRenderWidget(expr, radialNetworkOutput, env, quoted = TRUE)
}

#' Convert an R hclust or dendrogram object into a radialNetwork list.
#'
#' \code{as.radialNetwork} converts an R hclust or dendrogram object into a list
#' suitable for use by the \code{radialNetwork} function.
#'
#' @param d An object of R class \code{hclust} or \code{dendrogram}.
#' @param root An optional name for the root node. If missing, use the first
#' argument variable name.
#'
#' @details \code{as.radialNetwork} coverts R objects of class \code{hclust} or
#' \code{dendrogram} into a list suitable for use with the \code{radialNetwork}
#' function.
#' @examples
#' # Create a hierarchical cluster object and display with radialNetwork
#' ## dontrun
#' hc <- hclust(dist(USArrests), "ave")
#' radialNetwork(as.radialNetwork(hc))
#'
#' @importFrom stats as.dendrogram
#'
#' @export

as.radialNetwork <- function(d, root)
{
    if(missing(root)) root <- as.character(match.call()[[2]])
    if("hclust" %in% class(d)) d <- as.dendrogram(d)
    if(!("dendrogram" %in% class(d)))
        stop("d must be a object of class hclust or dendrogram")
    ul <- function(x, level = 1) {
        if(is.list(x)) {
            return(lapply(x, function(y)
        {
        name <- ""
        if(!is.list(y)) name <- attr(y, "label")
            list(name=name, children=ul(y, level + 1))
        }))
    }
    list(name = attr(x,"label"))
    }
    list(name = root, children = ul(d))
}
