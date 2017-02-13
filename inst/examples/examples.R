
library(networkD3)

# simpleNetwork
src <- c("A", "A", "A", "A", "B", "B", "C", "C", "D")
target <- c("B", "C", "D", "J", "E", "F", "G", "H", "I")
networkData <- data.frame(src, target)
simpleNetwork(networkData)

# with sans-serif 
simpleNetwork(networkData, fontFamily = "sans-serif")

# with another font 
simpleNetwork(networkData, fontFamily = "fantasy")

# forceNetwork 
data(MisLinks)
data(MisNodes)

# Create graph
forceNetwork(Links = MisLinks, Nodes = MisNodes, Source = "source",
             Target = "target", Value = "value", NodeID = "name",
             Group = "group", opacity = 1, zoom = F, bounded = T)

# with a simple click action - make the circles bigger when clicked
MyClickScript <- 
  '      d3.select(this).select("circle").transition()
.duration(750)
.attr("r", 30)'

forceNetwork(Links = MisLinks, Nodes = MisNodes, Source = "source",
             Target = "target", Value = "value", NodeID = "name",
             Group = "group", opacity = 1, zoom = F, bounded = T,
             clickAction = MyClickScript)

# showing how you can re-use the name of the clicked-on node (which is 'd')
# You are unlikely to want to do this pop-up alert, but you might want 
# instead to use Shiny.onInputChange() to allocate d.XXX to an element
# input$XXX for user in a Shiny app.
MyClickScript <- 'alert("You clicked " + d.name + " which is in row " + (d.index + 1) +
" of your original R data frame");'
forceNetwork(Links = MisLinks, Nodes = MisNodes, Source = "source",
             Target = "target", Value = "value", NodeID = "name",
             Group = "group", opacity = 1, zoom = F, bounded = T,
             clickAction = MyClickScript)

forceNetwork(Links = MisLinks, Nodes = MisNodes, Source = "source",
             Target = "target", Value = "value", NodeID = "name",
             Group = "group", opacity = 1, zoom = F, bounded = T,
             clickAction = "alert('Ouch!')")

# With a different font, and dimensions chosen to illustrate bounded box
forceNetwork(Links = MisLinks, Nodes = MisNodes, Source = "source",
             Target = "target", Value = "value", NodeID = "name",
             Group = "group", opacity = 1, zoom = F, bounded = T,
             fontFamily = "cursive",
             width = 1500, height = 300)

# With a different font, and node text faintly visible when not hovered over
forceNetwork(Links = MisLinks, Nodes = MisNodes, Source = "source",
             Target = "target", Value = "value", NodeID = "name",
             Group = "group", opacity = 1, zoom = F, bounded = T,
             fontFamily = "cursive", opacityNoHover = 0.3)

# Create graph with legend and varying radius
forceNetwork(Links = MisLinks, Nodes = MisNodes, Source = "source",
             Target = "target", Value = "value", NodeID = "name",
             Nodesize = 'size', radiusCalculation = "d.nodesize",
             Group = "group", opacity = 1, legend = T, bounded = F) 

# Create graph with legend and varying radius and a bounded box
forceNetwork(Links = MisLinks, Nodes = MisNodes, Source = "source",
             Target = "target", Value = "value", NodeID = "name",
             Nodesize = 'size', radiusCalculation = " Math.sqrt(d.nodesize)+6",
             Group = "group", opacity = 1, legend = T, bounded = T) 


# sankeyNetwork
URL <- "https://cdn.rawgit.com/christophergandrud/networkD3/master/JSONdata/energy.json"
Energy <- jsonlite::fromJSON(URL)

# Plot
sankeyNetwork(Links = Energy$links, Nodes = Energy$nodes, Source = "source",
              Target = "target", Value = "value", NodeID = "name",
              fontSize = 12, nodeWidth = 30)

# And with a different font
sankeyNetwork(Links = Energy$links, Nodes = Energy$nodes, Source = "source",
              Target = "target", Value = "value", NodeID = "name",
              fontSize = 12, nodeWidth = 30, fontFamily = "monospace")

# as of 0.2.6 sankeyNetwork supports cycles
# simple network with cycle 5 -> 0
net_cycles <- list(
  links = data.frame(
    source = c(0,0,0,1,1,5),
    target = c(1,2,3,4,5,0),
    value = 10
  ),
  nodes = data.frame(
    name = letters[1:6]
  )
)

# notice how few arguments we need now
# some output but not the nice output I expect
sankeyNetwork(
  net_cycles$links,
  net_cycles$nodes,
  Value = "value"
)


# radialNetwork
Flare <- jsonlite::fromJSON(
  "https://gist.githubusercontent.com/mbostock/4063550/raw/a05a94858375bd0ae023f6950a2b13fac5127637/flare.json",
  simplifyDataFrame = FALSE
)

hc <- hclust(dist(USArrests), "ave")

radialNetwork(List = Flare, fontSize = 10, opacity = 0.9, margin=0)
radialNetwork(as.radialNetwork(hc))

# and with a different font
radialNetwork(List = Flare, fontSize = 10, opacity = 0.9, margin=0, fontFamily = "sans-serif")

diagonalNetwork(List = Flare, fontSize = 10, opacity = 0.9, margin=0)
diagonalNetwork(as.radialNetwork(hc), height = 700, margin = 50)


# dendroNetwork
hc <- hclust(dist(USArrests), "ave")

dendroNetwork(hc, height = 600)
dendroNetwork(hc, treeOrientation = "vertical")

dendroNetwork(hc, height = 600, linkType = "diagonal")
dendroNetwork(hc, treeOrientation = "vertical", linkType = "diagonal")

dendroNetwork(hc, textColour = c("red", "green", "orange")[cutree(hc, 3)],
              height = 600)
dendroNetwork(hc, textColour = c("red", "green", "orange")[cutree(hc, 3)],
              treeOrientation = "vertical")

# chordDiagram
hairColourData <- matrix(c(11975,  1951,  8010, 1013,
                           5871, 10048, 16145,  990,
                           8916,  2060,  8090,  940,
                           2868,  6171,  8045, 6907), nrow = 4)
                              
chordNetwork(data = hairColourData, 
             width = 500, 
             height = 500,
             colourScale = c("#000000", "#FFDD89", "#957244", "#F26223"))
