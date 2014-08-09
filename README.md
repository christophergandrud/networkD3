
### Tools for creating D3 JavaScript network graphs from R

This is a port of Christopher Gandrud's [d3Network](http://christophergandrud.github.io/d3Network/) package to the [htmlwidgets](https://github.com/ramnathv/htmlwidgets) framework. 

#### Installation

To install and use you'll need to install this package and two of it's dependencies from GitHub:

```S
library(devtools)
install_github(c('rstudio/htmltools', 'ramnathv/htmlwidgets', 'christophergandrud/networkD3'))
```

#### Usage

Here's an example of `simpleNetwork`:

```S
src <- c("A", "A", "A", "A", "B", "B", "C", "C", "D")
target <- c("B", "C", "D", "J", "E", "F", "G", "H", "I")
networkData <- data.frame(src, target)

simpleNetwork(networkData)
```

Here's `forceNetwork`:

```S
data(MisLinks)
data(MisNodes)

forceNetwork(Links = MisLinks, Nodes = MisNodes, Source = "source",
             Target = "target", Value = "value", NodeID = "name",
             Group = "group", opacity = 0.4)
```


