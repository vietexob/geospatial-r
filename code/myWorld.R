rm(list = ls())

library(maptools)
library(ggplot2)
library(rgeos)

## Load the world map shapefile
filename <- "./data/ne_110m_admin_0_countries/ne_110m_admin_0_countries.shp"
world <- readShapePoly(filename)

## Load my world data
my.world <- read.csv(file = "./data/my_world2.csv", header = TRUE)
visited <- world$name %in% my.world$Country2
world@data <- data.frame(world@data, visited)

## Plot the world map of R downloads
world.f <- fortify(world, region = "name")
world.f <- merge(world.f, world@data, by.x = "id", by.y = "name")
Map <- ggplot(world.f, aes(long, lat, group = group, fill = visited)) + geom_polygon()
(Map <- Map + ggtitle("Countries I've Visited as of Dec 2017"))

## Save a really large map
filename <- "./figures/my_world.png"
width <- par("din")[1]
height <- width / 1.68
ggsave(filename, scale = 1.5, dpi = 400, width = width, height = height)
