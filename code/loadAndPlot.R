rm(list = ls())

library(maptools)
library(rgdal)
library(ggplot2)
library(rgeos)
library(ggmap)
library(plyr)

## 1. Loading Spatial Data
filename <- "./data/spatialggplot/london_sport.shp"
# sport <- readShapePoly(fn = filename)
## This is not the best way to read shapefiles, a better way is
filepath <- "./data/spatialggplot/"
sport <- readOGR(dsn = filepath, layer = "london_sport")

## This file has been incorrectly specified, so we change it
proj4string(sport) <- CRS("+init=epsg:27700")
## If we want to reproject the data into something like WGS84 or latitude and longitude
sport.wgs84 <- spTransform(sport, CRS("+init=epsg:4326"))

## 2. Plotting Spatial Data with ggplot2
## Create a scatterplot with the attribute data in the sport object
## The characters inside the aes argument refer to the parts of that data frame
## that you wish to use
p <- ggplot(sport@data, aes(Partic_Per, Pop_2001))
## Add a player (or geom) to the data, scale the points by population,
## colour them by sports participation, and add text to the plot
q <- p + geom_point(aes(colour = Partic_Per, size = Pop_2001)) +
  geom_text(size = 2, aes(label = name))

## The the shapefiles into a format that can be plotted
sport.f <- fortify(sport, region = "ons_label")
## This step has lost the attribute information associated with the sport object
## We add it back using the merge function
sport.f <- merge(sport.f, sport@data, by.x = "id", by.y = "ons_label")

Map <- ggplot(sport.f, aes(long, lat, group = group, fill = Partic_Per)) + geom_polygon()
Map <- Map + coord_equal() + labs(x = "Easting (m)", y = "Northing (m)",
                                  fill = "% Sport Partic.")
(Map <- Map + ggtitle("London Sports Participation"))
## Save a really large map
filename <- "./figures/london_sports.pdf"
ggsave(filename, scale = 3, dpi = 400)

## Produce the map in black and white
Map2 <- Map + scale_fill_gradient(low = "white", high = "black")
