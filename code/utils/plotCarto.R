plotCarto <- function(world, input.data, field.name, plot.nameStr, legendStr,
                      plot.filename, blurIndex=0) {
  ## Join the two datasets
  matched.indices <- match(world@data[, "ISO3"], input.data[, "Country.Code"])
  world@data <- data.frame(world@data, input.data[matched.indices, ])
  
  world.carto <- quick.carto(world, world@data[, field.name], blur = blurIndex)
  world.f <- fortify(world.carto, region = "Country.Code")
  world.f <- merge(world.f, world@data, by.x = "id", by.y = "Country.Code")
  Map <- ggplot(world.f, aes(long, lat, group = group, fill = world.f[, field.name])) + labs(fill = legendStr) + geom_polygon()
  (Map <- Map + ggtitle(plot.nameStr))
  
  ## Save a really large map
  width <- par("din")[1]
  height <- width / 1.68
  ggsave(plot.filename, scale = 1.5, dpi = 400, width = width, height = height)
}
