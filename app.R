

#Load packages
library(shiny)
library(tidyverse)
library(leaflet)
library(reshape2)
library(shinydashboard)

#Load data
farmers_market_short <- read_csv("farmers_market_short.csv")

# Wrangle data

fm_melt <- farmers_market_short %>%
  rename("Baked Goods" = Bakedgoods) %>% 
  melt(id = c("MarketName", "Website", "County", "address", "latitude", "longitude")) %>% 
  rename("Product" = variable, "Availability" = value)



# Shiny App
#################################################

# Define UI for application 
ui <- dashboardPage(
   
   # Application title
   dashboardHeader(title = "Central California Coast Farmers Market Directory", titleWidth = 500),
   
   # Sidebar with a dropdown input and check box 
   dashboardSidebar(
     
      sidebarMenu(
        
        menuItem("Farmers Market Locator", tabName ="tab_1"),
        menuItem("About", tabName = "tab_2")
  )
),
   
   dashboardBody(
     
     tabItems(
       
       tabItem(tabName = "tab_1", 
               
               fluidRow(
                 
                 box(title = "Farmers Market County", selectInput("county",label = "Select County:", choices = unique(fm_melt$County)), height = 420),
                 box(leafletOutput("market_map"), height = 420),
                 
                 box(title = "Farmers Market Products",
                     radioButtons("product", label = "Select Product:", choices = unique(fm_melt$Product), selected = NULL), height = 420),
                 
                 box(DT::dataTableOutput("market_table"))
                 ), height = 420),
       
       tabItem(tabName = "tab_2",
               
               fluidRow(
                 
                box(title = "About", status = "warning", "This app was created by Giovanna Davila and Charlene Kormondy, graduate students at the University of California, Santa Barbara, as part of the coursework for ESM 244, Advanced Statistics and Data Analysis.", br(), br(),"Data Source: Ragland, Ed. Agricultural Marketing Service, Department of Agriculture. USDA-29231. The USDA National Farmers Market Directory. Available at: https://catalog.data.gov/dataset/national-farmers-market-directory.") 
               ))
            ))

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
  
  
  #Create table output
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
    
    
    #Create table using fm_table dataset created above
    DT :: datatable(fm_table)
    
  })
      
   }

# Run the application 
shinyApp(ui = ui, server = server)

