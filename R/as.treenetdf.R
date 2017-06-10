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

as.treenetdf <- function(data, dftype = 'treenetdf', subset = names(data), cols = '', root = NULL) {
  if (inherits(data, 'hclust')) {
    data <- hclust_to_treenetdf(data)

  } else if (inherits(data, 'list')) {
    data <- nestedlist_to_treenetdf(data)

  } else if (inherits(data, 'Node')) {
    data <- Node_to_treenetdf(data)

  } else if (inherits(data, 'phylo')) {
    data <- phylo_to_treenetdf(data)

  } else if (inherits(data, 'tbl_graph')) {
    data <- tbl_graph_to_treenetdf(data)

  } else if (inherits(data, 'igraph')) {
    data <- igraph_to_treenetdf(data)

  } else if (inherits(data, 'data.frame')) {
    if (dftype == 'leafpathdf') {
      if (is.null(root)) {
        root <- all.names(substitute(data))
        if (length(root) > 1) { root <- root[2] }
      }
      data <- leafpathdf_to_treenetdf(data, subset = subset, root = root)
    }
  }

  # convert custom column names to native names
  cols <- cols[cols %in% names(data)]  # only use custom names that exist in data
  namestoswitch <- names(data) %in% cols
  names(data)[namestoswitch] <- names(cols)[match(names(data)[namestoswitch], cols)]

  data
}


#########################################################################
# hclust_to_treenetdf

hclust_to_treenetdf <- function(hc) {
  clustparents <-
    unlist(sapply(seq_along(hc$height), function(i) {
      parent <- which(i == hc$merge)
      parent <- ifelse(parent > nrow(hc$merge), parent - nrow(hc$merge), parent)
      as.integer(ifelse(length(parent) == 0, NA_integer_, parent))
    }))

  leaveparents <-
    unlist(sapply(seq_along(hc$labels), function(i) {
      parent <- which(i * -1 == hc$merge)
      parent <- ifelse(parent > nrow(hc$merge), parent - nrow(hc$merge), parent)
      as.integer(ifelse(length(parent) == 0, NA, parent))
    }))

  data.frame(
    nodeId = 1:(length(hc$height) + length(hc$labels)),
    parentId = c(clustparents, leaveparents),
    name = c(rep('', length(hc$height)), hc$labels),
    height = c(hc$height, rep(0, length(hc$labels)))
  )
}


#########################################################################
# nestedlist_to_treenetdf

nestedlist_to_treenetdf <- function(hrlist, children_name = 'children', node_name = 'name') {
  makelistofdfs <- function(hrlist) {
    children <- hrlist[[children_name]]
    children <-
      lapply(children, function(child) {
        if ('parentId' %in% names(hrlist)) {
          child$parentId <- paste0(hrlist$parentId, ':', hrlist[[node_name]])
        } else {
          child$parentId <- hrlist[[node_name]]
        }
        if ('nodeId' %in% names(hrlist)) {
          child$nodeId <- paste0(hrlist$nodeId, ':', child[[node_name]])
        } else {
          child$nodeId <- paste0(hrlist[[node_name]], ':', child[[node_name]])
        }
        return(child)
      })

    if (length(children) == 0)
      return(list(hrlist[names(hrlist)[!names(hrlist) %in% children_name]]))

    c(list(hrlist[names(hrlist)[!names(hrlist) %in% children_name]]),
      unlist(recursive = F, lapply(children, makelistofdfs)))
  }

  listoflists <- makelistofdfs(hrlist)
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
  df
}


#########################################################################
# leafpathdf_to_treenetdf

leafpathdf_to_treenetdf <- function(df, subset = names(df), root = NULL) {
  # get root name from name of passed data.frame, even if it was subset in the
  # argument, unless explicitly set
  if (is.null(root)) {
    root <- all.names(substitute(df))
    if (length(root) > 1) {
      root <- root[2]
    }
  }

  # subset the df by cols (default, same as it is)
  df <- df[, subset]

  # add a root col if necessary, otherwise reset root from the data
  if (length(unique(df[[1]])) != 1) {
    df <- data.frame(root, df, stringsAsFactors = F)
  } else {
    root <- unique(df[[1]])
  }

  nodelist <-
    c(setNames(root, root),
      unlist(
        sapply(2:ncol(df), function(i) {
          subdf <- unique(df[, 1:i])
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

  data.frame(nodeId = nodeId, parentId = parentId, name = name, stringsAsFactors = F)
}


#########################################################################
# Node_to_treenetdf

Node_to_treenetdf <- function(tree) {
  require(data.tree)
  df <- do.call(data.tree::ToDataFrameNetwork, c(tree, direction = 'descend', tree$fieldsAll))
  names(df)[1:2] <- c('nodeId', 'parentId')
  rootId <- unique(df$parentId[! df$parentId %in% df$nodeId])
  df <- rbind(c(nodeId = rootId, parentId = NA, rep(NA, ncol(df) - 2)), df)
  df$name <- df$nodeId
  df
}


#########################################################################
# phylo_to_treenetdf

phylo_to_treenetdf <- function(tree) {
  df <- data.frame(nodeId = tree$edge[, 2],
                   parentId = tree$edge[, 1],
                   name = tree$tip.label[tree$edge[, 2]],
                   depth = tree$edge.length,
                   stringsAsFactors = F)
  rootId <- unique(df$parentId[! df$parentId %in% df$nodeId])
  rbind(c(nodeId = rootId, parentId = NA, name = NA, depth = 1), df)
}


#########################################################################
# tbl_graph_to_treenetdf

tbl_graph_to_treenetdf <- function(graph) {
  igraph_to_treenetdf(graph)
}


#########################################################################
# igraph_to_treenetdf

igraph_to_treenetdf <- function(graph) {
  require(igraph)
  df <- igraph::as_data_frame(graph)
  names(df)[1:2] <- c('nodeId', 'parentId')
  rootId <- unique(df$parentId[! df$parentId %in% df$nodeId])
  if (length(rootId) > 1) {
    root <- Reduce(function(x, y) {
      rbind(x, c(nodeId = y, parentId = 'root', setNames(rep(NA, length(names(df)) - 2), names(df)[-(1:2)])))
    }, rootId, c(nodeId = 'root', parentId = NA, setNames(rep(NA, length(names(df)) - 2), names(df)[-(1:2)])))
    df <- rbind(root, df, stringsAsFactors = F, make.row.names = F)
    df$name <- df$nodeId
    df$name[1] <- NA
  } else {
    root <- c(nodeId = rootId, parentId = NA, rep(NA, ncol(df) - 2))
    df <- rbind(root, df, stringsAsFactors = F, make.row.names = F)
    df$name <- df$nodeId
  }
  df
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
