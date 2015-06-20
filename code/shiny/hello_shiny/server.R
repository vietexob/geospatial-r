library(shiny)

## Define a server logic required to draw a histogram
shinyServer(function(input, output) {
  ## Expression that generates a histogram. The expression is wrapped in a call
  ## to renderPlot to indicated that: (1) It is reactive, and therefore should be
  ## re-execute automatically when inputs change. (2) Its output type is a plot.
  output$distPlot <- renderPlot({
    x <- faithful[, 2] # Old Faithful Geyser data
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    ## Draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = 'skyblue', border = 'white')
  })
})
