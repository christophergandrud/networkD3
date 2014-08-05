
#' Internal function to add required attributes to widget definitions
#' 
#' @param x widget parameters
#' @param class widget class name
#' @return a widget definition with all required attributes
#' 
#' @keywords internal
#' @noRd
asWidget <- function(x, name) {
  structure(x, 
    class = c(name, "htmlwidget"),
    package = "networkD3",
    config = sprintf("www/widgets/%s/config.yaml", name),
    jsfile = sprintf("www/widgets/%s/widget.js", name)
  )
}

# TODO: htmltools pickup single js file rather than directory

# htmlwidgets
#  lib/
#  simpleNetwork.yaml
#  simpleNetwork.js
#  
# 
# createWidget <- function(name, 
#                          data,
#                          options,
#                          width = NULL,
#                          height = NULL,
#                          sizePolicy = sizePolicy(), 
#                          package = packageName(), 
#                          config = sprintf("htmlwidgets/%s.yaml", name), 
#                          jsfile = sprintf("htmlwidgets/%s.js", name)) {
#   
#   
#   
# }


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
