library(shiny)
library(leaflet)
library(RColorBrewer)

## Learning point: To modify a map that’s already running in the page, use the
## leafletProxy() function in place of the leaflet() call; otherwise, use Leaflet
## function calls as normal.

shinyServer(function(input, output, session) {
  ## Reactive expression for the data subsetted to what the user selected
  filteredData <- reactive({
    quakes[quakes$mag >= input$range[1] & quakes$mag <= input$range[2], ]
  })
  
  ## This reactive expression represents the palette function that changes
  ## as the user makes selections in the UI.
  colorPal <- reactive({
    colorNumeric(input$colors, quakes$mag)
  })
  
  output$map <- renderLeaflet({
    ## Use leaflet() here, and only include aspects of the map that won't
    ## need to change dynamically (at least, not unless the entire map is
    ## being torn down and recreated).
    leaflet(quakes) %>% addTiles() %>%
      fitBounds(~min(long), ~min(lat), ~max(long), ~max(lat))
  })
  
  ## Incremental changes to the map (in this case, replacing the circles
  ## when a new color is chosen) should be performed in an observer. Each
  ## independent set of things that can change should be managed in its own observer.
  observe({
    pal <- colorPal()
    leafletProxy("map", data = filteredData()) %>%
      clearShapes() %>%
      addCircles(radius = ~10^mag/10, weight = 1, color = "#777777",
                 fillColor = ~pal(mag), fillOpacity = 0.7, popup = ~paste(mag))
  })
  
  ## Use a separate observer to recreate the legend as needed.
  observe({
    proxy <- leafletProxy("map", data = quakes)
    ## Remove any existing legend, and only if the legend is enabled, create
    ## a new one.
    proxy %>% clearControls()
    if(input$legend) {
      pal <- colorPal()
      proxy %>% addLegend(position = "bottomright", pal = pal, values = ~mag)
    }
  })
})
