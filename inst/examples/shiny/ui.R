
library(networkD3)

shinyUI(fluidPage(
  
  titlePanel("Shiny networkD3 "),
  
  tabsetPanel(
    tabPanel("Simple Network", simpleNetworkOutput("simple")),
    tabPanel("Force Network", forceNetworkOutput("force"))
  )
))