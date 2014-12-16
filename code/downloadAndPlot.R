rm(list = ls())

library(maptools)
library(ggplot2)
library(rgeos)

## Here's an easy way to get all the URLs in R
start <- as.Date('2014-12-08')
today <- as.Date('2014-12-13')

all_days <- seq(start, today, by = 'day')

year <- as.POSIXlt(all_days)$year + 1900
urls <- paste0('http://cran-logs.rstudio.com/', year, '/', all_days, '.csv.gz')

## Download the files into a temp directory and merge them
# all_files <- paste0("./temp/", all_days, ".csv.gz")
# for(i in 1:length(files)) {
#   download.file(urls[i], files[i])
# }

## Merge all the files
all_files <- paste0("./temp/", all_days, ".csv")
for(file in all_files) {
  if(!exists("dataset")) {
    dataset <- read.csv(file, header = TRUE)
  }
  else {
    temp_dataset <- read.csv(file, header = TRUE)
    dataset <- rbind(dataset, temp_dataset)
    rm(temp_dataset)
  }
  print(file)
}

## Aggregate the data to get the number of requests per country
dataset$flag <- 1
counts <- aggregate(dataset$flag, by = list(dataset$country), sum)
names(counts) <- c("country", "count")

## Load the world map shapefile
filename <- "./data/ne_110m_admin_0_countries/ne_110m_admin_0_countries.shp"
world <- readShapePoly(filename)

## Join our counts object to the world object to assign the log counts to 
## each country based on the "iso_a2" and "country" fields respectively
world@data <- data.frame(world@data,
                         counts[match(world@data[, "iso_a2"], counts[, "country"]), ])
## Save the new shapefile
writePolyShape(world, "./data/world/world_r_use.shp")

## Plot the world map of R downloads
world.f <- fortify(world, region = "country")
world.f <- merge(world.f, world@data, by.x = "id", by.y = "country")
Map <- ggplot(world.f, aes(long, lat, group = group, fill = count)) + geom_polygon()
(Map <- Map + ggtitle("R Activity around the World from Dec 08 to Dec 13, 2014"))

## Save a really large map
filename <- "./figures/r_activity.png"
width <- par("din")[1]
height <- width / 1.68
ggsave(filename, scale = 1.5, dpi = 400, width = width, height = height)
