rm(list = ls())

library(devtools)
library(Rcartogram)
library(ggplot2)
library(getcartr)

source("./code/visualization/fivethirtyeight_theme.R")

## Load the world map shapefile
world.filename <- "./data/TM_WORLD_BORDERS-0.3/TM_WORLD_BORDERS-0.3.shp"
world <- readShapePoly(world.filename)

## Load the world pop file
pop.filename <- "./data/world_bank/sp.pop.totl_Indicator_en_csv_v2.csv"
world.pop <- read.csv(file = pop.filename, stringsAsFactors = FALSE)
smaller.data <- data.frame(Country.Code = world.pop$Country.Code,
                           Population = world.pop$X2013)
smaller.data <- na.omit(smaller.data)

plot.nameStr <- "Cartogram of the World Population (2013)"
## Join the two datasets
matched.indices <- match(world@data[, "ISO3"], smaller.data[, "Country.Code"])
world@data <- data.frame(world@data, smaller.data[matched.indices, ])

## Have to set blur = 0.5 in order to work!
world.carto <- quick.carto(world, world@data$Population, blur = 0.5)
world.f <- fortify(world.carto, region = "Country.Code")
world.f <- merge(world.f, world@data, by.x = "id", by.y = "Country.Code")
my_map <- ggplot(world.f, aes(long, lat, group = group, fill = world.f$Population)) +
  labs(fill = "Population") + geom_polygon() + fivethirtyeight_theme()
(my_map <- my_map + ggtitle(plot.nameStr))

## Save a really large map
width <- par("din")[1]
height <- width / 1.68
plot.filename <- "./figures/cartograms/world_pop_cartogram.png"
ggsave(plot.filename, width = width, height = height)
print(paste('Saved figure to file:', plot.filename))
