# Tools for creating D3 JavaScript network graphs from R

Version 0.7

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
# Load energy projection data
library(RCurl)
URL <- "https://raw.githubusercontent.com/christophergandrud/networkD3/master/JSONdata/energy.json"
Energy <- getURL(URL, ssl.verifypeer = FALSE)

# Convert to data frame
EngLinks <- JSONtoDF(jsonStr = Energy, array = "links")
EngNodes <- JSONtoDF(jsonStr = Energy, array = "nodes")

# Plot
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
```

### Saving to an external file

Use `saveNetwork` to save a network to stand alone HTML file:

```R
library(magrittr)

simpleNetwork(networkData) %>% saveNetwork(file = 'Net1.html')
```
