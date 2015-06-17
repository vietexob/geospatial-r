rm(list = ls())

## Original: http://www.computerworld.com/article/2894448/useful-new-r-packages-for-data-visualization-and-analysis.html
 
library("leaflet")
library("dplyr")
library("ggvis")

## Create a basic map object and add tiles
my.map <- leaflet()
my.map <- addTiles(my.map)

## Set where to center the map and its zoom level
my.map <- setView(my.map, -84.3847, 33.7613, zoom = 17)
(my.map)

## Add a pop-up
addPopups(my.map, -84.3847, 33.7616, "Data journalists at work, <b>NICAR 2015</b>")

## Alternative: %>% takes results of one function and sends it to the next one
my.map <- leaflet() %>%
  addTiles() %>%
  setView(-84.3847, 33.7613, zoom=17) %>%
  addPopups(-84.3847, 33.7616, "Data journalists at work, <b>NICAR 2015</b>")

## Map nearby Starbucks locations
starbucks <- read.csv(file="./data/leaflet/All_Starbucks_Locations_in_the_US_-_Map.csv")
atlanta <- subset(starbucks, City=="Atlanta" & State=="GA")
leaflet() %>% addTiles() %>% setView(-84.3847, 33.7613, zoom=16) %>%
  addMarkers(data=atlanta, lat=~Latitude, lng=~Longitude, popup=atlanta$Name) %>%
  addPopups(-84.3847, 33.7616, "Data journalists at work, <b>NICAR 2015</b>")

## How many people are there per Starbucks in each state
state.pops <- read.csv(file="./data/leaflet/acs2013_1yr_statepop.csv", stringsAsFactors=FALSE)
starbucks.by.state <- count(starbucks, State)
## Add state population by left joining
starbucks.by.state <- merge(starbucks.by.state, state.pops, all.x=TRUE,
                            by.x="State", by.y="State")
## Add a new column using dplyr mutate function
starbucks.data <- starbucks.by.state %>%
  mutate(PeoplePerStarbucks = round(Population/n)) %>%
  select(State, n, PeoplePerStarbucks) %>%
  arrange(desc(PeoplePerStarbucks))

## Histogram with interactive sliders
## Add a rollover tooltip
starbucks.data %>% ggvis(x=~PeoplePerStarbucks, fill:="gray") %>%
  layer_histograms(width=input_slider(1000, 20000, step=1000, label="width")) %>%
  add_tooltip(function(df) (df$stack_upr_ - df$stack_lwr_))
