#' Read a link-node structured JSON file into R as two data frames.
#' 
#' \code{JSONtoDF} reads a JSON data file into R and converts part of it to a 
#' data frame.
#'
#' @param jsonStr a JSON object to convert. Note if \code{jsonStr} is specified, 
#' then \code{file} must be \code{NULL}.
#' @param file character string of the JSON file name. Note if \code{file} is 
#' specified, then \code{jsonStr} must be \code{NULL}.
#' @param array character string specifying the name of the JSON array to 
#' extract. (JSON arrays are delimited by square brackets).
#'
#' @details \code{JSONtoDF} is intended to load JSON files into R and convert 
#' them to data frames that can be used to create network graphs. The command 
#' converts the files into R lists and then extracts the JSON array the user 
#' would like to make into a data frame.
#'
#' @source Part of the idea for the command comes from mropa's comment on 
#' StackExchange: 
#' \url{http://stackoverflow.com/questions/4227223/r-list-to-data-frame}.
#' 
#' @importFrom rjson fromJSON
#' @importFrom plyr ldply
#' @export

JSONtoDF <- function(jsonStr = NULL, file = NULL, array){
  if (!is.null(jsonStr) & !is.null(file)){
    stop("Must specify jsonStr OR file.")
  }
  if (is.null(file)){
    MainList <- fromJSON(json_str = jsonStr)
  }
  if (is.null(jsonStr)){
    MainList <- fromJSON(file = file)
  }
  ArrayList <- MainList[[array]]
  MainDF <- ldply(ArrayList, data.frame)
  return(MainDF)
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


#' Convert an R hclust or dendrogram object into a treeNetwork list.
#' 
#' \code{as.treeNetwork} converts an R hclust or dendrogram object into a list suitable
#' for use by the \code{treeNetwork} function.
#'
#' @param d An object of R class \code{hclust} or \code{dendrogram}.
#' @param root An optional name for the root node. If missing, use the first argument
#' variable name.
#'
#' @details \code{as.treeNetwork} coverts R objects of class \code{hclust} or
#' \code{dendrogram} into a list suitable for use with the \code{treeNetwork} function.
#'
#' @examples
#' # Create a hierarchical cluster object and display with treeNetwork
#' ## dontrun
#' hc <- hclust(dist(USArrests), "ave")
#' treeNetwork(as.treeNetwork(hc))
#' 
#' @export

as.treeNetwork <- function(d, root)
{
  if(missing(root)) root <- as.character(match.call()[[2]])
  if("hclust" %in% class(d)) d <- as.dendrogram(d)
  if(!("dendrogram" %in% class(d)))
    stop("d must be a object of class hclust or dendrogram")
  ul <- function(x, level=1)
  {
    if(is.list(x))
    {
      return(lapply(x, function(y)
                       {
                         name <- ""
                         if(!is.list(y)) name <- attr(y,"label")
                         list(name=name, children=ul(y,level+1))
                       }))
    }
    list(name=attr(x,"label"))
  }
  list(name=root,children=ul(d))
}
