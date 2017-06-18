# convert one of many types to treeNetwork's native' treenetdf form:
# treenetdf (network) [nodeId|parentId] data.frame
# leafpathdf (table) [parent|parent|node] data.frame
# hierarchical nested list (JSON)
# hclust
# data.tree Node
# igraph
# ape phylo


#########################################################################
# as.treenetdf
#' @export
as.treenetdf <- function(data = NULL, ...) {
  UseMethod("as.treenetdf")
}

#########################################################################
# hclust_to_treenetdf
#' @export
as.treenetdf.hclust <- function(data, ...) {
  clustparents <-
    unlist(sapply(seq_along(data$height), function(i) {
      parent <- which(i == data$merge)
      parent <- ifelse(parent > nrow(data$merge), parent - nrow(data$merge), parent)
      as.integer(ifelse(length(parent) == 0, NA_integer_, parent))
    }))
  
  leaveparents <-
    unlist(sapply(seq_along(data$labels), function(i) {
      parent <- which(i * -1 == data$merge)
      parent <- ifelse(parent > nrow(data$merge), parent - nrow(data$merge), parent)
      as.integer(ifelse(length(parent) == 0, NA, parent))
    }))
  
  df <- 
    data.frame(
      nodeId = 1:(length(data$height) + length(data$labels)),
      parentId = c(clustparents, leaveparents),
      name = c(rep('', length(data$height)), data$labels),
      height = c(data$height, rep(0, length(data$labels)))
    )
  
  if (require('tibble')) { return(tibble::as.tibble(df)) }
  return(df)
}

#########################################################################
# nestedlist_to_treenetdf
#' @export
as.treenetdf.list <- function(data=NULL, children_name = 'children', node_name = 'name', ...) {
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
          child$nodeId <- paste0(data[[node_name]], ':', child[[node_name]])
        }
        return(child)
      })
    
    if (length(children) == 0)
      return(list(data[names(data)[!names(data) %in% children_name]]))
    
    c(list(data[names(data)[!names(data) %in% children_name]]),
      unlist(recursive = F, lapply(children, makelistofdfs)))
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
  
  if (require('tibble')) { return(tibble::as.tibble(df)) }
  return(df)
}


#########################################################################
# Node_to_treenetdf
#' @export
as.treenetdf.Node <-  function(data = NULL, ...) {
  require(data.tree)
  df <- do.call(data.tree::ToDataFrameNetwork, c(data, direction = 'descend', data$fieldsAll))
  names(df)[1:2] <- c('nodeId', 'parentId')
  rootId <- unique(df$parentId[! df$parentId %in% df$nodeId])
  df <- rbind(c(nodeId = rootId, parentId = NA, rep(NA, ncol(df) - 2)), df)
  df$name <- df$nodeId
  
  if (require('tibble')) { return(tibble::as.tibble(df)) }
  return(df)
}

#########################################################################
# phylo_to_treenetdf
#' @export
as.treenetdf.phylo <- function(data = NULL, ...) {
  df <- data.frame(nodeId = data$edge[, 2],
                   parentId = data$edge[, 1],
                   name = data$tip.label[data$edge[, 2]],
                   edge.length = data$edge.length,
                   depth = NA,
                   stringsAsFactors = F)
  
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
  df <- rbind(c(nodeId = rootId, parentId = NA, name = NA, edge.length = 0, depth = 0, height = max(df$depth)), df)
  
  if (require('tibble')) { return(tibble::as.tibble(df)) }
  return(df)
}



#########################################################################
# tbl_graph_to_treenetdf
#' @export
as.treenetdf.tbl_graph <- function(data = NULL, ...) {
  as.treenetdf.igraph(data)
}

#########################################################################
# igraph_to_treenetdf
#' @export
as.treenetdf.igraph <- function(data = NULL, root = 'root', ...) {
  require(igraph)
  df <- igraph::as_data_frame(data)
  names(df)[1:2] <- c('nodeId', 'parentId')
  rootId <- unique(df$parentId[! df$parentId %in% df$nodeId])
  if (length(rootId) > 1) {
    rootdf <- Reduce(function(x, y) {
      rbind(x, c(nodeId = y, parentId = root, setNames(rep(NA, length(names(df)) - 2), names(df)[-(1:2)])))
    }, rootId, c(nodeId = root, parentId = NA, setNames(rep(NA, length(names(df)) - 2), names(df)[-(1:2)])))
    df <- rbind(rootdf, df, stringsAsFactors = F, make.row.names = F)
    df$name <- df$nodeId
    df$name[1] <- NA
  } else {
    rootdf <- c(nodeId = rootId, parentId = NA, rep(NA, ncol(df) - 2))
    df <- rbind(rootdf, df, stringsAsFactors = F, make.row.names = F)
    df$name <- df$nodeId
  }
  
  if (require('tibble')) { return(tibble::as.tibble(df)) }
  return(df)
}


#########################################################################
# data.frame_to_treenetdf
#' @export
as.treenetdf.data.frame <- function(data = NULL, cols = setNames(names(data), names(data)), dftype = 'treenetdf', subset = names(data), root = NULL, ...) {
  if (dftype == 'treenetdf') {
    # convert custom column names to native names
    cols <- cols[cols %in% names(data)]  # only use custom names that exist in data
    namestoswitch <- names(data) %in% cols
    names(data)[namestoswitch] <- names(cols)[match(names(data)[namestoswitch], cols)]
    
    if (require('tibble')) { return(tibble::as.tibble(data)) }
    return(data)
    
  } else if (dftype == 'leafpathdf') {
    # get root name from name of passed data.frame, even if it was subset in the
    # argument, unless explicitly set
    if (is.null(root)) {
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
            sapply(1:nrow(subdf), function(i) setNames(paste(subdf[i, ], collapse = '::'), rev(subdf[i, ])[1]))
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
    
    if (require('tibble')) {
      return(tibble::tibble(nodeId = nodeId, parentId = parentId, name = name))
    }
    return(data.frame(nodeId = nodeId, parentId = parentId, name = name, stringsAsFactors = F))
  }
}



#########################################################################
# treenetdf_to_nestedlist

treenetdf_to_nestedlist <- function(df, id_col = 'nodeId', parent_col = 'parentId') {
  stopifnot(anyDuplicated(df[[id_col]]) == 0)  # no duplicate nodeId's
  stopifnot(!any(df[[id_col]] == df[[parent_col]], na.rm = T))  # no self-referential nodes
  stopifnot(all(na.exclude(df[[parent_col]]) %in% df[[id_col]]))  # no unidentified parent nodes

  if (sum(is.na(df[[parent_col]])) != 1) {  # mutliple roots or no root
    stop('mutliple or no roots')
    # potentially add a root to df and continue
  }

  rootid <- df[is.na(df[[parent_col]]), id_col]

  makelist <- function(nodeid) {
    i <- which(df[[id_col]] == nodeid)
    child_ids <- df[[id_col]][which(df[[parent_col]] == nodeid)]

    if (length(child_ids) == 0)
      return(as.list(df[i, ]))

    c(as.list(df[i, ]),
      children = list(lapply(child_ids, makelist)))
  }

  makelist(rootid)
}
