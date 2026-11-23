library(networkD3)

links <- data.frame(from = c(1L, 2L), to = c(2L, 3L), value = c(1, 2))
nodes <- data.frame(name = c("A", "B", "C"), group = c("x", "x", "y"))

index_warning <- function(expr) {
    warned <- FALSE
    widget <- withCallingHandlers(expr, warning = function(w) {
        if (grepl("not zero-indexed", conditionMessage(w), fixed = TRUE)) {
            warned <<- TRUE
            invokeRestart("muffleWarning")
        }
    })
    stopifnot(inherits(widget, "htmlwidget"))
    warned
}

stopifnot(index_warning(sankeyNetwork(links, nodes, Value = "value")))
stopifnot(index_warning(forceNetwork(links, nodes, Value = "value",
    NodeID = "name", Group = "group")))

if (requireNamespace("tibble", quietly = TRUE)) {
    tibble_links <- tibble::as_tibble(links)
    stopifnot(index_warning(sankeyNetwork(tibble_links, nodes, "from", "to",
        "value", "name")))
    stopifnot(index_warning(forceNetwork(tibble_links, nodes, "from", "to",
        "value", "name", Group = "group")))
}

links$from <- links$from - 1L
links$to <- links$to - 1L
stopifnot(!index_warning(sankeyNetwork(links, nodes, Value = "value")))
stopifnot(!index_warning(forceNetwork(links, nodes, Value = "value",
    NodeID = "name", Group = "group")))
