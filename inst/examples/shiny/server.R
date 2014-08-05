

library(networkD3)

shinyServer(function(input, output) {
  
  
  networkData <- reactive({
     src <- c("A", "A", "A", "A", "B", "B", "C", "C", "D")
     target <- c("B", "C", "D", "J", "E", "F", "G", "H", "I")
     data.frame(src, target)
  })
  
  output$network <- renderSimpleNetwork({
    simpleNetwork(networkData())
  })
  
})