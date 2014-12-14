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

## 4. Joining and Clipping
## Replot our spatial dataset
lnd <- readOGR(dsn = filepath, layer = "london_sport")
plot(lnd)

filename <- "./data/spatialggplot/mps-recordedcrime-borough.csv"
crimeDat <- read.csv(file = filename)
crimeTheft <- crimeDat[which(crimeDat$CrimeType == "Theft & Handling"), ]
crimeAg <- aggregate(CrimeCount ~ Borough, FUN = "sum", data = crimeTheft)
levels(crimeAg$Borough)[25] <- as.character(lnd$name[which(!lnd$name %in% crimeAg$Borough)])

## Rename variables to make the join work
crimeAg <- rename(crimeAg, replace = c(Borough = "name"))
## Joining by name
lnd@data <- join(lnd@data, crimeAg)

## Download London's tube stations
# download.file("http://www.personal.leeds.ac.uk/~georl/egs/lnd-stns.zip", "lnd-stns.zip")
# unzip("lnd-stns.zip")
stations <- readOGR(dsn = filepath, layer = "lnd-stns", p4s = "+init=epsg:27700")
## Convert the station dataset into lat-lon coordinates
stationsWGS <- spTransform(stations, CRSobj = CRS(proj4string(lnd)))
stations <- stationsWGS
rm(stationsWGS)

plot(lnd)
points(stations[sample(1:nrow(stations), size = 500), ])

## Clipping the points so that only those that fall within London boroughs are retained
int <- gIntersects(stations, lnd, byid = TRUE) # find which stations intersect
plot(lnd)
points(stations[200, ], col = "red") # this point is outside the zone
points(stations[500, ], col = "green") # this point is inside
points(coordinates(lnd[32, ]), col = "black")

## We are interested in whether the points intersect with any of the boroughs
clipped <- apply(int == FALSE, MARGIN = 2, all)
plot(stations[which(clipped), ]) # show all the stations we do not want
stations.cl <- stations[which(!clipped), ]
points(stations.cl, col = "green")
stations <- stations.cl
rm(stations.cl)

## Rerun the intersection query
int <- gIntersects(stations, lnd, byid = TRUE)
b.indices <- which(int, arr.ind = TRUE)
b.names <- lnd$name[b.indices[, 1]]
b.count <- aggregate(b.indices ~ b.names, FUN = length)
## Sanity check
plot(lnd[which(grepl("Barking", lnd$name)), ])
points(stations)

## Count the points the polygon and report back how many there are
## Transfer the data on station counts back into the polygon dataframe
## Rename variables to perform the join operation (from plyr)
b.count <- rename(b.count, replace = c(b.names = "name"))
b.count.tmp <- join(lnd@data, b.count)
lnd$station.count <- b.count.tmp[, 7]
