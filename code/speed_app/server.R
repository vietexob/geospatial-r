library(shiny)
library(leaflet)
library(scales)

load("data/pgh_coords.RData")

source("./convertSPLines.R")

shinyServer(function(input, output, session) {
  ## These reactive expressions (functions) get rerun only when the original widgets change
  inputData <- reactive({
    input.data <- NULL
    is.weekday <- input$weekday == 1
    is.training <- input$train == 0
    
    if(input$viz == 1) { # speed prediction
      if(is.training) {
        if(is.weekday) {
          input.data <- switch(input$time,
                               "1" = read.csv("data/pgh_weekday_train_8.csv"),
                               "2" = read.csv("data/pgh_weekday_train_14.csv"),
                               "3" = read.csv("data/pgh_weekday_train_20.csv"))
        } else {
          input.data <- switch(input$time,
                               "1" = read.csv("data/pgh_weekend_train_8.csv"),
                               "2" = read.csv("data/pgh_weekend_train_14.csv"),
                               "3" = read.csv("data/pgh_weekend_train_20.csv"))
        }
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
    } else { # spatial clustering
      if(is.training) {
        if(is.weekday) {
          input.data <- read.csv(file = 'data/pgh_weekday_train_space.csv')
        } else {
          input.data <- read.csv(file = 'data/pgh_weekend_train_space.csv')
        }
      } else {
        if(is.weekday) {
          input.data <- read.csv(file = 'data/pgh_weekday_test_space.csv')
        } else {
          input.data <- read.csv(file = 'data/pgh_weekend_test_space.csv')
        }
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
    
    if(input$viz == 1) {
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
    } else {
      K <- max(input.data$class)
      colors_used <- scales::hue_pal()(K)
      pal <- colorFactor(colors_used, domain = NULL, levels = 1:K)
      
      if(!is.null(input.data)) {
        input.data <- convertSPLines(input.data, is.speed = FALSE)
        
        leafletProxy("map", data = input.data) %>%
          clearShapes() %>% clearMarkers() %>% clearControls() %>%
          addPolylines(color = ~pal(member),
                       weight = 3, opacity = 0.85) %>%
          addLegend("bottomleft", pal=pal, values=~(member),
                    title='Spatial Cluster', opacity = 0.90)
      }
    }
  })
})
