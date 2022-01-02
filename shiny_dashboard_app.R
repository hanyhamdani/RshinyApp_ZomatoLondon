# Load required libraries
#install.packages("DT")
library(shiny)
library(shinydashboard)
library(leaflet)
library(DBI)
library(odbc)
library(DT)


# Read database credentials
# source("./03_shiny_HW1/credentials_v3.R")
source("./credentials_v4.R")


ui <- fluidPage(
  
  #tags$head(
   # tags$style("label{font-family: BentonSans Book;}")
  #),
 
 # setBackgroundImage(src = "https://www.fillmurray.com/1920/1080", shinydashboard = TRUE), 
  

  dashboardPage(

  dashboardHeader(title = "Restaurant Search" ),
  #Sidebar content
  dashboardSidebar(
  #Add sidebar menus here
    sidebarMenu(
      menuItem("About the App", tabName = "HWSummary", icon = icon("dashboard")),
      menuItem("Votes Based Search", tabName = "dbquery", icon = icon("dashboard")),
      menuItem("Map of Restaurants", tabName = "leaflet", icon = icon("th"))
    )
  ),
  dashboardBody(
    
    
    tabItems(
      # Add contents for first tab
      tabItem(tabName = "HWSummary",
              h3("This HW was submitted by Syed Hassan Raza of ITOM6265"),
              p("Welcome to Hassan's Shiny App!", style = "color:green ; font-size: 32px"),
              
              p("In this app, I allow users to search popular restaurants based on number of votes a restaurant has
              receieved. You may also, search a restaurant's detail
                by typing in its name. You can use the search service by going to 'Votes Based Search'
                Tab available on left side of the page.",style="color:purple; font-size: 24px"),
              
              p("In 'Map of Restaurants' Tab (available on left side of page), you can view locations of these restaurants on map.
              For Maps, I have used OpenStreetMap because of its city view.
              
                ",style="color:purple; font-size: 24px" )
      ),
      
      # Add contents for second tab
      
      tabItem(tabName = "dbquery",
              textInput("text", label = h3("Tell us Your Favorite Restaurant"), value = ""),
              sliderInput("rest_votes", label = h3("Range of Votes to Search for"), min = 0, 
                          max = 100, value = c(0, 100)),
              actionButton("Go", label = "Get Results"),
              hr(),
              DT::dataTableOutput("mytable1")
      ),
      #  Add contents for third tab
      tabItem(tabName = "leaflet", h2("Click on Teardrops to View Names of Restaurants"),
              leafletOutput("mymap")
      )
    ),
    tags$img(
      src = "https://www.call-systems.com/blog/wp-content/uploads/2016/01/London-Restaurants-to-follow-on-Instagram-Image-680x510.jpg",
      style = 'position: absolute'
    )
   
  )
  
)
 

)




server <- function(input, output) {
  
  #Develop your server side code (Model) here
  db <- dbConnector(
    server   = getOption("database_server"),
    database = getOption("database_name"),
    uid      = getOption("database_userid"),
    pwd      = getOption("database_password"),
    port     = getOption("database_port")
  )
  on.exit(dbDisconnect(db), add = TRUE)
  
  query <- "SELECT MIN(votes) AS min, MAX(votes) AS max from zomato_rest"
  
  data <- dbGetQuery(db, query)
  
  updateSliderInput(inputId = "rest_votes", min = data$min, max = data$max)
  
  observeEvent(input$Go, {
    
    output$mytable1 <- renderDataTable({
    
    #output$range <- renderPrint({ input$rest_votes })
    #output$value <- renderPrint({ input$Go })
    # open DB connection
    db <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db), add = TRUE)
    
    
    
    # browser()
    #instead of sql query running two times, it should give min and max range values in one time
   # query <- paste0 ("SELECT " ,input$rest_votes[1], " AND " ,input$rest_votes[2], ";")
    #print(query)
    
    #data <- dbGetQuery(db, query)
   
    
 
    #data
    
  } )
    
  } )
  
  output$mymap <- renderLeaflet({ 
    
    db <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db), add = TRUE)
    
    query <- paste0("SELECT HH_TrctLng ,HH_TrctLat from TimeIndependentHH
                    WHERE HH_TrctLng  IS NOT NULL AND HH_TrctLat IS NOT NULL;")
    data <- dbGetQuery(db, query)
    leaflet(data) %>%
      addProviderTiles(providers$OpenStreetMap)%>%
            addMarkers(lng = ~ HH_TrctLng, lat = ~HH_TrctLat, popup = data$name)
      
      
    
    })
  
}

shinyApp(ui, server)

