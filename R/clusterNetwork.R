#' Create hierarchical cluster network diagrams.
#'
#' @param hc a hierarchical (\code{hclust}) cluster object.
#' @param height height for the network graph's frame area in pixels
#' @param width numeric width for the network graph's frame area in pixels
#' @param fontSize numeric font size in pixels for the node text labels.
#' @param linkColour character string specifying the colour you want the link
#' lines to be. Multiple formats supported (e.g. hexadecimal).
#' @param nodeColour character string specifying the colour you want the node
#' circles to be. Multiple formats supported (e.g. hexadecimal).
#' @param nodeStroke character string specifying the colour you want the node
#' perimeter to be. Multiple formats supported (e.g. hexadecimal).
#' @param textColour character vector or scalar specifying the colour you want
#' the text to be before they are clicked. Order should match the order of
#' \code{hclust$labels}. Multiple formats supported (e.g. hexadecimal).
#' @param textOpacity numeric vector or scalar of the proportion opaque you
#' would like the text to be before they are clicked. rder should match the
#' order of \code{hclust$labels}.
#' @param textRotate numeric degress to rotate text for node text. Default
#' is 0 for horizontal and 65 degrees for vertical.
#' @param opacity numeric value of the proportion opaque you would like the
#' graph elements to be.
#' @param margins numeric value or named list of plot margins
#' (top, right, bottom, left). Set the margin appropriately to accomodate
#' long text labels.
#' @param linkType character specifying the link type between points. Options
#' are 'elbow' and 'diagonal'.
#' @param treeOrientation character specifying the tree orientation, Options
#' are 'vertical' and 'horizontal'.
#' @param zoom logical enabling plot zoom and pan.
#'
#'
#' @examples
#' \dontrun{
#' hc <- hclust(dist(USArrests), "ave")
#'
#' clusterNetwork(hc, height = 600)
#' clusterNetwork(hc, treeOrientation = "vertical")
#'
#' clusterNetwork(hc, height = 600, linkType = "diagonal")
#' clusterNetwork(hc, treeOrientation = "vertical", linkType = "diagonal")
#'
#' clusterNetwork(hc, textColour = c("red", "green", "orange")[cutree(hc, 3)],
#'                height = 600)
#' clusterNetwork(hc, textColour = c("red", "green", "orange")[cutree(hc, 3)],
#'                treeOrientation = "vertical")
#' }
#'
#' @source Mike Bostock: \url{http://bl.ocks.org/mbostock/4063570}.
#'
#' Fabio Nelli: \url{http://www.meccanismocomplesso.org/en/dendrogramma-d3-parte1/}
#'
#' @importFrom rjson toJSON
#' @export
#'
clusterNetwork <- function(
    hc,
    height = 500,
    width = 800,
    fontSize = 10,
    linkColour = "#ccc",
    nodeColour = "#fff",
    nodeStroke = "steelblue",
    textColour = "#111",
    textOpacity = 0.9,
    textRotate = NULL,
    opacity = 0.9,
    margins = NULL,
    linkType = c("elbow", "diagonal"),
    treeOrientation = c("horizontal", "vertical"),
    zoom = FALSE)
{
    # validate input
    if (length(textColour) == 1L)
    textColour = rep(textColour, length(hc$labels))
    if (length(textOpacity) == 1L)
    textOpacity = rep(textOpacity, length(hc$labels))

    linkType = match.arg(linkType[1], c("elbow", "diagonal"))
    treeOrientation = match.arg(treeOrientation[1], c("horizontal", "vertical"))

    root <- toJSON(as.clusterNetwork(hc, textColour, textOpacity))

    if (treeOrientation == "vertical")
    margins_def = list(top = 40, right = 40, bottom = 150, left = 40)
    else
    margins_def = list(top = 40, right = 150, bottom = 40, left = 40)
    if (length(margins) == 1L && is.numeric(margins)) {
    margins = as.list(setNames(rep(margins, 4),
                               c("top", "right", "bottom", "left")))
    } else if (is.null(margins)) {
    margins = margins_def
    } else {
    margins = modifyList(margins_def, margins)
    }

    if (is.null(textRotate))
    textRotate = ifelse(treeOrientation == "vertical", 65, 0)

    # create options
    options = list(
    height = height,
    width = width,
    fontSize = fontSize,
    linkColour = linkColour,
    nodeColour = nodeColour,
    nodeStroke = nodeStroke,
    textRotate = textRotate,
    margins = margins,
    opacity = opacity,
    linkType = linkType,
    treeOrientation = treeOrientation,
    zoom = zoom
    )

    # create widget
    htmlwidgets::createWidget(
        name = "clusterNetwork",
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
    clusterNetworkOutput <- function(outputId, width = "100%",
                                     height = "800px") {
    shinyWidgetOutput(outputId, "clusterNetwork", width, height,
                    package = "networkD3")
    }

    #' @rdname networkD3-shiny
    #' @export
    renderClusterNetwork <- function(expr, env = parent.frame(),
        quoted = FALSE) {
    if (!quoted) { expr <- substitute(expr) } # force quoted
        shinyRenderWidget(expr, clusterNetworkOutput, env, quoted = TRUE)
    }

    as.clusterNetwork <- function(hc, textColour, textOpacity)
    {
    if (!("hclust" %in% class(hc)))
        stop("hc must be a object of class hclust")

    if (length(textColour) != length(hc$labels))
        stop("textColour lenght must match label length")
    if (length(textOpacity) != length(hc$labels))
        stop("textOpacity lenght must match label length")

    ul <- function(lev)
    {
    child = lapply(1:2, function(i) {
        val <- abs(hc$merge[lev, ][i])
        if (hc$merge[lev, ][i] < 0)
            list(name = hc$labels[val], y = 0, textColour = textColour[val],
                 textOpacity = textOpacity[val])
        else
            ul(val)
    })
        list(name = "", y = hc$height[lev], children = child)
    }
    ul(nrow(hc$merge))
}
