rm(list = ls())

library(devtools)
library(Rcartogram)
library(maptools)
library(ggplot2)
library(rgeos)
library(getcartr)

source("./code/plotCarto.R")

## Load the world map shapefile
world.filename <- "./data/TM_WORLD_BORDERS-0.3/TM_WORLD_BORDERS-0.3.shp"
world <- readShapePoly(world.filename)

## Load the world pop file
pop.filename <- "./data/world_bank/sp.pop.totl_Indicator_en_csv_v2.csv"
world.pop <- read.csv(file = pop.filename, header = TRUE)
smaller.data <- data.frame(Country.Code = world.pop$Country.Code,
                           Population = world.pop$X2013)
smaller.data <- na.omit(smaller.data)

plot.nameStr <- "Cartogram of the World's Population by Country (2013)"
plot.filename <- "./figures/world_population_carto.png"
legendStr <- "Population"
plotCarto(world, smaller.data, "Population", plot.nameStr, legendStr, plot.filename)

## Load the world's GDP file
gdp.filename <- "./data/world_bank/ny.gdp.mktp.cd_Indicator_en_csv_v2.csv"
world.gdp <- read.csv(file = gdp.filename, header = TRUE)

plot.nameStr <- "Cartogram of the World's GDP by Country (2013)"
plot.filename <- "./figures/world_gdp_carto.png"
legendStr <- "USD"
plotCarto(world, world.gdp, "X2013", plot.nameStr, legendStr, plot.filename)

## Load the GDP per capita data
gdppc.filename <- "./data/world_bank/ny.gdp.pcap.cd_Indicator_en_csv_v2.csv"
world.gdppc <- read.csv(file = gdppc.filename, header = TRUE)

plot.nameStr <- "Cartogram of the World's GDP per capita by Country (2013)"
plot.filename <- "./figures/world_gdp_pc_carto.png"
legendStr <- "USD"
plotCarto(world, world.gdppc, "X2013", plot.nameStr, legendStr, plot.filename)

