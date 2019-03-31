# Clear the workspace
rm(list = ls())

df_train <- read.csv('./code/speed_app/data/pgh_train.csv')
df_pred <- read.csv('./code/speed_app/data/pgh_pred.csv')
df_segment <- read.csv('./code/speed_app/data/pgh_segments.csv')

is_weekday <- TRUE
select_time <- 14

# Subset the training and prediction set by day and time
if(is_weekday) {
  df_train <- subset(df_train, is.weekday==1)
  df_pred <- subset(df_pred, is.weekday==1)
} else {
  df_train <- subset(df_train, is.weekday==0)
  df_pred <- subset(df_pred, is.weekday==0)
}

df_train <- subset(df_train, time==select_time)
df_pred <- subset(df_pred, time==select_time)

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
