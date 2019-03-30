library(shiny)
library(leaflet)

shinyUI(bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%; height:100%}"),
  tags$head(includeCSS("styles.css")),
  
  leafletOutput("map", width = "100%", height = "100%"),
  
  absolutePanel(top = 10, right = 10,
                helpText("Global Relational GP with Side Information."),
                
                selectInput('train', label = 'Training or prediction?',
                            choices = list('Training' = 0, 'Prediction' = 1), selected = 0),
                
                selectInput('weekday', label = 'Is weekday?',
                            choices = list('Yes' = 1, 'No' = 0), selected = 1),
                
                selectInput("time", label = "Choose a time:",
                            choices = list("8 a.m." = 1, "2 p.m." = 2, "8 p.m." = 3),
                            selected = 1)
  )
))
