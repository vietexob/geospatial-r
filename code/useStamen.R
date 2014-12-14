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

## 3. Adding Base Map to ggplot2
## Calculate the bounding box (bb) of the sport.wgs84 object
b <- bbox(sport.wgs84)
## Scale longitude and latitude (increase bb by 5% for plot)
b[1, ] <- (b[1, ] - mean(b[1, ])) * 1.05 + mean(b[1, ])
b[2, ] <- (b[2, ] - mean(b[2, ])) * 1.05 + mean(b[2, ])

lnd.b1 <- ggmap(get_map(location = b))

## Fortify the sport.wgs84 object and then merge with the required attributes
sport.wgs84.f <- fortify(sport.wgs84, region = "ons_label")
sport.wgs84.f <- merge(sport.wgs84.f, sport.wgs84@data, by.x = "id", by.y = "ons_label")
## Overlay this on our base map
(lnd.b1 <- lnd.b1 + geom_polygon(data = sport.wgs84.f,
                                 aes(x = long, y = lat, group = group,
                                     fill = Partic_Per), alpha = 0.5))

## Use Stamen map instead
lnd.b2 <- ggmap(get_map(location = b, source = "stamen", maptype = "toner", crop = TRUE))
lnd.b2 <- lnd.b2 + geom_polygon(data = sport.wgs84.f, aes(x = long, y = lat, group = group,
                                                          fill = Partic_Per), alpha = 0.5)
print(lnd.b2)

## Increase the detail of the base map by using the zoom parameter
lnd.b3 <- ggmap(get_map(location = b, source = "stamen", maptype = "toner"), crop = TRUE,
                zoom = 11)
lnd.b3 <- lnd.b3 + geom_polygon(data = sport.wgs84.f, aes(x = long, y = lat, group = group,
                                                          fill = Partic_Per), alpha = 0.5)
print(lnd.b3)

## Increase the detail of the base map by using the zoom parameter
lnd.b3 <- ggmap(get_map(location = b, source = "stamen", maptype = "toner"), crop = TRUE,
                zoom = 11)
lnd.b3 <- lnd.b3 + geom_polygon(data = sport.wgs84.f, aes(x = long, y = lat, group = group,
                                                          fill = Partic_Per), alpha = 0.5)
print(lnd.b3)
