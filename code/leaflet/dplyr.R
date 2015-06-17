rm(list = ls())

## Original: http://www.computerworld.com/article/2894448/useful-new-r-packages-for-data-visualization-and-analysis.html?page=2

library(dplyr)
library(ggplot2)
library(ggvis)
library(googleVis)

## Load dataset of domestic flights in and out of Georgia airports
ga <- read.csv(file="./data/leaflet/GAontime.csv", header=TRUE)
## Turn this into a dplyr class tbl_df object
ga <- tbl_df(ga)
## Look at the structure
str(ga)
## More specific function glimpse() with a slightly better format
glimpse(ga)
## Get only Hartfield data: filter for either ORIGIN and DEST with code ATL
atlanta <- filter(ga, ORIGIN=="ATL" | DEST=="ATL")

## What's the mean/median/longest delay for flights to a specific place by carrier?
bos.delays1 <- atlanta %>%
  filter(DEST=="BOS") %>%
  group_by(CARRIER) %>%
  summarize(
    mean.delay = mean(DEP_DELAY, na.rm=TRUE),
    median.delay=median(DEP_DELAY, na.rm=TRUE),
    max.delay=max(DEP_DELAY, na.rm=TRUE))

## Or just the mean delay by any airlines to Boston
mean.delays <- atlanta %>%
  filter(DEST=="BOS") %>%
  group_by(CARRIER) %>%
  summarize(mean.delay = mean(DEP_DELAY, na.rm=TRUE))

## What's the mean delay by airlines for each month?
mean.delays.by.month <- atlanta %>%
  filter(DEST=="BOS") %>%
  group_by(CARRIER, MONTH) %>%
  summarize(mean.delay=round(mean(DEP_DELAY, na.rm=TRUE), 1))

bos.delays <- subset(atlanta, DEST=="BOS", select=c("CARRIER", "DEP_DELAY", "MONTH"))

## What are the top 5 longest delays per airline?
delays <- atlanta %>%
select(CARRIER, DEP_DELAY, DEST, FL_NUM, FL_DATE) %>% # columns I want
  group_by(CARRIER) %>%
  top_n(5, DEP_DELAY) %>%
  arrange(CARRIER, desc(DEP_DELAY))

View(delays)

## What are the top-5 delays per destinations?
delays2 <- atlanta %>%
  select(CARRIER, DEP_DELAY, DEST, FL_NUM, FL_DATE) %>%
  group_by(DEST) %>%
  top_n(5, DEP_DELAY) %>%
  arrange(CARRIER, desc(DEP_DELAY))

View(delays2)

## Percentage delayed flights by airline
atlanta_delays1 <- subset(atlanta, select=c("CARRIER", "DEP_DELAY")) %>%
  group_by(CARRIER) %>%
  summarize(Percent = sum(DEP_DELAY, na.rm=TRUE) / n())

atlanta_delays2 <- atlanta %>%
  group_by(CARRIER) %>%
  summarize(
    Delays=sum(DEP_DELAY, na.rm=TRUE),
    Total=n(),
    Percent=round((Delays/Total)*100, 2)) %>% # This is fishy!
  arrange(desc(Percent))

## And a basic bar chart
ggplot(data=atlanta_delays2, aes(x=reorder(CARRIER, Percent), y=Percent)) +
  geom_bar(stat="identity", fill="lightblue", color="black") + xlab("Airline") +
  ggtitle("Percent delayed flights from Atlanta Jan-Nov 2014")

delay.subset <- subset(atlanta_delays2, select=c("CARRIER", "Percent"))
g.chart <- gvisColumnChart(delay.subset, options=list(title="Percent ATL delays by carrier"))
plot(g.chart)

## Are there any specific airplanes that flew in/out of Atlanta most often?
by_plane <- count(atlanta, TAIL_NUM) %>%
  arrange(desc(n))

## What's its distribution?
by_plane %>% ggvis(x=~n, fill:="gray") %>%
  layer_histograms(width=input_slider(10, 20, step=10, label="binwidth"))

## How might delay be related to distance flown?
by_tailnum <- group_by(atlanta, TAIL_NUM)
delay <- summarize(by_tailnum,
                   count=n(),
                   dist=mean(DISTANCE, na.rm=TRUE),
                   delay=mean(ARR_DELAY, na.rm=TRUE))
delay <- filter(delay, count>20, dist<2000)

ggplot(delay, aes(dist, delay)) +
  geom_point(aes(size=count), alpha=0.5) +
  geom_smooth() + scale_size_area()
## Not much correlation between distance flown and delay?

## Read in Atlanta weather data
atl.wx <- read.csv(file="./data/leaflet/AtlantaTemps.csv", stringsAsFactors=FALSE)
atl.wx$date <- as.Date(atl.wx$date, format="%Y-%m-%d")
data.viz <- gvisCalendar(atl.wx, datevar="date", numvar="max",
                         options=list(title="Daily high temps in Atlanta",
                                      width=1000, height=8000))
plot(data.viz)
