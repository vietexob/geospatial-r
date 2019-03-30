library(shiny)
library(leaflet)
library(scales)

load("data/pgh_coords.RData")

source("./convertSPLines.R")

get_train_data <- function(is_weekday, time) {
  train_data <- read.csv("data/pgh_train.csv")
  
  if(is_weekday) {
    train_data <- subset(train_data, is.weekday==1)
  } else {
    train_data <- subset(train_data, is.weekday==0)
  }
  
  train_data <- switch(time,
                       "1" = subset(train_data, time==8),
                       "2" = subset(train_data, time==14),
                       "3" = subset(train_data, time==20))
  
  return(train_data)
}

shinyServer(function(input, output, session) {
  ## These reactive expressions (functions) get rerun only when the original widgets change
  inputData <- reactive({
    input.data <- NULL
    is.weekday <- input$weekday == 1
    is.training <- input$train == 0
    
    # speed prediction
    if(is.training) {
      input.data <- get_train_data(is.weekday, input$time)
    } else {
      if(is.weekday) {
        train.data <- switch(input$time,
                             "1" = read.csv("data/pgh_weekday_train_8.csv"),
                             "2" = read.csv("data/pgh_weekday_train_14.csv"),
                             "3" = read.csv("data/pgh_weekday_train_20.csv"))
        
        segment.data <- read.csv('data/pgh_weekday_test_space.csv')
        pred.data <- switch(input$time,
                            "1" = read.csv("data/pgh_weekday_pred_8.csv"),
                            "2" = read.csv("data/pgh_weekday_pred_14.csv"),
                            "3" = read.csv("data/pgh_weekday_pred_20.csv"))
        
        input.data <- data.frame(from.x = segment.data$from.x,
                                 from.y = segment.data$from.y,
                                 to.x = segment.data$to.x, to.y = segment.data$to.y,
                                 speed = pred.data$X..speed)
        input.data <- rbind(input.data, train.data)
      } else {
        train.data <- switch(input$time,
                             "1" = read.csv("data/pgh_weekend_train_8.csv"),
                             "2" = read.csv("data/pgh_weekend_train_14.csv"),
                             "3" = read.csv("data/pgh_weekend_train_20.csv"))
        
        segment.data <- read.csv('data/pgh_weekend_test_space.csv')
        pred.data <- switch(input$time,
                            "1" = read.csv("data/pgh_weekend_pred_8.csv"),
                            "2" = read.csv("data/pgh_weekend_pred_14.csv"),
                            "3" = read.csv("data/pgh_weekend_pred_20.csv"))
        
        input.data <- data.frame(from.x = segment.data$from.x,
                                 from.y = segment.data$from.y,
                                 to.x = segment.data$to.x, to.y = segment.data$to.y,
                                 speed = pred.data$X..speed)
        input.data <- rbind(input.data, train.data)
      }
    }
    
    return(input.data)
  })
  
  output$map <- renderLeaflet(
    leaflet(data = inputData()) %>% 
      addTiles(urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
               attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
      setView(lng = allegheny_lon, lat = allegheny_lat, zoom = 14)
  )
  
  observe({
    input.data <- inputData()
    
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
