library(shiny)
library(leaflet)
library(RColorBrewer)

## Original: http://rstudio.github.io/leaflet/shiny.html

# shinyUI(fluidPage(
#   leafletOutput("mymap"),
#   p(),
#   actionButton("recalc", "New points")
# ))

shinyUI(bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 10,
                sliderInput("range", "Magnitudes", min(quakes$mag), max(quakes$mag),
                            value = range(quakes$mag), step = 0.1),
                selectInput("colors", "Color Scheme",
                            rownames(subset(brewer.pal.info, category %in% c("seq", "div")))),
                checkboxInput("legend", "Show legend", TRUE)
  )
))
