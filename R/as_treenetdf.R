#' Convert one of numerous data types to treeNetwork's 'native' treenetdf form
#'
#' @param data a tree network description in one of numerous forms (see
#' details).
#' @param ... other arguments that will be passed on to as_treenetdf
#'
#' @description
#' The `treeNetwork` function uses a 'native' data format that consists of a data
#' frame with minimally 2 vectors/columns, one named `'nodeId'` and one named
#' `'parentId'`. Other columns in the data frame are also passed on to the
#' JavaScript code and attached to the elements in the D3 visualization so that
#' they can potentially be accessed by other JavaScript functions. This is an
#' advantageous format because:
#' - it's an easy to use and understand R-like format
#' - a hierarchical network can be succinctly defined by a list of each unique
#' node and its parent node
#' - since each row defines a unique node, additional columns can be added to
#' add node-specific properties
#' - in a hierarchical network, every link/edge can be uniquely identified by
#' the node which it leads to, therefore each link/edge can also be specifically
#' addressed by adding columns for formatting of the incoming link
#'
#' `as_treenetdf` can convert from any of the following data types:
#' - `leafpathdf` (table)--`parent|parent|node`--`data.frame`
#' - hierarchical nested list (JSON)
#' - `hclust`
#' - `data.tree` Node
#' - igraph
#' - ape `phylo`
#'
#' @examples 
#' links <- read.csv(header = TRUE, stringsAsFactors = FALSE, text = '
#'                    source,target,name
#'                    1,,one
#'                    2,1,two
#'                    3,1,three
#'                    4,1,four
#'                    5,2,five
#'                    6,2,six
#'                    7,2,seven
#'                    8,6,eight')
#'                    
#'  # Convert data
#'  as_treenetdf(links, cols = c(nodeId = 'source', parentId = 'target'))
#'  
#'  # Graph (calls as_treenetdf internally)
#'  treeNetwork(links, cols = c(nodeId = 'source', parentId = 'target'))
#'
#' @importFrom data.tree ToDataFrameNetwork
#' @importFrom igraph as_data_frame
#' @importFrom stats na.exclude
#' @importFrom stats setNames
#'
#' @md
#' @export
#'

as_treenetdf <- function(data = NULL, ...) {
    UseMethod("as_treenetdf")
}

#########################################################################
#' Convert hclust objects to \code{treenetdf}
#'
#' @inheritParams as_treenetdf
#' @param ... arguments to pass to methods.
#'
#' @export

as_treenetdf.hclust <- function(data, ...) {
    clustparents <-
        unlist(sapply(seq_along(data$height), function(i) {
            parent <- which(i == data$merge)
            parent <- ifelse(parent > nrow(data$merge),
                             parent - nrow(data$merge), parent)
            as.integer(ifelse(length(parent) == 0, NA_integer_, parent))
        }))

    leaveparents <-
        unlist(sapply(seq_along(data$labels), function(i) {
            parent <- which(i * -1 == data$merge)
            parent <- ifelse(parent > nrow(data$merge), parent -
                             nrow(data$merge), parent)
            as.integer(ifelse(length(parent) == 0, NA, parent))
        }))

    df <-
        data.frame(
            nodeId = 1:(length(data$height) + length(data$labels)),
            parentId = c(clustparents, leaveparents),
            name = c(rep('', length(data$height)), data$labels),
            height = c(data$height, rep(0, length(data$labels)))
        )

    if (pkg_installed('tibble')) return(tibble::as.tibble(df))
    return(df)
}

#########################################################################
#' Convert a nested list to \code{treenetdf}
#'
#' @inheritParams as_treenetdf
#' @param children_name character specifying the name used for the list element
#' that contains the childeren elements.
#' @param node_name character specifying the name used for the list element that
#' contains the name of the node
#' @param ... arguments to pass to methods.
#'
#' @export
as_treenetdf.list <- function(data, children_name = 'children',
                              node_name = 'name', ...) {
    makelistofdfs <- function(data) {
        children <- data[[children_name]]
        children <-
        lapply(children, function(child) {
            if ('parentId' %in% names(data)) {
                child$parentId <- paste0(data$parentId, ':', data[[node_name]])
            } else {
            child$parentId <- data[[node_name]]
            }
            if ('nodeId' %in% names(data)) {
                child$nodeId <- paste0(data$nodeId, ':', child[[node_name]])
            } else {
                child$nodeId <- paste0(data[[node_name]], ':',
                                       child[[node_name]])
            }
            return(child)
        })

        if (length(children) == 0)
            return(list(data[names(data)[!names(data) %in% children_name]]))

            c(list(data[names(data)[!names(data) %in% children_name]]),
            unlist(recursive = FALSE, lapply(children, makelistofdfs)))
    }

    listoflists <- makelistofdfs(data)
    col_names <- unique(unlist(sapply(listoflists, names)))
    matrix <-
        sapply(col_names, function(col_name) {
            unlist(
                sapply(listoflists, function(x) {
                    ifelse(col_name %in% names(x),
                        x[col_name],
                        list(col_name = NA))
                })
            )
    })

    df <- data.frame(matrix, stringsAsFactors = F)
    df$nodeId[is.na(df$nodeId)] <- df[[node_name]][is.na(df$nodeId)]

    if (pkg_installed('tibble')) return(tibble::as.tibble(df))
    return(df)
}


#########################################################################
#' data.tree to \code{treenetdf}
#'
#' @inheritParams as_treenetdf
#' @param ... arguments to pass to methods.
#'
# @importFrom data.tree ToDataFrameNetwork
#
#' @export
as_treenetdf.Node <-  function(data, ...) {
    df <- do.call(data.tree::ToDataFrameNetwork,
                  c(data, direction = 'descend', data$fieldsAll))
    names(df)[1:2] <- c('nodeId', 'parentId')
    rootId <- unique(df$parentId[! df$parentId %in% df$nodeId])
    df <- rbind(c(nodeId = rootId, parentId = NA, rep(NA, ncol(df) - 2)), df)
    df$name <- df$nodeId

    if (pkg_installed('tibble')) return(tibble::as.tibble(df))
    return(df)
}

#########################################################################
#' Phylo tree to \code{treenetdf}
#'
#' @inheritParams as_treenetdf
#' @param ... arguments to pass to methods.
#'
#' @export

as_treenetdf.phylo <- function(data, ...) {
    df <- data.frame(nodeId = data$edge[, 2],
                    parentId = data$edge[, 1],
                    name = data$tip.label[data$edge[, 2]],
                    edge.length = data$edge.length,
                    depth = NA,
                    stringsAsFactors = FALSE)

    rootId <- unique(df$parentId[! df$parentId %in% df$nodeId])

    calc_height <- function(parentId) {
        childIdxs <- df$parentId == parentId
        childIds <- df$nodeId[childIdxs]

        parentHeight <- df$depth[df$nodeId == parentId]
        if (length(parentHeight) == 0) { parentHeight <- 0 }
        df$depth[childIdxs] <<- df$edge.length[childIdxs] + parentHeight

        if (length(childIds) > 0) { lapply(childIds, calc_height) }
        invisible(df)
    }
    df <- calc_height(rootId)

    df$height <- max(df$depth) - df$depth
    df <- rbind(c(nodeId = rootId, parentId = NA, name = NA, edge.length = 0,
                depth = 0, height = max(df$depth)), df)

    if (pkg_installed('tibble')) return(tibble::as.tibble(df))
    return(df)
}

#########################################################################
#' tbl_graph_to_treenetdf
#'
#' @inheritParams as_treenetdf
#' @param ... arguments to pass to methods.
#'
#' @export

as_treenetdf.tbl_graph <- function(data, ...) {
    as_treenetdf.igraph(data)
}

#########################################################################
#' Convert igraph tree to \code{treenetdf}
#'
#' @inheritParams as_treenetdf
#' @param root character specifying the string that should be used to name the
#' root node
#' @param ... arguments to pass to methods.
#'
#' @importFrom igraph as_data_frame
#'
#' @export
as_treenetdf.igraph <- function(data, root = 'root', ...) {
    df <- igraph::as_data_frame(data)
    names(df)[1:2] <- c('nodeId', 'parentId')
    rootId <- unique(df$parentId[! df$parentId %in% df$nodeId])
    if (length(rootId) > 1) {
        rootdf <- Reduce(function(x, y) {
            rbind(x, c(nodeId = y, parentId = root,
                 setNames(rep(NA, length(names(df)) - 2), names(df)[-(1:2)])))
        }, rootId, c(nodeId = root, parentId = NA,
                     setNames(rep(NA, length(names(df)) - 2),
                             names(df)[-(1:2)])))
        df <- rbind(rootdf, df, stringsAsFactors = F, make.row.names = FALSE)
        df$name <- df$nodeId
        df$name[1] <- NA
    } else {
        rootdf <- c(nodeId = rootId, parentId = NA, rep(NA, ncol(df) - 2))
        df <- rbind(rootdf, df, stringsAsFactors = F, make.row.names = FALSE)
        df$name <- df$nodeId
    }

    if (pkg_installed('tibble')) { return(tibble::as.tibble(df)) }
    return(df)
}


#########################################################################
#' Convert a data.frame to a \code{treenetdf}
#'
#' @inheritParams as_treenetdf
#' @param cols named character vector specifying the names of columns to be
#' converted to the standard \code{treenetdf} names.
#' @param df_type character specifying which type of data frame to convert. Can
#' be \code{treenetdf} or
#' \code{leafpathdf}.
#' @param subset character vector specifying the names of the columns (in order)
#' that should be used to define the hierarchy.
#' @param root root name.
#' @param ... arguments to pass to methods.
#'
#' @importFrom stats na.omit
#'
#' @export

as_treenetdf.data.frame <- function(data,
                                    cols = setNames(names(data), names(data)),
                                    df_type = 'treenetdf', subset = names(data),
                                    root, ...) {
    if (df_type == 'treenetdf') {
      # convert custom column names to native names
      cols <- cols[cols %in% names(data)]  # only use custom names that exist in data
      namestoswitch <- names(data) %in% cols
      names(data)[namestoswitch] <- names(cols)[match(names(data)[namestoswitch],
                                                    cols)]

    if (nrow(na.omit(data[-1, ])) < nrow(data[-1, ])) # assumes root is in first row
        warning("Missing values found in data. May cause graph to fail.",
                call. = FALSE)

      if (pkg_installed('tibble')) return(tibble::as.tibble(data))
      return(data)

    } else if (df_type == 'leafpathdf') {
        # get root name from name of passed data.frame, even if it was subset in the
        # argument, unless explicitly set
        if (missing(root)) {
            root <- all.names(substitute(data))
        if (length(root) > 1) {
            root <- root[2]
        }
    }

    # subset the data by cols (default, same as it is)
    data <- data[, subset]

    # add a root col if necessary, otherwise reset root from the data
    if (length(unique(data[[1]])) != 1) {
        data <- data.frame(root, data, stringsAsFactors = F)
    } else {
        root <- unique(data[[1]])
    }

    nodelist <-
        c(setNames(root, root),
            unlist(
                sapply(2:ncol(data), function(i) {
                    subdf <- unique(data[, 1:i])
                    sapply(1:nrow(subdf), function(i)
                    setNames(paste(subdf[i, ], collapse = '::'),
                             rev(subdf[i, ])[1]))
                })
            )
        )

    nodeId <- seq_along(nodelist)
    name <- names(nodelist)
    parentId <-
        c(NA_integer_,
            match(
                sapply(nodelist[-1], function(x) {
                    elms <- strsplit(x, '::')[[1]]
                    paste(elms[1:max(length(elms) - 1)], collapse = '::')
                }),
              nodelist
          )
    )

    if (pkg_installed('tibble'))
        return(tibble::tibble(nodeId = nodeId, parentId = parentId,
                              name = name))
    return(data.frame(nodeId = nodeId, parentId = parentId, name = name,
                      stringsAsFactors = F))
    }
}
