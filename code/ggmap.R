rm(list = ls())

library(ggplot2)
library(ggmap)

data(crime)

## Find a reasonable spatial extent
qmap('houston', zoom = 13)
## Only violent crimes
violent_crimes <- subset(crime, offense != 'auto theft' & offense != 'theft'
                         & offense != 'burglary')
## Order violent crimes
violent_crimes$offense <- factor(violent_crimes$offense,
                                 levels = c('robbery', 'aggravated assault', 'rape', 'murder'))

## Restrict to downtown
violent_crimes <- subset(violent_crimes, -95.39681 <= lon & lon <= -95.34188
                         & 29.73631 <= lat & lat <= 29.78400)

## Create a spatial bubble chart
theme_set(theme_bw(16))
HoustonMap <- qmap('houston', zoom = 14, color = 'bw', legend = 'topleft')
HoustonMap <- HoustonMap + geom_point(aes(x = lon, y = lat, colour = offense, size = offense),
                                      data = violent_crimes)
## Bin the points and drop the bins that don't have any samples in them
## The result shows us where the crimes are happening at the expense of knowing their freq.
HoustonMap <- HoustonMap + stat_bin2d(aes(x = lon, y = lat, colour = offense, fill = offense),
                                      size = 0.5, bins = 30, alpha = 0.5, data = violent_crimes)

## What about violent crime in general?
houston <- get_map('houston', zoom = 14)
HoustonMap <- ggmap(houston, extent = 'device', legend = 'topleft')
HoustonMap <- HoustonMap + stat_density2d(aes(x = lon, y = lat, fill = ..level..,
                                              alpha = ..level..), size = 2, bins = 4,
                                          data = violent_crimes, geom = "polygon")

overlay <- stat_density2d(aes(x = lon, y = lat, fill = ..level.., alpha = ..level..),
                          bins = 4, geom = 'polygon', data = violent_crimes)
HoustonMap <- HoustonMap + overlay + inset(grob = ggplotGrob(ggplot() + overlay + theme_inset()),
                                           xmin = -95.35836, xmax = Inf,
                                           ymin = -Inf, ymax = 29.75062)

## Faceted plot for spatiotemporal data with discrete temporal components
houston <- get_map(location = 'houston', zoom = 14, color = 'bw', source = 'osm')
HoustonMap <- ggmap(houston, base_layer = ggplot(aes(x = lon, y = lat), data = violent_crimes))
HoustonMap <- HoustonMap + stat_density2d(aes(x = lon, y = lat, fill = ..level.., alpha = ..level..),
                                          bins = 5, geom = 'polygon', data = violent_crimes) +
  scale_fill_gradient(low = 'black', high = 'red') + facet_wrap(~ day)

## Utility functions
## 1. From string address to lon-lat coordinates
geocode('baylor university', output = 'more')
## Return the entire JSON tree given by Google Geocoding API parsed by rjson
geocode('baylor university', output = 'all')

## 2. Convert lon-lat coordinates into physical addresses
gc <- geocode('baylor university')
(gc <- as.numeric(gc))
(revgeocode(gc, output = 'more'))
(revgeocode(gc, output = 'all'))

## 3. Compute real distances using Google Distance Matrix API
from <- c('houston', 'houston', 'dallas')
to <- c('waco, texas', 'san antonio', 'houston')
## Default mode of transportation is driving
mapdist(from, to)
## Check my remaining balance of queries
distQueryCheck()
.GoogleDistQueryCount

## 4. Compute the map distances for the sequence of "legs" that constitute
## the routes between two locations: route function, plotted using geom_leg and geom_segment

## Plotting shapefiles
library(maptools)
library(gpclib)
library(sp)

gpclibPermit()
shapefile <- readShapeSpatial("./data/tr48_d00_shp/tr48_d00.shp",
                              proj4string = CRS("+proj=longlat + datum=WGS84"))
## Convert shapefile into a dataframe
data <- fortify(shapefile)
(qmap('texas', zoom = 6, maptype = 'satellite') + geom_polygon(aes(x = long, y = lat, group = group),
                                                              data = data, colour = 'white',
                                                              fill = 'black', alpha = .4, size = .3))
