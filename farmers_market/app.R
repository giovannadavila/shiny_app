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

#Load data
farmers_market <- read_csv("farmers_market.csv")

# Define UI for application 
ui <- fluidPage(
   
   # Application title
   titlePanel("Central Coast Farmer's Market Directory"),
   
   # Sidebar with a dropdown input and check box 
   sidebarLayout(
      sidebarPanel(
        selectInput("county", label = h3("Select County:"), 
                    choices = unique(farmers_market$County) 
                )
        
        #Add in checkbox function here
        
      ),
      

      # Show a map of the filtered farmers markets 
      mainPanel(
        leafletOutput("market_map")
      )
   )
)

# Define server logic required to make map and table
server <- function(input, output) {
  
  output$market_map <- renderLeaflet({ 
    
    #Set output for county selection
    fm <- farmers_market %>% 
      filter(County == input$county)
    
    #Create map as a function of 'county' input and 'product' input
    leaflet() %>% 
      addTiles()
    
    })
   
  
      
      
   }

# Run the application 
shinyApp(ui = ui, server = server)

