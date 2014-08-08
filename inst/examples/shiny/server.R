

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
  
})