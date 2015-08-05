# D3 JavaScript Network Graphs from R

Version 0.1.8 [![Build Status](https://travis-ci.org/christophergandrud/networkD3.svg?branch=master)](https://travis-ci.org/christophergandrud/networkD3) ![CRAN Downloads](http://cranlogs.r-pkg.org/badges/last-month/networkD3)

This is a port of Christopher Gandrud's
[d3Network](http://christophergandrud.github.io/d3Network/) package to the
[htmlwidgets](https://github.com/ramnathv/htmlwidgets) framework.

This README includes information on set up and a number of basic examples.
For more information see the package's [main page](http://christophergandrud.github.io/networkD3/).

## Usage

Here's an example of `simpleNetwork`:

```S
# Create fake data
src <- c("A", "A", "A", "A", "B", "B", "C", "C", "D")
target <- c("B", "C", "D", "J", "E", "F", "G", "H", "I")
networkData <- data.frame(src, target)

# Plot
simpleNetwork(networkData)
```

Here's `forceNetwork`:

```S
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

```S
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
            fontSize = 12, nodeWidth = 30)
```

### Saving to an external file

Use `saveNetwork` to save a network to stand alone HTML file:

```S
library(magrittr)

simpleNetwork(networkData) %>% saveNetwork(file = 'Net1.html')
```
