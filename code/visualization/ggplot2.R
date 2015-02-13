rm(list = ls())

## Following this tutorial: http://minimaxir.com/2015/02/ggplot-tutorial/

source("./code/visualization/fivethirtyeight_theme.R")

library(ggplot2)
library(scales)
library(grid)
library(RColorBrewer)

df <- read.csv(file = "./data/visualization/buzzfeed_linkbait_headlines.csv", header=TRUE)

## Making histogram
## Make a basic histogram instantaneously
ggplot(df, aes(listicle_size)) + geom_histogram(binwidth = 1)

## Add fivethirtyeight theme to the chart
ggplot(df, aes(listicle_size)) + geom_histogram(binwidth=1) + fivethirtyeight_theme()

## Add lables to axes and a title
ggplot(df, aes(listicle_size)) + geom_histogram(binwidth=1) + fivethirtyeight_theme() +
  labs(title="Distribution of Listicle Sizes for Buzzfeed Listicles",
       x="# Entries", y="# Listicles")

## Add a few finishing touches: scaling of the axes 
ggplot(df, aes(listicle_size)) + geom_histogram(binwidth=1, fill="#c0392b", alpha=0.75) +
  fivethirtyeight_theme() +
  labs(title="Distribution of Listicle Sizes for Buzzfeed Listicles",
       x="# Entries", y="# Listicles") + scale_x_continuous(breaks=seq(0, 50, by=5)) +
  scale_y_continuous(labels=comma) + geom_hline(yintercept=0, size=0.4, color="black")

## Save the plot using ggsave
ggsave(file = "./figures/visualization/histogram.png", width=4, height=3)

## Making scatterplot
## Basic scatterplot where the axis vectors are declared explicitly
ggplot(df, aes(x=listicle_size, y=num_fb_shares)) + geom_point()

## Scale the y-axes logarithmically to reduce skewness and reduce opacity of points
## (because many of them are overlapping)
ggplot(df, aes(x=listicle_size, y=num_fb_shares)) + geom_point(alpha=0.05) +
  scale_y_log10(labels=comma)

## Apply theme and labels
ggplot(df, aes(x=listicle_size, y=num_fb_shares)) + geom_point(alpha=0.05) +
  scale_y_log10(labels=comma) + fivethirtyeight_theme() +
  labs(x="# Entries", y="# FB Shares", title="FB Shares vs. Listicle Size (Buzzfeed)")

## Add the final touches: scaling of axes and smooth trend line
ggplot(df, aes(x=listicle_size, y=num_fb_shares)) + geom_point(alpha=0.05, color="#c0392b") +
  scale_x_continuous(breaks=seq(0, 50, by=5)) +
  scale_y_log10(labels=comma, breaks=10^(0:6)) + 
  geom_hline(yintercept=1, size=0.4, color="black") + 
  geom_smooth(alpha=0.25, color="black", fill="black") + fivethirtyeight_theme() +
  labs(x="# Entries", y="# FB Shares", title="FB Shares vs. Listicle Size (Buzzfeed)")

## Save the plot using ggsave
ggsave(file = "./figures/visualization/scatterplot.png", width=4, height=3)
