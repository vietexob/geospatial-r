rm(list = ls())

## Original: http://www.computerworld.com/article/2894448/useful-new-r-packages-for-data-visualization-and-analysis.html

library("leaflet")
library("dygraphs")
library("xts")

## Use the included data: monthly male and female deaths from lung diseases in the UK
## from 1974 to 1979 (mdeaths and fdeaths)
lung.deaths <- cbind(mdeaths, fdeaths)

## Create an interactive multi-series graph
dygraph(lung.deaths)

## Read data file for Atlanta unemployment rates
atl.un <- read.csv(file="./data/leaflet/FRED-ALTA-unemployment.csv",
                   stringsAsFactors=FALSE)
## Convert this into a time-series object
atl.ts <- ts(data=atl.un$Unemployment, frequency=12, start=c(1990, 1))
dygraph(atl.ts, main="Monthly Atlanta Unemployment Rate")
