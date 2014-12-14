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

## 2. Plotting Spatial Data with ggplot2
## Create a scatterplot with the attribute data in the sport object
## The characters inside the aes argument refer to the parts of that data frame
## that you wish to use
p <- ggplot(sport@data, aes(Partic_Per, Pop_2001))
## Add a player (or geom) to the data, scale the points by population,
## colour them by sports participation, and add text to the plot
q <- p + geom_point(aes(colour = Partic_Per, size = Pop_2001)) +
  geom_text(size = 2, aes(label = name))

## The the shapefiles into a format that can be plotted
sport.f <- fortify(sport, region = "ons_label")
## This step has lost the attribute information associated with the sport object
## We add it back using the merge function
sport.f <- merge(sport.f, sport@data, by.x = "id", by.y = "ons_label")

Map <- ggplot(sport.f, aes(long, lat, group = group, fill = Partic_Per)) + geom_polygon()
Map <- Map + coord_equal() + labs(x = "Easting (m)", y = "Northing (m)",
                                  fill = "% Sport Partic.")
(Map <- Map + ggtitle("London Sports Participation"))
## Save a really large map
filename <- "./figures/london_sports.pdf"
ggsave(filename, scale = 3, dpi = 400)

## Produce the map in black and white
Map2 <- Map + scale_fill_gradient(low = "white", high = "black")

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


