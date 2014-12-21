rm(list = ls())

library(maptools)
library(ggplot2)
# library(rgeos)

## Load the world map shapefile
filename <- "./data/ne_110m_admin_0_countries/ne_110m_admin_0_countries.shp"
world <- readShapePoly(filename)

## Load my world data
my.world <- read.csv(file = "./data/my_world2.csv", header = TRUE)

## Plot the world map of R downloads
world.f <- fortify(world, region = "country")
world.f <- merge(world.f, world@data, by.x = "id", by.y = "country")
Map <- ggplot(world.f, aes(long, lat, group = group, fill = count)) + geom_polygon()
(Map <- Map + ggtitle("R Activity around the World from Dec 08 to Dec 13, 2014"))

