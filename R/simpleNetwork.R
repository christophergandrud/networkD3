#' Function for creating simple D3 JavaScript force directed network graphs.
#'
#' \code{simpleNetwork} creates simple D3 JavaScript force directed network
#' graphs.
#'
#' @param Data a data frame object with three columns. The first two are the
#'   names of the linked units. The third records an edge value. (Currently the
#'   third column doesn't affect the graph.)
#' @param Source character string naming the network source variable in the data
#'   frame. If \code{Source = NULL} then the first column of the data frame is
#'   treated as the source.
#' @param Target character string naming the network target variable in the data
#'   frame. If \code{Target = NULL} then the second column of the data frame is
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
#' @param fontFamily font family for the node text labels.
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
#' @param zoom logical value to enable (\code{TRUE}) or disable (\code{FALSE})
#' zooming
#'
#' @examples
#' # Fake data
#' Source <- c("A", "A", "A", "A", "B", "B", "C", "C", "D")
#' Target <- c("B", "C", "D", "J", "E", "F", "G", "H", "I")
#' NetworkData <- data.frame(Source, Target)
#'
#' # Create graph
#' simpleNetwork(NetworkData)
#' simpleNetwork(NetworkData, fontFamily = "sans-serif")
#'
#' @source D3.js was created by Michael Bostock. See \url{http://d3js.org/} and,
#'   more specifically for directed networks
#'   \url{https://github.com/mbostock/d3/wiki/Force-Layout}
#'
#' @export
simpleNetwork <- function(Data,
                          Source = NULL,
                          Target = NULL,
                          height = NULL,
                          width = NULL,
                          linkDistance = 50,
                          charge = -200,
                          fontSize = 7,
                          fontFamily = "serif",
                          linkColour = "#666",
                          nodeColour = "#3182bd",
                          nodeClickColour = "#E34A33",
                          textColour = "#3182bd",
                          opacity = 0.6,
                          zoom = F)
{
  # validate input
    if (!is.data.frame(Data))
        stop("data must be a data frame class object.")

  # create links data
    if (is.null(Source) && is.null(Target))
        links <- Data[, 1:2]
    else if (!is.null(Source) && !is.null(Target))
        links <- data.frame(Data[, Source], Data[, Target])
    names(links) <- c("source", "target")

    # create options
    options = list(
        linkDistance = linkDistance,
        charge = charge,
        fontSize = fontSize,
        fontFamily = fontFamily,
        linkColour = linkColour,
        nodeColour = nodeColour,
        nodeClickColour = nodeClickColour,
        textColour = textColour,
        opacity = opacity,
        zoom = zoom
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

#' @rdname networkD3-shiny
#' @export
simpleNetworkOutput <- function(outputId, width = "100%", height = "500px") {
    shinyWidgetOutput(outputId, "simpleNetwork", width, height,
                        package = "networkD3")
}

#' @rdname networkD3-shiny
#' @export
renderSimpleNetwork <- function(expr, env = parent.frame(), quoted = FALSE) {
    if (!quoted) { expr <- substitute(expr) } # force quoted
    shinyRenderWidget(expr, simpleNetworkOutput, env, quoted = TRUE)
}
