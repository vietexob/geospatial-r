rm(list = ls())

## Original: http://rpubs.com/walkerke/wdi_leaflet

source("./code/leaflet/wdi_leaflet.R")

## This command creates a map of countries shaded by the percent of their population
## that lives in urban areas; it will show in your RStudio viewer.
wdi_leaflet("SP.URB.TOTL.IN.ZS")

## This creates a map of life expectancy by country in 1980,
## with more informative pop-ups, six classes, and a diverging color scheme.
wdi_leaflet("SP.DYN.LE00.IN", "Life expectancy at birth", 1980, 6, "RdYlGn")
