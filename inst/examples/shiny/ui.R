
library(networkD3)

shinyUI(fluidPage(
  
  titlePanel("Simple Network"),
  
  sidebarLayout(
    sidebarPanel(
      
    ),
    
    mainPanel(
      simpleNetworkOutput("network")
    )
  )
))