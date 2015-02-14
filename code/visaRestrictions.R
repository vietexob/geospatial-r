rm(list = ls())

library(maptools)
library(ggplot2)
library(rgeos)

## Load the world map shapefile
filename <- "./data/ne_110m_admin_0_countries/ne_110m_admin_0_countries.shp"
world <- readShapePoly(filename)
badIndex <- which(world$name == "C\xf4te d'Ivoire")

## Load the visa restrictions data
visa.restrictions <- read.csv(file = "./data/visa_restrictions.csv", header = TRUE,
                              stringsAsFactor = FALSE)
goodIndex <- which(visa.restrictions$Country == "Cote d'Ivoire")
visa.restrictions$Country[goodIndex] <- toString(world$name[badIndex])

matchIndices <- match(visa.restrictions$Country, world$name)
mismatchIndices <- which(is.na(matchIndices))
(visa.restrictions$Country[mismatchIndices])

## Join the two datasets
world@data <- data.frame(world@data,
                         visa.restrictions[match(world@data[, "name"],
                                                 visa.restrictions[, "Country"]), ])

## Plot the world map of visa restriction index
world.f <- fortify(world, region = "Country")
world.f <- merge(world.f, world@data, by.x = "id", by.y = "Country")
Map <- ggplot(world.f, aes(long, lat, group = group, fill = Score)) + geom_polygon()
(Map <- Map + ggtitle("International Freedom of Movement Index 2014"))

## Save a really large map
filename <- "./figures/visa_restrictions.png"
width <- par("din")[1]
height <- width / 1.68
ggsave(filename, scale = 1.5, dpi = 400, width = width, height = height)
