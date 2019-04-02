# Clear the workspace
rm(list = ls())

library(leaflet)
library(scales)
source("./code/speed_app/convertSPLines.R")

load("./code/speed_app/data/pgh_coords.RData")

get_input_data <- function(is_weekday, select_time, is_training=TRUE) {
  if(is_training) {
    input_data <- read.csv("./code/speed_app/data/pgh_train.csv")
  } else {
    input_data <- read.csv("./code/speed_app/data/pgh_pred.csv")
  }
  
  if(is_weekday) {
    input_data <- subset(input_data, is.weekday==1)
  } else {
    input_data <- subset(input_data, is.weekday==0)
  }
  
  time_values <- unique(input_data$time)
  if(select_time %in% time_values) {
    input_data <- subset(input_data, time==select_time)
  } else {
    stop('The select time is invalid: ', select_time)
  }
  
  return(input_data)
}

is_weekday <- sample(c(FALSE, TRUE), size = 1)
if(is_weekday) {
  paste('Speed data for:', 'Weekday')
} else {
  paste('Speed data for:', 'Weekend')
}

select_time <- sample(c(8, 14, 20), size = 1)
paste('Select time =', select_time)

df_train <- get_input_data(is_weekday, select_time, is_training = TRUE)
df_pred <- get_input_data(is_weekday, select_time, is_training = FALSE)
df_segment <- read.csv('./code/speed_app/data/pgh_segments.csv')

# Merge prediction with segment data frame
pred_segment <- data.frame(from.x = df_segment$from.x,
                           from.y = df_segment$from.y,
                           to.x = df_segment$to.x,
                           to.y = df_segment$to.y,
                           speed = df_pred$speed)

# Drop the unused columns in training data
df_train$time <- NULL
df_train$is.weekday <- NULL

# Then merge with the training set to get the complete speed data
speed_data <- rbind(pred_segment, df_train)
# Convert speed data into spatial lines for drawing
speed_segment <- convertSPLines(speed_data)

# Create the speed color legend
pal <- colorNumeric("RdYlGn", domain = NULL, na.color = "#808080")

my_viz <- leaflet(data = speed_segment) %>%
  # clearShapes() %>% clearMarkers() %>% clearControls() %>%
  addTiles(urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
           attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
  setView(lng = allegheny_lon, lat = allegheny_lat, zoom = 14) %>%
  addPolylines(color = ~pal(speed),
               weight = 3, opacity = 0.90) %>%
  addLegend("bottomleft", pal=pal, values=~speed, title='Speed (mph)',
            opacity = 0.90)
print(my_viz)
