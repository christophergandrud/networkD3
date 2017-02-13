library(shiny)
library(networkD3)

shinyUI(fluidPage(
  
  titlePanel("Shiny networkD3 "),
  
  sidebarLayout(
    sidebarPanel(
      numericInput("opacity", "Opacity", 0.6, min = 0.1, max = 1, step = .1)
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Simple Network", simpleNetworkOutput("simple")),
        tabPanel("Force Network", forceNetworkOutput("force")),
        tabPanel("Force Network with Legend & Radius", forceNetworkOutput("forceRadius")),
        tabPanel("Sankey Network", 
                 checkboxInput("sinksRight", "sinksRight", value = TRUE),
                 sankeyNetworkOutput("sankey")),
        tabPanel("Reingold-Tilford Tree", radialNetworkOutput("rt"))
      )
    )
  )
))