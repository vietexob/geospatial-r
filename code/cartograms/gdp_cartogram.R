rm(list = ls())

library(devtools)
library(Rcartogram)
library(ggplot2)
library(getcartr)

source("./code/visualization/fivethirtyeight_theme.R")

## Load the world map shapefile
world.filename <- "./data/TM_WORLD_BORDERS-0.3/TM_WORLD_BORDERS-0.3.shp"
world <- readShapePoly(world.filename)

## Load the world's GDP file
gdp.filename <- "./data/world_bank/ny.gdp.mktp.cd_Indicator_en_csv_v2.csv"
world.gdp <- read.csv(file = gdp.filename, header = TRUE)
smaller.data <- data.frame(Country.Code = world.gdp$Country.Code,
                           GDP = world.gdp$X2013)
smaller.data <- na.omit(smaller.data)
smaller.data$GDP <- smaller.data$GDP / 1000000
# smaller.data$GDP <- sqrt(smaller.data$GDP)

plot.nameStr <- "Largest Economies in the World (by GDP in 2013)"
## Join the two datasets
matched.indices <- match(world@data[, "ISO3"], smaller.data[, "Country.Code"])
world@data <- data.frame(world@data, smaller.data[matched.indices, ])

world.carto <- quick.carto(world, world@data$GDP, blur = 0.5)
world.f <- fortify(world.carto, region = "Country.Code")
world.f <- merge(world.f, world@data, by.x = "id", by.y = "Country.Code")
my_map <- ggplot(world.f, aes(long, lat, group = group, fill = world.f$GDP)) +
  labs(fill = "GDP") + geom_polygon() + fivethirtyeight_theme()
(my_map <- my_map + ggtitle(plot.nameStr))

## Save a really large map
width <- par("din")[1]
height <- width / 1.68
plot.filename <- "./figures/cartograms/world_gdp_cartogram.png"
ggsave(plot.filename, scale = 1.5, dpi = 400, width = width, height = height)

## Load the GDP per capita data
gdppc.filename <- "./data/world_bank/ny.gdp.pcap.cd_Indicator_en_csv_v2.csv"
world.gdppc <- read.csv(file = gdppc.filename, header = TRUE)
smaller.data <- data.frame(Country.Code = world.gdppc$Country.Code,
                           GDPPC = world.gdppc$X2013)
smaller.data <- na.omit(smaller.data)
# smaller.data$GDPPC <- smaller.data$GDPPC / 1000

plot.nameStr <- "Countries by GDP per Capita (2013)"
## Join the two datasets
matched.indices <- match(world@data[, "ISO3"], smaller.data[, "Country.Code"])
world@data <- data.frame(world@data, smaller.data[matched.indices, ])

world.carto <- quick.carto(world, world@data$GDPPC, blur = 0.5)
world.f <- fortify(world.carto, region = "Country.Code")
world.f <- merge(world.f, world@data, by.x = "id", by.y = "Country.Code")
my_map <- ggplot(world.f, aes(long, lat, group = group, fill = world.f$GDPPC)) +
  labs(fill = "GDPPC") + geom_polygon() + fivethirtyeight_theme()
(my_map <- my_map + ggtitle(plot.nameStr))

## Save a really large map
width <- par("din")[1]
height <- width / 1.68
plot.filename <- "./figures/cartograms/world_gdp_capita_cartogram.png"
ggsave(plot.filename, width = width, height = height)
