#' Create a d3 bundle
#' @param data Json data to use for the bundle
#' @param width The width of the window to put the svg in; defaults to automatically expand to fit the svg
#' @param height The height of the window to put the svg in; defaults to automatically expand to fit the svg
#' @import htmlwidgets
#' @export
bundle <- function(data, width = NULL, height = NULL) {
  # create a list that contains the settings
  settings <- list(
  )
  
  # pass the data and settings using 'x'
  x <- list(
    data = data,
    settings = settings
  )

  # create the widget
  htmlwidgets::createWidget("bundle", x, width, height, 
                            sizingPolicy = htmlwidgets::sizingPolicy(browser.fill = TRUE, padding = 0))
}
#' Create a bundle output
#' @param outputId The ID that you will use in server.R to render to this output
#' @param width The width of the SVG
#' @param height The height of the SVG
#' @import htmlwidgets
#' @export
bundleOutput <- function(outputId, width = "100%", height = "1200px") {
  shinyWidgetOutput(outputId, "bundle", width = width, height = height, package = "networkD3")
}

#' Render a bundle
#' @param expr An expression that generates a bundle, probably using this package's bundle() method
#' @param env Environment to evaluate the code in.
#' @param quoted If we should force quoted or not.
#' @import htmlwidgets
#' @export
renderBundle <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, bundleOutput, env, quoted = TRUE)
}
