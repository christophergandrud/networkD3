#' Inform user that treeNetwork has been depricated.
#'
#' @param ... arguments to pass to function.
#'
#' @export

treeNetwork <- function(...) {
    stop('treeNetwork is deprecated. Please use either radialNetwork or diagonalNetwork.')
}
