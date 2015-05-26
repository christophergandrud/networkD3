
library(networkD3)

# simpleNetwork
src <- c("A", "A", "A", "A", "B", "B", "C", "C", "D")
target <- c("B", "C", "D", "J", "E", "F", "G", "H", "I")
networkData <- data.frame(src, target)
simpleNetwork(networkData)

# forceNetwork  
data(MisLinks)
data(MisNodes)
forceNetwork(Links = MisLinks, Nodes = MisNodes, Source = "source",
             Target = "target", Value = "value", NodeID = "name",
             Group = "group", opacity = 0.4)

# sankeyNetwork
library(RCurl)
URL <- "https://raw.githubusercontent.com/christophergandrud/d3Network/sankey/JSONdata/energy.json"
Energy <- getURL(URL, ssl.verifypeer = FALSE)
# Convert to data frame
EngLinks <- JSONtoDF(jsonStr = Energy, array = "links")
EngNodes <- JSONtoDF(jsonStr = Energy, array = "nodes")

# Plot
sankeyNetwork(Links = EngLinks, Nodes = EngNodes, Source = "source",
              Target = "target", Value = "value", NodeID = "name",
              fontsize = 12, nodeWidth = 30)

# treeNetwork
Flare <- RCurl::getURL("https://gist.githubusercontent.com/mbostock/4063550/raw/a05a94858375bd0ae023f6950a2b13fac5127637/flare.json")
Flare <- rjson::fromJSON(Flare)
treeNetwork(List = Flare, fontSize = 10, opacity = 0.9, margin=0)
