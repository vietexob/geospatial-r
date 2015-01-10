rm(list = ls())

library(ggplot2)
library(ggmap)

filenames <- list.files("./data/geolife/Trajectory_007/")
for(filename in filenames) {
  fig.filename <- strsplit(filename, ".plt")[[1]]
  fig.filename <- paste(fig.filename, ".pdf", sep = "")
  filename <- paste("./data/geolife/Trajectory_007/", filename, sep = "")
  trajec <- readLines(filename, n = -1)
  
  firstLine <- strsplit(trajec[7], ",")[[1]]
  trajec.data <- data.frame(lat = as.numeric(firstLine[1]),
                            lon = as.numeric(firstLine[2]), alt = as.numeric(firstLine[4]),
                            date = firstLine[6], time = firstLine[7])
  for(i in 8:length(trajec)) {
    lineStr <- strsplit(trajec[i], ",")[[1]]
    row.data <- data.frame(lat = as.numeric(lineStr[1]),
                           lon = as.numeric(lineStr[2]), alt = as.numeric(lineStr[4]),
                           date = lineStr[6], time = lineStr[7])
    trajec.data <- rbind(trajec.data, row.data)
  }
  
  # Specify a map with center at the center of all the coordinates
  map.gilbert <- get_map(location = c(lon = mean(trajec.data$lon),
                                      lat = mean(trajec.data$lat)), zoom = 15, scale = 2)
  # Make a map that plots each attraction
  trajec.pts <- geom_point(data = trajec.data, aes(x = lon, y = lat,
                                                   fill = "red", alpha = 0.75),
                           size = 3, shape = 21)
  
  dot.map <- ggmap(map.gilbert) + trajec.pts + guides(fill = FALSE, alpha = FALSE,
                                                      size = FALSE)
  dateStr <- toString(trajec.data$date[1])
  mapTitle <- paste("Geolife #007", dateStr)
  titled.map <- dot.map + ggtitle(mapTitle)
  
  fig.filename <- paste("./figures/geolife/Trajectory_007/", fig.filename, sep = "")
  pdf(file = fig.filename)
  print(titled.map)
  dev.off()
}
