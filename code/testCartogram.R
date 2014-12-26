rm(list = ls())

library(devtools)
library(Rcartogram)
library(maptools)
library(ggplot2)
library(rgeos)

## Only if getcartr is not installed ##
# install_github("chrisbrunsdon/getcartr", subdir = "getcartr")
library(getcartr)

data(georgia)

## "georgia2" is used as it has a plane projection coordinate system
georgia.carto <- quick.carto(georgia2, georgia2$TotPop90, blur = 1)
filename <- "./figures/georgia_pop_carto.pdf"
pdf(file = filename)
op <- par(mfrow = c(1, 2), mar = c(0.5, 0.5, 3, 0.5))
plot(georgia2)
title("Original Projection")
plot(georgia.carto)
title("Cartogram Projection")
dev.off()
par(op)

## Draw the dispersion plot
dispersion(georgia.carto, col = "darkred")

## Load the world map shapefile
filename <- "./data/ne_110m_admin_0_countries/ne_110m_admin_0_countries.shp"
world <- readShapePoly(filename)
## Change "C\xf4te d'Ivoire"
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

world$Score <- (world$Score)^1.7
world.carto <- quick.carto(world, world$Score, blur = 1)
mainStr <- "Cartogram of International Freedom of Movement Index 2014"
filename <- "./figures/visa_restrictions_carto.png"
png(file = filename)
plot(world.carto, main = mainStr)
dev.off()
