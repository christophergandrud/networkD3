#' Create character strings that will be evaluated as JavaScript
#'
#' @param ... character string to evaluate
#'
#' @source A direct import of \code{JS} from Ramnath Vaidyanathan, Yihui Xie,
#' JJ Allaire, Joe Cheng and Kenton Russell (2015). \link{htmlwidgets}: HTML
#' Widgets for R. R package version 0.4.
#'
#' @export

JS <- function (...)
{
    x <- c(...)
    if (is.null(x))
        return()
    if (!is.character(x))
        stop("The arguments for JS() must be a chraracter vector")
    x <- paste(x, collapse = "\n")
    structure(x, class = unique(c("JS_EVAL", oldClass(x))))
}



#' Internal function from Wei Luo to convert a data frame to a JSON array
#'
#' @param dtf a data frame object.
#' @source Function from:
#' \url{http://theweiluo.wordpress.com/2011/09/30/r-to-json-for-d3-js-and-protovis/}
#' @keywords internal
#' @noRd
toJSONarray <- function(dtf){
  clnms <- colnames(dtf)

  name.value <- function(i){
    quote <- '';
    if(class(dtf[, i])!='numeric' && class(dtf[, i])!='integer'){
      quote <- '"';
    }
    paste('"', i, '" : ', quote, dtf[,i], quote, sep='')
  }
  objs <- apply(sapply(clnms, name.value), 1, function(x){paste(x,
                                                          collapse=', ')})
  objs <- paste('{', objs, '}')

  res <- paste('[', paste(objs, collapse=', '), ']')

  return(res)
}


#' Read a text file into a single string
#'
#' @source Code taken directly from Ramnath Vaidyanathan's Slidify
#' \url{https://github.com/ramnathv/slidify}.
#' @param doc path to text document
#' @return string with document contents
#' @keywords internal
#' @noRd
read_file <- function(doc, ...){
  paste(readLines(doc, ...), collapse = '\n')
}


#' Utility function to handle margins
#' @param margin an \code{integer}, a named \code{vector} of integers,
#'    or a named \code{list} of integers specifying the margins
#'    (top, right, bottom, and left)
#'    in \code{px}/\code{pixels} for our htmlwidget.  If only a single
#'    \code{integer} is provided, then the value will be assumed to be
#'    the \code{right} margin.
#' @return named \code{list} with top, right, bottom, left margins
#' @noRd
margin_handler <- function(margin){
  # margin can be either a single value or a list with any of
  #    top, right, bottom, left
  # if margin is a single value, then we will stick
  #    with the original behavior of networkD3 and use it for the right margin
  if(!is.null(margin) && length(margin) == 1 && is.null(names(margin))){
    margin <- list(
      top = NULL,
      right = margin,
      bottom = NULL,
      left = NULL
    )
  } else if(!is.null(margin)){
    # if margin is a named vector then convert to list
    if(!is.list(margin) && !is.null(names(margin))){
      margin <- as.list(margin)
    }
    # if we are here then margin should be a list and
    #   we will use the values supplied with NULL as default
    margin <- modifyList(
      list(top = NULL, right = NULL, bottom = NULL, left = NULL),
      margin
    )
  } else {
    # if margin is null, then make it a list of nulls for each position
    margin <- list(top = NULL, right = NULL, bottom = NULL, left = NULL)
  }
}


#' Function to convert igraph graph to a list suitable for networkD3
#'
#' @param g an \code{igraph} class graph object
#' @param group an object that contains node group values, for example, those
#' created with igraph's \code{\link{membership}} function.
#' @param what a character string specifying what to return. If
#' \code{what = 'links'} or \code{what = 'nodes'} only the links or nodes are
#' returned as data frames, respectively. If \code{what = 'both'} then both
#' data frames will be return in a list.
#'
#' @return A list of link and node data frames or only the link or node data
#' frames.
#'
#' @examples
#' # Load igraph
#' library(igraph)
#' 
#' # Use igraph to make the graph and find membership
#' karate <- make_graph("Zachary")
#' wc <- cluster_walktrap(karate)
#' members <- membership(wc)
#' 
#' # Convert to object suitable for networkD3
#' karate_d3 <- igraph_to_networkD3(karate, group = members)
#' 
#' # Create force directed network plot
#' forceNetwork(Links = karate_d3$links, Nodes = karate_d3$nodes, 
#'              Source = 'source', Target = 'target', NodeID = 'name', 
#'              Group = 'group')
#' 
#' \dontrun{
#' # Example with data from data frame
#' # Load data
#' ## Original data from http://results.ref.ac.uk/DownloadSubmissions/ByUoa/21
#' data('SchoolsJournals')
#'
#' # Convert to igraph
#' SchoolsJournals <- graph.data.frame(SchoolsJournals, directed = FALSE)
#'
#' # Remove duplicate edges
#' SchoolsJournals <- simplify(SchoolsJournals)
#'
#' # Find group membership
#' wt <- cluster_walktrap(SchoolsJournals, steps = 6)
#' members <- membership(wt)
#'
#' # Convert igraph to list for networkD3
#' sj_list <- igraph_to_networkD3(SchoolsJournals, group = members)
#'
#' # Plot as a forceDirected Network
#' forceNetwork(Links = sj_list$links, Nodes = sj_list$nodes, Source = 'source',
#'              Target = 'target', NodeID = 'name', Group = 'group',
#'              zoom = TRUE, linkDistance = 200)
#' }
#'
#' @importFrom igraph V as_data_frame graph.data.frame simplify cluster_walktrap membership
#' @importFrom magrittr %>%
#' @export

igraph_to_networkD3 <- function(g, group, what = 'both') {
    # Sanity check
    if (!('igraph' %in% class(g))) stop('g must be an igraph class object.',
                                      call. = FALSE)
    if (!(what %in% c('both', 'links', 'nodes'))) stop('what must be either "nodes", "links", or "both".',
                                                     call. = FALSE)

    # Extract vertices (nodes)
    temp_nodes <- V(g) %>% as.matrix %>% data.frame
    temp_nodes$name <- row.names(temp_nodes)
    names(temp_nodes) <- c('id', 'name')

    # Convert to base 0 (for JavaScript)
    temp_nodes$id <- temp_nodes$id - 1

    # Nodes for output
    nodes <- temp_nodes$name %>% data.frame %>% setNames('name')
    # Include grouping variable if applicable
    if (!missing(group)) {
      group <- as.matrix(group)
      if (nrow(nodes) != nrow(group)) stop('group must have the same number of rows as the number of nodes in g.',
                                          call. = FALSE)
      nodes <- cbind(nodes, group)
    }
    row.names(nodes) <- NULL

    # Convert links from names to numbers
    links <- as_data_frame(g, what = 'edges')
    links <- merge(links, temp_nodes, by.x = 'from', by.y = 'name')
    links <- merge(links, temp_nodes, by.x = 'to', by.y = 'name')
    links <- links[, c('id.x', 'id.y')] %>% setNames(c('source', 'target'))

    # Output requested object
    if (what == 'both') {
      return(list(links = links, nodes = nodes))
    }
    else if (what == 'links') {
      return(links)
    }
    else if (what == 'nodes') {
      return(nodes)
    }
}
