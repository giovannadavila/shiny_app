#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#Load packages
library(shiny)
library(tidyverse)
library(leaflet)
library(tmap)

#Load data
farmers_market <- read_csv("farmers_market.csv")

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Central Coast Farmer's Market Directory"),
   
   # Sidebar with a dropdown input and check box 
   sidebarLayout(
      sidebarPanel(
        selectInput("county", label = h3("Select County:"), choices = unique(farmers_market$County) 
                ) 
      ),
      

      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("distPlot") # Change to map
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  output$value <- renderPrint({ input$select 
    
    #Set output for county selection
    fm <- farmers_market %>% 
      filter(County == input$county)
    
    })
   
  
      
      
   }

# Run the application 
shinyApp(ui = ui, server = server)

