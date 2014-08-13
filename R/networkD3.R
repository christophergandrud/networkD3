
#' Tools for creating D3 network graphs from R
#'
#' This packages is intended to make it easy to create D3 JavaScript
#' network, tree, dendrogram, and Sankey graphs from R using data frames.
#'
#' @name networkD3-package
#' @aliases networkD3
#' @docType package
NULL


#' Shiny bindings for networkD3 widgets
#' 
#' Output and render functions for using networkD3 widgets within Shiny 
#' applications and interactive Rmd documents.
#' 
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{"100\%"},
#'   \code{"400px"}, \code{"auto"}) or a number, which will be coerced to a
#'   string and have \code{"px"} appended.
#' @param expr An expression that generates a networkD3 graph
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This 
#'   is useful if you want to save an expression in a variable.
#'   
#' @importFrom htmlwidgets shinyWidgetOutput
#' @importFrom htmlwidgets shinyRenderWidget
#' 
#' @name networkD3-shiny
NULL

