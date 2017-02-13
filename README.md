# D3 JavaScript Network Graphs from R

Version 0.2.13
[![CRAN Version](http://www.r-pkg.org/badges/version/networkD3)](http://cran.r-project.org/package=networkD3)
[![Build Status](https://travis-ci.org/christophergandrud/networkD3.svg?branch=master)](https://travis-ci.org/christophergandrud/networkD3)
![CRAN Monthly Downloads](http://cranlogs.r-pkg.org/badges/last-month/networkD3)
![CRAN Total Downloads](http://cranlogs.r-pkg.org/badges/grand-total/networkD3)

<<<<<<< HEAD
This is a port of Christopher Gandrud's
[d3Network](http://christophergandrud.github.io/d3Network/) package to the
[htmlwidgets](https://github.com/ramnathv/htmlwidgets) framework.

## Installation

To install and use you'll need to install this package and two of it's dependencies from GitHub:

```R
library(devtools)
install_github(c('rstudio/htmltools', 
                 'ramnathv/htmlwidgets',
                 'christophergandrud/networkD3'))
```
=======
This README includes information on set up and a number of basic examples.
For more information see the package's [main page](http://christophergandrud.github.io/networkD3/).
>>>>>>> b2767b3648f674d5ac3074e4ad7f063812f68a74

## Usage

Here's an example of `simpleNetwork`:

```R
# Create fake data
src <- c("A", "A", "A", "A", "B", "B", "C", "C", "D")
target <- c("B", "C", "D", "J", "E", "F", "G", "H", "I")
networkData <- data.frame(src, target)

# Plot
simpleNetwork(networkData)
```

Here's `forceNetwork`:

```R
# Load data
data(MisLinks)
data(MisNodes)

# Plot
forceNetwork(Links = MisLinks, Nodes = MisNodes, Source = "source",
             Target = "target", Value = "value", NodeID = "name",
             Group = "group", opacity = 0.4,
             colourScale = "d3.scale.category20b()")
```

Here's `sankeyNetwork` using a downloaded JSON data file:

```R
<<<<<<< HEAD
=======
# Recreate Bostock Sankey diagram: http://bost.ocks.org/mike/sankey/
>>>>>>> b2767b3648f674d5ac3074e4ad7f063812f68a74
# Load energy projection data
URL <- paste0("https://cdn.rawgit.com/christophergandrud/networkD3/",
              "master/JSONdata/energy.json")
Energy <- jsonlite::fromJSON(URL)

# Plot
<<<<<<< HEAD
sankeyNetwork(Links = EngLinks, Nodes = EngNodes, Source = "source",
              Target = "target", Value = "value", NodeID = "name",
              fontsize = 12, nodeWidth = 30)
```

*New in version 0.2*

There are two tree network functions available, `radialNetwork` and `diagonalNetwork`:

```R
library(jsonlite)
URL <- paste0("https://raw.githubusercontent.com/christophergandrud/",
              "networkD3/master/JSONdata/flare.json")
Flare <- getURL(URL)

## Convert to list format
Flare <- rjson::fromJSON(Flare)

## Recreate Bostock example from http://bl.ocks.org/mbostock/4063550
radialNetwork(List = Flare, fontSize = 10, opacity = 0.9)
diagonalNetwork(List = Flare, fontSize = 10, opacity = 0.9)
```

*New in version 0.2*

Finally, `dendroNetwork` can be used to create a dendrogram:

```R
hc <- hclust(dist(USArrests), "ave")

dendroNetwork(hc, height = 600)
=======
sankeyNetwork(Links = Energy$links, Nodes = Energy$nodes, Source = "source",
             Target = "target", Value = "value", NodeID = "name",
             units = "TWh", fontSize = 12, nodeWidth = 30)
```
### Interacting with igraph

You can use [igraph](http://igraph.org/r/) to create network graph data that can be plotted with **networkD3**. The `igraph_to_networkD3` function converts igraph graphs to lists that work well with **networkD3**. For example:

```R
# Load igraph
library(igraph)

# Use igraph to make the graph and find membership
karate <- make_graph("Zachary")
wc <- cluster_walktrap(karate)
members <- membership(wc)

# Convert to object suitable for networkD3
karate_d3 <- igraph_to_networkD3(karate, group = members)

# Create force directed network plot
forceNetwork(Links = karate_d3$links, Nodes = karate_d3$nodes, 
             Source = 'source', Target = 'target', NodeID = 'name', 
             Group = 'group')
>>>>>>> b2767b3648f674d5ac3074e4ad7f063812f68a74
```

### Saving to an external file

Use `saveNetwork` to save a network to stand alone HTML file:

```R
library(magrittr)

simpleNetwork(networkData) %>% saveNetwork(file = 'Net1.html')
```

## Note

networkD3 began as a port of
[d3Network](http://christophergandrud.github.io/d3Network/) package to the
[htmlwidgets](https://github.com/ramnathv/htmlwidgets) framework. d3Network is 
no longer supported.
