library(shiny)
library(leaflet)
library(scales)

load("data/pgh_coords.RData")

source("./convertSPLines.R")

get_input_data <- function(is_weekday, time, is_training=TRUE) {
  if(is_training) {
    input_data <- read.csv("data/pgh_train.csv")
  } else {
    input_data <- read.csv("data/pgh_pred.csv")
  }
  
  if(is_weekday) {
    input_data <- subset(input_data, is.weekday==1)
  } else {
    input_data <- subset(input_data, is.weekday==0)
  }
  
  input_data <- switch(time,
                       "1" = subset(input_data, time==8),
                       "2" = subset(input_data, time==14),
                       "3" = subset(input_data, time==20))
  
  return(input_data)
}

shinyServer(function(input, output, session) {
  ## These reactive expressions (functions) get rerun only when the original widgets change
  input_data <- reactive({
    input.data <- NULL
    is.weekday <- input$weekday == 1
    is.training <- input$train == 0
    
    if(is.training) {
      input.data <- get_input_data(is.weekday, input$time, is_training = TRUE)
    } else { # speed prediction
      train.data <- get_input_data(is.weekday, input$time, is_training = TRUE)
      # Drop unused columns
      train.data$time <- NULL
      train.data$is.weekday <- NULL
      
      pred.data <- get_input_data(is.weekday, input$time, is_training = FALSE)
      segment.data <- read.csv('data/pgh_segments.csv')
      
      input.data <- data.frame(from.x = segment.data$from.x,
                               from.y = segment.data$from.y,
                               to.x = segment.data$to.x,
                               to.y = segment.data$to.y,
                               speed = pred.data$speed)
      input.data <- rbind(input.data, train.data)
    }
    
    return(input.data)
  })
  
  output$map <- renderLeaflet(
    leaflet(data = input_data()) %>% 
      addTiles(urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
               attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
      setView(lng = allegheny_lon, lat = allegheny_lat, zoom = 14)
  )
  
  observe({
    input.data <- input_data()
    
    pal <- colorNumeric("RdYlGn", domain = NULL, na.color = "#808080")
    if(!is.null(input.data)) {
      input.data <- convertSPLines(input.data)
      
      leafletProxy("map", data = input.data) %>%
        clearShapes() %>% clearMarkers() %>% clearControls() %>%
        addPolylines(color = ~pal(speed),
                     weight = 3, opacity = 0.90) %>%
        addLegend("bottomleft", pal=pal, values=~speed, title='Speed (mph)',
                  opacity = 0.90)
    }
  })
})
