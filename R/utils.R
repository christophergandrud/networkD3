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
