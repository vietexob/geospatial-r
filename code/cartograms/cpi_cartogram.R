rm(list = ls())

library(devtools)
library(Rcartogram)
library(ggplot2)
library(getcartr)

source("./code/visualization/fivethirtyeight_theme.R")

## Load the world map shapefile
world.filename <- "./data/TM_WORLD_BORDERS-0.3/TM_WORLD_BORDERS-0.3.shp"
world <- readShapePoly(world.filename)

## Load the CPI 2014 data file
cpi.data <- read.csv(file="./data/cpi_2014.csv", header=TRUE)
cpi.data$CPI_Score <- 100 - cpi.data$CPI_Score

title <- "Countries by Corruption Perception Index (2014)"
## Join the two datasets
matched.indices <- match(world@data[, "ISO3"], cpi.data[, "WB_Code"])
world@data <- data.frame(world@data, cpi.data[matched.indices, ])

world.carto <- quick.carto(world, world@data$CPI_Score, blur = 0.5)
world.f <- fortify(world.carto, region = "WB_Code")
world.f <- merge(world.f, world@data, by.x = "id", by.y = "WB_Code")
my_map <- ggplot(world.f, aes(long, lat, group = group, fill = world.f$CPI_Score)) +
  labs(fill = "CPI_Score") + geom_polygon() + fivethirtyeight_theme()
(my_map <- my_map + ggtitle(title))

## Save plot to disk
width <- par("din")[1]
height <- width / 1.68
plot.filename <- "./figures/cartograms/cpi_2014_cartogram.png"
ggsave(plot.filename, width = width, height = height)
print(paste('Saved figure to file:', plot.filename))
