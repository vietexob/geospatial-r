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

## The the shapefiles into a format that can be plotted
sport.f <- fortify(sport, region = "ons_label")
## This step has lost the attribute information associated with the sport object
## We add it back using the merge function
sport.f <- merge(sport.f, sport@data, by.x = "id", by.y = "ons_label")

## 5. Using ggplot2 for Descriptive Statistics
filename <- "./data/spatialggplot/ambulance_assault.csv"
input <- read.csv(file = filename)

## Plot a histogram
p.ass <- ggplot(input, aes(x = assault_09_11))
(p.ass <- p.ass + geom_histogram(binwidth = 10) + geom_density(fill = NA, colour = "black"))

## Overlay density estimation over the histogram
p2.ass <- ggplot(input, aes(x = assault_09_11, y = ..density..))
(p2.ass <- p2.ass + geom_histogram() + geom_density(fill = NA, colour = "red"))

## Box and whisker plot
p3.ass <- ggplot(input, aes(x = Bor_Code, y = assault_09_11))
(p3.ass <- p3.ass + geom_boxplot() + coord_flip())

## Do faceting based on the example of the histogram plot above
(p.ass <- p.ass + facet_wrap(~Bor_Code))

## Faceting for Maps
library(reshape2)

## Data shows historic population values between 1801 and 2001 for London
filename <- "./data/spatialggplot/census-historic-population-borough.csv"
london.data <- read.csv(file = filename)

## Melt the data so that the columns become rows
london.data.melt <- melt(london.data, id = c("Area.Code", "Area.Name"))
## Merge the population data with the London borough geometry contained within
## our sport.f object
plot.data <- merge(sport.f, london.data.melt, by.x = "id", by.y = "Area.Code")

## Use faceting to produce one map per year (this may take a little while to appear)
ggplot(data = plot.data,
       aes(x = long, y = lat, fill = value, group = group)) + geom_polygon() + geom_path(
         colour = "grey", lwd = 0.1) + coord_equal() + facet_wrap(~variable)

## Save a really large map
filename <- "./figures/london_population.pdf"
ggsave(filename, scale = 3, dpi = 400)
