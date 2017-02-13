library(shiny)
library(networkD3)

data(MisLinks)
data(MisNodes)

shinyServer(function(input, output) {
    
  output$simple <- renderSimpleNetwork({
    src <- c("A", "A", "A", "A", "B", "B", "C", "C", "D")
    target <- c("B", "C", "D", "J", "E", "F", "G", "H", "I")
    networkData <- data.frame(src, target)
    simpleNetwork(networkData, opacity = input$opacity)
  })
  
  output$force <- renderForceNetwork({
    forceNetwork(Links = MisLinks, Nodes = MisNodes, Source = "source",
                 Target = "target", Value = "value", NodeID = "name",
                 Group = "group", opacity = input$opacity)
  })
  
  output$forceRadius <- renderForceNetwork({
          forceNetwork(Links = MisLinks, Nodes = MisNodes, Source = "source",
                       Target = "target", Value = "value", NodeID = "name",
                       Nodesize = 'size', radiusCalculation = " Math.sqrt(d.nodesize)+6",
                       Group = "group", opacity = input$opacity, legend = T) 
  })
  
  output$sankey <- renderSankeyNetwork({
    URL <- "https://cdn.rawgit.com/christophergandrud/networkD3/master/JSONdata/energy.json"
    Energy <- jsonlite::fromJSON(URL)
    sankeyNetwork(Links = Energy$links, Nodes = Energy$nodes, Source = "source",
                  Target = "target", Value = "value", NodeID = "name",
                  fontSize = 12, nodeWidth = 30, sinksRight = input$sinksRight)
  })

  output$rt <- renderRadialNetwork({
    Flare <- jsonlite::fromJSON(
      "https://gist.githubusercontent.com/mbostock/4063550/raw/a05a94858375bd0ae023f6950a2b13fac5127637/flare.json",
      simplifyDataFrame = FALSE
    )
    radialNetwork(List = Flare, fontSize = 10, opacity = 0.9, margin=0)
  })
  
})
