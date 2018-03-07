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
   titlePanel("California Central Coast Farmers Market Directory"),
   
   # Sidebar with a dropdown input and check box 
   sidebarLayout(
      sidebarPanel(
        selectInput("county", label = h3("Select County:"), 
                    choices = unique(fm_melt$County)),
        
  
        checkboxGroupInput("product", label = h3("Select Products:"), choices = unique(fm_melt$Product), "No products")
        
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
      filter(County %in% input$county) %>% 
      filter(Product %in% input$product & Availability %in% "Y")
    
    
    #Create map with popup markers using fm_map created above
    leaflet(fm_map) %>% 
      addTiles() %>% 
      addMarkers(popup = ~as.character(fm_map$address)) 
      
    })
  
  
  
  output$market_table <- DT :: renderDataTable({ 
    spacing = c("xs")
    width = "auto"
    
    #Create table dataframe for widget inputs: county selection & product
    fm_table <- fm_melt %>% 
      filter(County %in% input$county) %>%
      filter(Product %in% input$product) %>% 
      filter(Availability %in% "Y") %>% 
      select(MarketName, address, Website) %>% 
      rename("Name of Market" = MarketName, "Address" = address) #%>% 
     # unique(fm_melt$MarketName, incomparables = , fromLast = TRUE)
    
    
    #Create table using fm_table dataset created above
    DT :: datatable(fm_table)
    
  })
      
   }

# Run the application 
shinyApp(ui = ui, server = server)

