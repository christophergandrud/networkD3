
#' Shiny output bindings for networkD3 widgets
#' 
#' Functions used to include networkD3 widgets within Shiny applications.
#' 
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like
#'   \code{"100\%"}, \code{"400px"}, \code{"auto"}) or a number, which will be
#'   coerced to a string and have \code{"px"} appended.
#' @param expr An expression that generates a networkD3 visualization.
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name networkD3shiny
#' @export
simpleNetworkOutput <- htmlwidgets::makeShinyOutput("simpleNetwork", "networkD3")

#' @rdname networkD3shiny
#' @export
renderSimpleNetwork <- htmlwidgets::makeShinyRender(simpleNetworkOutput)


