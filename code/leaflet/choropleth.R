rm(list = ls())

## The map displays GDP per capita in thousands of pesos for Mexican states in 2008
## Original: http://rpubs.com/walkerke/leaflet_choropleth

library(rgdal)
library(leaflet)

mexico <- readOGR(dsn="./data/mexico", layer="mexico", encoding="UTF-8")
head(mexico@data)

## The variable we are interested in mapping is gdp08, which is per capita
## gross domestic product in thousands of pesos for 2008 (in 2003 pesos)

## 1. Define a ColorBrewer color ramp and means of classifying data
pal <- colorQuantile("YlGn", NULL, n=5)

## 2. Define parameters of HTML pop-up
state_popup <- paste0("<strong>Estado: </strong>",
                      mexico$name,
                      "<br><strong>PIB per capita, miles de pesos, 2008: </strong>",
                      mexico$gdp08)
mb_tiles <- "http://a.tiles.mapbox.com/v3/kwalkertcu.l1fc0hab/{z}/{x}/{y}.png"
mb_attribution <- 'Mapbox <a href="http://mapbox.com/about/maps" target="_blank">Terms &amp; Feedback</a>'

## 3. Call the leaflet function, pull in tiles from my MyBox account for the basemap layer
## with addTiles, and then style the polygons within the addPolygons function
leaflet(data=mexico) %>%
  addTiles(urlTemplate = mb_tiles, attribution = mb_attribution) %>%
  addPolygons(fillColor = ~pal(gdp08),
              fillOpacity = 0.8,
              color = "#BDBDC3",
              weight = 1, popup = state_popup)
