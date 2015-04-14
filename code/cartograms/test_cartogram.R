rm(list = ls())

library(devtools)
library(Rcartogram)
library(maptools)
library(ggplot2)
library(rgeos)

## Only if getcartr is not installed ##
# install_github("chrisbrunsdon/getcartr", subdir = "getcartr")
library(getcartr)

source("./code/visualization/fivethirtyeight_theme.R")

data(georgia)

## "georgia2" is used as it has a plane projection coordinate system
georgia.carto <- quick.carto(georgia2, georgia2$TotPop90, blur = 1)
# filename <- "./figures/cartograms/georgia_pop_cartogram.pdf"
# pdf(file = filename)
op <- par(mfrow = c(1, 2), mar = c(0.5, 0.5, 3, 0.5))
plot(georgia2)
title("Original Projection")
plot(georgia.carto)
title("Cartogram Projection")
# dev.off()
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

# world$Score <- (world$Score)^2
world.carto <- quick.carto(world, world$Score, blur = 0)
world.f <- fortify(world.carto, region = "Country")
world.f <- merge(world.f, world@data, by.x = "id", by.y = "Country")
Map <- ggplot(world.f, aes(long, lat, group = group, fill = Score)) +
  geom_polygon() + fivethirtyeight_theme()
(Map <- Map + ggtitle("Cartogram of the International Freedom of Movement Index (2014)"))

## Save a really large map
filename <- "./figures/cartograms/visa_restriction_cartogram.png"
width <- par("din")[1]
height <- width / 1.68
ggsave(filename, scale = 1.5, dpi = 400, width = width, height = height)

## Apply cartogram transform to a set of points
## Create a set of 25 points from northwest to southeast corners
xl <- seq(1419424,939220.7,l=25)
yl <- seq(905508,1405900,l=25)
pset <- readWKT(paste("MULTIPOINT(",
                      paste(apply(cbind(xl,yl),1,function(x) paste("(",x[1],x[2],")")),
                            collapse=","),")"))
## Transform it
pset.carto <- warp.points(pset, georgia.carto)

## Plot the original points
par(mfrow = c(1, 2), mar = c(0.5, 0.5, 3, 0.5))
plot(georgia2, border = "gray")
plot(pset, add = TRUE, col = "red")
title("Original Projection")

## Plot in cartogram space
plot(georgia.carto, border = "grey")
plot(pset.carto, add = TRUE, col = "red")
title("Cartogram Projection")

## Apply cartogram transform to a set of lines
## Create a line from southwest to northeast corners,  with 100 segments
xl <- seq(939220.7,1419424,l=100)
yl <- seq(905508,1405900,l=100)
aline <- readWKT(paste("LINESTRING(",
                       paste(apply(cbind(xl,yl),1,function(x) paste(x[1],x[2])),
                             collapse=","),")"))

## Transform it
aline.carto <- warp.lines(aline, georgia.carto)

## Plot the original line
par(mfrow = c(1, 2), mar = c(0.5, 0.5, 3, 0.5))
plot(georgia2, border = "gray")
plot(aline, add = TRUE, col = "red")
title("Original Projection")

## Plot in cartogram space
plot(georgia.carto, border = "grey")
plot(aline.carto, add = TRUE, col = "red")
title("Cartogram Projection")

## Apply cartogram transform to areas
## Create a pseudocircle with 100 segments
xl <- cos(seq(0,2*pi,l=100))*100000 + 1239348
yl <- sin(seq(0,2*pi,l=100))*100000 + 1093155
circ <- readWKT(paste("MULTIPOLYGON(((",
                      paste(apply(cbind(xl,yl),1,
                                  function(x) sprintf("%7.0f %7.0f",x[1],x[2])),
                            collapse=","),")))"))

## Transform it
circ.carto <- warp.polys(circ, georgia.carto)

## Plot the original circle
par(mfrow=c(1,2),mar=c(0.5,0.5,3,0.5))
plot(georgia2,border='grey')
plot(circ, add=TRUE, col=rgb(1,0,0,0.4), border=NA)
title('Original Projection')

## Plot in cartogram space
plot(georgia.carto, border = "grey")
plot(circ.carto, add = TRUE, col = rgb(1, 0, 0, 0.4), border = NA)
title("Cartogram Projection")

## Alternative approach
require(GISTools)
data(newhaven)

## Plot the untransformed data
par(mfrow = c(1, 2), mar = c(0.5, 0.5, 3, 0.5))
plot(blocks) # census blocks
plot(roads, col = "lightgrey", add = TRUE) # roads
plot(burgres.f, col = "darkred", pch = 16, add = TRUE) # forced entry burglaries

# Create the cartogram transform function
# The 'res' here gives the resolution of the cartogram interpolation grid 
# - default is 128,  so here we have 4 times that resolution. Slower but
# more accurate...
to.carto <- carto.transform(blocks, blocks$POP1990, res = 512)

## Create a cartogram version of the map
## Plot the blocks carto
plot(to.carto(blocks))
## Add roads, transform the cartogram space
plot(to.carto(roads), add = TRUE, col = "lightgray")
## Add forced entry residential burglaries, transformed to cartogram space
plot(to.carto(burgres.f), add = TRUE, col = "darkred", pch = 16)

## A few visual diagnostics
## Superimpose dispersion diagram on cartogram
par(mfrow = c(1, 2), mar = c(0.5, 0.5, 3, 0.5))
blocks.cart <- to.carto(blocks)
plot(blocks.cart)
dispersion(blocks.cart, col = rgb(0.5, 0, 0, 0.3), add = TRUE)

## Scatterplot the actual cartogram variable against actual zone area
par(mar = c(5, 5, 5, 5))
cartvar <- blocks$POP1990
cartarea <- poly.areas(blocks.cart)
plot(cartvar, cartarea, xlab = "Population", ylab = "Cartogram 'Pixels'")
abline(lm(cartarea ~ 0 + cartvar), lty = 2, col = "red")

## NOTE: For more diagnostic plots: 
## https://github.com/chrisbrunsdon/getcartr/blob/master/demo.Rmd
