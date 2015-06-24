rm(list = ls())

## Original: http://spatialanalysis.co.uk/2012/02/great-maps-ggplot2/

## Load packages and enter development mode
library(devtools)
dev_mode()

library(ggplot2)
library(proto)

## Use maptools if your map data is a shapefile
library(maptools)
gpclibPermit()

## Create GeomSegment2 function
GeomSegment2 <- proto(ggplot2:::GeomSegment, {
  objname <- "geom_segment2"
  draw <- function(., data, scales, coordinates, arrow=NULL, ...) {
    if(is.linear(coordinates)) {
      return(with(coord_transform(coordinates, data, scales),
                  segmentsGrob(x, y, xend, yend, default.units="native",
                               gp=gpar(col=alpha(color, alpha), lwd=size*.pt,
                                       lty=linetype, lineend="round"), arrow=arrow)))
    }
  }
})

geom_segment2 <- function(mapping=NULL, data=NULL, stat="identity",
                          position="identity", arrow=NULL, ...) {
  GeomSegment2$new(mapping=mapping, data=data, stat=stat, position=position,
                   arrow=arrow, ...)
}

## Load data: stlat/stlong are the start points, elat/elong the end points of the lines
lon <- read.csv(file="./data/bikes_london.csv", header=FALSE, sep=";")
names(lon) <- c("stlat", "stlon", "elat", "elong", "count")

## Load spatial data: need to fortify if loaded as shapefiles






