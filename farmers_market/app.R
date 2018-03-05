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
library(DT)
library(reshape2)

#Load data
farmers_market <- read_csv("farmers_market.csv") # Complete dataset
farmers_market_short <- read_csv("farmers_market_short.csv") # Filtered for melt()

# Wrangle data

fm_melt <- farmers_market_short %>%
  rename("Baked Goods" = Bakedgoods) %>% 
  melt(id = c("MarketName", "Website", "County", "address", "latitude", "longitude")) %>% 
  rename("Product" = variable, "Availability" = value)


# Shiny App
#################################################

# Define UI for application 
ui <- fluidPage(
   
   # Application title
   titlePanel("Central Coast Farmers Market Directory"),
   
   # Sidebar with a dropdown input and check box 
   sidebarLayout(
      sidebarPanel(
        selectInput("county", label = h3("Select County:"), 
                    choices = unique(fm_melt$County)),
        
  
        checkboxGroupInput("product", label = h3("Select Products:"), choices = unique(fm_melt$Product))
        
      ),
      

      # Setting leaflet map and table outputs on the main panel 
      mainPanel(
        leafletOutput("market_map"),
        
        DT::dataTableOutput("market_table")
      
      )
   )
)   

# Define server logic required to make map and table
server <- function(input, output) {
  
  #Set leaflet map output
  output$market_map <- renderLeaflet({ 
    
    #Create map dataset for widget inputs: county selection & product
    fm_map <- fm_melt %>% 
      filter(County == input$county)
    #How to filter the mapped dataset based on the 'product' checkbox input??
    
    #Create map with popup markers using fm_map created above
    leaflet(fm_map) %>% 
      addTiles() %>% 
      addMarkers(popup = ~as.character(fm_map$address))
      
    })
  
  
  
  output$market_table <- DT :: renderDataTable({ 
    spacing = c("xs")
    width = "auto"
    
    #Create table dataset for widget inputs: county selection & product
    fm_table <- fm_melt %>% 
      filter(County == input$county) %>% #  && Product == input$product
      select(MarketName, address, Website) %>% 
      rename("Name of Market" = MarketName, "Address" = address)
    #How to filter by the 'product' checkbox input and not have the repeated counties from the melted df show up??
    
    #Create table using fm_table dataset created above
    DT :: datatable(fm_table)
    
  })
      
   }

# Run the application 
shinyApp(ui = ui, server = server)

